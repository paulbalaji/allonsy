#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  echo "Allonsy's installer currently supports macOS only." >&2
  exit 1
fi

if [ -x /opt/homebrew/bin/brew ]; then
  brew_cmd=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  brew_cmd=/usr/local/bin/brew
else
  echo "Homebrew is required. Install it from https://brew.sh, then rerun this installer." >&2
  exit 1
fi

echo "Installing runtime dependencies..."
"$brew_cmd" install ffmpeg deno uv

brew_prefix="$("$brew_cmd" --prefix)"
uv_cmd="$brew_prefix/bin/uv"
install_dir="$HOME/.local/bin"

# Ignore ambient uv configuration and index variables so installation always
# resolves from PyPI. --force replaces the command without deleting its previous
# package-manager environment.
uv_environment=(
  env -i
  "HOME=$HOME"
  "PATH=/usr/bin:/bin:/usr/sbin:/sbin"
  "TMPDIR=${TMPDIR:-/tmp}"
  "UV_TOOL_BIN_DIR=$install_dir"
)
"${uv_environment[@]}" "$uv_cmd" tool install \
  --force \
  --no-config \
  --default-index https://pypi.org/simple \
  --managed-python \
  --python 3.13 \
  'yt-dlp[default]'

mkdir -p "$install_dir"
script_dir="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)"
install -m 755 "$script_dir/bin/allonsy" "$install_dir/allonsy"

case ":$PATH:" in
  *":$install_dir:"*) ;;
  *)
    case "${SHELL##*/}" in
      zsh) profile_file="$HOME/.zprofile" ;;
      *) profile_file="$HOME/.bash_profile" ;;
    esac
    path_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    if ! grep -Fq "$path_line" "$profile_file" 2>/dev/null; then
      printf '\n%s\n' "$path_line" >> "$profile_file"
    fi
    export PATH="$install_dir:$PATH"
    echo "Added ~/.local/bin to PATH in $profile_file"
    ;;
esac

echo
"$install_dir/allonsy" --version
"${uv_environment[@]}" "$install_dir/yt-dlp" --version
"$brew_prefix/bin/ffmpeg" -version >/dev/null
"$brew_prefix/bin/deno" --version >/dev/null
yt_dlp_python="$("${uv_environment[@]}" "$uv_cmd" tool dir --no-config)/yt-dlp/bin/python"
"${uv_environment[@]}" "$yt_dlp_python" -I -c 'import yt_dlp_ejs'
echo "Installed successfully. Open a new terminal, then run:"
echo "  allonsy VIDEO_ID"
