function theme_alabaster
    # Alabaster Dark Theme for Fish Shell
    # Uses terminal-defined colors (ANSI palette) so the terminal emulator
    # (alacritty/foot/ghostty) controls the exact Alabaster palette.

    # Syntax Highlighting
    set -g fish_color_normal normal
    set -g fish_color_command normal --bold
    set -g fish_color_keyword blue
    set -g fish_color_quote green
    set -g fish_color_redirection cyan
    set -g fish_color_end normal
    set -g fish_color_error red
    set -g fish_color_param normal
    set -g fish_color_comment brblack
    set -g fish_color_match --background=black
    set -g fish_color_selection --background=black
    set -g fish_color_search_match --background=yellow
    set -g fish_color_operator cyan
    set -g fish_color_escape red
    set -g fish_color_autosuggestion brblack

    # Prompt colors
    set -g fish_color_user blue
    set -g fish_color_host cyan
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_cancel red

    # Pager
    set -g fish_pager_color_progress cyan
    set -g fish_pager_color_prefix normal --bold
    set -g fish_pager_color_completion normal
    set -g fish_pager_color_description brblack
    set -g fish_pager_color_selected_background black
end
