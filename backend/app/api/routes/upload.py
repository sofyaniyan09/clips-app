from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from app.models.schemas import UploadLinkRequest
from app.core.security import get_current_user
from app.core.supabase import supabase_admin
from app.worker.tasks import process_video_task

router = APIRouter()

@router.post("/link")
def upload_link(request: UploadLinkRequest, user = Depends(get_current_user)):
    """Ingest a video via YouTube/TikTok link."""
    url = str(request.url)
    
    # Create a job in database
    import uuid
    job_id = str(uuid.uuid4())
    job_data = {
        "id": job_id,
        "user_id": user.id if hasattr(user, 'id') else user.get('id'),
        "title": "Imported via Link",
        "status": "queued",
        "video_url": url,
        "progress": 0
    }
    
    try:
        response = supabase_admin.table('jobs').insert(job_data).execute()
    except Exception as e:
        print(f"DB Insert Error: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
        
    if not response.data:
        raise HTTPException(status_code=500, detail="Failed to create job")
        
    job_id = response.data[0]["id"]
    
    # Trigger Celery Task (Async)
    process_video_task.delay(job_id, "link", url)
    
    return {
        "job_id": job_id,
        "status": "queued",
        "message": "Video added to processing queue"
    }

@router.post("/file")
async def upload_file(file: UploadFile = File(...), user = Depends(get_current_user)):
    """Ingest a video via local file upload."""
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")
        
    # Save the file to local temp dir
    import os
    import uuid
    import shutil
    
    temp_dir = "/tmp/clipper_temp"
    os.makedirs(temp_dir, exist_ok=True)
    file_id = str(uuid.uuid4())
    local_path = os.path.join(temp_dir, f"{file_id}_{file.filename}")
    
    try:
        with open(local_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save file: {e}")
        
    # Create a job in database
    job_id = str(uuid.uuid4())
    job_data = {
        "id": job_id,
        "user_id": user.id if hasattr(user, 'id') else user.get('id'),
        "title": file.filename,
        "status": "queued",
        "video_url": "local_upload",
        "progress": 0
    }
    
    try:
        response = supabase_admin.table('jobs').insert(job_data).execute()
    except Exception as e:
        print(f"DB Insert Error: {e}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    
    if not response.data:
        raise HTTPException(status_code=500, detail="Failed to create job")
        
    job_id = response.data[0]["id"]
    
    # Trigger Celery Task (Async)
    process_video_task.delay(job_id, "local", local_path)
    
    return {
        "job_id": job_id,
        "status": "queued",
        "message": "File uploaded and added to processing queue"
    }
