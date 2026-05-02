# Dotfiles

Personal configuration for terminal, editor, desktop, and agent tools. This context records load-bearing language for decisions that should survive future configuration reviews.

## Language

**Regular Neovim**:
Neovim running as the editor process, outside VSCode.
_Avoid_: standalone nvim, real nvim

**VSCode-Neovim**:
Neovim running inside VSCode via the VSCode-Neovim integration.
_Avoid_: vscode mode, VSCode path

**Numbered tabline**:
The Neovim buffer tabline that shows page-relative numbers for keyboard buffer selection.
_Avoid_: bufferline, tabs, tab bar

**Tabline page**:
A visible group of at most ten **Normal file buffers** in the **Numbered tabline**.
_Avoid_: tab group, tabline window

**Normal file buffer**:
A listed buffer backed by an ordinary file, excluding terminals, help, quickfix, and plugin buffers.
_Avoid_: listed buffer, file-ish buffer

## Relationships

- **Regular Neovim** uses the **Numbered tabline**.
- **VSCode-Neovim** keeps editor-integration behavior quarantined from **Regular Neovim** behavior.
- A **Numbered tabline** contains one **Tabline page** at a time.
- A **Tabline page** contains zero to ten **Normal file buffers**.
- A **Normal file buffer** appears in opening order in the **Numbered tabline**.

## Example dialogue

> **Dev:** "Should `<leader>3` jump to the third listed buffer overall?"
> **Domain expert:** "No — in the **Numbered tabline**, `<leader>3` jumps to the third **Normal file buffer** on the current **Tabline page**."

## Flagged ambiguities

- "tab" can mean a Neovim tabpage, a visual tabline item, or a buffer selector — resolved: use **Numbered tabline** and **Tabline page** for the buffer selector.
- "vscode mode" was used for editor-integration behavior — resolved: use **VSCode-Neovim**.
