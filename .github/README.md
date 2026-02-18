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
| `.zfunc` | Shell functions, like `vm` (see below) |
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
- **Search**: fzf, ripgrep
- **File listing**: eza
- **File preview**: bat
- **Directory jumping**: zoxide

## CLI Customizations

### Navigation

[zoxide](https://github.com/ajeetdsouza/zoxide) replaces `cd` with a frecency-based directory jumper. Use `z` instead of `cd` — it learns your most-visited directories and lets you jump with partial names.

### File Listing

`eza` replaces `ls` with icons, git status, and better formatting. Several aliases are configured:

| Alias | Description |
|-------|-------------|
| `ls` | Default listing with icons |
| `ll` | Long format with git status, timestamps, and groups |
| `lt` | Tree view |
| `lg` | Grid view |
| `xls` | Escape hatch to system `ls` |

### Finding and Opening Files

Two functions in `.zfunc/` combine ripgrep, fzf, bat, and Neovim into a fast file-picking workflow. Both require `bat` for previews.

**`vf`** — fuzzy file picker with preview. Launches fzf with a syntax-highlighted bat preview of each file; opens the selection in Neovim.

**`vrg`** — search file contents, preview matches, open at the right line. Runs ripgrep across the current directory, passes results to fzf with bat highlighting the matched line, then opens the file in Neovim at the correct line number. Useful as a terminal-native alternative to an IDE's global search.

### Development Server

**`serve [port]`** — starts a Python HTTP server for the current directory, defaulting to port 8000. If that port is taken, it increments automatically up to 10 times before giving up.

```bash
serve        # starts at 8000, or next available
serve 3000   # starts at 3000, or next available
```

## Dev Virtual Machines with Lima

[Lima](https://lima-vm.io/) provides Linux VMs on macOS (and Linux). The included `.lima/_config/default.yaml` automatically provisions dotfiles on every new VM.

### Install Lima

```sh
brew install lima
```

### Basic Commands

Create a VM with minimal config (recommended)
```sh
limactl create --name myvm ~/.config/lima/templates/minimal.yaml
```

Start the VM
```sh
limactl start myvm
```

Or use Lima's default template (verbose config)
```sh
limactl create --name myvm
```

```sh
limactl start myvm
```

Shell into the VM
```sh
limactl shell myvm
```

Stop and delete
```sh
limactl stop myvm
```

```sh
limactl delete myvm
```

List all VMs
```sh
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
### Project-Aware VM Execution

A `vm` shell function enables running commands in a Lima VM without explicitly SSHing. It looks for a `.vm` file in your current directory to determine which VM to use (or asks which vm to use and optionally saves it to `.vm`).

It even works for interactive tools like Claude.

#### Usage
```bash
# First time in a new project (no .vm file)
vm ls
# → Available VMs:
#   1) work
#   2) personal
# Which VM? (number or name): 2
# Save 'personal' to .vm file? (y/n): y

# In a project directory with a .vm file
vm claude             # Run Claude in the associated VM
vm npm test           # Run npm test in the VM
vm git status         # Run git in the VM
```

This pattern enables sandboxed execution of AI tools (like Claude Code) or experimental code without replicating your entire development environment in the VM:

- **Security**: AI tools run isolated from your SSH keys, API tokens, and credentials
- **Flexibility**: Use your local editor, git, and familiar tools
- **Progressive isolation**: Start minimal, add VM-specific tooling only as needed
- **Low friction**: The `.vm` file acts as a simple project-level configuration

Add `.vm` to your global gitignore since VM names are machine-specific:
```bash
echo ".vm" >> ~/.gitignore
```

## Local Overrides

For machine-specific settings that shouldn't be committed:

- `.zshrc_local` - Shell customizations
- `.gitconfig.local` - Git identity, work vs personal email
