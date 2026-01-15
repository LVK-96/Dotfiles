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

set background=dark
silent! colorscheme industry

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
