#!/bin/bash

# This is an evolving record of setting up a macOS or unix box
# It most mostly serves as as record keeping and notes to myself
# Before running this, init the dotfiles setup
# curl -Lks https://gist.githubusercontent.com/jimray/dad38720ddcfbca58e8f5a1ac1af00d7/raw | /bin/bash
#
# When setting up a new Mac, you should be able to run the above script from the built-in Terminal app
# and then never have to touch that again as iTerm 2 is one of the apps that gets gets installed
# via homebrew. Neat!

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

# Install z
git clone https://github.com/rupa/z.git ~/._z

# Install asdf
# ASDF manages plugins that manage software versions like python, nodejs
# I always forget how this works! Example:
# asdf plugin add nodejs
# asdf install nodejs 13.14.0
# asdf plugin add python
# asdf install python latest
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

# At some point, set up SSH for Github
# ssh-keygen -f ~/.ssh/gh -t ed25519 -C "gh_email@emaildomain.tld"
#
# Then add it to the ssh-agent
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/gh
#
# Then add ssh key to your github using the `gh` CLI
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

# Projects go in the Projects directory
mkdir ~/Projects

# MacOS specific subshell.
(
if [ "$(uname)" != "Darwin" ]
then exit
fi

# Install xcode CLI tools
# This will have likely already happened but just in case
if [ ! -d "/Library/Developer/CommandLineTools" ]
then xcode-select --install
fi

# Install Homebrew
if [ ! -f "/opt/homebrew/bin/brew" ]
then /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"


# Oceanic for iTerm, too
# https://raw.githubusercontent.com/mhartington/oceanic-next-iterm/master/Oceanic-Next.itermcolors
# TODO figure out how to automate iTerm's colors

# Install some handy CLI tools all helpfully bundled up in a local Brewfile
# to generate the .Brewfile: brew bundle dump --file .Brewfile
brew bundle --file .Brewfile
rm .Brewfile.lock.json

# fzf needs some additional config
$(brew --prefix)/opt/fzf/install

# brew installs some default apps, like bbedit, macvim, visual-studio-code, and iterm, so ok to config here

# Config iTerm
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.iterm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

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
# don't animate when opening an app
defaults write com.apple.dock launchanim -bool false

# done with Dock customization, go ahead and restart it
killall Dock

# figure out how to install Safari extensions: Bumpr, Better, 1Password, Quiet, keysearch, StopTheMadness
# The answer is the `mas` app but Apple keeps breaking it

# don't hide the ~/Library/ folder
setfile -a v ~/Library
chflags nohidden ~/Library
)
# End MacOS specific subshell

# Linux specific subshell
(
if [ "$(uname)" != "Linux" ]
then exit fi

# Install Debian based linux utils
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get -y update
  sudo apt-get -y install "git" "zsh" "vim" "tmux" "tldr" "exa" "ripgrep" "fzf"

  # install starship
  curl -sS https://starship.rs/install.sh | sh

  # install the github CLI
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh
fi

# use zsh
chsh -s $(which zsh)
)
# End Linux specific subshell
