" source vim config
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" clipboard integration
set clipboard+=unnamedplus

" git line blame
autocmd BufEnter * EnableBlameLine

