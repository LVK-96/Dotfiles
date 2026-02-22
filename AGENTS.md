# AGENTS.md

## Scope
These instructions apply to the entire repository.

## Neovim Config Formatting
- When you modify files under `nvim/.config/nvim/` that contain Lua code, run `stylua` on the changed Lua files before finishing.
- Preferred command for targeted formatting:
  - `stylua <changed-file-1>.lua <changed-file-2>.lua ...`
- If many Neovim Lua files were changed, you may format the whole Neovim config:
  - `stylua nvim/.config/nvim`
- Do not skip formatting for Neovim Lua changes.

## Shell Script Linting
- When you modify shell scripts, run `shellcheck` on the changed shell files before finishing.
- Preferred command for targeted linting:
  - `shellcheck <changed-script-1>.sh <changed-script-2>.sh ...`
- Include shell scripts that may not use the `.sh` extension if they are executable shell files.
- Do not skip `shellcheck` for shell script changes.
