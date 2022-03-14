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

# Deno -- this is for the raspberry pi binary only
# asdf doesn't currently support an arm64 build of deno
# deno manually installed from here: https://github.com/LukeChannings/deno-arm64/releases
export PATH="$HOME/.deno/bin:$PATH"

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


# run OS-specific bits
case `uname` in
  Darwin)
    # macOS commands here
    if [ -f ~/.zshrc_macos ]; then
      source ~/.zshrc_macos
    fi
  ;;
  Linux)
    # Linux commands here
    if [ -f ~/.zshrc_linux ]; then
      source ~/.zshrc_linux
    fi
  ;;
esac

# if connecting over SSH
if [[ $STY = '' && $SSH_TTY != '' ]]; then
  if [ -f ~/.zshrc_ssh ]; then
    source ~/.zshrc_ssh
  fi
fi

# use a local .zshrc if it exists
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

