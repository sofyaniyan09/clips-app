from pydantic import BaseModel, HttpUrl
from typing import Optional
from datetime import datetime
from uuid import UUID

class PresetCreate(BaseModel):
    name: str
    color_grading: Optional[str] = "Standard"
    font_style: Optional[str] = "Inter"

class PresetUpdate(BaseModel):
    name: Optional[str] = None
    color_grading: Optional[str] = None
    font_style: Optional[str] = None

class PresetResponse(PresetCreate):
    id: UUID
    user_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True

class UploadLinkRequest(BaseModel):
    url: str

class JobResponse(BaseModel):
    id: UUID
    user_id: UUID
    title: Optional[str]
    status: Optional[str]
    progress: Optional[int]
    platform: Optional[str]
    estimated_time: Optional[str]
    source_url: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True

class ClipResponse(BaseModel):
    id: UUID
    job_id: UUID
    title: str
    thumbnail_url: Optional[str]
    video_url: Optional[str]
    start_time: Optional[float]
    end_time: Optional[float]
    transcript_segments: Optional[list] = []
    duration: Optional[str]
    virality_score: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True
