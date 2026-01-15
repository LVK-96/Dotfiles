function theme_solarized
    # Solarized Light Theme for Fish Shell

    # Palette
    set -l base03  002b36
    set -l base02  073642
    set -l base01  586e75
    set -l base00  657b83
    set -l base0   839496
    set -l base1   93a1a1
    set -l base2   eee8d5
    set -l base3   fdf6e3
    set -l yellow  b58900
    set -l orange  cb4b16
    set -l red     dc322f
    set -l magenta d33682
    set -l violet  6c71c4
    set -l blue    268bd2
    set -l cyan    2aa198
    set -l green   859900

    # Syntax Highlighting
    set -g fish_color_normal $base00             # Default text
    set -g fish_color_command $base00 --bold     # Commands (using base00 to avoid flashing)
    set -g fish_color_keyword $green             # Keywords
    set -g fish_color_quote $cyan                # Strings
    set -g fish_color_redirection $blue          # Pipes/Redirects
    set -g fish_color_end $base00                # Separators
    set -g fish_color_error $red                 # Errors
    set -g fish_color_param $base00              # Arguments
    set -g fish_color_comment $base1             # Comments
    set -g fish_color_match --background=$base2  # Matches
    set -g fish_color_selection --background=$base2 # Selection
    set -g fish_color_search_match --background=$yellow
    set -g fish_color_operator $blue
    set -g fish_color_escape $red
    set -g fish_color_autosuggestion $base1      # Autosuggestions (dimmed)
    
    # Prompt colors
    set -g fish_color_user $blue
    set -g fish_color_host $cyan
    set -g fish_color_cwd $green
    set -g fish_color_cwd_root $red
    set -g fish_color_cancel $red

    # Pager
    set -g fish_pager_color_progress $cyan
    set -g fish_pager_color_prefix $base00 --bold
    set -g fish_pager_color_completion $base00
    set -g fish_pager_color_description $base1
    set -g fish_pager_color_selected_background $base2
end
