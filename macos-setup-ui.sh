#!/bin/bash

# To make this script executable:
# chmod +x macos-setup-ui.sh

# UI-Enhanced Launcher for macos-setup.sh using gum

if ! command -v gum &> /dev/null; then
    echo "❌ 'gum' is not installed. Please install it using 'brew install gum' and try again."
    exit 1
fi

clear
gum style --border double --margin "1" --padding "1 2" --foreground 212 "Welcome to macOS Setup"
echo "This will install development tools and configure your Mac."
echo

# Define default selections
CLI_TOOLS=(git azure-cli bicep awscli docker node nvm python jq httpie wget htop tree tmux watch fzf ripgrep fd bat zoxide neofetch mas powershell)
GUI_APPS=(brave-browser firefox visual-studio-code sublime-text github postman slack microsoft-teams spotify rectangle alfred microsoft-remote-desktop notion obsidian zoom docker discord iterm2 raycast 1password)

# CLI tool selection (all pre-selected)
selected_cli=$(printf "%s\n" "${CLI_TOOLS[@]}" | gum choose --no-limit --selected "${CLI_TOOLS[@]}" --header "Select CLI tools to install:")

# GUI app selection (all pre-selected)
selected_gui=$(printf "%s\n" "${GUI_APPS[@]}" | gum choose --no-limit --selected "${GUI_APPS[@]}" --header "Select GUI apps to install:")

# Verbose or Quiet?
GUM_VERBOSE=$(gum choose "verbose" "quiet" --header "Select output mode:")

# Final confirmation
gum confirm "Run the setup script now with the selected tools and apps?"

if [ $? -eq 0 ]; then
    SCRIPT_PATH="$HOME/Desktop/macos-setup.sh"
    if [ -f "$SCRIPT_PATH" ]; then
        gum style --border normal --padding "1 2" --foreground 10 "Running setup script with selections..."
        chmod +x "$SCRIPT_PATH"

        CLI_LIST=$(echo "$selected_cli" | paste -sd "," -)
        GUI_LIST=$(echo "$selected_gui" | paste -sd "," -)


        export SELECTED_CLI_TOOLS="$CLI_LIST"
        export SELECTED_GUI_APPS="$GUI_LIST"
        VERBOSE=$([ "$GUM_VERBOSE" = "verbose" ] && echo true || echo false)
        export VERBOSE

        "$SCRIPT_PATH"
    else
        gum style --border normal --padding "1 2" --foreground 1 "Script not found at: $SCRIPT_PATH"
    fi
else
    gum style --border normal --padding "1 2" --foreground 3 "Cancelled. Nothing was installed."
fi
