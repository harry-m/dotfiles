#!/usr/bin/env bash
set -euo pipefail

echo "=== dotfiles setup ==="

# Git
echo "Configuring git..."
git config --global user.name "Harry Metcalfe"
git config --global user.email "mail@harrymetcalfe.com"
git config --global init.defaultBranch main
git config --global core.editor nvim
echo "  done"

# Neovim plugins
echo "Installing neovim plugins..."
nvim --headless "+Lazy! sync" +qa
echo "  done"

echo "=== setup complete ==="
