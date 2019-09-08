call plug#begin('~/.vim/plugged')
"Esssentials
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ntpeters/vim-better-whitespace'
Plug 'yggdroot/indentline'
Plug 'roxma/vim-paste-easy'
Plug 'scrooloose/nerdcommenter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-grepper'
Plug 'w0rp/ale'
Plug 'majutsushi/tagbar'
Plug 'mattn/emmet-vim'
Plug 'jpalardy/vim-slime'

"Language plugins
Plug 'ekalinin/dockerfile.vim'
Plug 'plasticboy/vim-markdown'
Plug 'derekwyatt/vim-scala'
Plug 'elzr/vim-json'
Plug 'editorconfig/editorconfig-vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
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
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod=':t'
let g:airline#extensions#tabline#keymap_ignored_filetypes = ['nerdtree']
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:ale_sign_column_always = 1
call matchadd('ColorColumn', '\%81v\S', 100)
let g:vim_json_syntax_conceal=0
let g:vim_markdown_folding_disabled=1
let g:graphql_javascript_tags=["gql", "graphql", "Relay.QL"]
highlight clear SignColumn
highlight GitGutterAdd    guifg=#009900 guibg=#000000 ctermfg=Green ctermbg=Black
highlight GitGutterChange guifg=#bbbb00 guibg=#000000 ctermfg=Yellow ctermbg=Black
highlight GitGutterDelete guifg=#ff2222 guibg=#000000 ctermfg=Red ctermbg=Black
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = 'Δ'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_modified_removed = '±'
let g:netrw_liststyle=3
let g:netrw_banner=0

"Keybindings
nnoremap <leader>t :TagbarToggle<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <leader>1 <Plug>AirlineSelectTab1
nnoremap <leader>2 <Plug>AirlineSelectTab2
nnoremap <leader>3 <Plug>AirlineSelectTab3
nnoremap <leader>4 <Plug>AirlineSelectTab4
nnoremap <leader>5 <Plug>AirlineSelectTab5
nnoremap <leader>6 <Plug>AirlineSelectTab6
nnoremap <leader>7 <Plug>AirlineSelectTab7
nnoremap <leader>8 <Plug>AirlineSelectTab8
nnoremap <leader>9 <Plug>AirlineSelectTab9
nnoremap <leader>- <Plug>AirlineSelectPrevTab
nnoremap <leader>+ <Plug>AirlineSelectNextTab
nnoremap <C-X> :bdelete<CR>
nnoremap <leader>f :Files<cr>
nnoremap <leader>g :GFiles<cr>
"Clear whitespace
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>
