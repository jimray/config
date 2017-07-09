# Basher
# https://github.com/basherpm/basher
export PATH="$HOME/.basher/bin:$PATH"
eval "$(basher init -)"

# This is for portable dotfiles style management, using a bare git tree
# https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/
alias config='/usr/bin/git --git-dir=/Users/jimray/.config --work-tree=/Users/jimray'
