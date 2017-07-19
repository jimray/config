# This doesn't do much yet, mostly for record keeping
# Before running this, init the dotfiles setup
# curl -Lks https://git.io/vQFTa | /bin/bash

# VIM
#####

# Set up vim for plugins
mkdir -p ~/.vim/pack/plugins/start/
mkdir -p ~/.vim/colors/

# Grab vim plugins - maybe move these into .vimrc and grep for them?
git clone https://github.com/tpope/vim-surround.git ~/.vim/pack/plugins/start/vim-surround
git clone https://github.com/vim-airline/vim-airline.git ~/.vim/pack/plugins/start/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes.git ~/.vim/pack/plugins/start/vim-airline-themes
git clone https://github.com/editorconfig/editorconfig-vim.git ~/.vim/pack/plugins/start/editorconfig-vim

# Make vim pretty
curl 'https://raw.githubusercontent.com/mhartington/oceanic-next/master/colors/OceanicNext.vim' > ~/.vim/colors/oceanic-next.vim
curl 'https://raw.githubusercontent.com/mhartington/oceanic-next/master/autoload/airline/themes/oceanicnext.vim' > ~/.vim/pack/plugins/start/vim-airline-themes/autoload/airline/themes

# Oceanic for iTerm, too
# https://raw.githubusercontent.com/mhartington/oceanic-next-iterm/master/Oceanic-Next.itermcolors
# TODO figure out how to automate iTerm's colors

# NVM
git clone https://github.com/creationix/nvm.git ~/.nvm
# go ahead and install an LTS version of node to get started
nvm install --lts
# install some sensible Node global packages
npm install -g nodemon
