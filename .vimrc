" Pathogen {{{1

execute pathogen#infect()
syntax on
filetype plugin indent on

" Appearance {{{1

set guifont=Consolas:h14:cANSI
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

" Basic {{{1

set noswapfile

set timeoutlen=1000 ttimeoutlen=0

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

" Searches become case sensitive only if uppercase letter appears
set ignorecase
set smartcase

set foldmethod=syntax
set foldlevelstart=99
let g:fastfold_fold_command_suffixes = []
nnoremap <s-tab> za

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

nnoremap <Leader>ev :e ~/vimfiles/.vimrc<CR>
nnoremap <Leader>sv :w<CR>:so $MYVIMRC<CR>:filetype detect<CR>
" TODO: replace the above with vim-scriptease :Runtime which does it for you

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

" function! g:RunCppScript(script_name)
"     let separator = strlen(git_root) > 0 ? '/' : ''
"     execute '!start cmd /k "py '
"         \ . g:GitRepoRoot() . separator . 'scripts/'
"         \ . a:script_name . '.py" && pause && exit'
" endfunction

function! g:RunCppScript(script_name)
  let git_repo_root = g:GitRepoRoot()
  let project_name = reverse(split(git_repo_root, '/'))[0]
  let vcpkg_toolchain = 'C:\Users\Janko\vcpkg\scripts\buildsystems\vcpkg.cmake'
  let g:cpp_scripts = {
    \ 'generate': 'rmdir /S /Q build & cd ' . git_repo_root
    \   . ' && mkdir build && cd build'
    \   . ' && mkdir x64-windows-ninja && cd x64-windows-ninja'
    \   . ' && cmake ..\..'
    \   . ' -G Ninja'
    \   . ' -D CMAKE_EXPORT_COMPILE_COMMANDS=ON'
    \   . ' -D CMAKE_TOOLCHAIN_FILE=' . vcpkg_toolchain
    \   . ' && cd ..\..'
    \   . ' && mklink /H compile_commands.json build\x64-windows-ninja\compile_commands.json'
    \   . ' && cd build'
    \   . ' && mkdir x64-windows-vs && cd x64-windows-vs'
    \   . ' && cmake ..\..'
    \   . ' -G "Visual Studio 16 2019" -A x64'
    \   . ' -D CMAKE_TOOLCHAIN_FILE=' . vcpkg_toolchain,
    \ 'build': 'cmake --build ' . git_repo_root . '/build/x64-windows-ninja',
    \ 'test': git_repo_root . '\build\x64-windows-ninja\' . project_name . '-tests.exe',
    \ 'run': git_repo_root . '\build\x64-windows-ninja\' . project_name . '-main.exe',
    \ 'ide': 'start build\x64-windows-vs\' . project_name . '.sln & exit',
    \ }
  " let g:cpp_scripts = {
  "     \ 'init': 'rmdir /S /Q out & cd ' . git_repo_root
  "     \  . ' && mkdir out && cd out & cmake ..'
  "     \  . ' -G"Visual Studio 15 2017 Win64"'
  "     \  . ' -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake',
  "     \ 'run': git_repo_root . '/out/Debug/' . project_name . '-main.exe',
  "     \ 'build': 'cmake --build ' . git_repo_root . '/out'
  "     \        . ' -- /nologo /verbosity:quiet',
  "     \ 'test': git_repo_root . '/out/Debug/' . project_name . '-tests.exe',
  "     \ 'ide': 'start out\' . project_name . '.sln & exit',
  "     \ }
  execute '!start cmd /k ' . g:cpp_scripts[a:script_name] . ' & pause & exit'
endfunction

nnoremap <leader>i :call RunCppScript('generate')<CR><CR>
nnoremap <leader>b :call RunCppScript('build')<CR><CR>
nnoremap <leader>tt :call RunCppScript('test')<CR><CR>
nnoremap <leader>r :call RunCppScript('run')<CR><CR>
nnoremap <leader>vs :call RunCppScript('ide')<CR><CR>

nnoremap <leader>ee :!start explorer .<CR>
nnoremap <leader>c :!start cmd<CR>

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

" Second argument is an expression, that's why it's in quotes
inoremap <expr> <CR> delimitMate#WithinEmptyPair() ? "<CR><Esc>O" : "<CR>"

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
nnoremap <leader>gl :Glog<CR>
nnoremap <leader>gp :Gpush<CR>
nnoremap <leader>gb :silent Gbrowse<CR>

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

" Automatically close quickfix and location lists when you make a choice
" https://stackoverflow.com/questions/21321357
autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>

