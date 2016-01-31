" jquery-doc.vim - Browse jQuery API doc
" Author:       Luca Pette <lucapette@gmail.com>
" Version:      0.2

if exists("g:loaded_jquery_doc")
  finish
endif
let g:loaded_jquery_doc = 1

if !exists('g:jquery_doc_command')
    let g:jquery_doc_command='xdg-open'
endif

command! -narg=1 JQueryDoc call jquerydoc#search(<q-args>)
