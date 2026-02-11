# ~/.local/bin is where utils like uv and claude live
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Version manager (mise reads .tool-versions)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# Editor preference
export EDITOR=nvim
export VISUAL=nvim

# where should ripgrep find its config file?
# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
if [ -x "$(command -v rg)" ]; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

