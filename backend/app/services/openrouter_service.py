import time
import json
import logging
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential
from app.core.config import settings

logger = logging.getLogger("OpenRouterService")
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=settings.OPENROUTER_API_KEY,
)

SYSTEM_PROMPT = """Anda adalah seorang Produser Video Viral dan Kurator Konten spesialis short-form (TikTok, Reels, Shorts).
Tugas Anda adalah membaca transkrip video berikut dan menemukan segmen-segmen (WAJIB berdurasi minimal 30 detik hingga 60 detik) yang memiliki struktur narasi paling kuat untuk dijadikan klip viral. Sangat disarankan agar dalam satu klip terdapat beberapa pergantian scene atau sub-topik yang saling berkaitan, sehingga penonton tidak bosan (jangan memilih klip yang terlalu pendek atau hanya berisi 1 scene singkat).

Jangan hanya mencari momen dengan suara keras. Anda WAJIB menganalisis struktur psikologis narasi yang mengandung elemen berikut:
1. Hook (3 detik pertama): Memancing rasa penasaran, pernyataan kontroversial, atau pertanyaan menggantung.
2. Twist / Fakta Mengejutkan: Informasi baru yang mengubah pemahaman atau mind-blowing.
3. Comment-Bait: Pernyataan yang memancing audiens untuk berdebat atau berkomentar.
4. Payoff: Penutup yang memuaskan dan memberi resolusi atau klimaks emosional.

Output Anda WAJIB berupa JSON array dengan struktur yang ketat sebagai berikut, tanpa tambahan teks atau markdown di luar JSON:
[
  {
    "start_time": "00:01:23",
    "end_time": "00:02:15",
    "hook_score": 85,
    "judul_saran": "Fakta Mengejutkan Tentang X",
    "alasan_naratif": "Klip ini dimulai dengan hook yang kuat tentang Y, diikuti dengan twist bahwa Z, yang akan memancing banyak komentar dari audiens."
  }
]"""

class OpenRouterService:
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
    def curate_narrative(self, transcript_text: str) -> list:
        """
        Analyze transcript and curate clips using OpenRouter (Gemini 1.5 Pro).
        Includes fallback to Claude 3.5 Sonnet.
        """
        models = [
            "google/gemini-2.5-pro",
            "anthropic/claude-sonnet-5",
        ]
        
        for i, model in enumerate(models):
            try:
                start_time = time.time()
                logger.info(f"Calling OpenRouter with model {model}...")
                
                response = client.chat.completions.create(
                    model=model,
                    messages=[
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user", "content": f"Berikut adalah transkripnya:\n\n{transcript_text}"}
                    ],
                    response_format={"type": "json_object"} if "gemini" not in model else None # some models support strict json_object, but we rely on prompt for standard
                )
                
                end_time = time.time()
                
                # Log usage
                usage = response.usage
                if usage:
                    logger.info(f"Token Usage - Input: {usage.prompt_tokens}, Output: {usage.completion_tokens}, Total: {usage.total_tokens}")
                logger.info(f"Request Duration: {end_time - start_time:.2f} seconds")
                
                content = response.choices[0].message.content
                
                # Clean markdown JSON formatting if present
                if content.startswith("```json"):
                    content = content[7:-3]
                elif content.startswith("```"):
                    content = content[3:-3]
                    
                clips = json.loads(content.strip())
                return clips
                
            except Exception as e:
                logger.warning(f"Model {model} failed: {str(e)}")
                if i == len(models) - 1:
                    raise Exception(f"All models failed for curation. Last error: {str(e)}")
                logger.info("Falling back to next model...")

openrouter_service = OpenRouterService()
