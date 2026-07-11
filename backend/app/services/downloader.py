import yt_dlp
import os
import uuid
from app.core.supabase import supabase
import shutil

class DownloaderService:
    def __init__(self):
        self.temp_dir = "/tmp/clipper_temp"
        os.makedirs(self.temp_dir, exist_ok=True)

    def download_from_url(self, url: str) -> str:
        """Download audio from a YouTube/TikTok URL using yt-dlp."""
        file_id = str(uuid.uuid4())
        output_path = f"{self.temp_dir}/{file_id}.mp4"
        
        ydl_opts = {
            'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
            'outtmpl': output_path,
            'socket_timeout': 30,
        }
        
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([url])
        except Exception as e:
            print(f"yt-dlp failed: {e}")
            raise Exception(f"Gagal mengunduh video: {e}")
            
        return output_path

    def download_from_storage(self, file_path: str) -> str:
        """Download video/audio from Supabase storage."""
        file_id = str(uuid.uuid4())
        output_path = f"{self.temp_dir}/{file_id}.mp4"
        
        # Download from Supabase
        with open(output_path, 'wb') as f:
            res = supabase.storage.from_('videos').download(file_path)
            f.write(res)
            
        # Optional: We could extract audio here using ffmpeg, but Groq accepts mp4 audio directly.
        # But to save Groq bandwidth, it's better to send audio. We'll rely on Groq accepting mp4 or we can extract it.
        # For now, let's return the downloaded file.
        return output_path

downloader = DownloaderService()
