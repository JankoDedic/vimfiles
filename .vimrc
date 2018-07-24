" Loading plugins ============================================================

execute pathogen#infect()
syntax on
filetype plugin indent on

" Appearance =================================================================

set guifont=Monaco:h14:cANSI

set columns=90 lines=30
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

set tabstop=4
set softtabstop=4 expandtab
set shiftwidth=4

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

" Leader Commands ==============================================================

let mapleader="\<Space>"
let maplocalleader="\<Space>"

nnoremap <Leader>ev :e $MYVIMRC<CR>
nnoremap <Leader>sv :w!<CR>:so $MYVIMRC<CR>

nnoremap <Leader>thl :set background=light<CR>
			\ :highlight ColorColumn ctermbg=Gray guibg=Gray<CR>
nnoremap <Leader>thd :set background=dark<CR>
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

nnoremap <C-T> :CtrlPTag<CR>
