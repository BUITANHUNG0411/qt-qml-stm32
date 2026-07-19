#!/bin/bash
OUTPUT_DIR="/home/buitanhung/Music"

songs=(
  "Mark Ronson - Uptown Funk official audio"
  "a-ha - Take On Me official audio"
  "Eminem - Lose Yourself official audio"
)

for song in "${songs[@]}"; do
  echo "Downloading: $song"
  ./yt-dlp \
    --ffmpeg-location ./ffmpeg-static \
    -x --audio-format mp3 --audio-quality 0 \
    --embed-metadata --embed-thumbnail \
    --parse-metadata "%(title)s:%(artist)s - %(title)s" \
    --output "$OUTPUT_DIR/%(title)s.%(ext)s" \
    "ytsearch1:$song"
done

# clean up stray webp
rm -f "$OUTPUT_DIR"/*.webp
