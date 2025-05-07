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
alias config='$(which git) --git-dir=$HOME/.cfg --work-tree=$HOME'

# Load zsh functions
for file in ~/.zfunc/**; do
  autoload $file
done

# ctrl-leftarrow and ctrl-right arrow move word by word
# bindkey ";5D" backward-word
# bindkey ";5C" forward-word


# Specific app setups
# ###################
#
# PDE SETUP || 2022-02-09T13:37:47-0500
##############################################
/usr/bin/ssh-add --apple-load-keychain >/dev/null 2>&1

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
##############################################
#

# activate z
# https://github.com/rupa/z
. $HOME/._z/z.sh

# activate poetry packaging
# https://python-poetry.org
export PATH="$HOME/.poetry/bin:$PATH"

#pipx autocompletion
autoload -U bashcompinit
bashcompinit

# eval "$(register-python-argcomplete pipx)"
export PATH="$PATH:/Users/jim.ray/.local/bin"

# where should ripgrep find its config file?
# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
if [ -x "$(command -v rg)" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

# Specific OS setups
# ##################
case `uname` in
  Darwin)
    # localize macOS commands in .zshrc_macos
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

# Aliases
# #######

# use eza instead of ls
if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias ll='eza --all --long --header --group --created --modified --git --icons'
  alias lt='eza --tree --icons'
  alias lg='eza -a --long --grid -h'
  # but if you *need* ls...
  alias xls='/bin/ls'
fi

alias reload='source ~/.zshrc'

alias g='git'

alias sqlite='sqlite3'
alias sql='sqlite3'

# start a simple HTTP server and serve the current directory at 8000
alias serve='python -m http.server 8000'



# Added by Windsurf
export PATH="/Users/jim.ray/.codeium/windsurf/bin:$PATH"
