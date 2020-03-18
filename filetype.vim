if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  autocmd! BufRead,BufNewFile CMakeLists.txt setfiletype cmake
augroup END

