# Init
# ####
#
# Fuzzy completion setup
# Enable case-insensitive and substring matching
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Enable approximate matching (allows typos)
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Make completion menu more readable
zstyle ':completion:*' menu select

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
# Add .zfunc to fpath
# This MUST happen before compinit below, or completion files living in
# .zfunc (like _poetry) never get registered.
fpath=(~/.zfunc $fpath)

# Autoload all functions in .zfunc
# This looks for files (not directories) in .zfunc
# (N) is the nullglob qualifier -- without it zsh throws "no matches found"
# on a machine where ~/.zfunc doesn't exist yet.
# Files starting with _ are completion functions; compinit handles those.
for func in ~/.zfunc/[^_]*(N:t); do
    autoload -Uz $func
done

# ctrl-leftarrow and ctrl-right arrow move word by word
# Keybindings
# ###########
# vi-style line editing. zsh would land here anyway -- it picks its keymap by
# checking whether $VISUAL/$EDITOR contains the substring "vi", and .zshenv
# sets both to nvim -- but relying on that is exactly how you end up in vi
# mode for years without knowing. Explicit, so the rest of this block can
# assume it.
#
# All of this must come BEFORE the fzf setup further down: `bindkey -v`
# changes which keymap `main` points at, and anything bound beforehand is
# left behind in the old keymap.
bindkey -v

# Esc responds immediately instead of waiting 400ms to see whether it was the
# start of an escape sequence. 1 = 10ms; much below that and real multi-byte
# terminal sequences start getting split.
KEYTIMEOUT=1

# Esc then v opens the line you're typing in $EDITOR as a real buffer --
# macros, :%s, the lot. :wq runs it. Worth the switch on its own for long
# pipelines.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Cursor shape as the mode indicator: block in normal, beam in insert.
# Better than a prompt symbol -- it's where you're already looking.
#
# starship also defines zle-keymap-select and wraps whatever it finds, which
# is fine exactly once. Re-sourcing this file makes it wrap its own wrapper
# and recurse until FUNCNEST trips, which is why `reload` execs a new shell
# instead of sourcing.
function zle-keymap-select {
  case $KEYMAP in
    vicmd)      printf '\e[1 q' ;;  # block
    viins|main) printf '\e[5 q' ;;  # beam
  esac
}
zle -N zle-keymap-select

function zle-line-init {
  printf '\e[5 q'   # every new prompt starts in insert mode
}
zle -N zle-line-init

# Keep the line-editing shortcuts that work everywhere else in the OS.
# Bound in viins so they're there while typing, without leaving insert mode.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank
# vi mode otherwise refuses to backspace over text you didn't type this
# insert -- the single most irritating default in the whole keymap
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# History search: vim-style in normal mode, ctrl-r from insert.
# fzf overrides ^R further down when it's installed.
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M viins '^R' history-incremental-search-backward

# Text objects -- ciw, di", ci( and friends. zsh ships the widgets but binds
# none of them.
autoload -Uz select-bracketed select-quoted
zle -N select-bracketed
zle -N select-quoted
for _km in visual viopp; do
  for _c in {a,i}${(s..)^:-\'\"\`}; do
    bindkey -M $_km $_c select-quoted
  done
  for _c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $_km $_c select-bracketed
  done
done
unset _km _c

# vim-surround, also shipped and also unbound: cs"' ds" ysiw"
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd 'cs' change-surround
bindkey -M vicmd 'ds' delete-surround
bindkey -M vicmd 'ys' add-surround
bindkey -M visual 'S' add-surround

# bindkey ";5D" backward-word
# bindkey ";5C" forward-word

# History
# #######
# Set explicitly rather than inheriting whatever the OS decided. macOS
# /etc/zshrc gives you 1000 lines; Ubuntu sets no HISTFILE at all, which
# means a Lima VM keeps NO history between sessions. Both are worse than
# this, and a deep history makes fzf's ctrl-r actually worth using.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000          # lines kept in memory
SAVEHIST=100000          # lines written to HISTFILE

setopt EXTENDED_HISTORY       # record timestamp and duration
setopt INC_APPEND_HISTORY     # write as you go, not just on exit
setopt SHARE_HISTORY          # share between concurrent shells (and tmux panes)
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates of a repeated command
setopt HIST_IGNORE_SPACE      # leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS     # tidy up whitespace before saving
setopt HIST_VERIFY            # expand !! etc. onto the line instead of running it

# Shell behavior
setopt AUTO_CD                # `cd` is optional when typing a bare directory
setopt INTERACTIVE_COMMENTS   # allow # comments when typing interactively
setopt EXTENDED_GLOB          # **/, ^negation, (#qN) qualifiers
setopt NO_BEEP

# Completions
# ###########
# compinit lives here (not in .zshrc_macos) so both OSes behave the same.
# It has to run AFTER the fpath line above. Ubuntu's /etc/zsh/zshrc runs its
# own compinit before this file is even read, which is too early to see
# ~/.zfunc -- skip_global_compinit in .zshenv turns that off.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"
# Only do the (slow) full security check on the dump once a day
if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

#pipx autocompletion -- must come after compinit
autoload -U bashcompinit
bashcompinit

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
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# fzf for fuzzy find
# github.com/junegunn/fzf
if (( $+commands[fzf] )); then
  # fzf 0.48+ ships its own keybindings and completions, so the old
  # ~/.fzf.zsh that `$(brew --prefix)/opt/fzf/install` writes is no longer
  # needed. Fall back to it for older fzf.
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  fi

  # Use fd for fzf's file list: it's faster than find and it respects
  # .gitignore, so node_modules stops drowning out real results.
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline'
  # ctrl-t previews files, alt-c previews the directory it would cd into
  (( $+commands[bat] )) && \
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
  (( $+commands[eza] )) && \
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level 2 --icons {}'"
fi

# Aliases
# #######

# use eza instead of ls
if (( $+commands[eza] )); then
  alias ls='eza --icons'
  alias ll='eza --all --long --group-directories-first --header --group --created --modified --git --icons'
  alias lt='eza --tree --icons'
  alias lg='eza -a --long --grid -h'
  # but if you *need* ls...
  alias xls='/bin/ls'
fi

if (( $+commands[nvim] )); then
  alias vim='nvim'
  alias vi='nvim'
fi

alias g='git'

alias sqlite='sqlite3'
alias sql='sqlite3'

# it's annoying to add the 3 to the end!
# Alias python to python3 if python command doesn't exist
if ! command -v python &> /dev/null; then
    alias python='python3'
fi

# Lima BEGIN
# Make sure iptables and mount.fuse3 are available
PATH="$PATH:/usr/sbin:/sbin"
export PATH
# Lima END

# init zoxide
# Guarded like starship above -- an unguarded eval prints
# "command not found: zoxide" on every single shell start on any machine
# where it isn't installed.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
