setlocal tabstop=4
setlocal softtabstop=4 expandtab
setlocal shiftwidth=4
" TODO: How to make (0 not align to parentheses (and just do nothing) ???
setlocal cindent cinoptions=:0,l1,g0,N-s,E-s,t0,(s
setlocal textwidth=120

function! PreviewWindowOpened()
  for nr in range(1, winnr('$'))
    if getwinvar(nr, "&pvw") == 1
      " found a preview
      return 1
    endif
  endfor
  return 0
endfunction

nnoremap <silent><buffer> <C-]> :LspDefinition<CR>
nnoremap <silent><buffer><expr> K PreviewWindowOpened() ? ":pclose\<CR>" : ":LspHover\<CR>"

iabbrev <buffer> /// // ============================================================================

map \ <Plug>(operator-macroify)
call operator#user#define('macroify', 'Macroify')
function! Macroify(motion_wiseness)
  let l:range = line("'[") . "," . (line("']") - 1)
  execute l:range . 'normal A \'
  execute l:range . 'EasyAlign /\\/'
endfunction

map g\ <Plug>(operator-demacroify)
call operator#user#define('demacroify', 'Demacroify')
function! Demacroify(motion_wiseness)
  '[,']substitute/\s*\\$//g
endfunction

" Disable vim-lsp signs
setlocal signcolumn=no

setlocal colorcolumn=80
