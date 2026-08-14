# Security Policy

## Supported versions

Security fixes are made on the latest `main` branch. Allonsy also installs
current upstream dependencies, so rerun `./install.sh` when updating.

## Reporting a vulnerability

Please do not open a public issue for a suspected vulnerability. Use GitHub's
private vulnerability reporting from the repository's **Security** tab:

<https://github.com/paulbalaji/allonsy/security/advisories/new>

Include the affected version or commit, operating system, reproduction steps,
impact, and any suggested remediation. Reports concerning `yt-dlp`, FFmpeg,
Deno, Homebrew, or uv themselves should be sent to the relevant upstream
project; please still report an Allonsy-specific unsafe integration or default.
Please allow time for a fix before publishing details.
