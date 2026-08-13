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
"$brew_cmd" install ffmpeg deno pipx

brew_prefix="$("$brew_cmd" --prefix)"
pipx_cmd="$brew_prefix/bin/pipx"
install_dir="$HOME/.local/bin"
export PIPX_BIN_DIR="$install_dir"

if "$pipx_cmd" list --short 2>/dev/null | grep -q '^yt-dlp '; then
  if "$pipx_cmd" runpip yt-dlp show yt-dlp-ejs >/dev/null 2>&1; then
    "$pipx_cmd" upgrade yt-dlp
  else
    # Migrate older minimal installs to yt-dlp's recommended dependency set.
    "$pipx_cmd" install --force 'yt-dlp[default]'
  fi
else
  "$pipx_cmd" install 'yt-dlp[default]'
fi

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
"$install_dir/yt-dlp" --version
"$brew_prefix/bin/ffmpeg" -version >/dev/null
"$brew_prefix/bin/deno" --version >/dev/null
"$pipx_cmd" runpip yt-dlp show yt-dlp-ejs >/dev/null
echo "Installed successfully. Open a new terminal, then run:"
echo "  allonsy 'https://youtu.be/VIDEO_ID'"
