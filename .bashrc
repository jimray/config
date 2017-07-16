# Dotfiles #
############
# This is for portable dotfiles-style config, using a bare git tree
# https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/
alias config='/usr/bin/git --git-dir=/Users/jimray/.config --work-tree=/Users/jimray'

# Aliases #
###########
alias ls='ls -G'
alias ll='ls -al'
alias reload='source ~/.bashrc'
# if MacVim is installed use that instead
if [ -e /Applications/MacVim.app/ ]; then
  alias vim='/Applications/MacVim.app/Contents/bin/vim'
  alias vi='/Applications/MacVim.app/Contents/bin/vim'
fi

# Git
alias g='git'

# Basher #
##########
# https://github.com/basherpm/basher
export PATH="$HOME/.basher/bin:$PATH"
eval "$(basher init -)"

# Console #
###########
# Git status
# https://gist.github.com/henrik/31631
function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo " 💩 "
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

# rocket current_working_dir [git_branch] >
export PS1='🚀  \W $(parse_git_branch) > '
