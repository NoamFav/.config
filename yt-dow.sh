#!/bin/bash

# Check if URL is given
if [ -z "$1" ]; then
    echo "Usage: $0 <URL> [mp3|mp4]"
    exit 1
fi

URL="$1"
FORMAT="${2:-mp3}" # default to mp3 if not given

# Set custom downloads folder
OUTPUT_DIR="/Users/noamfavier/Library/Mobile Documents/com~apple~CloudDocs/Downloads"
mkdir -p "$OUTPUT_DIR"

# Detect platform
if [[ "$URL" == *"tiktok.com"* ]]; then
    echo "Detected TikTok URL."
    yt-dlp -f "bv*+ba*/b[ext=mp4][vcodec^=h264]/b" -o "$OUTPUT_DIR/TikTok_%(id)s.%(ext)s" "$URL"
else
    # Handle YouTube (and others) as usual
    if [ "$FORMAT" = "mp3" ]; then
        yt-dlp --cookies-from-browser safari --extract-audio --audio-format mp3 -o "$OUTPUT_DIR/%(title)s.%(ext)s" "$URL"
    elif [ "$FORMAT" = "mp4" ]; then
        yt-dlp --cookies-from-browser safari -f bestvideo+bestaudio --merge-output-format mp4 -o "$OUTPUT_DIR/%(title)s.%(ext)s" "$URL"
    else
        echo "Invalid format: $FORMAT"
        echo "Use mp3 or mp4."
        exit 2
    fi
fi

echo "Download complete"
