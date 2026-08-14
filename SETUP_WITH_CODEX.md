# Paste this into Codex on a new Mac

```text
Set up the public Allonsy video downloader from GitHub on this Mac.

Repository: https://github.com/paulbalaji/allonsy

Please do the work rather than only giving me instructions:

1. Confirm this is macOS and check whether Homebrew and Git are installed.
2. Install missing Homebrew and Git prerequisites if safe to do so.
3. Clone the public `https://github.com/paulbalaji/allonsy` repository into a
   sensible directory, or fast-forward it if it is
   already cloned. Preserve any local changes rather than overwriting them.
4. Read its README and `install.sh`, then run the installer.
5. Verify `allonsy --version`, `yt-dlp --version`, `ffmpeg -version`, and that a
   supported JavaScript runtime is available.
6. Confirm `yt-dlp-ejs` is installed in the `yt-dlp` uv tool environment.
7. Confirm `~/.local/bin` is available in a fresh login shell.
8. Do not download a test video unless I provide a URL. Report the installed
   paths and any remaining manual step.

Allonsy must retain its core behavior: select `bestvideo+bestaudio/best`, perform
no audio or video transcoding, losslessly mux into MKV, save to `~/Movies` by
default, resume partial downloads, and avoid overwriting completed files.
```
