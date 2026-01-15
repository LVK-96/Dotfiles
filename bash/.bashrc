#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Ensure local paths are set (Pixi/Local/Mason)
export PATH="$HOME/.local/share/nvim/mason/bin:${PIXI_HOME:-$HOME/.pixi}/bin:$HOME/.local/bin:$PATH"

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

# Fast git status prompt (matches fish style)
__git_prompt() {
    local branch
    branch=$(git branch --show-current 2>/dev/null) || return
    [[ -z "$branch" ]] && return

    local status=""
    # Dirty working tree
    git diff --quiet 2>/dev/null || status="*"
    # Staged changes (only if not dirty)
    [[ -z "$status" ]] && ! git diff --cached --quiet 2>/dev/null && status="+"
    # Untracked files
    [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]] && status="${status}%"

    echo " ($branch$status)"
}

# Green cwd, yellow git status, $ prompt
PS1='\[\e[32m\]\w\[\e[33m\]$(__git_prompt)\[\e[0m\] $ '

# FZF Setup (check multiple locations: pixi, homebrew, system)
for fzf_dir in "${PIXI_HOME:-$HOME/.pixi}/share/fzf" "$HOME/.fzf" "/opt/homebrew/opt/fzf/shell" "/usr/share/fzf" "/usr/share/doc/fzf/examples"; do
    if [[ -d "$fzf_dir" ]]; then
        [[ -f "$fzf_dir/key-bindings.bash" ]] && source "$fzf_dir/key-bindings.bash"
        [[ -f "$fzf_dir/completion.bash" ]] && source "$fzf_dir/completion.bash"
        break
    fi
done

# Load local config if it exists (for env vars you don't want in git)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
