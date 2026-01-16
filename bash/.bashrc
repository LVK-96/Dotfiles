#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Ensure local paths are set
export PATH="$HOME/.local/share/nvim/mason/bin:$HOME/.local/bin:$PATH"

# Add pixi to PATH if installed
if [[ -n "$PIXI_HOME" && -d "$PIXI_HOME/bin" ]]; then
    export PATH="$PIXI_HOME/.opencode/bin:$PIXI_HOME/bin:$PATH"
elif [[ -d "$HOME/.pixi/bin" ]]; then
    export PATH="$HOME/.pixi/.opencode/bin:$HOME/.pixi/bin:$PATH"
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

# Fast git status, branch name and dirty flag in prompt
parse_git_info() {
   branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
   [ -n "$branch" ] || return
   dirty=$(git status --porcelain 2>/dev/null)
   [ -n "$dirty" ] && echo "($branch*)" || echo "($branch)"
}
export PS1="\[\033[32m\]\w\[\033[33m\]\$(parse_git_info)\[\033[00m\] \$ "

bind 'TAB:menu-complete'

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
