#!/bin/sh
set -e

# This is an evolving record of setting up a macOS or unix box
# It mostly serves as record keeping and notes to myself
#
# Before running this, init the dotfiles setup:
# curl -Lks https://raw.githubusercontent.com/jimray/config/main/.dotfiles-init.sh | /bin/sh
#
# When setting up a new Mac (or Lima VM), run the above command from the built-in Terminal
# and then never have to touch that again as iTerm 2 is one of the apps that gets installed
# via homebrew. Neat!

# Operating system specific configurations

# first, macOS
if [ "$(uname)" = "Darwin" ]; then
    # macOS-specific configuration
    echo "Starting macOS specific configuration"

    # Install Xcode command line tools
    if ! command -v xcode-select >/dev/null 2>&1; then
        echo "Installing Xcode command line tools..."
        xcode-select --install
    fi

    # Install Homebrew if not already installed
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Install some handy CLI tools all helpfully bundled up in a local Brewfile
    # to generate the .Brewfile: brew bundle dump --file .Brewfile
    brew bundle --file .Brewfile
    rm .Brewfile.lock.json

    # Ask the user if they want to run brew bundle
    read -p "Do you want to install non-work apps in .Brewfile.personal? (y/n): " run_brew_bundle
    if [ "$run_brew_bundle" = "y" ]; then
        brew bundle --file .Brewfile.personal
    fi

    # fuzzy completion and keybindings for fzf
    $(brew --prefix)/opt/fzf/install

    # brew installs some default apps, like bbedit, macvim, visual-studio-code, and iterm, so ok to config here

    # Config iTerm
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.iterm"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    # Oceanic for iTerm
    # This gets saved in the ~/.iterm plist file, here for reference
    # https://raw.githubusercontent.com/mhartington/oceanic-next-iterm/master/Oceanic-Next.itermcolors

    # Allows you to hold down keys in VSCode Vim Mode
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

    # Set up the dock
    # hide
    defaults write com.apple.dock autohide -bool true
    # magnify
    defaults write com.apple.dock magnification -bool true
    # set the dock size
    defaults write com.apple.dock tilesize -float 35
    defaults write com.apple.dock largesize -float 100
    # only show active apps in the dock
    defaults write com.apple.dock static-only -bool true
    # dont animate when opening an app
    defaults write com.apple.dock launchanim -bool false

    # Set up Finder
    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: icnv, clmv, glyv
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    # Finder always displays folders first when sorting by name
    defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"

    # Set up Safari
    # show the debug menu
    defaults write com.apple.Safari IncludeDebugMenu -boolean true
    # show the full URL always
    defaults write com.apple.safari ShowFullURLInSmartSearchField -bool true
    # show the favorites bar (for bookmarklets mostly)
    defaults write com.apple.Safari ShowFavoritesBar -bool true

    # done with Dock customization, go ahead and restart it
    killall Dock

    # don't hide the ~/Library/ folder
    setfile -a v ~/Library
    chflags nohidden ~/Library

    echo "Finished with macOS configuration"
fi

if [ "$(uname)" = "FreeBSD" ]; then
    # FreeBSD-specific configuration
    echo "Starting FreeBSD specific configuration"

    # Install applications using FreeBSD ports
    if ! command -v pkg >/dev/null 2>&1; then
        echo "pkg is not installed. Please install it manually."
        exit 1
    fi

    sudo pkg install -y git zsh vim tmux tldr eza ripgrep fzf gh starship

    # use zsh
    chsh -s $(which zsh)

    echo "Finished with FreeBSD configuration"
fi

if [ "$(uname)" = "Linux" ]; then
    # Linux-specific configuration
    echo "Starting Linux specific configuration"

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get -y update

        # Install core packages (eza installed separately below)
        sudo apt-get -y install git zsh vim tmux ripgrep fzf jq neovim wget curl gpg

        # Install eza (modern ls replacement) - requires adding the official repository
        # https://github.com/eza-community/eza/blob/main/INSTALL.md
        if ! command -v eza >/dev/null 2>&1; then
            echo "Installing eza from official repository..."
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get -y update
            sudo apt-get -y install eza
        fi

        # Install tldr (may not be in all repos, try npm fallback)
        if ! command -v tldr >/dev/null 2>&1; then
            if sudo apt-get -y install tldr 2>/dev/null; then
                echo "tldr installed via apt"
            elif command -v npm >/dev/null 2>&1; then
                echo "Installing tldr via npm..."
                sudo npm install -g tldr
            else
                echo "Warning: Could not install tldr (not in apt repos and npm not available)"
            fi
        fi

        # Install the GitHub CLI
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
        if ! command -v gh >/dev/null 2>&1; then
            echo "Installing GitHub CLI..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
            && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt-get -y update \
            && sudo apt-get -y install gh
        fi
    else
        echo "apt-get is not available. Please install the required packages manually."
        exit 1
    fi

    # Install starship (non-interactive)
    if ! command -v starship >/dev/null 2>&1; then
        echo "Installing starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # install mise
    curl https://mise.run | sh

    # install claude
    curl -fsSL https://claude.ai/install.sh | bash


    # Set zsh as default shell (if not already)
    # Check actual login shell from /etc/passwd, not $SHELL env var
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    zsh_path=$(which zsh)
    echo "Current login shell: $current_shell, zsh path: $zsh_path"
    if [ "$current_shell" != "$zsh_path" ]; then
        echo "Setting zsh as default shell..."
        # Add zsh to /etc/shells if not present
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
        # Change login shell
        sudo chsh -s "$zsh_path" "$USER"
    else
        echo "zsh is already the default shell"
    fi

    echo "Finished with Linux configuration"
fi

echo "Starting non-OS specific configuration"

# TMUX
#####

# Set up tmux for plugins
echo "Setting up tmux plugins..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
# Note: TPM plugins are auto-installed on first tmux launch (prefix + I)
# Running install_plugins outside tmux fails due to missing TMUX_PLUGIN_MANAGER_PATH

# VIM
#####
# Set up vim for plugins
# These are vim8-style packages, not using a plugin manager like Pathogen
# :h packages
echo "Setting up vim plugins..."
mkdir -p ~/.vim/pack/plugins/start/

# Helper function to clone a plugin only if it doesn't exist
clone_plugin() {
    repo_url="$1"
    dest_dir="$2"
    extra_args="${3:-}"
    if [ ! -d "$dest_dir" ]; then
        echo "  Cloning $(basename "$dest_dir")..."
        git clone $extra_args "$repo_url" "$dest_dir"
    fi
}

# Grab vim plugins
clone_plugin "https://github.com/tpope/vim-surround.git" "$HOME/.vim/pack/plugins/start/vim-surround"
clone_plugin "https://github.com/tpope/vim-vinegar.git" "$HOME/.vim/pack/plugins/start/vim-vinegar"
clone_plugin "https://github.com/tpope/vim-commentary.git" "$HOME/.vim/pack/plugins/start/vim-commentary"
clone_plugin "https://github.com/tpope/vim-fugitive.git" "$HOME/.vim/pack/plugins/start/vim-fugitive"
clone_plugin "https://github.com/vim-airline/vim-airline.git" "$HOME/.vim/pack/plugins/start/vim-airline"
clone_plugin "https://github.com/vim-airline/vim-airline-themes.git" "$HOME/.vim/pack/plugins/start/vim-airline-themes"
clone_plugin "https://github.com/airblade/vim-gitgutter.git" "$HOME/.vim/pack/plugins/start/vim-gitgutter"
clone_plugin "https://github.com/editorconfig/editorconfig-vim.git" "$HOME/.vim/pack/plugins/start/editorconfig-vim"
clone_plugin "https://github.com/fatih/vim-go.git" "$HOME/.vim/pack/plugins/start/vim-go"
clone_plugin "https://github.com/christoomey/vim-tmux-navigator.git" "$HOME/.vim/pack/plugins/start/vim-tmux-navigator"
clone_plugin "https://github.com/plasticboy/vim-markdown.git" "$HOME/.vim/pack/plugins/start/vim-markdown"
clone_plugin "https://github.com/reedes/vim-pencil.git" "$HOME/.vim/pack/plugins/start/vim-pencil"
clone_plugin "https://github.com/jiangmiao/auto-pairs.git" "$HOME/.vim/pack/plugins/start/auto-pairs"
clone_plugin "https://github.com/adrian5/oceanic-next-vim" "$HOME/.vim/pack/plugins/start/oceanic-next-vim" "--depth 1"

# fzf requires both the binary with the fzf plugin and an additional plugin :shrug:
clone_plugin "https://github.com/junegunn/fzf" "$HOME/.vim/pack/plugins/start/fzf"
clone_plugin "https://github.com/junegunn/fzf.vim" "$HOME/.vim/pack/plugins/start/fzf.vim"

# vim help config - generate helptags for plugins with doc directories
echo "Generating vim helptags..."
for plugin_doc in ~/.vim/pack/plugins/start/*/doc; do
    if [ -d "$plugin_doc" ]; then
        vim -u NONE -c "helptags $plugin_doc" -c q 2>/dev/null || true
    fi
done

# NEOVIM
# ######
# Set up nvim to use vim for now
# Eventually, this will all be migrated to native neovim config
# Symlink vim plugins so neovim can find them
if command -v nvim >/dev/null 2>&1; then
    echo "Setting up Neovim plugin symlink"
    mkdir -p ~/.local/share/nvim/site/pack
    ln -sf ~/.vim/pack/plugins ~/.local/share/nvim/site/pack/plugins
fi

# At some point, set up SSH for Github
# ssh-keygen -f ~/.ssh/gh -t ed25519 -C "gh_email@emaildomain.tld"
#
# Then add it to the ssh-agent
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/gh
#
# Then add ssh key to your github using the gh CLI
# Get access token here: https://github.com/settings/tokens
# gh ssh-key add ~/.ssh/gh
#
#
# You'll need a ~/.ssh/config that
# at least contains Personal GitHub account:
#Host github.com
# HostName github.com
# User git
# AddKeysToAgent yes
# IdentityFile ~/.ssh/gh
#
# There's probably a way to automate all of this without it feeling
# insecure?

echo ""
echo "Bootstrap complete!"
