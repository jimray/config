# Init
# ####
# This is for portable dotfiles-style config, using a bare git tree
# https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-rep
# Usage is just git commands, with the config alias instead
#
# config status
# config add .my_dotfile
# config commit -m "Added a dotfile"
# config push
alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'

# Aliases
# #######
alias ls='ls -G'
alias ll='ls -al'
alias reload='source ~/.zshrc'

alias g='git'

# if MacVim is installed use that instead
if [ -e /Applications/MacVim.app/ ]; then
  alias vim='/Applications/MacVim.app/Contents/bin/vim'
  alias vi='/Applications/MacVim.app/Contents/bin/vim'
fi

if [ -e /Applications/Nova.app/ ]; then
  alias coda='nova'
fi

# Console
# #######
# a rocket!
export PS1='🚀 %1~ > '

# NVM
# ###
# export NVM_AUTO_USE=true
# source ~/.zsh-nvm/zsh-nvm.plugin.zsh

# Python
# ######
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# heroku autocomplete setup
# HEROKU_AC_ZSH_SETUP_PATH=/Users/jimray/Library/Caches/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

# activate asdf
# https://asdf-vm.com
. $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit

# activate z
# https://github.com/rupa/z
. $HOME/._z/z.sh

export PATH="$HOME/.poetry/bin:$PATH"

# use a local .zshrc if they got it
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
