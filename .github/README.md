# dotfiles

Personal configuration files for macOS, Linux, and FreeBSD. Uses a bare git repo approach so dotfiles live directly in `$HOME` without symlinks.

## Quick Start

On a fresh machine, run:

```sh
curl -Lks https://raw.githubusercontent.com/jimray/config/main/.dotfiles-init.sh | /bin/sh
```

This will:
1. Install git if needed
2. Clone the dotfiles as a bare repo to `~/.cfg`
3. Check out config files (backing up any conflicts)
4. Optionally run the bootstrap script

## What's Included

| File | Purpose |
|------|---------|
| `.zshrc` | Main shell config (sources OS-specific files) |
| `.zshrc_macos` / `.zshrc_linux` | OS-specific shell settings |
| `.vimrc` | Vim/Neovim configuration |
| `.tmux.conf` | tmux with plugins (resurrect, continuum, vim-navigator) |
| `.gitconfig` | Git aliases and settings |
| `.config/starship.toml` | Starship prompt theme |
| `.config/nvim/` | Neovim configuration |
| `.Brewfile` | Homebrew packages (work) |
| `.Brewfile.personal` | Homebrew packages (personal) |
| `.bootstrap.sh` | Full system setup script |
| `.lima/_config/default.yaml` | Auto-provisions dotfiles in Lima VMs |

## Managing Dotfiles

After setup, use the `config` alias instead of `git`:

```sh
config status
config add .vimrc
config commit -m "Update vim config"
config push
```

## Bootstrap Script

The bootstrap script (`.bootstrap.sh`) installs everything needed for a development environment:

- **macOS**: Homebrew, CLI tools, app preferences (Dock, Finder, Safari)
- **Linux**: apt packages, eza, GitHub CLI, starship prompt
- **FreeBSD**: pkg packages

Plus cross-platform setup:
- tmux plugin manager (tpm)
- Vim plugins (vim8-style packages)
- Neovim symlinks

## Key Tools

- **Shell**: zsh + [Starship](https://starship.rs/) prompt
- **Editor**: Neovim (with vim as fallback)
- **Terminal**: tmux + iTerm2 (macOS)
- **Search**: fzf, ripgrep, eza

## Lima Virtual Machines

[Lima](https://lima-vm.io/) provides Linux VMs on macOS (and Linux). The included `.lima/_config/default.yaml` automatically provisions dotfiles on every new VM.

### Install Lima

```sh
brew install lima
```

### Basic Commands

```sh
# Create a VM with minimal config (recommended)
limactl create --name myvm ~/.config/lima/templates/minimal.yaml
limactl start myvm

# Or use Lima's default template (verbose config)
limactl create --name myvm
limactl start myvm

# Shell into the VM
limactl shell myvm

# Stop and delete
limactl stop myvm
limactl delete myvm

# List all VMs
limactl list
```

### How Auto-Provisioning Works

When any Lima VM starts, the config in `.lima/_config/default.yaml` runs automatically:
1. Checks if `~/.cfg` exists (dotfiles already set up)
2. If not, downloads and runs the dotfiles init script
3. Runs the bootstrap to install tools

No manual setup needed - just `limactl create` and your dev environment is ready.

### Writable Directories

By default, Lima mounts your home directory as **read-only**. To make directories writable for a specific VM, edit `~/.lima/<vm-name>/lima.yaml` and add a `mounts` section:

```yaml
mounts:
  - location: "~"
    writable: false
  - location: "~/Projects"
    writable: true
```

Then restart the VM for changes to take effect:

```sh
limactl stop myvm && limactl start myvm
```

## Local Overrides

For machine-specific settings that shouldn't be committed:

- `.zshrc_local` - Shell customizations
- `.gitconfig.local` - Git identity, work vs personal email
