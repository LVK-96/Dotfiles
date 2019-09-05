call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'jpalardy/vim-slime'
Plug 'mattn/emmet-vim'
Plug 'w0rp/ale'
Plug 'roxma/vim-paste-easy'
Plug 'easymotion/vim-easymotion'
Plug 'ntpeters/vim-better-whitespace'
Plug 'majutsushi/tagbar'
Plug 'yggdroot/indentline'
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
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'jparise/vim-graphql'
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'
call plug#end()

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
set encoding=utf-8
set updatetime=100
set timeoutlen=1000
set ttimeoutlen=0
set t_Co=256
set guicursor=
autocmd OptionSet guicursor noautocmd set guicursor=
set omnifunc=htmlcomplete#CompleteTags
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
au BufNewFile,BufRead Jenkinsfile setf groovy
let g:slime_target = "tmux"

color desert
let g:airline_theme='raven'
let g:airline#extensions#ale#enabled = 1
let g:ale_sign_column_always = 1
call matchadd('ColorColumn', '\%81v\S', 100)
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1
let NERDTreeShowHidden=1
let g:vim_json_syntax_conceal=0
highlight clear SignColumn
highlight GitGutterAdd    guifg=#009900 guibg=#000000 ctermfg=Green ctermbg=Black
highlight GitGutterChange guifg=#bbbb00 guibg=#000000 ctermfg=Yellow ctermbg=Black
highlight GitGutterDelete guifg=#ff2222 guibg=#000000 ctermfg=Red ctermbg=Black
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = 'Δ'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_modified_removed = '±'
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

map <C-n> :NERDTreeToggle<CR>
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>
map <F8> :TagbarToggle<CR>
