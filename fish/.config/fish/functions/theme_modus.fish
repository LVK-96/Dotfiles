function theme_modus
    # Modus Vivendi (Dark) Theme for Fish Shell
    # Based on https://protesilaos.com/emacs/modus-themes

    # Syntax Highlighting
    set -g fish_color_normal ffffff              # fg-main
    set -g fish_color_command ffffff             # fg-main
    set -g fish_color_keyword 3548cf             # blue-warmer
    set -g fish_color_quote 2fafff               # cyan-intense
    set -g fish_color_redirection 00d3d0         # cyan
    set -g fish_color_end ffffff                 # fg-main
    set -g fish_color_error ff8059               # red-intense
    set -g fish_color_param ffffff               # fg-main
    set -g fish_color_comment a8a8a8             # fg-alt
    set -g fish_color_match --background=3c3c3c  # bg-active
    set -g fish_color_selection --background=3c3c3c # bg-active
    set -g fish_color_search_match --background=3c3c3c
    set -g fish_color_operator 00d3d0            # cyan
    set -g fish_color_escape 00bcff              # blue-intense
    set -g fish_color_autosuggestion 93959b      # fg-dim
    set -g fish_color_user 00bcff                # blue-intense
    set -g fish_color_host 00d3d0                # cyan
    set -g fish_color_cwd 2fafff                 # blue
    set -g fish_color_cwd_root ff8059            # red
    set -g fish_color_cancel ff8059              # red

    # Pager (Tab Completion Menu)
    set -g fish_pager_color_progress 00d3d0      # cyan
    set -g fish_pager_color_prefix 00bcff --bold # blue-intense
    set -g fish_pager_color_completion ffffff    # fg-main
    set -g fish_pager_color_description a8a8a8   # fg-alt
    set -g fish_pager_color_selected_background 3c3c3c # bg-active
end
