#!/bin/sh
# Dotfiles initialization script
# Usage: curl -Lks https://raw.githubusercontent.com/jimray/config/main/.dotfiles-init.sh | /bin/sh
#
# This script:
# 1. Installs git if not present
# 2. Clones the dotfiles bare repo
# 3. Checks out config files (backing up conflicts)
# 4. Optionally runs the bootstrap script

set -e

echo "=== Dotfiles Initialization ==="

# Install git if not available
if ! command -v git >/dev/null 2>&1; then
    echo "Git not found. Installing..."

    if [ "$(uname)" = "Darwin" ]; then
        # macOS - xcode-select installs git
        xcode-select --install 2>/dev/null || true
        echo "Please complete the Xcode Command Line Tools installation, then re-run this script."
        exit 1
    elif [ "$(uname)" = "Linux" ]; then
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y git
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -Sy --noconfirm git
        else
            echo "Error: Could not find a package manager to install git."
            echo "Please install git manually and re-run this script."
            exit 1
        fi
    elif [ "$(uname)" = "FreeBSD" ]; then
        sudo pkg install -y git
    else
        echo "Error: Unsupported operating system. Please install git manually."
        exit 1
    fi
fi

echo "Git is available: $(git --version)"

# Define the config command helper
# Using a bare git repo with $HOME as the work tree
CFG_DIR="$HOME/.cfg"
CFG_BACKUP="$HOME/.config-backup"

config() {
    git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"
}

# Clone the bare repository if it doesn't exist
if [ -d "$CFG_DIR" ]; then
    echo "Config directory already exists at $CFG_DIR"
    echo "If you want to re-initialize, remove it first: rm -rf $CFG_DIR"
else
    echo "Cloning dotfiles repository..."
    git clone --bare https://github.com/jimray/config.git "$CFG_DIR"

    # Configure fetch refspec - bare repos don't set this up by default,
    # which breaks git fetch/pull. This makes the bare repo behave normally.
    config config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
fi

# Create backup directory
mkdir -p "$CFG_BACKUP"

# Try to checkout
echo "Checking out config files..."
if config checkout 2>/dev/null; then
    echo "Checked out config successfully."
else
    echo "Backing up pre-existing dot files..."
    # Get list of conflicting files and back them up
    config checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | while read -r file; do
        if [ -n "$file" ]; then
            echo "  Backing up: $file"
            mkdir -p "$CFG_BACKUP/$(dirname "$file")"
            mv "$HOME/$file" "$CFG_BACKUP/$file" 2>/dev/null || true
        fi
    done

    # Try checkout again
    if config checkout; then
        echo "Checked out config after backing up conflicts."
    else
        echo "Error: Could not checkout config files."
        echo "Please resolve conflicts manually."
        exit 1
    fi
fi

# Don't show untracked files (the whole home directory would show up)
config config status.showUntrackedFiles no

echo ""
echo "=== Dotfiles initialized successfully ==="
echo ""
echo "Your dotfiles are now in place. The 'config' alias will be available"
echo "in new shell sessions to manage your dotfiles."
echo ""
echo "Backed up files (if any) are in: $CFG_BACKUP"
echo ""

# Ask about running bootstrap
printf "Do you want to run the bootstrap script now? (y/n): "
read -r run_bootstrap

if [ "$run_bootstrap" = "y" ] || [ "$run_bootstrap" = "Y" ]; then
    if [ -x "$HOME/.bootstrap.sh" ]; then
        echo ""
        echo "=== Running bootstrap script ==="
        "$HOME/.bootstrap.sh"
    elif [ -f "$HOME/.bootstrap.sh" ]; then
        echo ""
        echo "=== Running bootstrap script ==="
        sh "$HOME/.bootstrap.sh"
    else
        echo "Bootstrap script not found at ~/.bootstrap.sh"
    fi
else
    echo ""
    echo "You can run the bootstrap script later with: ~/.bootstrap.sh"
fi
