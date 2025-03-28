# 🍎 macOS Developer Setup Script

A one-stop automation tool for setting up a fresh macOS machine with:
- CLI tools (Git, Azure CLI, Docker, etc.)
- GUI apps (VS Code, Slack, Spotify, etc.)
- macOS preferences (Dock cleanup, Finder tweaks, etc.)

## 🚀 Quick Start (Fresh Mac)

1. Open Terminal
2. Paste and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nikoapajainen/machine-setup/main/bootstrap.sh)"
```

This will:
- Install Homebrew (if needed)
- Install `gum` (for the terminal UI)
- Clone this repo to your Desktop
- Launch the interactive setup UI

---

## 🧠 What It Installs

### CLI Tools (Selectable)
- git, azure-cli, bicep, docker, node, nvm, python, jq, fzf, etc.

### GUI Apps (Selectable)
- Brave, Firefox, VS Code, Slack, Teams, Spotify, Postman, Rectangle, Alfred, etc.

### macOS Tweaks
- Auto-hide Dock
- Show battery %
- Set Brave as default browser
- Remove Apple TV, Music, and FaceTime from Dock
- Screenshot location: `~/Screenshots`

### VS Code Extensions
- Azure Functions
- Bicep
- Terraform
- Python
- Prettier

---

## 🛠 Usage

### Run the Script Interactively:
```bash
./macos-setup-ui.sh
```

### Run the Full Script Directly:
```bash
chmod +x macos-setup.sh
./macos-setup.sh
```

This will install all default tools and apps without the UI selection step.

---

## 📝 Logs & Output

- Installation log: `~/Desktop/setup-log.txt`
- CLI usage reference: `~/Desktop/cli-tools-summary.txt`

---

## ✅ Requirements
- macOS
- Git (comes pre-installed)
- Internet connection

---

## 📦 Want to Customize?
- Edit `macos-setup.sh` to add/remove tools, apps, or preferences
- Edit `macos-setup-ui.sh` to change UI options

---

Made with ☕ and a love for clean Mac setups.
