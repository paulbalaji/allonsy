# Allonsy

> Maximum quality through the time vortex.

Allonsy is a small, independent macOS command that downloads the best video
stream and the best audio stream exposed by a supported site, then losslessly
muxes them into an MKV file. It is a deterministic wrapper around
[`yt-dlp`](https://github.com/yt-dlp/yt-dlp) and FFmpeg.

Allonsy is not affiliated with or endorsed by YouTube, Google, the BBC,
Doctor Who, `yt-dlp`, or FFmpeg. The name is a playful use of the ordinary
French phrase *allons-y* ("let's go"); this project uses no third-party logos,
artwork, characters, or other brand assets.

```shell
allonsy VIDEO_ID
```

Files are saved to `~/Movies` by default.

## Why this exists

YouTube usually serves its highest-quality video and audio separately. Allonsy
always requests `bestvideo+bestaudio/best` and lets FFmpeg combine the original
streams without re-encoding them. MKV is used because it can safely contain
combinations such as VP9 video plus Opus audio without forcing a lower-quality
codec or a lossy conversion.

If a site does not expose separate video-only and audio-only streams, Allonsy
falls back to that site's best combined stream and still remuxes without
transcoding. “Best” follows `yt-dlp`'s extractor-specific quality ranking; it is
not a claim that every source provides a lossless or high-resolution original.

Allonsy also:

- resumes interrupted downloads;
- refuses to overwrite an existing result;
- embeds available metadata and chapters;
- installs a supported JavaScript runtime for current YouTube extraction; and
- checks that the selected remote formats are downloadable before starting.

## Requirements

- macOS on Apple Silicon or Intel
- [Homebrew](https://brew.sh)
- a terminal
- enough disk space for the original streams (4K files can exceed 1 GB)

For playback, use VLC, IINA, or another player that supports MKV/VP9/Opus.

The installer supplies the remaining dependencies:

- `yt-dlp` and a managed Python 3.13 runtime via `uv`
- FFmpeg and `ffprobe`
- Deno, used by `yt-dlp` for YouTube's JavaScript challenges

## Install on another Mac

```shell
git clone https://github.com/paulbalaji/allonsy.git
cd allonsy
./install.sh
```

When `~/.local/bin` is not already on `PATH`, the installer adds the required
export line to `.zprofile` or `.bash_profile` and reports that change.

Open a new terminal after installation and verify it:

```shell
allonsy --version
```

Alternatively, paste [`SETUP_WITH_CODEX.md`](SETUP_WITH_CODEX.md) into Codex and
let it perform and verify the setup.

## Usage

Download one or more individual videos:

```shell
allonsy hHAziowW_Vg
allonsy https://youtu.be/hHAziowW_Vg
allonsy URL_ONE URL_TWO
```

A bare 11-character YouTube video ID or clean `youtu.be/VIDEO_ID` URL needs no
quotes. Shared URLs containing `?`, `&`, or other shell metacharacters must
still be quoted because zsh interprets them before Allonsy starts. The tracking
query is unnecessary, so copying only the video ID is the simplest option.
For the rare valid video ID beginning with `-`, separate it from Allonsy's
options: `allonsy -- -ABCDEFGHIJ`.

Choose another destination:

```shell
allonsy --output-dir "$HOME/Desktop/Media" 'https://youtu.be/VIDEO_ID'
```

Allonsy intentionally does not download entire playlists when given a playlist
URL. Pass the individual video URLs you want.

## Update

```shell
cd /path/to/allonsy
git pull --ff-only
./install.sh
```

The installer also upgrades `yt-dlp` when it is already installed.

## Dependency and supply-chain model

Allonsy does not bundle `yt-dlp`, FFmpeg, Deno, Python, uv, or Homebrew. The
installer fetches current releases from Homebrew and PyPI at installation time.
uv also fetches a managed Python 3.13 runtime built by Astral's
`python-build-standalone` project. Dependency patch versions are intentionally
not pinned because video extractors require frequent compatibility and security
updates. This improves freshness but means installs are not bit-for-bit
reproducible and inherit the trust and availability of Homebrew, PyPI, uv,
Astral's Python distributions, and their transitive dependencies.

Review `install.sh` before running it. For a controlled environment, install
audited dependency versions yourself and copy `bin/allonsy` into a directory on
your `PATH` instead of running the installer. Allonsy expects Deno and FFmpeg in
the standard Apple Silicon or Intel Homebrew binary directory.

## Playback

The output is designed to preserve source quality rather than maximize Apple
QuickTime compatibility. [VLC](https://www.videolan.org/vlc/) supports the MKV,
H.264, VP9, AAC, and Opus combinations normally returned by YouTube:

```shell
brew install --cask vlc
open -a VLC "$HOME/Movies/example.mkv"
```

## Troubleshooting

### `command not found: allonsy`

Open a new terminal. The installer adds `~/.local/bin` to the appropriate shell
profile when necessary.

### Downloads suddenly stop working

Video sites change frequently. Refresh everything:

```shell
cd /path/to/allonsy
git pull --ff-only
./install.sh
```

### A site requires login or age verification

Allonsy deliberately does not read browser cookies by default. Run `yt-dlp`
directly with the appropriate `--cookies-from-browser` option after reviewing
the [`yt-dlp` FAQ](https://github.com/yt-dlp/yt-dlp/wiki/FAQ).

Allonsy ignores external `yt-dlp` configuration files and plugins so its format,
cookie, hook, and post-processing behavior cannot be changed implicitly.

## Legal note

Allonsy is a general-purpose interoperability tool. Only download media when
the service permits it, you have permission from the relevant rights holders,
or applicable law otherwise allows it. You are responsible for complying with
site terms, copyright law, privacy rights, and other rules applicable to your
use. Allonsy does not bypass DRM and does not grant rights to downloaded media.

## License

Allonsy is available under the [MIT License](LICENSE). Its separately installed
dependencies have their own licenses and terms.

## Contributing and support

Focused issues and pull requests are welcome. This is a small personal project
maintained on a best-effort basis; there is no guaranteed support or response
time.
