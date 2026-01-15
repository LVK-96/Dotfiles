# Simple prompt: green cwd + yellow git status + $
function fish_prompt
    # Green current directory (shortened)
    set_color green
    echo -n (prompt_pwd)

    # Yellow git status
    set_color yellow
    set -l git_branch (git branch --show-current 2>/dev/null)
    if test -n "$git_branch"
        set -l git_status ""

        # Check for dirty state
        if not git diff --quiet 2>/dev/null
            set git_status "*"
        else if not git diff --cached --quiet 2>/dev/null
            set git_status "+"
        end

        # Check for untracked files
        if test -n "(git ls-files --others --exclude-standard 2>/dev/null)"
            set git_status "$git_status%"
        end

        echo -n " ($git_branch$git_status)"
    end

    # Reset color and show prompt
    set_color normal
    echo -n ' $ '
end
