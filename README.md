# Dotfiles

Managed with a bare git repo. Files live in their normal locations in `$HOME`; git internals live in `~/.dotfiles`.

## Usage

The `dot` alias (defined in `.zshrc`) replaces `git` for dotfiles operations:

```bash
dot status
dot add ~/.some-config-file
dot commit -m "add some-config-file"
dot push
```

## Prerequisites

Ubuntu:

```bash
sudo apt update && sudo apt install -y zsh neovim && chsh -s $(which zsh) && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

macOS (requires [Homebrew](https://brew.sh)):

```bash
brew install neovim && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Setup on a new machine

```bash
git clone --bare https://github.com/harry-m/dotfiles.git ~/.dotfiles
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dot checkout
dot config status.showUntrackedFiles no
```

If checkout fails due to existing files, back them up first:

```bash
dot checkout 2>&1 | grep "^\s" | xargs -d '\n' -I{} mv {} {}.bak
dot checkout
```

## What's tracked

- `.zshrc` - Shell config, aliases
- `.config/nvim/init.lua` - Neovim config (lazy.nvim, telescope, smart-open, lualine)
- `.claude/settings.json` - Global Claude Code permissions and plugins
- `.claude/CLAUDE.md` - Personal Claude Code instructions
