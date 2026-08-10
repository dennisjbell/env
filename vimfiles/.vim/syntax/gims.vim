if exists('b:current_syntax') | finish|  endif

syn region gimsString start=+'+ end=+'+ skip=+\\\\\|\\'+ contains= oneline
syn region gimsString start=+"+ end=+"+ skip=+\\\\\|\\"+ contains= oneline
syn match gimsComment '\s*%.*$'

syntax keyword gimsKeyword let
syntax keyword gimsKeyword goto
syntax keyword gimsKeyword out
syntax keyword gimsKeyword if
syntax keyword gimsKeyword elseif
syntax keyword gimsKeyword else
syntax keyword gimsKeyword endif
syntax keyword gimsKeyword while
syntax keyword gimsKeyword endwhile
syntax keyword gimsKeyword break
syntax keyword gimsKeyword find
syntax keyword gimsKeyword all
syntax keyword gimsKeyword set
syntax keyword gimsKeyword auto
syntax keyword gimsKeyword or
syntax keyword gimsKeyword and
syntax keyword gimsKeyword localprocedure
syntax keyword gimsKeyword procedure
syntax keyword gimsKeyword endprocedure

syntax match gimsNumber '\<\d\+\(\.\d\+\)\?\>'
syntax match gimsVariable '$[a-zA-Z][a-zA-Z0-9_]*'
syntax match gimsLabel '\<[a-zA-Z][a-zA-Z-0-9_]*:\>'

hi def link gimsKeyword Statement
hi def link gimsComment Comment
hi def link gimsString String
hi def link gimsNumber Number
hi def link gimsVariable Structure
hi def link gimsLabel Structure

let b:current_syntax = 'gims'
