# This doesn't do much yet, mostly for record keeping
# Before running this, init the dotfiles setup
# curl -Lks https://git.io/vNPBg| /bin/bash

# TMUX
#####

# Set up tmux for plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


# VIM
#####

# On the Mac, we're using MacVim, which gets installed manually
# TODO: make that more automatic, maybe via brew?

# Set up vim for plugins
# These are vim8-style packages, not using a plugin manager like Pathogen
# :h packages
mkdir -p ~/.vim/pack/plugins/start/
mkdir -p ~/.vim/colors/

# Grab vim plugins -
# TODO move these into .vimrc and grep for them?
git clone https://github.com/tpope/vim-surround.git ~/.vim/pack/plugins/start/vim-surround
git clone https://github.com/vim-airline/vim-airline.git ~/.vim/pack/plugins/start/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes.git ~/.vim/pack/plugins/start/vim-airline-themes
git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/pack/plugins/start/editorconfig-vim
git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
git clone https://github.com/tpope/vim-vinegar.git ~/.vim/pack/plugins/start/vim-vinegar
git clone https://github.com/christoomey/vim-tmux-navigator.git ~/.vim/pack/plugins/start/vim-tmux-navigator

# Make vim pretty
curl 'https://raw.githubusercontent.com/mhartington/oceanic-next/master/colors/OceanicNext.vim' > ~/.vim/colors/oceanic-next.vim
curl 'https://raw.githubusercontent.com/mhartington/oceanic-next/master/autoload/airline/themes/oceanicnext.vim' > ~/.vim/pack/plugins/start/vim-airline-themes/autoload/airline/themes/oceanicnext.vim

# Oceanic for iTerm, too
# https://raw.githubusercontent.com/mhartington/oceanic-next-iterm/master/Oceanic-Next.itermcolors
# TODO figure out how to automate iTerm's colors

# Install z
git clone https://github.com/rupa/z.git ~/._z

# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

# NVM
# replacing with asdf(?)
# git clone https://github.com/lukechilds/zsh-nvm.git ~/.zsh-nvm

# TODO test this! Installing some defaults makes sense, but probably last!
# go ahead and install an LTS version of node to get started
# nvm install --lts
# install some sensible Node global packages
# npm install -g nodemon

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

# Install some handy CLI tools
# brew install "git" "tmux" || :
# brew cask install "ngrok" || :
brew bundle --file .Brewfile
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

# don't hid the ~/Library/ folder
chflags nohidden ~/Library/
)
# End MacOS specific subshell
