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
alias config='/usr/bin/git --git-dir=/Users/jimray/.cfg --work-tree=/Users/jimray'

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

# Console
# #######
# show the current directory. And a rocket!
export PS1='🚀  %~ > '

# NVM
# ###
export NVM_AUTO_USE=true
source ~/.zsh-nvm/zsh-nvm.plugin.zsh

# Python
# ######
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

