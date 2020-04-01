" Easy setup for developing.
" autocmd VimEnter * edit /Users/Janko/vimfiles/bundle/vim-debugger/plugin/debugger.vim
"       \ | edit /Users/Janko/vimfiles/bundle/vim-debugger/plugin/debugger.py
"       \ | edit /Users/Janko/src/vim-debugger/main.cpp
"       \ | cd /Users/Janko/src/vim-debugger

" Caveat: "Editing" a file sets 'buflisted'. This happens when you jump out of
" a 'nobuflisted' buffer, and then back in (which counts as editing). This
" seems to happen in other plugins, like fugitive's :Gstatus as well.
" https://github.com/vim/vim/issues/715
function! s:CallStackBufReadCmd()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodifiable
  setlocal readonly
endfunction

function! s:VariablesBufReadCmd()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodifiable
  setlocal readonly
endfunction

" TODO: augroup
autocmd BufReadCmd debugger://call_stack call s:CallStackBufReadCmd()
autocmd BufReadCmd debugger://variables call s:VariablesBufReadCmd()

function! g:WriteLinesIntoBuffer(buffer, lines) abort
  let l:bufnr = bufadd(a:buffer)
  call bufload(l:bufnr)
  call setbufvar(l:bufnr, '&modifiable', 1)
  call setbufvar(l:bufnr, '&readonly', 0)
  call deletebufline(l:bufnr, 1, '$')
  " call setbufline(l:bufnr, 1, a:lines)
  call appendbufline(l:bufnr, 0, a:lines)
  call setbufvar(l:bufnr, '&modifiable', 0)
  call setbufvar(l:bufnr, '&readonly', 1)
endfunction

" set signcolumn=yes

" TODO: Use sign groups. You'll need a breakpoint group for deleting all
" breakpoint signs at once (to match the lldb command).
sign define breakpoint text=\  texthl=ErrorMsg
sign define program_counter text==> texthl=QuickFixLine
sign define breakpoint_and_program_counter text==> texthl=ErrorMsg
sign define selected_frame linehl=IncSearch

" Initialize at startup. Debugger is always running.
execute 'py3file ' . expand('<sfile>:p:r') . '.py'

function! g:ShowHideCallStack()
  let l:winnr = bufwinnr('debugger://call_stack')
  if l:winnr == -1
    below 5new
    set nocursorline
    buffer debugger://call_stack
    wincmd p
  else
    execute l:winnr . 'wincmd c'
  endif
endfunction

function! g:ShowHideVariables()
  let l:winnr = bufwinnr('debugger://variables')
  if l:winnr == -1
    rightbelow 60vnew
    " TODO: Make this clean so it affects only this window and this buffer.
    " Looks like it's local to window from the documentation, but still.
    " vim-orgmode uses setlocal in indent/ directory somehow.
    " https://github.com/jceb/vim-orgmode/blob/ce17a40108a7d5051a3909bd7c5c94b0b5660637/indent/org.vim#L10
    set foldmethod=indent
    buffer debugger://variables
    wincmd p
  else
    execute l:winnr . 'wincmd c'
  endif
endfunction

nnoremap <M-r> :py3 debugger.start()<CR>
nnoremap <M-c> :py3 debugger.continue_()<CR>
nnoremap <M-s> :py3 debugger.stop()<CR>
nnoremap <M-j> :py3 debugger.lower_frame()<CR>
nnoremap <M-k> :py3 debugger.higher_frame()<CR>
nnoremap <M-l> :py3 debugger.step_over()<CR>
nnoremap <M-i> :py3 debugger.step_into()<CR>
nnoremap <M-o> :py3 debugger.step_out()<CR>
nnoremap <M-p> :py3 debugger.toggle_breakpoint_at_current_line()<CR>
nnoremap <M-m> :silent call g:ShowHideCallStack()<CR>
nnoremap <M-n> :silent call g:ShowHideVariables()<CR>
