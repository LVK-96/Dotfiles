call plug#begin('~/.vim/plugged')
" Look
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'itchyny/vim-gitbranch'
Plug 'airblade/vim-gitgutter'
Plug 'machakann/vim-highlightedyank'
Plug 'yggdroot/indentline'
Plug 'ntpeters/vim-better-whitespace'

" Navigation
Plug 'tpope/vim-vinegar'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-grepper'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-rooter'
Plug 'christoomey/vim-tmux-navigator'

" Enhancements
Plug 'andymass/vim-matchup'
Plug 'roxma/vim-paste-easy'
Plug 'scrooloose/nerdcommenter'

" Linting & autocompletion
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

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
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
call plug#end()

" Misc
set relativenumber
set rnu
set tabstop=4
set shiftwidth=4
set expandtab
set ai
set number
set hlsearch
set hidden
set encoding=utf-8
set updatetime=100
set timeoutlen=1000
set ttimeoutlen=0
runtime plugin/grepper.vim
let g:grepper.prompt = 0

" Syntax
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_math = 1
let g:graphql_javascript_tags = ["gql", "graphql", "Relay.QL"]
let g:tex_conceal = ""
set omnifunc=htmlcomplete#CompleteTags
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
au BufNewFile,BufRead Jenkinsfile setf groovy

" Look
set background=dark
set guicursor=
autocmd OptionSet guicursor noautocmd set guicursor=
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set laststatus=2
set showtabline=2
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#shorten_path = 0
let g:lightline#bufferline#unnamed = '[No Name]'
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }
let g:lightline.tabline = {'left': [['buffers']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type = {'buffers': 'tabsel'}
let g:gruvbox_contrast_dark ='hard'
color gruvbox
let g:gruvbox_improved_warnings = 1
let g:ale_sign_column_always = 1
call matchadd('ColorColumn', '\%81v\S', 100)
highlight ColorColumn guibg=#ff2222 ctermbg=Red
highlight clear SignColumn
highlight GitGutterAdd    guifg=#009900  ctermfg=Green
highlight GitGutterChange guifg=#bbbb00  ctermfg=Yellow
highlight GitGutterDelete guifg=#ff2222  ctermfg=Red
highlight GitGutterChangeDelete guifg=#009900 ctermfg=Green
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = 'Δ'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_modified_removed = '±'
let g:netrw_liststyle=3
let g:netrw_banner=0
let g:highlightedyank_highlight_duration = 5000

" Keybindings
nnoremap <leader>t :TagbarToggle<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)
nnoremap <C-X> :bdelete<CR>
nnoremap <leader>f :Files<cr>
nnoremap <leader>g :GFiles<cr>
" Clear whitespace
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>
