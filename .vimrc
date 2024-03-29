" Misc
colorscheme default
set autoindent
set backspace=indent,eol,start
set complete-=i
set smarttab
set scrolloff=1
set sidescrolloff=5
set display+=lastline
set ruler
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set formatoptions+=j " Delete comment character when joining commented lines
setglobal tags-=./tags tags-=./tags; tags^=./tags;
set wildmenu
set autoread
set relativenumber
set rnu
set tabstop=4
set shiftwidth=4
set expandtab
set ai
set number
set hlsearch
set incsearch
set ignorecase
set smartcase
set gdefault
set hidden
set encoding=utf-8
set updatetime=100
set timeoutlen=1000
set ttimeout
set ttimeoutlen=0
set undodir=~/.vimdid
set undofile
set splitright
set splitbelow
set history=1000
set tabpagemax=50
set viminfo^=!
set sessionoptions-=options
set viewoptions-=options
set laststatus=2
set showtabline=2
call matchadd('ColorColumn', '\%81v\S', 100)
highlight ColorColumn ctermbg=Red ctermfg=Yellow
let g:netrw_liststyle=3
let g:netrw_banner=0

" Keybindings
map <Space> <Leader>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <Leader>l :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>n :bn<CR>
nnoremap <C-X> :bdelete<CR>
" Clear whitespace
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

syntax on
