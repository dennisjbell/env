" GUI Scheme
"set guifont=Anonymice\ Nerd\ Font\ Complete\ Mono:h17
set guifont=RobotoMonoForPowerline-Light:h17
set mousehide
set transparency=0 " was 12
set noequalalways
"set background=dark
"color vividchalk
highlight ColorColumn guibg=#0x202028

" Start without the toolbar, but with tabbar
set guioptions-=T
set showtabline=2
set guitablabel=%f\ %m

if has("gui_macvim")
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert

  " Command-Shift-F for CommandT (File File)
  "macmenu Window.Toggle\ Full\ Screen\ Mode key=<D-M-f>
  map <D-F> :CommandT<CR>
  map! <D-F> <ESC>:CommandT<CR>

  " Command-/ for Ack
  map <D-/> :Ack!<space>
  map! <D-/> <ESC>:Ack!<space>
  vmap <D-/> y<ESC>:Ack!<space>"<C-R>*"<CR>

  " Command-> to toggle comments
  map <D->> <plug>NERDCommenterToggle<CR>
endif

" Tab Navigation
map  <S-D-Right> :tabnext<CR>
map! <S-D-Right> <ESC>:tabnext<CR>li
map  <S-D-Left> :tabprevious<CR>
map! <S-D-Left> <ESC>:tabprevious<CR>li

set listchars=tab:⦙\ ,trail:∙,extends:⊳,precedes:⊲,nbsp:◦
set listchars+=eol:⤸ "if you want to see EOLs
let g:indentLine_color_gui = '#A4E57E'

let g:NERDTreeGitStatusIndicatorMapCustom = {
            \ 'Modified'  : '∗',
            \ 'Staged'    : '+',
            \ 'Untracked' : '?',
            \ 'Renamed'   : '>',
            \ 'Unmerged'  : '•',
            \ 'Deleted'   : '⨯',
            \ 'Dirty'     : '…',
            \ 'Clean'     : '✓',
            \ 'Ignored'   : '¿',
            \ 'Unknown'   : '⚬'
            \ }

highlight NERDTreeGitStatusModified guifg=gold1

" ConqueTerm wrapper -- disabled currentl
"map <D->> :call StartTerm()<CR>
"function StartTerm()
  "execute 'ConqueTerm ' . $SHELL . ' --login'
  "setlocal listchars=tab:\ \ 
"endfunction

" Project Tree
au VimEnter * NERDTree
au VimEnter * wincmd p
au VimEnter * call s:CdIfDirectory(expand("<amatch>"))

" Disable netrw's autocmd, since we're ALWAYS using NERDTree
runtime plugin/netRwPlugin.vim
augroup FileExplorer
  au!
augroup END

let g:NERDTreeHijackNetrw = 0

" If the parameter is a directory, cd into it
function s:CdIfDirectory(directory)
  if isdirectory(a:directory)
    call ChangeDirectory(a:directory)
  endif
endfunction

" NERDTree utility function
function s:UpdateNERDTree(stay)
  if exists("t:NERDTreeBufName")
    if bufwinnr(t:NERDTreeBufName) != -1
      NERDTree
      if !a:stay
        wincmd p
      end
    endif
  endif
endfunction

" Utility functions to create file commands
function s:CommandCabbr(abbreviation, expansion)
  execute 'cabbrev ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
endfunction

function s:FileCommand(name, ...)
  if exists("a:1")
    let funcname = a:1
  else
    let funcname = a:name
  endif

  execute 'command -nargs=1 -complete=file ' . a:name . ' :call ' . funcname . '(<f-args>)'
endfunction

function s:DefineCommand(name, destination)
  call s:FileCommand(a:destination)
  call s:CommandCabbr(a:name, a:destination)
endfunction

" Public NERDTree-aware versions of builtin functions
function ChangeDirectory(dir, ...)
  execute "cd " . a:dir
  let stay = exists("a:1") ? a:1 : 1
  call s:UpdateNERDTree(stay)
endfunction

function Touch(file)
  execute "!touch " . a:file
  call s:UpdateNERDTree(1)
endfunction

function Remove(file)
  let current_path = expand("%")
  let removed_path = fnamemodify(a:file, ":p")

  if (current_path == removed_path) && (getbufvar("%", "&modified"))
    echo "You are trying to remove the file you are editing. Please close the buffer first."
  else
    execute "!rm " . a:file
  endif
endfunction

function Edit(file)
  if exists("b:NERDTreeRoot")
    wincmd p
  endif

  execute "e " . a:file

ruby << RUBY
  destination = File.expand_path(VIM.evaluate(%{system("dirname " . a:file)}))
  pwd         = File.expand_path(Dir.pwd)
  home        = pwd == File.expand_path("~")

  if home || Regexp.new("^" + Regexp.escape(pwd)) !~ destination
    VIM.command(%{call ChangeDirectory(system("dirname " . a:file), 0)})
  end
RUBY
endfunction

" Define the NERDTree-aware aliases
call s:DefineCommand("cd", "ChangeDirectory")
call s:DefineCommand("touch", "Touch")
call s:DefineCommand("rm", "Remove")
call s:DefineCommand("e", "Edit")

