let g:ale_linters = {"python": ["pylint", "mypy", "black"]}
let g:ale_fixers = {"python": ["black", "autoimport", "isort"]}
let g:ale_python_isort_options = "--profile black"
let g:ale_python_autoimport_options = "--ignore-init-modules"
" auto apply ALE fix on save
let g:ale_fix_on_save = 1

