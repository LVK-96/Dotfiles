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
color evening
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn', '\%81v\S', 100)
let g:airline_theme='simple'
au BufNewFile,BufRead Jenkinsfile setf groovy

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()
