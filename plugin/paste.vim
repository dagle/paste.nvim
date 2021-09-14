if exists('g:loaded_nvim_paste') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_paste = 1

command! -nargs=* Paste lua require'nvim-paste'.paste([[<args>]])
command! -nargs=* Pastebuf lua require'nvim-paste'.pastebuf()
command! -nargs=* Pastesel lua require'nvim-paste'.pastesel()
command! -nargs=* Pasteyank lua require'nvim-paste'.pasteyank()
