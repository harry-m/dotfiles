# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

COLORTERM=truecolor

export EDITOR="nvim"

alias dangerclaude="claude --dangerously-skip-permissions"
alias dot="git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME"
alias oldvim="command vim"
alias vim="nvim"
export PATH="$HOME/scripts:$HOME/.local/bin:$PATH"
