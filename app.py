import whisperx
from flask import Flask, request, jsonify
import os
import gunicorn.app.base
import base64
import io
import numpy as np
import soundfile as sf

app = Flask(__name__)

device = "cpu"
compute_type = "int8"
batch_size = 16  # Reduce if low on GPU mem

model_name = os.getenv("WHISPERX_MODEL", "tiny")
model = whisperx.load_model(model_name, device, compute_type=compute_type)

# Load alignment model
alignment_model, metadata = whisperx.load_align_model(language_code="en", device=device)

def decode_audio(audio_base64):
    audio_bytes = base64.b64decode(audio_base64)
    audio_buffer = io.BytesIO(audio_bytes)
    audio, samplerate = sf.read(audio_buffer)
    return np.array(audio, dtype=np.float32)

@app.route("/transcribe", methods=["POST"])
def transcribe_endpoint():
    try:
        data = request.get_json()
        audio_base64 = data.get("audio")
        if not audio_base64:
            return jsonify({"error": "Missing audio data"}), 400
        
        audio = decode_audio(audio_base64)
        result = model.transcribe(audio, batch_size=batch_size)
        
        return jsonify({"segments": result["segments"]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/align", methods=["POST"])
def align_endpoint():
    try:
        data = request.get_json()
        segments = data.get("segments")
        audio_base64 = data.get("audio")
        
        if not segments or not audio_base64:
            return jsonify({"error": "Missing required data"}), 400
        
        audio = decode_audio(audio_base64)
        aligned_segments = whisperx.align(segments, alignment_model, metadata, audio, device, return_char_alignments=False)
        
        return jsonify({"aligned_segments": aligned_segments["segments"]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    from gunicorn.app.wsgiapp import run
    run()
