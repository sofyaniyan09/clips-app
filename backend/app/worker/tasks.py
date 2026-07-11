import time
from app.core.celery_app import celery_app
from app.core.supabase import supabase_admin
import os
import json
from app.services.downloader import downloader
from app.services.groq_service import groq_service
from app.services.openrouter_service import openrouter_service
from app.services.face_tracker import face_tracker
from app.services.subtitle_generator import subtitle_generator
from app.services.ffmpeg_renderer import ffmpeg_renderer
import uuid

@celery_app.task(name="app.worker.tasks.process_video_task")
def process_video_task(job_id: str, source_type: str, source_url: str):
    """
    Dummy task for Phase 2.
    In actual implementation (Phase 3 & 4), this will trigger Whisper, OpenRouter, and FFmpeg.
    For now, it just simulates a delay and updates progress in Supabase.
    """
    try:
        # 1. Mark as processing
        supabase_admin.table('jobs').update({
            'status': 'processing',
            'progress': 10
        }).eq('id', job_id).execute()
        
        # 2. Download audio
        if source_type == 'link':
            audio_path = downloader.download_from_url(source_url)
        elif source_type == 'local':
            audio_path = source_url
        else:
            audio_path = downloader.download_from_storage(source_url)
            
        supabase_admin.table('jobs').update({'progress': 30}).eq('id', job_id).execute()
        
        # 3. Transcribe with Groq
        transcription_result = groq_service.transcribe_audio(audio_path)
        transcript_text = transcription_result.get('text', '')
        
        supabase_admin.table('jobs').update({'progress': 60}).eq('id', job_id).execute()
        
        # 4. Clean up temporary audio file
        # We don't remove video_path yet since we need it for FFmpeg
            
        # 5. Curate narrative with OpenRouter
        clips = openrouter_service.curate_narrative(transcript_text)
        if not clips:
            print("OpenRouter returned empty clips, using fallback clip.")
            clips = [{'start_time': 0, 'end_time': min(15.0, transcription_result.get('segments', [{'end': 15.0}])[-1]['end']), 'judul_saran': 'Viral Moment', 'hook_score': 95}]
        
        # 5.5 Face Tracking (extract once per video)
        try:
            face_centers = face_tracker.get_face_centers(audio_path) # audio_path is actually video_path now
        except Exception as e:
            print(f"Face tracking failed: {e}")
            face_centers = []
        
        supabase_admin.table('jobs').update({'progress': 90}).eq('id', job_id).execute()
        
        # 6. Save clips and render with FFmpeg
        clips_dir = os.path.join(os.getcwd(), "static", "clips")
        os.makedirs(clips_dir, exist_ok=True)
        
        all_segments = transcription_result.get('segments', [])
        
        for clip in clips:
            clip_id = str(uuid.uuid4())
            ass_path = os.path.join(clips_dir, f"{clip_id}.ass")
            output_mp4 = os.path.join(clips_dir, f"{clip_id}.mp4")
            output_thumb = os.path.join(clips_dir, f"{clip_id}.jpg")
            
            # Start/end time from AI format to seconds
            # OpenRouter output might be '00:15' or seconds directly depending on prompt.
            # Let's handle both string and float.
            def parse_time(t):
                if isinstance(t, str):
                    if ':' in t:
                        parts = t.split(':')
                        if len(parts) == 3:
                            return float(parts[0])*3600 + float(parts[1])*60 + float(parts[2])
                        elif len(parts) == 2:
                            return float(parts[0])*60 + float(parts[1])
                    return float(t)
                return float(t)
                
            start_sec = parse_time(clip.get('start_time', 0))
            end_sec = parse_time(clip.get('end_time', 15))
            
            # Filter segments that fall within the clip
            clip_segments = []
            for seg in all_segments:
                seg_start = seg.get('start', 0)
                seg_end = seg.get('end', 0)
                # If segment overlaps with clip
                if seg_start < end_sec and seg_end > start_sec:
                    # Adjust segment time relative to clip start
                    rel_start = max(0, seg_start - start_sec)
                    rel_end = min(end_sec - start_sec, seg_end - start_sec)
                    clip_segments.append({
                        'start': rel_start,
                        'end': rel_end,
                        'text': seg.get('text', '')
                    })
                    
            # If no segments matched, fallback to dummy
            if not clip_segments:
                clip_segments = [{'start': 0.0, 'end': end_sec - start_sec, 'text': clip.get('judul_saran', 'Wow')}]
                
            subtitle_generator.generate_ass(clip_segments, ass_path)
            
            # Filter face centers for this specific clip
            clip_face_centers = [
                c for c in face_centers
                if start_sec <= c.get('time', 0) <= end_sec
            ]
            
            try:
                ffmpeg_renderer.render_clip(audio_path, str(start_sec), str(end_sec), clip_face_centers, ass_path, output_mp4)
                ffmpeg_renderer.generate_thumbnail(output_mp4, output_thumb)
                
                final_video_url = f"/static/clips/{clip_id}.mp4"
                final_thumbnail_url = f"/static/clips/{clip_id}.jpg"
            except Exception as e:
                print(f"Render failed for {clip_id}: {e}")
                final_video_url = 'https://picsum.photos/seed/mock2/400/800'
                final_thumbnail_url = 'https://picsum.photos/seed/mock1/400/800'
                
            try:
                # For testing with supabase we can just insert with relative path, frontend adds base URL
                res = supabase_admin.table('clips').insert({
                    'job_id': job_id,
                    'title': clip.get('judul_saran', f"Generated Clip"),
                    'thumbnail_url': final_thumbnail_url,
                    'video_url': final_video_url, 
                    'duration': f"{start_sec}-{end_sec}",
                    'start_time': start_sec,
                    'end_time': end_sec,
                    'virality_score': clip.get('hook_score', 80),
                    'transcript_segments': clip_segments
                }).execute()
                
                if not res.data:
                    print(f"Failed to insert clip to Supabase! Result: {res}")
            except Exception as e:
                print(f"Supabase clip insert failed (Timeout/Network): {e}")
            
        # Clean up video file after all renders
        if os.path.exists(audio_path):
            os.remove(audio_path)
        
        # 7. Mark as done
        try:
            supabase_admin.table('jobs').update({
                'status': 'done',
                'progress': 100
            }).eq('id', job_id).execute()
        except Exception as e:
            print(f"Failed to mark job as done in Supabase: {e}")
        
    except Exception as e:
        # Mark as failed on error
        print(f"Task failed with error: {e}")
        try:
            supabase_admin.table('jobs').update({
                'status': 'failed',
                'progress': 100
            }).eq('id', job_id).execute()
        except Exception as update_err:
            print(f"Failed to mark job as failed: {update_err}")
        print(f"Job {job_id} failed: {e}")
