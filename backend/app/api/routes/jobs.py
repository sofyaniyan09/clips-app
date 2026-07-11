from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.models.schemas import JobResponse
from app.core.security import get_current_user
from app.core.supabase import supabase_admin

router = APIRouter()

@router.get("/", response_model=List[JobResponse])
def get_jobs(user = Depends(get_current_user)):
    """Get all jobs for the current user."""
    try:
        user_id = user.id if hasattr(user, 'id') else user.get('id')
        response = supabase_admin.table('jobs').select("*").eq('user_id', user_id).order('created_at', desc=True).execute()
        return response.data
    except Exception as e:
        import traceback
        traceback.print_exc()
        print(f"DEBUG: Error in get_jobs: {e}")
        # To avoid 500, we'll return a 400 for now to see it in Flutter, or just raise it.
        raise HTTPException(status_code=500, detail=f"DEBUG ERROR: {str(e)}")

@router.get("/{job_id}/status", response_model=JobResponse)
def get_job_status(job_id: str, user = Depends(get_current_user)):
    """Get the status of a specific job."""
    user_id = user.id if hasattr(user, 'id') else user.get('id')
    response = supabase_admin.table('jobs').select("*").eq('id', job_id).eq('user_id', user_id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Job not found")
    return response.data[0]
