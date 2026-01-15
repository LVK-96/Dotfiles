#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Ensure local paths are set (Pixi/Local/Mason)
export PATH="$HOME/.local/share/nvim/mason/bin:$HOME/.pixi/bin:$HOME/.local/bin:$PATH"

# Auto-launch Fish if available (Pixi installed)
if command -v fish >/dev/null; then
    exec fish
fi

# ls with colors
alias ls='ls --color=auto'

export TERM='xterm-256color'
export EDITOR='nvim'
alias vim="nvim"

# Better History Control
export HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and space-prefixed commands
export HISTSIZE=100000                   # Big history
export HISTFILESIZE=100000
shopt -s histappend                      # Append to history, don't overwrite

# Check window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# FZF Setup (System Install)
[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash

# Load local config if it exists (for env vars you don't want in git)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
