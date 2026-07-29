#!/bin/sh
set -e

# This is an evolving record of setting up a macOS or unix box
# It mostly serves as record keeping and notes to myself
#
# Before running this, init the dotfiles setup:
# curl -Lks https://raw.githubusercontent.com/jimray/config/main/.dotfiles-init.sh | /bin/sh
#
# When setting up a new Mac (or Lima VM), run the above command from the built-in Terminal
# and then never have to touch that again as iTerm 2 is one of the apps that gets installed
# via homebrew. Neat!

# Operating system specific configurations

# first, macOS
if [ "$(uname)" = "Darwin" ]; then
    # macOS-specific configuration
    echo "Starting macOS specific configuration"

    # Install Xcode command line tools
    if ! command -v xcode-select >/dev/null 2>&1; then
        echo "Installing Xcode command line tools..."
        xcode-select --install
    fi

    # Install Homebrew if not already installed
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Install some handy CLI tools all helpfully bundled up in a local Brewfile
    # to generate the .Brewfile: brew bundle dump --file ~/.Brewfile
    # Absolute paths: this script gets run from whatever directory you happen
    # to be in, and with `set -e` a relative path that misses aborts the
    # whole bootstrap. Same reason `rm` has -f.
    brew bundle --file "$HOME/.Brewfile"
    rm -f "$HOME/.Brewfile.lock.json"

    # Ask the user if they want to run brew bundle
    # (printf + read -r, not `read -p`, which is a bashism this /bin/sh
    # script can't rely on)
    printf "Do you want to install non-work apps in .Brewfile.personal? (y/n): "
    read -r run_brew_bundle
    if [ "$run_brew_bundle" = "y" ] || [ "$run_brew_bundle" = "Y" ]; then
        brew bundle --file "$HOME/.Brewfile.personal"
        rm -f "$HOME/.Brewfile.personal.lock.json"
    fi

    # fzf 0.48+ emits its own keybindings via `fzf --zsh` (see .zshrc), so
    # the interactive install script isn't needed on a current fzf.
    if ! fzf --zsh >/dev/null 2>&1; then
        "$(brew --prefix)"/opt/fzf/install --all
    fi

    # brew installs some default apps, like bbedit, macvim, visual-studio-code, and iterm, so ok to config here

    # Config iTerm
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.iterm"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    # Oceanic for iTerm
    # This gets saved in the ~/.iterm plist file, here for reference
    # https://raw.githubusercontent.com/mhartington/oceanic-next-iterm/master/Oceanic-Next.itermcolors

    # Allows you to hold down keys in VSCode Vim Mode
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

    # Set up the dock
    # hide
    defaults write com.apple.dock autohide -bool true
    # magnify
    defaults write com.apple.dock magnification -bool true
    # set the dock size
    defaults write com.apple.dock tilesize -float 35
    defaults write com.apple.dock largesize -float 100
    # only show active apps in the dock
    defaults write com.apple.dock static-only -bool true
    # dont animate when opening an app
    defaults write com.apple.dock launchanim -bool false

    # Set up Finder
    # Use list view in all Finder windows by default
    # Four-letter codes for the other view modes: icnv, clmv, glyv
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    # Finder always displays folders first when sorting by name
    defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"

    # Vim-ish movement between spaces
    # This doesn't work reliably so probably best to set in System Settings > Keyboard > Keyboard Shortcuts > Mission Control
    # Move left a space: cmd+ctrl+h
    # defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "{enabled=1;value={parameters=(104,4,1310720);type=standard;};}"
    # Move right a space: cmd+ctrl+l
    # defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 "{enabled=1;value={parameters=(108,37,1310720);type=standard;};}"

    # Set up Safari
    # show the debug menu
    defaults write com.apple.Safari IncludeDebugMenu -boolean true
    # show the full URL always
    defaults write com.apple.safari ShowFullURLInSmartSearchField -bool true
    # show the favorites bar (for bookmarklets mostly)
    defaults write com.apple.Safari ShowFavoritesBar -bool true

    # done with Dock customization, go ahead and restart it
    killall Dock

    # don't hide the ~/Library/ folder
    setfile -a v ~/Library
    chflags nohidden ~/Library

    echo "Finished with macOS configuration"
fi

if [ "$(uname)" = "FreeBSD" ]; then
    # FreeBSD-specific configuration
    echo "Starting FreeBSD specific configuration"

    # Install applications using FreeBSD ports
    if ! command -v pkg >/dev/null 2>&1; then
        echo "pkg is not installed. Please install it manually."
        exit 1
    fi

    # neovim, bat, fd-find and zoxide are needed by .zshenv/.zshrc and the
    # .zfunc helpers, same as on Linux
    sudo pkg install -y git zsh vim neovim tmux tldr eza ripgrep fzf gh starship \
        bat fd-find zoxide

    # use zsh
    chsh -s $(which zsh)

    echo "Finished with FreeBSD configuration"
fi

if [ "$(uname)" = "Linux" ]; then
    # Linux-specific configuration
    echo "Starting Linux specific configuration"

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get -y update

        # Install core packages (eza installed separately below)
        # bat and fd-find are here because the .zfunc helpers (vf, vrg, rgd,
        # zd) hard-depend on them -- without these they just print
        # "bat is not installed" in every Lima VM.
        sudo apt-get -y install git zsh vim tmux ripgrep fzf jq neovim wget curl gpg libatomic1 \
            bat fd-find

        # Debian/Ubuntu ship these under different binary names to avoid
        # clashes (bat -> batcat, fd -> fdfind). Everything else in these
        # dotfiles calls them bat and fd, so alias them onto the PATH.
        mkdir -p "$HOME/.local/bin"
        if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
            ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
        fi
        if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
            ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        fi

        # Install eza (modern ls replacement) - requires adding the official repository
        # https://github.com/eza-community/eza/blob/main/INSTALL.md
        if ! command -v eza >/dev/null 2>&1; then
            echo "Installing eza from official repository..."
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get -y update
            sudo apt-get -y install eza
        fi

        # Install tldr (may not be in all repos, try npm fallback)
        if ! command -v tldr >/dev/null 2>&1; then
            if sudo apt-get -y install tldr 2>/dev/null; then
                echo "tldr installed via apt"
            elif command -v npm >/dev/null 2>&1; then
                echo "Installing tldr via npm..."
                sudo npm install -g tldr
            else
                echo "Warning: Could not install tldr (not in apt repos and npm not available)"
            fi
        fi

        # Install the GitHub CLI
        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
        if ! command -v gh >/dev/null 2>&1; then
            echo "Installing GitHub CLI..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
            && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt-get -y update \
            && sudo apt-get -y install gh
        fi
    else
        echo "apt-get is not available. Please install the required packages manually."
        exit 1
    fi

    # Install starship (non-interactive)
    if ! command -v starship >/dev/null 2>&1; then
        echo "Installing starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # zoxide -- .zshrc initialises it, and the README calls it a key tool,
    # but nothing installed it on Linux until now
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "Installing zoxide..."
        if ! sudo apt-get -y install zoxide 2>/dev/null; then
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        fi
    fi

    # install mise
    curl https://mise.run | sh

    # install claude
    curl -fsSL https://claude.ai/install.sh | bash


    # Set zsh as default shell (if not already)
    # Check actual login shell from /etc/passwd, not $SHELL env var
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    zsh_path=$(which zsh)
    echo "Current login shell: $current_shell, zsh path: $zsh_path"
    if [ "$current_shell" != "$zsh_path" ]; then
        echo "Setting zsh as default shell..."
        # Add zsh to /etc/shells if not present
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
        # Change login shell
        sudo chsh -s "$zsh_path" "$USER"
    else
        echo "zsh is already the default shell"
    fi

    echo "Finished with Linux configuration"
fi

echo "Starting non-OS specific configuration"

# TMUX
#####

# Set up tmux for plugins
echo "Setting up tmux plugins..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
# Note: TPM plugins are auto-installed on first tmux launch (prefix + I)
# Running install_plugins outside tmux fails due to missing TMUX_PLUGIN_MANAGER_PATH

# VIM
#####
# Set up vim for plugins
# These are vim8-style packages, not using a plugin manager like Pathogen
# :h packages
echo "Setting up vim plugins..."
mkdir -p ~/.vim/pack/plugins/start/

# Helper function to clone a plugin only if it doesn't exist
# Everything is shallow-cloned -- nobody needs the full history of a plugin,
# and it makes a fresh VM noticeably quicker to set up.
clone_plugin() {
    repo_url="$1"
    dest_dir="$2"
    extra_args="${3:---depth 1}"
    if [ ! -d "$dest_dir" ]; then
        echo "  Cloning $(basename "$dest_dir")..."
        git clone $extra_args "$repo_url" "$dest_dir"
    fi
}

# GIT IDENTITY
# ############
# .gitconfig deliberately has no [user] block -- it's kept out of the repo so
# work and personal machines can differ. Nothing created that file though, so
# a fresh machine had no identity at all and every commit failed with
# "Please tell me who you are". Create it here if it's missing.
if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo ""
    echo "No ~/.gitconfig.local found -- git needs a name and email to commit."
    printf "  Name  [Jim Ray]: "
    read -r git_name
    printf "  Email [470581+jimray@users.noreply.github.com]: "
    read -r git_email

    cat > "$HOME/.gitconfig.local" <<EOF
# Local git identity. Not checked into the config repo.
[user]
	name = ${git_name:-Jim Ray}
	email = ${git_email:-470581+jimray@users.noreply.github.com}
EOF
    echo "  Wrote ~/.gitconfig.local"
fi

# Grab vim plugins
clone_plugin "https://github.com/tpope/vim-surround.git" "$HOME/.vim/pack/plugins/start/vim-surround"
clone_plugin "https://github.com/tpope/vim-vinegar.git" "$HOME/.vim/pack/plugins/start/vim-vinegar"
clone_plugin "https://github.com/tpope/vim-commentary.git" "$HOME/.vim/pack/plugins/start/vim-commentary"
clone_plugin "https://github.com/tpope/vim-fugitive.git" "$HOME/.vim/pack/plugins/start/vim-fugitive"
clone_plugin "https://github.com/vim-airline/vim-airline.git" "$HOME/.vim/pack/plugins/start/vim-airline"
clone_plugin "https://github.com/vim-airline/vim-airline-themes.git" "$HOME/.vim/pack/plugins/start/vim-airline-themes"
clone_plugin "https://github.com/airblade/vim-gitgutter.git" "$HOME/.vim/pack/plugins/start/vim-gitgutter"
clone_plugin "https://github.com/editorconfig/editorconfig-vim.git" "$HOME/.vim/pack/plugins/start/editorconfig-vim"
clone_plugin "https://github.com/fatih/vim-go.git" "$HOME/.vim/pack/plugins/start/vim-go"
clone_plugin "https://github.com/christoomey/vim-tmux-navigator.git" "$HOME/.vim/pack/plugins/start/vim-tmux-navigator"
# vim-markdown and vim-pencil both moved to the preservim org, which is where
# the maintained versions live now (plasticboy/reedes just redirect).
clone_plugin "https://github.com/preservim/vim-markdown.git" "$HOME/.vim/pack/plugins/start/vim-markdown"
clone_plugin "https://github.com/preservim/vim-pencil.git" "$HOME/.vim/pack/plugins/start/vim-pencil"
# NOTE: jiangmiao/auto-pairs has been unmaintained since 2019.
# LunarWatcher/auto-pairs is a drop-in maintained fork if it starts misbehaving.
clone_plugin "https://github.com/jiangmiao/auto-pairs.git" "$HOME/.vim/pack/plugins/start/auto-pairs"
clone_plugin "https://github.com/adrian5/oceanic-next-vim" "$HOME/.vim/pack/plugins/start/oceanic-next-vim" "--depth 1"
clone_plugin "https://github.com/shortcuts/no-neck-pain.nvim.git" "$HOME/.vim/pack/plugins/start/no-neck-pain.nvim"

# fzf requires both the binary with the fzf plugin and an additional plugin :shrug:
clone_plugin "https://github.com/junegunn/fzf" "$HOME/.vim/pack/plugins/start/fzf"
clone_plugin "https://github.com/junegunn/fzf.vim" "$HOME/.vim/pack/plugins/start/fzf.vim"

# vim help config - generate helptags for every plugin in one pass.
# `helptags ALL` walks every doc/ directory on the runtimepath, so this does
# the same job as the old per-plugin loop without starting vim 16 times.
# packloadall! is required: -u NONE skips package loading, so without it the
# pack/plugins/start/* directories never make it onto the runtimepath and
# helptags ALL silently finds nothing.
echo "Generating vim helptags..."
vim -u NONE --not-a-term \
    -c 'set packpath^=~/.vim' \
    -c 'silent! packloadall!' \
    -c 'helptags ALL' \
    -c q >/dev/null 2>&1 || true

# Re-running this script only clones plugins that are missing, so it will
# never update one that's already there. `vimup` (in .zfunc) pulls them all.

# NEOVIM
# ######
# Set up nvim to use vim for now
# Eventually, this will all be migrated to native neovim config
# Symlink vim plugins so neovim can find them
if command -v nvim >/dev/null 2>&1; then
    echo "Setting up Neovim plugin symlink"
    mkdir -p ~/.local/share/nvim/site/pack
    ln -sf ~/.vim/pack/plugins ~/.local/share/nvim/site/pack/plugins
fi

# At some point, set up SSH for Github
# ssh-keygen -f ~/.ssh/gh -t ed25519 -C "gh_email@emaildomain.tld"
#
# Then add it to the ssh-agent
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/gh
#
# Then add ssh key to your github using the gh CLI
# Get access token here: https://github.com/settings/tokens
# gh ssh-key add ~/.ssh/gh
#
#
# You'll need a ~/.ssh/config that
# at least contains Personal GitHub account:
#Host github.com
# HostName github.com
# User git
# AddKeysToAgent yes
# IdentityFile ~/.ssh/gh
#
# There's probably a way to automate all of this without it feeling
# insecure?

echo ""
echo "Bootstrap complete!"
