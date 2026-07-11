import os
from groq import Groq
from tenacity import retry, stop_after_attempt, wait_exponential
from app.core.config import settings

client = Groq(api_key=settings.GROQ_API_KEY)

class GroqService:
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def transcribe_audio(self, file_path: str) -> dict:
        """
        Transcribe audio using Groq's whisper-large-v3 model.
        Returns the full transcript and timestamp segments.
        """
        print(f"[GroqService] Transcribing {file_path}...")
        with open(file_path, "rb") as file:
            transcription = client.audio.transcriptions.create(
                file=(os.path.basename(file_path), file.read()),
                model="whisper-large-v3",
                response_format="verbose_json",
            )
        
        # We return the verbose JSON dict to get segments/timestamps
        return transcription.model_dump()

groq_service = GroqService()
