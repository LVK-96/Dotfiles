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
Plug 'morhetz/gruvbox'

"Language plugins
Plug 'ekalinin/dockerfile.vim'
Plug 'plasticboy/vim-markdown'
Plug 'derekwyatt/vim-scala'
Plug 'elzr/vim-json'
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
set guicursor=
autocmd OptionSet guicursor noautocmd set guicursor=
set omnifunc=htmlcomplete#CompleteTags
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
au BufNewFile,BufRead Jenkinsfile setf groovy
let g:slime_target = "tmux"
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let g:gruvbox_contrast_dark='hard'
color gruvbox
let g:gruvbox_improved_warnings=1
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'
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
highlight GitGutterAdd    guifg=#009900  ctermfg=Green
highlight GitGutterChange guifg=#bbbb00  ctermfg=Yellow
highlight GitGutterDelete guifg=#ff2222  ctermfg=Red
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
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>+ <Plug>AirlineSelectNextTab
nnoremap <C-X> :bdelete<CR>
nnoremap <leader>f :Files<cr>
nnoremap <leader>g :GFiles<cr>
"Clear whitespace
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

