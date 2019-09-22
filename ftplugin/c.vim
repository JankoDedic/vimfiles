setlocal tabstop=4
setlocal softtabstop=4 expandtab
setlocal shiftwidth=4
setlocal cindent cinoptions=:0,l1,g0,N-s,E-s,t0,(s

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

setlocal formatprg=clang-format
