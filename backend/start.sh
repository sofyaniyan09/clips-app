#!/bin/bash
# Jalankan Celery worker di background (sebagai proses yang bekerja memotong video)
celery -A app.core.celery_app worker --pool=solo --loglevel=info &

# Jalankan Uvicorn Web Server di foreground (sebagai penerima request)
uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
