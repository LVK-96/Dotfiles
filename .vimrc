syntax on
set relativenumber
set rnu
set tabstop=4
set shiftwidth=4
set expandtab
set ai
set number
set hlsearch
set ruler
set autoindent
set smartindent 
set background=dark
set t_Co=256
color desert
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn', '\%81v\S', 100)
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>
let g:airline_theme='raven'
let g:slime_target = "tmux"
au BufNewFile,BufRead Jenkinsfile setf groovy

call plug#begin('~/.vim/plugged')
Plug 'w0rp/ale'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jpalardy/vim-slime'
Plug 'ekalinin/dockerfile.vim'
call plug#end()
