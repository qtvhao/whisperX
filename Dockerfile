FROM debian

# Set the working directory in the container to /app
WORKDIR /app

# Install required packages and Miniconda
RUN apt update && apt install -y wget ffmpeg
RUN apt update && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda init

# Set environment variables for Conda
ENV PATH="/opt/conda/bin:$PATH"

# Copy the environment file and create the Conda environment
COPY environment.yaml /app
RUN conda env create -f /app/environment.yaml

# Copy the app itself
RUN mkdir -p /app/uploads
COPY app.py config.py /app

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable for Flask to run on 0.0.0.0
ENV FLASK_RUN_HOST=0.0.0.0

# Run the command to start your app
CMD ["/opt/conda/envs/whisperx/bin/gunicorn", "-b", "0.0.0.0:5000", "--workers", "1", "--timeout", "300", "app:app"]
