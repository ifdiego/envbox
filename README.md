# ffmpeg-video-compressor

```bash
git clone https://github.com/ifdiego/ffmpeg-video-compressor.git
cd ffmpeg-video-compressor
make install
```

A lightweight CLI tool to detect and compress video files.

By default, it:

* Scans the current directory or specified files for videos.
* Ignores non-video files and files already located in the `compressed` folder.
* Compresses using **ffmpeg** with `libx265` codec and CRF 28.
* Saves results in a `compressed/` folder.
* Provides basic logs for skipped files and progress.

Installation via **Makefile**:

* Copies `vidcompress` to `~/.local/bin`.
* Makes it executable.
* Supports `make uninstall` to remove the binary.

Usage: to compress specific videos, run `vidcompress video1.mp4 video2.mov`; to
compress all videos in the current directory, simply run `vidcompress`.

Limitations:

* No recursive folder scanning.
* Codec and quality fixed.

Feature requests and bug reports are welcome.
