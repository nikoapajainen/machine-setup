#!/bin/bash

# One-line bootstrap script for setting up a Mac from GitHub

REPO_URL="https://github.com/nikoapajainen/machine-setup.git"
CLONE_DIR="$HOME/Desktop/mac-setup"

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$($(brew --prefix)/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

# Install gum if missing
if ! command -v gum &> /dev/null; then
  echo "Installing gum..."
  brew install gum
fi

# Clone setup repo
if [ ! -d "$CLONE_DIR" ]; then
  echo "Cloning setup repo to $CLONE_DIR..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "Setup repo already exists at $CLONE_DIR"
fi

cd "$CLONE_DIR"
chmod +x macos-setup-ui.sh
./macos-setup-ui.sh
