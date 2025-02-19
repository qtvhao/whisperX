import whisperx
import os

device = "cpu"
compute_type = "int8"
audio_file = "audio.aac"
batch_size = 16 # reduce if low on GPU mem
model_name = os.getenv("WHISPERX_MODEL", "tiny")

model = whisperx.load_model(model_name, device, compute_type=compute_type)
audio = whisperx.load_audio(audio_file)
result = model.transcribe(audio, batch_size=batch_size)

print(result["segments"]) # before alignment
