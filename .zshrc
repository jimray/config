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
#
# a rocket!
export PS1='🚀 %1~ > '

# Specific app setups
# ###################
#
# activate asdf
# https://asdf-vm.com
. $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit

# Homebrew
export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"

# activate z
# https://github.com/rupa/z
. $HOME/._z/z.sh

# activate poetry packaging
# https://python-poetry.org
export PATH="$HOME/.poetry/bin:$PATH"

# use a local .zshrc if they got it
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# PDE SETUP || 2022-02-09T13:37:47-0500
##############################################
/usr/bin/ssh-add --apple-load-keychain >/dev/null 2>&1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
##############################################

