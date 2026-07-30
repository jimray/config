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
| `.zshenv` | Runs for every zsh (login or not) — PATH, mise, Homebrew |
| `.zshrc` | Main interactive shell config (sources OS-specific files) |
| `.zshrc_macos` / `.zshrc_linux` | OS-specific shell settings |
| `.zfunc` | Shell functions, like `vm` (see below) |
| `.vimrc` | Vim/Neovim configuration |
| `.tmux.conf` | tmux with plugins (resurrect, continuum, vim-navigator) |
| `.gitconfig` | Git aliases and settings |
| `.gitignore` | Global gitignore (`core.excludesfile`) |
| `.ripgreprc` | ripgrep defaults, found via `$RIPGREP_CONFIG_PATH` |
| `.editorconfig` | Per-filetype indent rules, read by vim + most editors |
| `.config/starship.toml` | Starship prompt theme |
| `.config/nvim/` | Neovim configuration |
| `.Brewfile` | Homebrew packages (work) |
| `.Brewfile.personal` | Homebrew packages (personal) |
| `.bootstrap.sh` | Full system setup script |
| `.lima/_config/default.yaml` | Auto-provisions dotfiles in Lima VMs |
| `.tool-versions` | mise-managed runtime versions |

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
- mise (runtime version manager)

## Key Tools

- **Shell**: zsh + [Starship](https://starship.rs/) prompt
- **Editor**: Neovim (with vim as fallback)
- **Terminal**: tmux + iTerm2 (macOS)
- **Search**: fzf, ripgrep
- **File listing**: eza
- **File preview**: bat
- **Directory jumping**: zoxide
- **Runtime versions**: mise

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

Several functions in `.zfunc/` combine ripgrep, fzf, bat, and Neovim into a fast file-picking workflow. They require `bat` for previews and `fd`/`rg` for searching — all installed by the bootstrap script on every platform.

**`vf [dir]`** — fuzzy file picker with preview. Launches fzf with a syntax-highlighted bat preview of each file; opens the selection in Neovim.

**`vrg [query]`** — search file contents, preview matches, open at the right line. ripgrep re-runs on every keystroke (fzf does no filtering of its own), so it stays fast in large repos. bat highlights the matched line in the preview, and the selection opens in Neovim at the correct line number. A terminal-native alternative to an IDE's global search.

**`rgd <pattern> [dir]`** — plain ripgrep search with a bat preview, for when you want to read results rather than jump to one.

**`zd`** — fuzzy-jump to any directory zoxide knows about, with an `eza` tree preview.

### Shell History

History is set explicitly in `.zshrc` rather than inherited from the OS: 100k lines, shared live between concurrent shells and tmux panes, with duplicates collapsed. Left to their own devices macOS caps you at 1000 lines and Ubuntu keeps no history at all between sessions, which makes fzf's `ctrl-r` far less useful than it should be.

A command typed with a **leading space** is kept out of history entirely — handy for anything with a token in it.

### Maintenance

**`vimup`** — updates every vim plugin under `~/.vim/pack/plugins/start/` and regenerates helptags. The bootstrap script only ever *clones* plugins that are missing, so it will never update one that already exists; this is how you pull new versions.

**`reload`** — re-sources `.zshrc` and reloads everything in `.zfunc/` without starting a new shell.

### Development Server

**`serve [port]`** — starts a Python HTTP server for the current directory, defaulting to port 8000. If that port is taken, it increments automatically up to 10 times before giving up.

```bash
serve        # starts at 8000, or next available
serve 3000   # starts at 3000, or next available
```

### Runtime Version Management with mise

[mise](https://github.com/jdx/mise) (mise-en-place) manages runtime versions for Node.js, Go, Deno, and other tools. It reads `.tool-versions` in the current directory (or `$HOME`) to determine which versions to use, making it easy to keep consistent versions across machines and VMs.

mise is activated in `.zshenv` so it's available in all shell sessions:

```sh
eval "$(mise activate zsh)"
```

The bootstrap script installs mise automatically on Linux and macOS.

#### Common commands

```sh
# Install all runtimes listed in .tool-versions
mise install

# Install a specific tool at a specific version
mise use --global node@lts
mise use --global node@22.0.0

# Check latest available version
mise latest node
mise latest go

# List installed tools and their versions
mise list

# Check what's active in the current directory
mise current
```

#### `.tool-versions`

The `.tool-versions` file in `$HOME` defines the global defaults:

```
deno 2.6.0
go 1.25.5
node 25.2.1
```

You can also drop a `.tool-versions` in any project directory to override versions locally — mise will pick it up automatically when you `cd` into that directory.

#### Installing Node in a Lima VM

Since dotfiles are provisioned automatically in new VMs, `.tool-versions` will already be present. From inside the VM:

```sh
# Install everything in .tool-versions at once
mise install

# Or install Node specifically
mise use --global node@lts
```

If you're still in a bash session (before `chsh` has switched you to zsh), activate mise manually first:

```sh
eval "$(~/.local/bin/mise activate bash)"
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

## Editor and tmux Notes

Two behaviors here are surprising enough to be worth writing down.

**tmux's prefix is `ctrl-d`, not `ctrl-b`.** That's the same key as the shell's EOF, so a bare `ctrl-d` no longer exits a shell or quits a REPL. Press it **twice** to send a real one through.

**Vim's `:q` doesn't quit vim.** `.vimrc` routes `:q`, `:q!`, `:wq`, and `:x` through `SmartQuit`, which closes the current *buffer* and only exits vim when it's the last one — closer to how a tabbed editor behaves. `:qa`, `:qa!`, and `:wqa` are untouched and still quit outright.

This is wired to the Enter key in command-line mode rather than to abbreviations. Abbreviations expand on any word boundary, which meant `:Rg q` searched for `call SmartQuit()` instead of `q`, and — worse — `:q!` expanded the `q` the moment you typed `!`, so it *wrote the file* and then failed with `E488: Trailing characters`. Checking the finished command line on Enter avoids both.

Undo history now persists across sessions (`undofile`), which matters more than usual here because swap and backup files are turned off.

## Local Overrides

For machine-specific settings that shouldn't be committed:

- `.zshrc_local` — Shell customizations. Sourced at the end of `.zshrc` if present.
- `.gitconfig.local` — Git identity, work vs personal email. `.gitconfig` has **no `[user]` block on purpose**, so this file is what makes commits possible; the bootstrap script prompts for a name and email and writes it on a fresh machine.

  Because `[include]` is expanded in place, anything set *after* the include in `.gitconfig` would silently override the local file. That's why the identity include sits at the very top.

## Git Defaults

Beyond aliases, `.gitconfig` turns on a handful of things git ships with but doesn't enable by default:

| Setting | What it does |
|---------|--------------|
| `merge.conflictStyle = zdiff3` | Conflict markers include the common ancestor, so you can see what each side actually changed |
| `diff.algorithm = histogram` | Better hunk boundaries than the default myers |
| `diff.colorMoved` | Moved lines colored differently from added/removed |
| `rerere.enabled` | Remembers how you resolved a conflict and replays it — pairs well with `pull.rebase` |
| `rebase.autostash` | Stashes a dirty worktree before rebasing, restores after |
| `rebase.updateRefs` | Keeps stacked branches pointing at the right commits |
| `commit.verbose` | Shows the full diff in the commit message editor |

These need git 2.38+ (`rebase.updateRefs` is the newest of them). Every supported platform's default git is well past that.
