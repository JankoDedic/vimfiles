setlocal tabstop=4
setlocal softtabstop=4 expandtab
setlocal shiftwidth=4
setlocal cindent cinoptions=:0g0N-sE-st0(1s

nnoremap <silent><buffer> <C-]> :LspDefinition<CR>
nnoremap <silent><buffer> K :LspHover<CR>
