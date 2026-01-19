# Simple prompt: green cwd + yellow git status + $
function fish_prompt
    # Green current directory (shortened)
    set_color green
    echo -n (prompt_pwd)

    # Yellow git status
    set_color yellow
    set -l git_branch (git branch --show-current 2>/dev/null)

    if test -n "$git_branch"
        # OPTIMIZATION:
        # 1. Use --porcelain (machine readable, faster).
        # 2. Use --untracked-files=normal (standard check).
        # 3. Pipe to head -n1. This kills the process the moment ONE change is found.
        if command git status --porcelain --untracked-files=normal 2>/dev/null | head -n1 | grep -q .
            # If we are here, the repo is dirty (staged, unstaged, OR untracked)
            echo -n " ($git_branch*)"
        else
            # The repo is clean
            echo -n " ($git_branch)"
        end
    end

    # Reset color and show prompt
    set_color normal
    echo -n ' $ '
end
