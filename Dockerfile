FROM debian:bookworm-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

ENV PIP_BREAK_SYSTEM_PACKAGES=1
    
# Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip

RUN pip install git+https://github.com/m-bain/whisperx.git torch torchvision torchaudio faster-whisper --index-url https://download.pytorch.org/whl/cpu --extra-index-url https://pypi.org/simple

# Copy the app itself
RUN mkdir -p /app/uploads
COPY audio.aac app.py config.py load_model.py /app

ENV WHISPERX_MODEL=tiny
RUN python3 load_model.py
RUN pip install --no-cache-dir gunicorn flask
# RUN gunicorn -b 0.0.0.0:5000 --workers 1 --timeout 300 app:app

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable for Flask to run on 0.0.0.0
ENV FLASK_RUN_HOST=0.0.0.0

# Run the command to start your app
CMD ["/opt/conda/envs/whisperx/bin/gunicorn", "-b", "0.0.0.0:5000", "--workers", "1", "--timeout", "300", "app:app"]
