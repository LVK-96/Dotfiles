function sane_defaults()
    vim.opt.autoindent = true
    vim.opt.backspace = { "indent", "eol", "start" }
    vim.opt.complete:remove("i")
    vim.opt.smarttab = true
    vim.opt.scrolloff = 1
    vim.opt.sidescrolloff = 5
    vim.opt.display:append("lastline")
    vim.opt.ruler = true
    vim.opt.listchars = { tab = "> ", trail = "-", extends = ">", precedes = "<", nbsp = "+" }
    vim.opt.formatoptions:append("j")
    vim.opt.tags:remove("./tags")
    vim.opt.tags:remove("./tags;")
    vim.opt.tags:prepend("./tags")
    vim.opt.wildmenu = true
    vim.opt.autoread = true
    vim.opt.relativenumber = true
    vim.opt.rnu = true
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.ai = true
    vim.opt.number = true
    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.gdefault = true
    vim.opt.hidden = true
    vim.opt.encoding = "utf-8"
    vim.opt.updatetime = 100
    vim.opt.timeoutlen = 1000
    vim.opt.ttimeout = true
    vim.opt.ttimeoutlen = 0
    vim.opt.undodir = vim.fn.expand("~/.vimdid")
    vim.opt.undofile = true
    vim.opt.splitright = true
    vim.opt.splitbelow = true
    vim.opt.history = 1000
    vim.opt.tabpagemax = 50
    vim.opt.viminfo:append("!")
    vim.opt.sessionoptions:remove("options")
    vim.opt.viewoptions:remove("options")
    vim.opt.laststatus = 2
    vim.opt.clipboard = "unnamedplus"
    vim.opt.mouse = "a"
end
