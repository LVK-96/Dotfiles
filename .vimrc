call plug#begin('~/.vim/plugged')
" Look
Plug 'noahfrederick/vim-hemisu'
Plug 'chriskempson/base16-vim'
Plug 'ap/vim-buftabline'
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
Plug 'tpope/vim-fugitive'
Plug 'janko/vim-test'
Plug 'tpope/vim-dispatch'
Plug 'benmills/vimux'
Plug 'tpope/vim-surround'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-commentary'
Plug 'breuckelen/vim-resize'
Plug 'junegunn/vim-easy-align'

" Linting & autocompletion
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"Language plugins
Plug 'derekwyatt/vim-scala'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim'
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'ekalinin/dockerfile.vim'
Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'jparise/vim-graphql'
Plug 'elzr/vim-json'
Plug 'stephpy/vim-yaml'
Plug 'cespare/vim-toml'
Plug 'lervag/vimtex'
call plug#end()

" Misc
let g:grepper = {
    \ 'tools': ['rg', 'git', 'ag'],
    \ }
let g:grepper.operator = {
    \ 'tools': ['rg', 'git', 'ag'],
    \ 'rg': {
    \   'grepprg':    'rg -H --no-heading --vimgrep --multiline --hidden',
    \ }
    \ }
let test#strategy = "dispatch"

" Syntax
let g:vim_json_syntax_conceal = 0
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_math = 1
let g:graphql_javascript_tags = ["gql", "graphql", "Relay.QL"]
let g:tex_conceal = ""
au BufNewFile,BufRead Jenkinsfile setf groovy
au BufRead,BufNewFile *.sbt set filetype=scala
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
let g:vimtex_view_method = 'zathura'
let g:mkdp_refresh_slow = 1
let g:mkdp_browser = 'qutebrowser'

" Look
set background=dark
colorscheme hemisu
hi CursorLineNr gui=underline cterm=underline ctermfg=grey

let g:tagbar_case_insensitive = 1
let g:tagbar_compact = 1
let g:tagbar_show_linenumbers = 2
let g:tagbar_sort = 1
let g:tagbar_width = 80

let g:ale_sign_column_always = 1

call matchadd('ColorColumn', '\%81v\S', 100)
highlight ColorColumn ctermbg=Red ctermfg=Yellow

let g:netrw_liststyle=3
let g:netrw_fastbrowse=0
autocmd FileType netrw setl bufhidden=wipe
let g:netrw_banner=0
let g:netrw_bufsettings = 'noma nomod renu nobl nowrap ro'

let g:highlightedyank_highlight_duration = 3000

let g:buftabline_numbers=2
let g:buftabline_indicators=1
hi link BufTabLineActive Tabline

" Statusline
function! Current_git_branch()
    let l:branch = split(fugitive#statusline(),'[()]')
    if len(l:branch) > 1
         return remove(l:branch, 1)
    endif
    return ""
endfunction

hi StatusLine guibg=#000000 ctermbg=black
hi StatusLineNC guibg=#000000 ctermbg=black
set statusline=
set statusline +=\ %{Current_git_branch()}
set statusline+=%=
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c

" Keybindings
" Prompt for a command to run
map <Leader>vr :VimuxPromptCommand<CR>

" Run last command executed by VimuxRunCommand
map <Leader>vl :VimuxRunLastCommand<CR>

" Inspect runner pane
map <Leader>vi :VimuxInspectRunner<CR>

" Close vim tmux runner opened by VimuxRunCommand
map <Leader>vq :VimuxCloseRunner<CR>

" Interrupt any command running in the runner pane
map <Leader>vx :VimuxInterruptRunner<CR>

" Zoom the runner pane (use <bind-key> z to restore runner pane)
map <Leader>vz :call VimuxZoomRunner()<CR>
nnoremap <leader>t :TagbarToggle<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nmap <leader>1 <Plug>BufTabLine.Go(1)
nmap <leader>2 <Plug>BufTabLine.Go(2)
nmap <leader>3 <Plug>BufTabLine.Go(3)
nmap <leader>4 <Plug>BufTabLine.Go(4)
nmap <leader>5 <Plug>BufTabLine.Go(5)
nmap <leader>6 <Plug>BufTabLine.Go(6)
nmap <leader>7 <Plug>BufTabLine.Go(7)
nmap <leader>8 <Plug>BufTabLine.Go(8)
nmap <leader>9 <Plug>BufTabLine.Go(9)
nmap <leader>0 <Plug>BufTabLine.Go(10)
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>n :bn<CR>
nnoremap <C-X> :bdelete<CR>
nnoremap <leader>f :Files<cr>
nnoremap <leader>F :GFiles<cr>
nnoremap <leader>g :Grepper -tool rg<cr>
nnoremap <leader>G :Grepper -tool git<cr>
nnoremap <leader>w :Grepper -tool rg -cword -noprompt<cr>
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>
map <F5> :StripWhitespace<cr>

"
" coc.nvim config https://github.com/neoclide/coc.nvim
"
set cmdheight=1

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <leader>d <Plug>(coc-range-select)
xmap <silent> <leader>d <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

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
set clipboard=unnamedplus
nnoremap <Leader>l :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
autocmd BufWritePre * :StripWhitespace
