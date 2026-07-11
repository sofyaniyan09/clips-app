from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    SUPABASE_URL: str
    SUPABASE_KEY: str
    SUPABASE_SERVICE_KEY: str
    REDIS_URL: str
    STORAGE_BUCKET_NAME: str = "videos"
    CORS_ORIGINS: str = "http://localhost:8080,http://localhost:5173"
    GROQ_API_KEY: str
    OPENROUTER_API_KEY: str
    
    @property
    def cors_origins_list(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(',')]

    class Config:
        env_file = ".env"

settings = Settings()
