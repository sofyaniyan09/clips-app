FROM python:3.9-slim

# Install system dependencies including FFmpeg
RUN apt-get update && apt-get install -y \
    ffmpeg \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directory for static clips if not exists
RUN mkdir -p /app/static/clips

# Command will be overridden by Procfile
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
