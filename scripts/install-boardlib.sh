#!/usr/bin/env bash
# One-time setup: install BoardLib on macOS so you can pull your
# Tension Board 2 logbook from the terminal.
#
# Usage: save this file, then in Terminal:
#   chmod +x install-boardlib.sh
#   ./install-boardlib.sh
set -euo pipefail

echo "==> Checking for Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew isn't installed. Installing it now."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "==> Checking for Python 3"
if ! command -v python3 >/dev/null 2>&1; then
  echo "Installing Python 3 via Homebrew"
  brew install python
fi

echo "==> Installing pipx (isolated installer for Python CLIs)"
if ! command -v pipx >/dev/null 2>&1; then
  brew install pipx
  pipx ensurepath
fi

echo "==> Installing BoardLib"
pipx install --force boardlib

echo
echo "Done. Open a new Terminal window, then run the pull script:"
echo "  ./pull-logbook.sh"
