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
let g:airline_theme='raven'

let g:slime_target = "tmux"

au BufNewFile,BufRead Jenkinsfile setf groovy

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe = 'npm run lint --'

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jpalardy/vim-slime'
call plug#end()
