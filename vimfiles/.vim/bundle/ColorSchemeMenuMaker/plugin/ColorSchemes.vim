"ColorScheme menu generated Thu 12 Nov 09:28:18 2015
"Menu created with ColorSchemeMenuMaker.vim by Erik Falor
"Get the latest version at http://www.vim.org/scripts/script.php?script_id=2004

"Do not load this menu unless running in GUI mode
if !has("gui_running") | finish | endif

"Themes by color:

"submenu black
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).elflord  :colo elflord<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).industry  :colo industry<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).koehler  :colo koehler<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).murphy  :colo murphy<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).pablo  :colo pablo<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).ron  :colo ron<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).*torte  :colo torte<CR>
9000amenu &ColorSchemes.&Colors\ (22).black\ (8).*vividchalk  :colo vividchalk<CR>

"submenu blue
9000amenu &ColorSchemes.&Colors\ (22).blue\ (3).blue  :colo blue<CR>
9000amenu &ColorSchemes.&Colors\ (22).blue\ (3).darkblue  :colo darkblue<CR>
9000amenu &ColorSchemes.&Colors\ (22).blue\ (3).navajo-midnight  :colo navajo-midnight<CR>

"submenu grey
9000amenu &ColorSchemes.&Colors\ (22).grey\ (3).desert  :colo desert<CR>
9000amenu &ColorSchemes.&Colors\ (22).grey\ (3).evening  :colo evening<CR>
9000amenu &ColorSchemes.&Colors\ (22).grey\ (3).slate  :colo slate<CR>

"submenu offwhite
9000amenu &ColorSchemes.&Colors\ (22).offwhite\ (1).morning  :colo morning<CR>

"submenu red
9000amenu &ColorSchemes.&Colors\ (22).red\ (1).peachpuff  :colo peachpuff<CR>

"submenu unknown
9000amenu &ColorSchemes.&Colors\ (22).unknown\ (2).default  :colo default<CR>
9000amenu &ColorSchemes.&Colors\ (22).unknown\ (2).xterm16  :colo xterm16<CR>

"submenu white
9000amenu &ColorSchemes.&Colors\ (22).white\ (4).delek  :colo delek<CR>
9000amenu &ColorSchemes.&Colors\ (22).white\ (4).*macvim  :colo macvim<CR>
9000amenu &ColorSchemes.&Colors\ (22).white\ (4).shine  :colo shine<CR>
9000amenu &ColorSchemes.&Colors\ (22).white\ (4).zellner  :colo zellner<CR>
"Themes by name:


"submenu B
amenu &ColorSchemes.&Names\ (22).B\ (1).blue  :colo blue<CR>

"submenu D
amenu &ColorSchemes.&Names\ (22).D\ (4).darkblue  :colo darkblue<CR>
amenu &ColorSchemes.&Names\ (22).D\ (4).default  :colo default<CR>
amenu &ColorSchemes.&Names\ (22).D\ (4).delek  :colo delek<CR>
amenu &ColorSchemes.&Names\ (22).D\ (4).desert  :colo desert<CR>

"submenu E
amenu &ColorSchemes.&Names\ (22).E\ (2).elflord  :colo elflord<CR>
amenu &ColorSchemes.&Names\ (22).E\ (2).evening  :colo evening<CR>

"submenu I
amenu &ColorSchemes.&Names\ (22).I\ (1).industry  :colo industry<CR>

"submenu K
amenu &ColorSchemes.&Names\ (22).K\ (1).koehler  :colo koehler<CR>

"submenu M
amenu &ColorSchemes.&Names\ (22).M\ (3).*macvim  :colo macvim<CR>
amenu &ColorSchemes.&Names\ (22).M\ (3).morning  :colo morning<CR>
amenu &ColorSchemes.&Names\ (22).M\ (3).murphy  :colo murphy<CR>

"submenu N
amenu &ColorSchemes.&Names\ (22).N\ (1).navajo-midnight  :colo navajo-midnight<CR>

"submenu P
amenu &ColorSchemes.&Names\ (22).P\ (2).pablo  :colo pablo<CR>
amenu &ColorSchemes.&Names\ (22).P\ (2).peachpuff  :colo peachpuff<CR>

"submenu R
amenu &ColorSchemes.&Names\ (22).R\ (1).ron  :colo ron<CR>

"submenu S
amenu &ColorSchemes.&Names\ (22).S\ (2).shine  :colo shine<CR>
amenu &ColorSchemes.&Names\ (22).S\ (2).slate  :colo slate<CR>

"submenu T
amenu &ColorSchemes.&Names\ (22).T\ (1).*torte  :colo torte<CR>

"submenu V
amenu &ColorSchemes.&Names\ (22).V\ (1).*vividchalk  :colo vividchalk<CR>

"submenu X
amenu &ColorSchemes.&Names\ (22).X\ (1).xterm16  :colo xterm16<CR>

"submenu Z
amenu &ColorSchemes.&Names\ (22).Z\ (1).zellner  :colo zellner<CR>

amenu &ColorSchemes.-Sep-   :
amenu &ColorSchemes.Reload\ Menu    :ReloadColorsMenu<CR>
amenu &ColorSchemes.Rebuild\ Menu   :RebuildColorsMenu<CR>

command! -nargs=0       ReloadColorsMenu        call <SID>ReloadColorsMenu()
command! -nargs=0       RebuildColorsMenu       call <SID>RebuildColorsMenu()

let s:totThemes = 22

if !exists("g:running_ReloadColorsMenu")
    function! <SID>ReloadColorsMenu()
        let g:running_ReloadColorsMenu = 1
        execute "aunmenu &ColorSchemes.&Colors\\ (" . s:totThemes . ")"
        execute "aunmenu &ColorSchemes.&Names\\ (" . s:totThemes  . ")"
        aunmenu &ColorSchemes.-Sep-
        aunmenu &ColorSchemes.Reload\ Menu
        aunmenu &ColorSchemes.Rebuild\ Menu
        execute 'source /Users/dbell/.vim/bundle/ColorSchemeMenuMaker/plugin/ColorSchemes.vim'
        unlet g:running_ReloadColorsMenu
        echomsg 'Done reloading /Users/dbell/.vim/bundle/ColorSchemeMenuMaker/plugin/ColorSchemes.vim'
    endfunction
endif
if !exists("g:running_RebuildColorsMenu")
    function! <SID>RebuildColorsMenu()
        let g:running_RebuildColorsMenu = 1
        call WriteColorSchemeMenu()
        call <SID>ReloadColorsMenu()
        unlet g:running_RebuildColorsMenu
        echomsg 'Done rebuilding /Users/dbell/.vim/bundle/ColorSchemeMenuMaker/plugin/ColorSchemes.vim'
    endfunction
endif
