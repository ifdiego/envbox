#!/bin/bash
set -euo pipefail

# ensure ffmpeg is available in PATH
if ! command -v ffmpeg &> /dev/null; then
    echo "[error]: ffmpeg is not installed"
    exit 1
fi

# detect whether a file is a video
# returns 0 if MIME type starts with "video/", otherwise returns 1
is_video() {
    file --brief --mime-type -- "$1" | grep -q '^video/'
}

videos=()

# determine input source:
# - if arguments were provided, use them
# - otherwise, scan current directory
if [[ $# -gt 0 ]]; then
    inputs=("$@")
    echo "[info]: processing files passed as arguments"
else
    inputs=(*)
    echo "[info]: scanning current directory for supported video files"
fi

# filter valid video files
for file in "${inputs[@]}"; do
    if [[ -f "$file" ]] && is_video "$file" && [[ "$file" != compressed/* ]]; then
        videos+=("$file")
    else
        echo "[skipping]: $file (not a supported video file)"
    fi
done

# exit program if no valid videos were found
if [[ ${#videos[@]} -eq 0 ]]; then
    echo "[error]: no supported video files were found"
    exit 1
fi

mkdir -p compressed

# compress each detected video
for video in "${videos[@]}"; do
    filename=$(basename -- "$video")
    output="compressed/$filename"

    echo "[info]: compressing: $filename"
    ffmpeg -i "$video" -vcodec libx265 -crf 28 "$output"
    echo "[done]: finished: $output"
done

echo "[done]: all videos compressed successfully"
