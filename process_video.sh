#!/bin/bash

# ─── Input Check ───────────────────────────────────────────────────────────────
VIDEO="$1"
if [ -z "$VIDEO" ]; then
    echo "Usage: $0 <video-file>"
    exit 1
fi

# ─── Variables ─────────────────────────────────────────────────────────────────
BASENAME=$(basename "$VIDEO" | cut -d. -f1)
AUDIO="${BASENAME}_audio.wav"
WHISPER_OUTPUT="${BASENAME}_audio.txt"
WHISPER_TRANSCRIPT="${BASENAME}_whisper.txt"
FRAME_DIR="frames_$BASENAME"
OCR_DIR="ocr_$BASENAME"
OCR_TRANSCRIPT="${BASENAME}_ocr.txt"
FINAL_TRANSCRIPT="${BASENAME}_final_transcript.txt"
MODEL_PATH="$HOME/.models/whisper/ggml-large-v3-turbo.bin"

# ─── Tool Check ────────────────────────────────────────────────────────────────
for cmd in ffmpeg tesseract whisper-cli; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ '$cmd' is not installed or not on PATH."
        exit 2
    fi
done

# ─── Extract Audio ─────────────────────────────────────────────────────────────
echo "🔊 Extracting audio..."
ffmpeg -y -i "$VIDEO" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$AUDIO"

# ─── Transcribe Audio with Whisper ─────────────────────────────────────────────
echo "🧠 Running Whisper transcription..."
whisper-cli -m "$MODEL_PATH" -otxt "$AUDIO"
mv "$WHISPER_OUTPUT" "$WHISPER_TRANSCRIPT"

# ─── Extract Frames at 30 FPS ──────────────────────────────────────────────────
echo "🎞️ Extracting frames at 30 FPS..."
mkdir -p "$FRAME_DIR"
ffmpeg -i "$VIDEO" -vf fps=30 "$FRAME_DIR/frame_%06d.png"

# ─── OCR Each Frame and Merge ──────────────────────────────────────────────────
echo "🔎 Running OCR on frames and merging..."
mkdir -p "$OCR_DIR"
>"$OCR_TRANSCRIPT"

for img in "$FRAME_DIR"/*.png; do
    text=$(tesseract "$img" stdout --oem 3 --psm 6 2>/dev/null)
    if [ -n "$text" ]; then
        echo "----- ${img} -----" >>"$OCR_TRANSCRIPT"
        echo "$text" >>"$OCR_TRANSCRIPT"
        echo >>"$OCR_TRANSCRIPT"
    fi
done

# ─── Combine Audio and OCR into One Transcript ─────────────────────────────────
echo "📝 Merging Whisper and OCR transcripts..."
{
    echo "===== WHISPER TRANSCRIPTION ====="
    cat "$WHISPER_TRANSCRIPT"
    echo
    echo "===== OCR TRANSCRIPTION ====="
    cat "$OCR_TRANSCRIPT"
} >"$FINAL_TRANSCRIPT"

# ─── Done ──────────────────────────────────────────────────────────────────────
echo "✅ All done!"
echo "• Whisper:           $WHISPER_TRANSCRIPT"
echo "• OCR:               $OCR_TRANSCRIPT"
echo "• Final transcript:  $FINAL_TRANSCRIPT"
