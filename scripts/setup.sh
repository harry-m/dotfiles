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

# Docker
echo "Installing docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
echo "  done"

echo "=== setup complete ==="
