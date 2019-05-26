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
color desert
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn', '\%81v\S', 100)

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/syntastic'
call plug#end()
