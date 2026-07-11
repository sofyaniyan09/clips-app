from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routes import presets, jobs, upload, clips, auth
from fastapi.staticfiles import StaticFiles
import os

app = FastAPI(title="Premium AI Video Clipper API", version="1.0.0")

# Setup CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(upload.router, prefix="/api/upload", tags=["Upload"])
app.include_router(jobs.router, prefix="/api/jobs", tags=["Jobs"])
app.include_router(presets.router, prefix="/api/presets", tags=["Presets"])
app.include_router(clips.router, prefix="/api/clips", tags=["Clips"])

os.makedirs("static", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def root():
    return {"message": "Welcome to Premium AI Video Clipper API"}
