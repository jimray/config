#!/bin/sh

# This is an evolving record of setting up a macOS or unix box
# It most mostly serves as as record keeping and notes to myself
# Before running this, init the dotfiles setup
# curl -Lks https://gist.githubusercontent.com/jimray/dad38720ddcfbca58e8f5a1ac1af00d7/raw | /bin/sh
#
# When setting up a new Mac, you should be able to run the above script from the built-in Terminal app
# and then never have to touch that again as iTerm 2 is one of the apps that gets gets installed
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
      sudo apt-get -y install "git" "zsh" "vim" "tmux" "tldr" "eza" "ripgrep" "fzf" "jq" "nvim"

        # install the github CLI
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
        type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
        && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
    else
      echo "apt-get is not available. Please install the required packages manually."
    fi

    # install starship
    curl -sS https://starship.rs/install.sh | sh

    # use zsh
    chsh -s $(which zsh)

    echo "Finished with Linux configuration"
fi

echo "Starting non-OS specific configuration"

# Projects go in the Projects directory
echo "Adding a Projects directory"
mkdir -p ~/Projects

# TMUX
#####

# Set up tmux for plugins
echo "Set up tmux for plugins"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install TPM plugins from .tmux.conf without needing to be in tmux
~/.tmux/plugins/tpm/bin/install_plugins

# VIM
#####
# Set up vim for plugins
# These are vim8-style packages, not using a plugin manager like Pathogen
# :h packages
echo "Set up vim for plugins"
mkdir -p ~/.vim/pack/plugins/start/

# Grab vim plugins
git clone https://github.com/tpope/vim-surround.git ~/.vim/pack/plugins/start/vim-surround
git clone https://github.com/tpope/vim-vinegar.git ~/.vim/pack/plugins/start/vim-vinegar
git clone https://github.com/tpope/vim-commentary.git ~/.vim/pack/plugins/start/vim-commentary
git clone https://github.com/tpope/vim-fugitive.git ~/.vim/pack/plugins/start/vim-fugitive
git clone https://github.com/vim-airline/vim-airline.git ~/.vim/pack/plugins/start/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes.git ~/.vim/pack/plugins/start/vim-airline-themes
git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/pack/plugins/start/vim-gitgutter
git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/pack/plugins/start/editorconfig-vim
git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
git clone https://github.com/christoomey/vim-tmux-navigator.git ~/.vim/pack/plugins/start/vim-tmux-navigator
git clone https://github.com/plasticboy/vim-markdown.git ~/.vim/pack/plugins/start/vim-markdown
git clone https://github.com/reedes/vim-pencil.git ~/.vim/pack/plugins/start/vim-pencil
git clone https://github.com/jiangmiao/auto-pairs.git ~/.vim/pack/plugins/start/auto-pairs
git clone --depth 1 https://github.com/adrian5/oceanic-next-vim ~/.vim/pack/plugins/start/oceanic-next-vim

# fzf requires both the binary with the fzf plugin and an additional plugin :shrug:
git clone http://github.com/junegunn/fzf ~/.vim/pack/plugins/start/fzf
git clone http://github.com/junegunn/fzf.vim ~/.vim/pack/plugins/start/fzf.vim

# vim help config
vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-airline/doc" -c q
vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-pencil/doc" -c q
vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-surround/doc" -c q
vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-commentary/doc" -c q
vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-fugitive/doc" -c q
vim -u NONE -c "helptags ~/.vim/pack/plugins/start/vim-gitgutter/doc" -c q

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
