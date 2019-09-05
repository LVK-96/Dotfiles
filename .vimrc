set relativenumber
set rnu
set tabstop=4
set shiftwidth=4
set expandtab
set ai
set number
set hlsearch
set hidden
set background=dark
au BufNewFile,BufRead Jenkinsfile setf groovy
let g:slime_target = "tmux"

color desert
let g:airline_theme='raven'
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn', '\%81v\S', 100)
let g:netrw_banner=0

nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'jpalardy/vim-slime'
Plug 'mattn/emmet-vim'
Plug 'w0rp/ale'
Plug 'roxma/vim-paste-easy'
Plug 'easymotion/vim-easymotion'
Plug 'ntpeters/vim-better-whitespace'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ekalinin/dockerfile.vim'
Plug 'plasticboy/vim-markdown'
Plug 'derekwyatt/vim-scala'
Plug 'elzr/vim-json'
Plug 'mxw/vim-jsx'
Plug 'editorconfig/editorconfig-vim'
Plug 'pangloss/vim-javascript'
call plug#end()
