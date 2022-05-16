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

# Load zsh functions
for file in ~/.zfunc/**; do
  autoload $file
done

# Aliases
# #######
# use exa instead of ls
if [ -x "$(command -v exa)" ]; then
  alias ls='exa --icons'
  alias ll='exa -alhgUm --git --icons'
  alias lt='exa --tree --icons'
  alias lg='exa -a --long --grid -h'
fi

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

# Specific app setups
# ###################
#
# Deno -- this is for the raspberry pi binary only
# asdf doesn't currently support an arm64 build of deno
# deno manually installed from here: https://github.com/LukeChannings/deno-arm64/releases
# TODO: move this to .zshrc.local on proper platform
# export PATH="$HOME/.deno/bin:$PATH"
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
if [ -x "$(command -v brew)" ]; then
  export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"
fi

# activate z
# https://github.com/rupa/z
. $HOME/._z/z.sh

# activate poetry packaging
# https://python-poetry.org
export PATH="$HOME/.poetry/bin:$PATH"

# where should ripgrep find its config file?
# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
if [ -x "$(command -v rg)" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# Specific OS setups
# ##################
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

# use starship for a nicer console
eval "$(starship init zsh)"

# fzf for fuzzy find
# github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# PDE SETUP || 2022-02-09T13:37:47-0500
##############################################
/usr/bin/ssh-add --apple-load-keychain >/dev/null 2>&1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
##############################################

