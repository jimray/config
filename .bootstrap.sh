#!/bin/bash

# This is an evolving record of setting up a macOS or unix box
# It most mostly serves as as record keeping
# Before running this, init the dotfiles setup
# TODO: currently busted, fix
# curl -Lks https://git.io/vNPBg| /bin/bash

# TMUX
#####

# Set up tmux for plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# VIM
#####
# Set up vim for plugins
# These are vim8-style packages, not using a plugin manager like Pathogen
# :h packages
mkdir -p ~/.vim/pack/plugins/start/
mkdir -p ~/.vim/colors/

# Grab vim plugins
git clone https://github.com/tpope/vim-surround.git ~/.vim/pack/plugins/start/vim-surround
git clone https://github.com/vim-airline/vim-airline.git ~/.vim/pack/plugins/start/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes.git ~/.vim/pack/plugins/start/vim-airline-themes
git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/pack/plugins/start/editorconfig-vim
git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
git clone https://github.com/tpope/vim-vinegar.git ~/.vim/pack/plugins/start/vim-vinegar
git clone https://github.com/christoomey/vim-tmux-navigator.git ~/.vim/pack/plugins/start/vim-tmux-navigator
git clone https://github.com/plasticboy/vim-markdown.git ~/.vim/pack/plugins/start/vim-markdown
git clone https://github.com/reedes/vim-pencil.git ~/.vim/pack/plugins/start/vim-pencil

# Make vim pretty
curl 'https://raw.githubusercontent.com/mhartington/oceanic-next/master/colors/OceanicNext.vim' > ~/.vim/colors/oceanic-next.vim
curl 'https://raw.githubusercontent.com/mhartington/oceanic-next/master/autoload/airline/themes/oceanicnext.vim' > ~/.vim/pack/plugins/start/vim-airline-themes/autoload/airline/themes/oceanicnext.vim

# Install z
git clone https://github.com/rupa/z.git ~/._z

# Install asdf
# ASDF manages plugins that manage software versions like python, nodejs
# I always forget how this works! Example:
# asdf plugin add nodejs
# asdf install nodejs 13.14.0
git clone https://github.com/asdf-vm/asdf.git ~/.asdf


# At some point, set up SSH. You'll need a config that at least contains
# Personal GitHub account
#Host github.com
# HostName github.com
# User git
# AddKeysToAgent yes
# IdentityFile ~/.ssh/id_rsa

# MacOS specific subshell.
(
if [ "$(uname)" != "Darwin" ]
then exit
fi

# Install Homebrew
if [ ! -f "/usr/local/bin/brew" ]
then /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install xcode CLI tools
if [ ! -d "/Library/Developer" ]
then xcode-select --install
fi

# On the Mac, we're using MacVim, which gets installed manually
# TODO: make that more automatic, maybe via brew?

# Oceanic for iTerm, too
# https://raw.githubusercontent.com/mhartington/oceanic-next-iterm/master/Oceanic-Next.itermcolors
# TODO figure out how to automate iTerm's colors

# Install some handy CLI tools all helpfully bundled up in a local Brewfile
# to generate the .Brewfile: brew bundle dump --file .Brewfile
brew bundle --file .Brewfile
rm .Brewfile.lock.json
# TODO investigate cask installs for stuff like "slack", "iterm2", "1password", "dropbox", "visual-studio-code", "firefox", "macvim", etc.

# Set up the dock
# hide that dock
defaults write com.apple.dock autohide -bool true
# magnify
defaults write com.apple.dock magnification -bool true
# set the dock size
defaults write com.apple.dock tilesize -float 35
defaults write com.apple.dock largesize -float 100
# only show active apps in the dock
defaults write com.apple.dock static-only -bool true
# don't animate when opening an app
defaults write com.apple.dock launchanim -bool false

# done with Dock customization, go ahead and restart it
killall Dock

# figure out how to install Safari extensions: Bumpr, Better, 1Password, Quiet, keysearch, StopTheMadness

# don't hide the ~/Library/ folder
chflags nohidden ~/Library/
)
# End MacOS specific subshell
