#!/bin/bash

LOG_FILE="$HOME/Desktop/setup-log.txt"
CLI_SUMMARY_FILE="$HOME/Desktop/cli-tools-summary.txt"
> "$LOG_FILE"
> "$CLI_SUMMARY_FILE"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

install_brew_package() {
    local name=$1
    log "Installing $name..."
    if brew list "$name" >/dev/null 2>&1 || brew install "$name" >> "$LOG_FILE" 2>&1; then
        log "$name: SUCCESS"
    else
        log "$name: FAILED"
    fi
}

install_cask_app() {
    local app=$1
    log "Installing $app..."
    if brew list --cask "$app" >/dev/null 2>&1 || brew install --cask "$app" >> "$LOG_FILE" 2>&1; then
        log "$app: SUCCESS"
    else
        log "$app: FAILED. Attempting cleanup and retry..."
        brew uninstall --cask --force "$app" >> "$LOG_FILE" 2>&1
        brew install --cask "$app" >> "$LOG_FILE" 2>&1 && log "$app: RETRY SUCCESS" || log "$app: RETRY FAILED"
    fi
}

write_cli_summary() {
    echo -e "$1\nUsage: $2\n" >> "$CLI_SUMMARY_FILE"
}

log "Requesting sudo..."
sudo -v

log "Checking for Xcode Command Line Tools..."
if xcode-select -p &> /dev/null; then
    log "Xcode CLT already installed."
else
    log "Installing Xcode Command Line Tools... (check for popup)"
    xcode-select --install
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    log "Xcode CLT installed."
fi

log "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOG_FILE" 2>&1
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    log "Homebrew already installed."
fi

log "Installing dockutil (for Dock cleanup)..."
install_brew_package dockutil

# Ensure Homebrew is in PATH (for VS Code and GUI apps)
log "Ensuring Homebrew path is set in shell profile..."
BREW_PATH_LINE='eval "$\(/opt/homebrew/bin/brew shellenv\)"'
SHELL_PROFILE="$HOME/.zprofile"

if [ -n "$ZSH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

grep -qxF "$BREW_PATH_LINE" "$SHELL_PROFILE" || echo "$BREW_PATH_LINE" >> "$SHELL_PROFILE"
eval "$BREW_PATH_LINE"

log "Updating Homebrew..."
brew update >> "$LOG_FILE" 2>&1

# CLI Tools
CLI_TOOLS=(
    git gh azure-cli  awscli docker node nvm python jq httpie wget htop tree tmux watch 
    fzf ripgrep fd bat zoxide neofetch mas powershell
)

for tool in "${CLI_TOOLS[@]}"; do
    install_brew_package "$tool"
done

# CLI Summaries
write_cli_summary "Git" "git --help"
write_cli_summary "Bicep CLI (via Azure CLI)" "az bicep install && az bicep --help"
write_cli_summary "Azure CLI" "az --help"
write_cli_summary "Bicep CLI" "bicep --help"
write_cli_summary "AWS CLI" "aws help"
write_cli_summary "Docker CLI" "docker --help"
write_cli_summary "Node.js" "node --help"
write_cli_summary "Python" "python3 --help"
write_cli_summary "jq (JSON parser)" "jq --help"
write_cli_summary "fzf (fuzzy finder)" "fzf --help"
write_cli_summary "ripgrep (search)" "rg --help"
write_cli_summary "fd (find alternative)" "fd --help"
write_cli_summary "bat (cat alternative)" "bat --help"
write_cli_summary "htop (system monitor)" "htop"
write_cli_summary "PowerShell (pwsh)" "pwsh --help"

# Install Bicep CLI via Azure CLI
log "Installing Bicep CLI via az..."
az bicep install >> "$LOG_FILE" 2>&1 || log "Bicep CLI install via az failed"

# GUI Apps
CASK_APPS=(
    brave-browser firefox visual-studio-code sublime-text github postman slack microsoft-teams spotify 
    rectangle alfred microsoft-remote-desktop notion obsidian zoom docker discord iterm2 raycast
)

for app in "${CASK_APPS[@]}"; do
    install_cask_app "$app"
done

# Set Brave as default browser
if brew list defaultbrowser >/dev/null 2>&1 || brew install defaultbrowser >> "$LOG_FILE" 2>&1; then
    defaultbrowser brave >> "$LOG_FILE" 2>&1
    log "Set Brave as default browser"
else
    log "Failed to set Brave as default browser"
fi

# macOS Preferences

# Show battery percentage in menu bar
log "Showing battery percentage in menu bar..."
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Set system sleep timer to 20 minutes
log "Setting system sleep timer to 20 minutes..."
sudo systemsetup -setcomputersleep 20

# Remove unwanted default Dock apps (Apple TV, FaceTime, Music)
log "Cleaning up Dock items..."
dockutil --remove 'TV' --no-restart || true
dockutil --remove 'Music' --no-restart || true
dockutil --remove 'FaceTime' --no-restart || true
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder

mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock persistent-apps -array
log "Restarting Dock to apply changes..."
killall Dock

# VS Code Extensions
VSCODE_EXTENSIONS=(
    ms-azuretools.vscode-azurefunctions
    ms-azuretools.vscode-bicep
    hashicorp.terraform
    esbenp.prettier-vscode
    ms-python.python
)

for ext in "${VSCODE_EXTENSIONS[@]}"; do
    log "Installing VS Code extension: $ext"
    code --install-extension "$ext" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "$ext: SUCCESS"
    else
        log "$ext: FAILED"
    fi

done

# Open Firefox extension page for Multi-Account Containers
open -a "Firefox" "https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/"

# Open log file at the end
open "$LOG_FILE"
open "$CLI_SUMMARY_FILE"

log "Setup complete!"
