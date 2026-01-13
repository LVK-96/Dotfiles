" Vim Configuration File, no plugins

" Sane defaults
set nocompatible
filetype plugin indent on
syntax on
set encoding=utf-8
set mouse=a
set number
set relativenumber
set splitbelow
set splitright
set scrolloff=8
set sidescrolloff=8
set nocursorline
set signcolumn=yes
set laststatus=2
set termguicolors
set ignorecase
set smartcase
set hlsearch
set incsearch
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smartindent
set wildmenu
set wildmode=list:longest,full
set backup
set undofile
set history=1000
silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
set undodir=~/.vim/undo//
set path+=** " Search subdirectories for 'gf' and :find

" Keybindings
let mapleader = " "
" Window Navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Leader + Number Tab Switching
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
" Tab/Search Management
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>h :nohlsearch<CR>

" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 3     " 3 = Open file in a new tab
let g:netrw_tabpriority = 1      " Ensure tabs are handled cleanly
let g:netrw_altv = 1
let g:netrw_winsize = 25

" Minimal tabline
set showtabline=2
function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    let s .= (i + 1 == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' ' . (i + 1) . ': '
    let buflist = tabpagebuflist(i + 1)

    let winnr = tabpagewinnr(i + 1)
    let bufname = bufname(buflist[winnr - 1])
    let s .= (bufname == '' ? '[No Name]' : fnamemodify(bufname, ':t')) . ' '
  endfor
  let s .= '%#TabLineFill%T'
  return s
endfunction
set tabline=%!MyTabLine()

" Statusline
set statusline=%f\ %m\ %r\ %h\ %w\ %=\ (%Y)\ [%l/%L,\ %c]

" Solarized light colors
function! s:ApplySolarizedLight()
    set background=light
    highlight clear
    if exists("syntax_on") | syntax reset | endif
    let g:colors_name = "solarized_light"
    " UI Element             | 16-Color Index | GUI Colors (hex)
    " -----------------------|----------------|-------------------------
    highlight Normal           ctermfg=11  ctermbg=15      guifg=#657b83 guibg=#fdf6e3
    highlight CursorLine       cterm=NONE  ctermbg=7                     guibg=#eee8d5
    highlight Visual                       ctermbg=7                     guibg=#eee8d5
    highlight LineNr           ctermfg=14  ctermbg=7       guifg=#93a1a1 guibg=#eee8d5
    highlight CursorLineNr     ctermfg=11  cterm=bold      guifg=#657b83
    highlight Search           ctermfg=15  ctermbg=3       guifg=#fdf6e3 guibg=#b58900
    highlight Todo             ctermfg=5   cterm=bold      guifg=#d33682
    " Syntax Highlighting    | 16-Color Index | GUI Colors (hex)
    " -----------------------|----------------|-------------------------
    highlight Identifier       ctermfg=4                   guifg=#268bd2
    highlight Statement        ctermfg=2                   guifg=#859900
    highlight Type             ctermfg=3                   guifg=#b58900
    highlight Constant         ctermfg=6                   guifg=#2aa198
    highlight Comment          ctermfg=14  cterm=italic    guifg=#93a1a1
    highlight Special          ctermfg=9                   guifg=#cb4b16
    highlight PreProc          ctermfg=9                   guifg=#cb4b16
    " Status & Tabs          | 16-Color Index | GUI Colors (hex)
    " -----------------------|----------------|-------------------------
    highlight StatusLine       ctermbg=0   ctermfg=15      guibg=#073642 guifg=#fdf6e3
    highlight TabLineSel       ctermbg=0   ctermfg=15      guibg=#073642 guifg=#fdf6e3
    highlight TabLine          ctermbg=7   ctermfg=11      guibg=#eee8d5 guifg=#657b83
    highlight TabLineFill      ctermbg=7   ctermfg=7       guibg=#eee8d5 guifg=#eee8d5
    highlight WildMenu         ctermbg=0   ctermfg=15      guibg=#073642 guifg=#fdf6e3
    " Netrw Explorer         | 16-Color Index | GUI Colors (hex)
    " -----------------------|----------------|-------------------------
    highlight NetrwDir         ctermfg=4                   guifg=#268bd2
    highlight NetrwExe         ctermfg=2                   guifg=#859900
    highlight NetrwLink        ctermfg=6                   guifg=#2aa198
    highlight NetrwTreeBar     ctermfg=14                  guifg=#93a1a1
    highlight NetrwList        ctermfg=11                  guifg=#657b83
endfunction
command! SolarizedLight call s:ApplySolarizedLight()
SolarizedLight

" Or set the default dark theme
" set background=dark
" silent! colorscheme default

" Return back to where we were last time
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" Remove trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
