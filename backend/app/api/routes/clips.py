from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.models.schemas import ClipResponse
from app.core.security import get_current_user
from app.core.supabase import supabase_admin

router = APIRouter()

@router.get("/", response_model=List[ClipResponse])
def get_clips(user = Depends(get_current_user)):
    """Get all clips generated from the user's jobs."""
    # We need to fetch clips that belong to the user's jobs.
    # We can do this by joining the jobs table or fetching user's jobs first.
    # Since we set up RLS, the user's token should handle this if we used their client.
    # However, since we use supabase_admin to query, we must manually filter.
    
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    jobs_resp = supabase_admin.table('jobs').select('id').eq('user_id', user_id).execute()
    if not jobs_resp.data:
        return []
        
    job_ids = [job['id'] for job in jobs_resp.data]
    
    # 2. Get clips for those jobs
    clips_resp = supabase_admin.table('clips').select("*").in_('job_id', job_ids).order('created_at', desc=True).execute()
    return clips_resp.data

@router.get("/{clip_id}", response_model=ClipResponse)
def get_clip_by_id(clip_id: str, user = Depends(get_current_user)):
    """Get a single clip by ID."""
    clip_resp = supabase_admin.table('clips').select("*").eq('id', clip_id).execute()
    if not clip_resp.data:
        raise HTTPException(status_code=404, detail="Clip not found")
        
    clip = clip_resp.data[0]
    
    # Verify user owns the job for this clip
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    job_resp = supabase_admin.table('jobs').select('user_id').eq('id', clip['job_id']).execute()
    if not job_resp.data or str(job_resp.data[0]['user_id']) != str(user_id):
        raise HTTPException(status_code=403, detail="Not authorized to access clips for this job")
        
    return clip
