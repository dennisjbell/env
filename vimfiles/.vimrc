set nocompatible
syntax on
filetype off
set runtimepath^=~/djbell-env/vimfiles/.vim

"Use Pathogen to manage plugins
call pathogen#infect()
call pathogen#helptags()

" Whitespace stuff
set nowrap
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab
set autoindent
set smartindent

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Tab completion
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc

" Tab Navigation
"map  <C-tab> :tabnext<CR>
"map!  <C-tab> <ESC>:tabnext<CR>li
"map  <C-S-tab> :tabprevious<CR>
"map!  <C-S-tab> <ESC>:tabprevious<CR>li

" Layout
set laststatus=2
set number
set splitbelow
set splitright
set showcmd
set cmdheight=2

" Status Line
set statusline=   " clear the statusline for when vimrc is reloaded
"set statusline+=%-3.3n\                      " buffer number
set statusline+=%h%m%r%w                     " flags
set statusline+=%f\                          " file name
set statusline+=%{exists('g:loaded_fugitive')?fugitive#statusline():''}\  " keep the space at the end
set statusline+=[%{strlen(&ft)?&ft:'none'},  " filetype
set statusline+=%{strlen(&fenc)?&fenc:&enc}, " encoding
set statusline+=%{&fileformat}]              " file format
set statusline+=%=                           " right align
set statusline+=%{synIDattr(synID(line('.'),col('.'),1),'name')}\  " highlight
set statusline+=0x%-8B\                      " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset


" Behaviour
set magic
set formatoptions=cq2
set diffopt=filler,iwhite
set errorbells
set novisualbell
set nowrap
set sidescroll=1
set linebreak                                "when wrap is on, will wrap at appropriate positions"
set wrapscan                                 "searches wrap around EOF
set whichwrap=27                             "bitwize representation of "b,s,<,>,[,]"
set clipboard=unnamed
set encoding=utf-8
set listchars=tab:⦙\ ,trail:∙,extends:⊳,precedes:⊲,nbsp:◦
set listchars+=eol:↩︎ "if you want to see EOLs
set list
" Remember last location in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
endif

" MakeGreen
nmap  <silent> <Leader>m <Plug>MakeGreen

" Tags
set tags=./tags,tags;/
map <Leader>rt :!ctags --extra=+f -R *<CR><CR>
nmap <silent> <Leader>RT:!ctags -R --languages=Ruby,C,C++,Javascript,Coffeescript --langmap='ruby:+.rake.builder.haml'<CR>

syntax on
filetype on
filetype plugin on
filetype indent on
set omnifunc=syntaxcomplete#Complete

" Scheme
set colorcolumn=80
set background=dark
color termschool
  " Previously:
  "   cobalt2
  "   base16-ateliersulphurpool
  "   vividchalk
  "   navajo-midnight
highlight ColorColumn ctermbg=1
let html_use_css=1
let html_output_xhtml=1

" Backups
set backup
set backupcopy=yes  "backup to copy, save over original -- for programs that watch for changes to original files
set backupdir=~/tmp/vim-backups,/tmp/vim-backups,.

" Commands
set shell=/bin/bash
let g:ruby_doc_command='open'
let g:jquery_doc_command='open'

" Lisp
let g:lisp_rainbow = 1

" Slime config
let g:slime_target = "tmux"

" Ruby
if v:version >= 801
  "set rubydll=/Users/dbell/.rvm/rubies/ruby-2.4.1/lib/libruby.2.4.1.dylib
  set rubydll=/Users/dennis.bell/.rvm/rubies/ruby-3.1.2/lib/libruby.3.1.dylib
endif

" Rails
let g:rails_level = 3
let g:rails_menu = 2

" Crystal
let g:crystal_auto_format = 1

" Golang
let g:go_version_warning = 0

" ZoomWin configuration
map <Leader>z :ZoomWin<CR>

" NERDTree configuration
let g:NERDTreeWinSize=20
let NERDTreeIgnore=['\.rbc$', '\~$', '^\..*\.sw.$']
let NERDTreeShowHidden=1
let NERDTreeSortOrder=[]
nmap <C-E> :NERDTreeTabsToggle<CR>
nmap <C-^> :NERDTreeFind<CR>
"autocmd VimEnter * NERDTree
autocmd BufEnter * NERDTreeMirror
autocmd BufWinEnter * NERDTreeMirror

" Neocomplete
"let g:neocomplete#enable_at_startup = 1

" Command-T configuration
"let g:CommandTMaxHeight=20
"nmap <C-L> :CommandT<CR>
"imap <C-L> <ESC>:CommandT<CR>

function s:setupWrapping()
  set ft=text
  set wrap
  set wm=2
  set textwidth=78
  set formatoptions+=t
endfunction

function s:setupMarkup()
  call s:setupWrapping()
  set ft=markdown
  map <buffer> <Leader>p :Mm <CR>
endfunction

" perl, make and python use real tabs
au FileType perl                                     set noexpandtab
au FileType make                                     set noexpandtab
au FileType python                                   set noexpandtab

" add yaml stuffs
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldlevelstart=50
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_lint_on_text_changed = 'always'

" Thorfile, Rakefile and Gemfile are Ruby
au BufRead,BufNewFile {Gemfile,Rakefile,Thorfile,config.ru}    set ft=ruby

" md, markdown, and mk are markdown and define buffer-local preview
au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn} call s:setupMarkup()

au BufRead,BufNewFile *.txt call s:setupWrapping()
au BufRead,BufNewFile {README,Readme} call s:setupWrapping()

" Turn on spelling for git commits
autocmd FileType gitcommit setlocal spell

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Unimpaired configuration
" Bubble single lines
nmap <C-M-Up> [e
nmap <C-M-Down> ]e
" Bubble multiple lines
vmap <C-M-Up> [egv
vmap <C-M-Down> ]egv

" Use modeline overrides
set modeline
set modelines=10

" indentLine
let g:indentLine_color_term = 239
let g:indentLine_char = '⦙'

" ALE
let g:ale_linters = {'perl': ['perl']}
let g:ale_lint_on_text_changed = 'never'
let g:ale_sign_column_always = 0
let g:ale_perl_perl_options = '-c -Mwarnings -Ilib'
if isdirectory("./site_perl")
  let g:ale_perl_perl_options .= ' -Isite_perl'
endif

" Airline
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 2
let g:airline#extensions#whitespace#checks = [ 'indent', 'trailing', 'long', 'mixed-indent' ]
let g:airline_powerline_fonts = 1
let g:airline_theme='jay'
nmap <silent> <M-S-tab> <Plug>(ale_previous_wrap)
nmap <silent> <M-tab>   <Plug>(ale_next_wrap)

" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#go#gocode_binary = '/Users/dbell/lib/go/bin/gocode'
let g:deoplete#sources#go#builtin_objects = 1

iabbrev mypry `cp /Users/dennis.bell/.replyrc \$HOME/` unless -f $ENV{HOME}."/.replyrc"; use Pry; pry;

let g:easytags_cmd = '/opt/homebrew/bin/ctags'

let g:rgbtxt = '/Users/dennis.bell/.vim/rgb.txt'

let g:copilot_filetypes = {
    \ 'gitcommit': v:true,
    \ 'markdown': v:true,
    \ 'yaml': v:true,
    \ 'perl': v:true,
    \ 'ruby': v:true,
    \ 'javascript': v:true,
    \ 'typescript': v:true,
    \ 'html': v:true,
    \ 'css': v:true,
    \ 'scss': v:true,
    \ 'go': v:true,
    \ }

let g:copilot_auto_enable = 1
imap <D-[> <Plug>(copilot-prev)
imap <D-]> <Plug>(copilot-next)
imap <D-'> <Plug>(copilot-suggest)
imap <C-Tab> <Plug>(copilot-accept-line)
imap <C-Space> <Plug>(copilot-accept-word)
