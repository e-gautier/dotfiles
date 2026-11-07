" source vim config
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" sudo write (no tty for sudo in nvim)
function! s:SudoWrite() abort
  let l:tmp = tempname()
  call writefile(getline(1, '$'), l:tmp)
  call system('sudo -k -S cp ' . shellescape(l:tmp) . ' ' . shellescape(expand('%:p')), inputsecret('[sudo] password: ') . "\n")
  call delete(l:tmp)
  if v:shell_error | echoerr 'sudo write failed' | else | setlocal nomodified | endif
endfunction
cnoremap w!! call <SID>SudoWrite()

" clipboard integration
set clipboard+=unnamedplus

" git line blame
autocmd BufEnter * EnableBlameLine

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Start TagBar when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'TagbarOpen' | endif

source ~/.config/nvim/config.lua
