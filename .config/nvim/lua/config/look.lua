local function statusline()
    local function current_git_branch()
        fugitive_statusline_str = vim.fn['fugitive#statusline']()
        if fugitive_statusline_str ~= "" then
            _, branch = fugitive_statusline_str:match("(Git%()(%a+)")
            return branch
        end
        return ""
    end

    vim.o.statusline = ''
    vim.o.statusline = vim.o.statusline .. current_git_branch()
    vim.o.statusline = vim.o.statusline .. '%='
    vim.o.statusline = vim.o.statusline .. ' %y'
    vim.o.statusline = vim.o.statusline .. ' %{&fileencoding?&fileencoding:&encoding}'
    vim.o.statusline = vim.o.statusline .. '[%{&fileformat}]'
    vim.o.statusline = vim.o.statusline .. ' %p%%'
    vim.o.statusline = vim.o.statusline .. ' %l:%c'
end

local function theme()
    vim.o.background = 'light'
    vim.cmd('colorscheme solarized8')
end

function look()
    vim.o.termguicolors = true
    vim.cmd('highlight Comment cterm=italic gui=italic')
    vim.cmd('call matchadd("ColorColumn", "\\%120v\\S", 100)')
    vim.cmd('highlight ColorColumn ctermbg=red ctermfg=white')
    vim.g.netrw_liststyle = 3
    vim.g.netrw_fastbrowse = 0
    vim.cmd('autocmd FileType netrw setl bufhidden=wipe')
    vim.g.netrw_banner = 0
    vim.g.netrw_bufsettings = 'noma nomod renu nobl nowrap ro'
    vim.g.highlightedyank_highlight_duration = 1500
    vim.g.buftabline_numbers = 2
    vim.g.buftabline_indicators = 1
    vim.cmd('hi link BufTabLineActive TablineSel')

    statusline()
    theme()
end

