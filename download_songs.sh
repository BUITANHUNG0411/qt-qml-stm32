#!/bin/bash
OUTPUT_DIR="/home/buitanhung/Music"
mkdir -p "$OUTPUT_DIR"

# List of 10 famous songs
songs=(
  "The Weeknd - Blinding Lights official audio"
  "Ed Sheeran - Shape of You official audio"
  "Queen - Bohemian Rhapsody official audio"
  "Michael Jackson - Billie Jean official audio"
  "Nirvana - Smells Like Teen Spirit official audio"
  "Whitney Houston - I Will Always Love You official audio"
  "Adele - Rolling in the Deep official audio"
  "Luis Fonsi - Despacito official audio"
  "Imagine Dragons - Believer official audio"
  "Coldplay - Viva La Vida official audio"
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

echo "Download completed!"
