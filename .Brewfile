# This is a standard set of tools, installable on just about any Mac you use
# To install personal apps (not on a work machine), run `brew bundle --file .Brewfile.personal`
#
# Core setup
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
tap "buo/cask-upgrade"    # upgrade cask installed apps via `brew cu`
tap "homebrew/cask-fonts"
brew "coreutils"

# deps?
brew "cmake"
brew "curl"
brew "libidn2"
brew "gnutls"
brew "gnupg"
brew "openssl@3"
brew "sqlite"

# git and github
brew "gh"
brew "git"
brew "git-lfs"

# handy tools
brew "eza"            # better ls, replaced exa
brew "ffmpeg"         # video swiss army knife
brew "fzf"            # fuzzy finder
brew "jq"             # CLI json tool
brew "lima"           # create and manage linux sandboxes
brew "llm"            # large language model cli tool
brew "macvim"         # vim, for the Mac
brew "mise"           # runtime version manager, replaces asdf, reads .tool-versions
brew "neovim"         # modern vim with better LSP handling
brew "pandoc"         # text processing engine
brew "ripgrep"        # recursively search directories for a regex, respects .gitignores
brew "starship"       # fancify the CLI
brew "tcptraceroute"  # traceroute, but TCP instead of UDP
brew "tlrc"           # better manpages, use with `tldr $COMMAND`
brew "tmux"           # terminal muxer of course
brew "uv"             # less bad python tooling
brew "wget"           # because some things you can't curl
brew "yt-dlp"         # download any video from anywhere

# Mac apps, sideloaded
# Upgrade with `brew cu -a --interactive`
cask "bbedit"
cask "claude"
cask "handbrake-app"
cask "iterm2"
cask "lolgato"
cask "nova"
cask "obsidian"
cask "raycast"
cask "safari-technology-preview"
cask "utm"
cask "visual-studio-code"
cask "vlc"

# fonts!
cask "font-sauce-code-pro-nerd-font"
cask "font-league-gothic"
cask "font-monaspace-nerd-font"
