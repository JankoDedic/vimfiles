" Loading plugins ============================================================

execute pathogen#infect()
syntax on
filetype plugin indent on

" Appearance =================================================================

set guifont=Monaco:h14:cANSI

" set columns=90 lines=30
set guicursor+=n-v-c:blinkon0

set guioptions-=m
set guioptions-=T
set guioptions-=r
set guioptions-=L

set t_Co=256
let g:ayucolor="mirage"
colorscheme ayu
" set background=dark

set colorcolumn=80
highlight ColorColumn ctermbg=Gray guibg=Gray

set cursorline
autocmd InsertEnter * set nocul
autocmd InsertLeave * set cul

" Basic ======================================================================

set noswapfile

set timeoutlen=1000 ttimeoutlen=0
set laststatus=2

set encoding=utf-8
set fileformat=dos

set autoindent
set nonumber
set nobackup
set nohlsearch

nnoremap ; :
nnoremap : ;

vnoremap ; :
vnoremap : ;

set backspace=indent,eol,start

set tabstop=2
set softtabstop=2 expandtab
set shiftwidth=2

set wildmenu

set listchars=tab:→\ ,trail:·,precedes:«,extends:»
set list

" Type optimizations ===========================================================

set formatoptions-=r formatoptions-=c formatoptions-=o

" Code navigation optimizations ================================================

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

" Leader Commands ==============================================================

let mapleader="\<Space>"
let maplocalleader="\<Space>"

nnoremap <Leader>ev :e ~/vimfiles/.vimrc<CR>
nnoremap <Leader>sv :w!<CR>:so $MYVIMRC<CR>

nnoremap <Leader>thl :let g:ayucolor="light"<CR>:colorscheme ayu<CR>
			\ :highlight ColorColumn ctermbg=Gray guibg=Gray<CR>
nnoremap <Leader>thm :let g:ayucolor="mirage"<CR>:colorscheme ayu<CR>
			\ :highlight ColorColumn ctermbg=Gray guibg=Gray<CR>
nnoremap <Leader>thd :let g:ayucolor="dark"<CR>:colorscheme ayu<CR>
			\ :highlight ColorColumn ctermbg=Gray guibg=Gray<CR>

" Buffer Navigation ============================================================

if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

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

set wildchar=<Tab> wildmenu wildmode=full
set wildcharm=<C-Z>

" Save if not saved and delete the buffer
nnoremap <Leader>x :write<CR>:bdelete<CR>

" Plugin Configuration =======================================================

" delimitMate
" Second argument is an expression, that's why it's in quotes
inoremap <expr> <CR> delimitMate#WithinEmptyPair() ? "<CR><Esc>O" : "<CR>"

" File-type specific =========================================================

" ftplugin/<filetype>.vim
" Some filetypes are not built-in and need to be defined, as they are here.

autocmd BufRead,BufNewFile *.txt setlocal filetype=txt
autocmd BufRead,BufNewFile *.jsx setlocal filetype=javascript
autocmd BufRead,BufNewFile CMakeLists.txt setlocal filetype=cmake

function! g:GitRepoRoot()
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    return v:shell_error ? '' : root
endfunction

function! g:RunCppScript(script_name)
    let git_root = g:GitRepoRoot()
    let separator = strlen(git_root) > 0 ? '/' : ''
    execute '!start cmd /k "py '
        \ . g:GitRepoRoot() . separator . 'scripts/'
        \ . a:script_name . '.py" && pause && exit'
endfunction

nnoremap <leader>r :call RunCppScript('run')<CR><CR>
nnoremap <leader>b :call RunCppScript('build')<CR><CR>
nnoremap <leader>tt :call RunCppScript('test')<CR><CR>

nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gw :Gwrite<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gc :Gcommit<CR>
nnoremap <leader>gl :Glog<CR>

" Add a space and then dashes to the end of the line (79)
function! g:EndLineWithDashes()
    let current_line = getline(".")
    let current_line_length = strlen(current_line)
    if current_line_length < 78
        call setline(line("."), current_line . ' ')
        let num_dashes = 79 - current_line_length - 1
        execute "normal " . num_dashes . "A-"
    endif
endfunction

nnoremap <leader>- I//<Esc>:call g:EndLineWithDashes()<CR>

" - semicolon after class, struct, enum etc. closing brace
" also proper namespace closing with a comment

" -----------------------------------------------------------------------------
" Add backslashes at column 79 of every line of visual selection

function! g:AddBackslashes()
    let saved_virtualedit = &virtualedit
    set virtualedit=all
    execute 'normal 79|i\'
    execute "set virtualedit=" . saved_virtualedit
endfunction

vnoremap <leader>as :call g:AddBackslashes()<CR>

function! g:RemoveBackslashes()
    execute 'normal $xdiw'
endfunction

vnoremap <leader>rs :call g:RemoveBackslashes()<CR>

let g:ctrlp_show_hidden = 1
let g:ctrlp_use_caching=0
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/](.git|.hg|.svn|out|node_modules)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
    \ }
