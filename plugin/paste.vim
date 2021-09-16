if exists('g:loaded_nvim_paste') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_paste = 1

command! -nargs=? Paste lua require'nvim-paste'.paste(<f-args>)
command! -nargs=0 Pastebuf lua require'nvim-paste'.pastebuf()
command! -nargs=0 Pastesel lua require'nvim-paste'.pastesel()
command! -nargs=0 Pasteyank lua require'nvim-paste'.pasteyank()
command! -nargs=1 Getpaste lua require'nvim-paste'.getPaste(<f-args>)

