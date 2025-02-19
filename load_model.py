import whisperx


device = "cpu"
compute_type = "int8"
audio_file = "audio.aac"
batch_size = 16 # reduce if low on GPU mem

model = whisperx.load_model("tiny", device, compute_type=compute_type)
audio = whisperx.load_audio(audio_file)
result = model.transcribe(audio, batch_size=batch_size)

print(result["segments"]) # before alignment
