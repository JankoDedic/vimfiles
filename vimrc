" Pathogen {{{1

execute pathogen#infect()
syntax on
filetype plugin indent on

" Appearance {{{1

set guicursor+=n-v-c:blinkon0

set guioptions-=m
set guioptions-=T
set guioptions-=r
set guioptions-=L

set t_Co=256
set background=light
colorscheme PaperColor

set cursorline
autocmd InsertEnter * set nocul
autocmd InsertLeave * set cul

if has("gui_running")
  set belloff=all
endif

" from tpope/.vimrc
command! -bar -nargs=0 Bigger  :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)+1','')
command! -bar -nargs=0 Smaller :let &guifont = substitute(&guifont,'\d\+$','\=submatch(0)-1','')
nnoremap <M-,>        :Smaller<CR>
nnoremap <M-.>        :Bigger<CR>

" Basic {{{1

set noswapfile

set timeoutlen=1000 ttimeoutlen=0

set encoding=utf-8
set fileformat=dos

set autoindent
set nonumber
set nobackup
set nohlsearch

" Swap ; and : in Normal, Visual and Operator-pending mode
noremap ; :
noremap : ;

set backspace=indent,eol,start

set tabstop=2
set softtabstop=2 expandtab
set shiftwidth=2

set wildmenu

set listchars=tab:→\ ,trail:·,precedes:«,extends:»
set list

" Searches become case sensitive only if uppercase letter appears
set ignorecase
set smartcase

set foldmethod=syntax
set foldlevelstart=99
let g:fastfold_fold_command_suffixes = []
nnoremap <s-tab> za

set mouse=a

" Type optimizations {{{1

set formatoptions-=r formatoptions-=c formatoptions-=o

" Navigation {{{1

" Scroll faster.
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
vnoremap <C-e> 3<C-e>
vnoremap <C-y> 3<C-y>

" Window resizing
nnoremap <C-h> <C-w><
nnoremap <C-j> <C-w>-
nnoremap <C-k> <C-w>+
nnoremap <C-l> <C-w>>

" Leader commands {{{1

let mapleader="\<Space>"
let maplocalleader="\<Space>"

nnoremap <Leader>ev :edit $MYVIMRC<CR>
nnoremap <Leader>sv :write<CR>:Runtime<CR>

nnoremap <Leader>thl :set background=light<CR>
nnoremap <Leader>thd :set background=dark<CR>

" TODO
" - make use of \ in normal mode
" - semicolon after class, struct, enum etc. closing brace
" - proper namespace closing with a comment (for cpp)

vnoremap <leader>\ :normal A \<CR>gv:EasyAlign /\\/<CR>
vnoremap <leader>d\ :normal $xdiw<CR>

" Buffer navigation {{{1

if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

set wildchar=<Tab> wildmenu wildmode=full
set wildcharm=<C-Z>

" Save if not saved and delete the buffer
nnoremap <Leader>x :bdelete<CR>

" :help restore-cursor
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" File-type specific {{{1

" ftplugin/<filetype>.vim
" Some filetypes are not built-in and need to be defined, as they are here.

autocmd BufRead,BufNewFile *.txt setlocal filetype=txt
autocmd BufRead,BufNewFile *.jsx setlocal filetype=javascript
autocmd BufRead,BufNewFile CMakeLists.txt setlocal filetype=cmake

" Scripts {{{1

function! g:GitRepoRoot()
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    return v:shell_error ? '' : root
endfunction

function! g:ExecuteCmdScript(script)
  execute '!start cmd /C "' . a:script . ' & pause & exit"'
endfunction

function! g:RunCppScript(script)
  let git_repo_root = g:GitRepoRoot()
  call g:ExecuteCmdScript('cd ' . git_repo_root . ' && ' . a:script)
endfunction

nnoremap <leader>i :call RunCppScript('cmake -P ~/vimfiles/scripts/GenerateProjects.cmake')<CR><CR>
" nnoremap <leader>b :call RunCppScript('cmake -P ~/vimfiles/scripts/Build.cmake')<CR><CR>
nnoremap <leader>b :!start /B cmake -P ~/vimfiles/scripts/Build.cmake<CR><CR>
" nnoremap <leader>tt :call RunCppScript('cmake -P ~/vimfiles/scripts/Test.cmake')<CR><CR>
" nnoremap <leader>tt :!start cmd /C "cmake -P ~/vimfiles/scripts/Test.cmake & pause & exit"<CR><CR>
nnoremap <leader>tt :!start /B cmake -P ~/vimfiles/scripts/Test.cmake<CR><CR>
" nnoremap <leader>r :call RunCppScript('cmake -P ~/vimfiles/scripts/Run.cmake')<CR><CR>
nnoremap <leader>r :!start /B cmake -P ~/vimfiles/scripts/Run.cmake<CR><CR>
" nnoremap <leader>vs :call RunCppScript('cmake -P ~/vimfiles/scripts/OpenVisualStudio.cmake')<CR><CR>
nnoremap <leader>vs :!start /B cmake -P ~/vimfiles/scripts/OpenVisualStudio.cmake<CR><CR>

nnoremap <leader>ee :!start explorer .<CR>
nnoremap <Leader>c :silent shell<CR>

" Plugin configuration {{{1
" vim-vinegar {{{2

" NETRW FIX
set nohidden
augroup netrw_buf_hidden_fix
    autocmd!

    " Set all non-netrw buffers to bufhidden=hide
    autocmd BufWinEnter *
                \  if &ft != 'netrw'
                \|     set bufhidden=hide
                \| endif

augroup end

" delimitMate {{{2

let delimitMate_expand_cr = 1

" ctrlp.vim {{{2

let g:ctrlp_show_hidden = 1
let g:ctrlp_use_caching=0
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/](.git|.hg|.svn|.next|out|node_modules|third_party|build|.clangd)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
    \ }

" vim-easy-align {{{2

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" vim-fugitive {{{2

" Automatically close fugitive buffers (so they don't clutter the buffer list)
autocmd BufReadPost fugitive://* set bufhidden=delete

nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gl :0Glog<CR>
nnoremap <leader>gp :Gpush<CR>
nnoremap <leader>gb :Gbrowse<CR>
xnoremap <leader>gb :Gbrowse<CR>

" vim-flagship {{{2

" Recommended settings
set laststatus=2
set showtabline=2
set guioptions-=e

" vim-lsp {{{2

if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '-background-index']},
        \ 'whitelist': ['c', 'cpp', 'h', 'hpp', 'objc', 'objcpp'],
        \ })
endif

let g:lsp_diagnostics_enabled = 0
let g:lsp_highlight_references_enabled = 1

" Preview the found LSP references while hovering
" autocmd FileType qf nnoremap <silent><buffer> j :cn<CR><C-w><C-p>
" autocmd FileType qf nnoremap <silent><buffer> k :cp<CR><C-w><C-p>
" Close the quickfix window after picking an option
autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>

autocmd FileType c,h,cpp,hpp setlocal omnifunc=lsp#complete

" Disable the preview window
set completeopt-=preview

" Close the preview window upon finalizing completion
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" nnoremap <S-f> :LspDocumentFormat<CR>
" vnoremap <S-f> :LspDocumentRangeFormat<CR>
