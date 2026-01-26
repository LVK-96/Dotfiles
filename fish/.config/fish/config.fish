# ~/.config/fish/config.fish

# Exit early if not interactive
status is-interactive || exit

# Disable greeting
set -g fish_greeting

# Theme
theme_modus

# Vi mode
fish_vi_key_bindings

# Emulate vim's cursor shape behavior
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

# Restore Ctrl+R (history search) in insert mode
bind -M insert \cr history-pager
bind -M insert \cp history-search-backward
bind -M insert \cn history-search-forward

# Environment variables
set -gx TERM xterm-256color
set -gx EDITOR nvim
set -gx BAT_THEME base16

if type -q eza
    alias l="eza -lh --icons --git"
    alias la="eza -lah --icons --git"
end

if type -q nvim
    alias vim="nvim"
end

function fish_user_key_bindings
    fzf_configure_bindings --directory=\ct
end


# Load environment config if it exists
set -l env_file (dirname (status filename))/env.fish
if test -f $env_file
    source $env_file
end

zoxide init fish | source
