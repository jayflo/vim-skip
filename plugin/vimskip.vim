" vimskip.vim - move horizontally binarily
" Maintainer:   Jaret Flores <github.com/jayflo>
" Version:      0.1

" ====[ Options ]====
if (exists("g:vimskip_disable") && g:vimskip_disable)
    finish
en
let g:vimskip_disable = 0

if !exists("g:vimskip_disable_default_maps") | let g:vimskip_disable_default_maps = 0 | en
if !exists("g:vimskip_multiplier") || g:vimskip_multiplier < 0 | let g:vimskip_multiplier = 0.5 | en
if !exists("g:vimskip_mode") | let g:vimskip_mode = "normal" | en
if !exists("g:vimskip_wraptocenter") | let g:vimskip_wraptocenter = 0 | en
if !exists("g:vimskip_split_passthroughcenter") | let g:vimskip_split_passthroughcenter = 1 | en
if !exists("g:vimskip_helix") | let g:vimskip_helix = 0 | en
if !exists("g:vimskip_ignore_initial_ws") | let g:vimskip_ignore_initial_ws= 1 | en
if !exists("g:vimskip_ignore_trailing_ws") | let g:vimskip_ignore_trailing_ws= 1 | en

" ====[ Helpers ]====
let s:factor = g:vimskip_multiplier

if g:vimskip_helix
    let s:safedown = "j"
    let s:safeup = "k"
    let s:safenext = 1
    let s:safeprevious = -1
else
    let s:safedown = ""
    let s:safeup = ""
    let s:safenext = 0
    let s:safeprevious = 0
en

let s:left = "h"
let s:right = "l"
let s:current = 0
let s:switchmode = "normal"

" ====[ Getters ]====
fu! s:Cursor()
    return getpos('.')[2]
endf

fu! s:Line(offset)
    return getline(line('.') + a:offset)
endf

fu! s:DistanceTo(destination)
    return abs(s:Cursor()-a:destination)
endf

fu! s:Scale(...)
    if a:0 > 1
        return float2nr(ceil(a:1 * 1.0 * a:2))
    else
        return float2nr(ceil(a:1 * 1.0 * s:factor))
    en
endf

fu! s:BeginningOf(line)
    if g:vimskip_ignore_initial_ws
        return match(a:line,'\S')+1
    else
        return 0
    en
endf

fu! s:EndOf(line)
    if g:vimskip_ignore_trailing_ws
        return strlen(substitute(a:line,'\s\+$','','g'))
    else
        return strlen(a:line)
    en
endf

fu! s:CenterOf(line)
    let l:beginningofline = s:BeginningOf(a:line)
    return l:beginningofline + s:Scale(s:EndOf(a:line)-l:beginningofline, 0.5)
endf

" ====[ Setters ]====
"          int     , str
fu! s:Skip(distance, direction)
    execute "normal! ".string(a:distance).a:direction
endf

fu! s:ToCenter(...)
    execute "normal! 0".a:1
    call s:Skip(s:CenterOf(s:Line(s:current)), s:right)
endf

fu! s:Wrap(destination)
    if a:destination == "tobeginning"
        if g:vimskip_ignore_initial_ws
            execute "normal! ".s:safedown."^"
        else
            execute "normal! ".s:safedown."0"
        en
    elseif a:destination == "toend"
        if g:vimskip_ignore_trailing_ws
            execute "normal! ".s:safeup."g_"
        else
            execute "normal! ".s:safeup."$"
        en
    elseif a:destination == "tocenterfrombeginning"
        call s:ToCenter(s:safeup)
    else
        call s:ToCenter(s:safedown)
    en
endf

" ====[ Normal Mode ]====
fu! s:NormalForward()
    let l:dist = s:DistanceTo(s:EndOf(s:Line(s:current)))
    if l:dist
        call s:Skip(s:Scale(l:dist), s:right)
    else
        if g:vimskip_wraptocenter
            call s:Wrap("tocenterfromend")
        else
            call s:Wrap("tobeginning")
        en
    en
endf

fu! s:NormalBackward()
    let l:dist = s:DistanceTo(s:BeginningOf(s:Line(s:current)))
    if l:dist
        call s:Skip(s:Scale(l:dist), s:left)
    else
        if g:vimskip_wraptocenter
            call s:Wrap("tocenterfrombeginning")
        else
            call s:Wrap("toend")
        en
    en
endf

" ====[ Split Mode ]====
fu! s:SplitForward()
    let l:cursor = s:Cursor()
    let l:center= s:CenterOf(s:Line(s:current))

    if l:cursor < l:center
        call s:Skip(s:Scale(l:center-l:cursor), s:right)
    elseif l:cursor > l:center
        let l:dist = s:DistanceTo(s:EndOf(s:Line(s:current)))

        if l:dist
            call s:Skip(s:Scale(l:dist), s:right)
        else
            if g:vimskip_wraptocenter
                call s:Wrap('tocenterfromend')
            else
                call s:Wrap("tobeginning")
            en
        en
    else
        if g:vimskip_split_passthroughcenter
            call s:Skip(s:Scale(s:DistanceTo(s:EndOf(s:Line(s:current)))), s:right)
        else
            call s:Wrap("tobeginning")
        en
    en
endf

fu! s:SplitBackward()
    let l:cursor = s:Cursor()
    let l:center= s:CenterOf(s:Line(s:current))

    if l:cursor > l:center
        call s:Skip(s:Scale(l:cursor-l:center), s:left)
    elseif l:cursor < l:center
        let l:dist = s:DistanceTo(s:BeginningOf(s:Line(s:current)))

        if l:dist
            call s:Skip(s:Scale(l:dist), s:left)
        else
            if g:vimskip_wraptocenter
                call s:Wrap("tocenterfrombeginning")
            else
                call s:Wrap("toend")
            en
        en
    else
        if g:vimskip_split_passthroughcenter
            call s:Skip(s:Scale(s:DistanceTo(s:BeginningOf(s:Line(s:current)))), s:left)
        else
            call s:Wrap("toend")
        en
    en
endf

" ====[ Antipodal Mode ]====
fu! s:AntiForward()
    let l:cursor = s:Cursor()
    let l:center= s:CenterOf(s:Line(s:current))

    if l:cursor < l:center
        call s:Skip(s:Scale(l:center-l:cursor), s:right)
    else
        let l:distancetoend = s:DistanceTo(s:EndOf(s:Line(s:current)))
        let l:beginningofline = s:BeginningOf(s:Line(s:safenext))
        if g:vimskip_helix
            let l:center = s:CenterOf(s:Line(s:safenext))
        en
        let l:skipdist = s:Scale(l:distancetoend + (l:center - l:beginningofline))

        if l:skipdist <= l:distancetoend
            call s:Skip(l:skipdist, s:right)
        else
            if g:vimskip_wraptocenter
                call s:Wrap("tocenterfromend")
            else
                call s:Wrap("tobeginning")
            en
            call s:Skip(l:skipdist - l:distancetoend, s:right)
        en
    en
endf

fu! s:AntiBackward()
    let l:cursor = s:Cursor()
    let l:center= s:CenterOf(s:Line(s:current))

    if l:cursor > l:center
        call s:Skip(s:Scale(l:cursor-l:center), s:left)
    else
        let l:distancetobeginning = s:DistanceTo(s:BeginningOf(s:Line(s:current)))
        let l:endofline = s:EndOf(s:Line(s:safeprevious))
        if g:vimskip_helix
            let l:center = s:CenterOf(s:Line(s:safeprevious))
        en
        let l:skipdist = s:Scale(l:distancetobeginning + (l:endofline-l:center))

        if l:skipdist <= l:distancetobeginning
            call s:Skip(l:skipdist, s:left)
        else
            if g:vimskip_wraptocenter
                call s:Wrap("tocenterfrombeginning")
            else
                call s:Wrap("toend")
            en
            call s:Skip(l:skipdist-l:distancetobeginning, s:left)
        en
    en
endf

" ====[ Fixed Skip Mode ]====
fu! s:FixedForward()
    let l:line = s:Line(s:current)
    let l:skipdist = s:Scale(strlen(l:line))
    let l:distancetoend = s:DistanceTo(s:EndOf(l:line))

    if l:skipdist <= l:distancetoend
        call s:Skip(l:skipdist, s:right)
    else
        if g:vimskip_wraptocenter
            call s:Wrap("tocenterfromend")
        else
            call s:Wrap("tobeginning")
        en
        call s:Skip(l:skipdist - l:distancetoend, s:right)
    en
endf

fu! s:FixedBackward()
    let l:line = s:Line(s:current)
    let l:distancetobeginning = s:DistanceTo(s:BeginningOf(l:line))
    let l:skipdist = s:Scale(strlen(l:line))

    if l:skipdist <= l:distancetobeginning
        call s:Skip(l:skipdist, s:left)
    else
        call s:Wrap("toend")
        call s:Skip(l:skipdist - l:distancetobeginning, s:left)
    en
endf

" ====[ Dynamic Option Changing ]====
fu! s:IncreaseMultiplier()
    let s:factor += 0.05
    echo "vim-skip multiplier is now: ".string(s:factor)
endf

fu! s:DecreaseMultiplier()
    let s:factor -= 0.05
    echo "vim-skip multiplier is now: ".string(s:factor)
endf

fu! s:VSMultiplier(value)
    let s:factor = str2float(a:value)
    echo "vim-skip multiplier is now: ".string(s:factor)
endf
command! -nargs=1 VSMultiplier call s:VSMultiplier(<f-args>)

fu! s:SetMaps(...)
    if a:0
        execute 'nmap s <Plug>'.toupper(a:1).'Forward'
        execute 'nmap S <Plug>'.toupper(a:1).'Backward'
    else
        if s:switchmode == "normal"
            s:switchmode = "split"
        elseif s:switchmode == "split"
            s:switchmode = "anti"
        elseif s:switchmode == "anti"
            s:switchmode = "fixed"
        elseif s:switchmode == "fixed"
            s:switchmode = "normal"
        else
            s:switchmode = "fixed"
        en
        call s:SetMaps(s:switchmode)
    en
endf

" ====[ Bindings ]====
nnoremap <silent> <Plug>ToCenter                :<C-u>call <SID>ToCenter('')<CR>
nnoremap <silent> <Plug>NORMALForward           :<C-u>call <SID>NormalForward()<CR>
nnoremap <silent> <Plug>NORMALBackward          :<C-u>call <SID>NormalBackward()<CR>
nnoremap <silent> <Plug>ANTIForward             :<C-u>call <SID>AntiForward()<CR>
nnoremap <silent> <Plug>ANTIBackward            :<C-u>call <SID>AntiBackward()<CR>
nnoremap <silent> <Plug>SPLITForward            :<C-u>call <SID>SplitForward()<CR>
nnoremap <silent> <Plug>SPLITBackward           :<C-u>call <SID>SplitBackward()<CR>
nnoremap <silent> <Plug>FIXEDForward            :<C-u>call <SID>FixedForward()<CR>
nnoremap <silent> <Plug>FIXEDBackward           :<C-u>call <SID>FixedBackward()<CR>
nnoremap <silent> <Plug>SwitchMode              :<C-u>call <SID>SetMaps()<CR>
nnoremap <silent> <Plug>IncreaseMultiplier      :<C-u>call <SID>IncreaseMultiplier()<CR>
nnoremap <silent> <Plug>DecreaseMultiplier      :<C-u>call <SID>DecreaseMultiplier()<CR>

if !hasmapto('<Plug>ToCenter') && !g:vimskip_disable_default_maps
    nmap gs <Plug>ToCenter
    call s:SetMaps(g:vimskip_mode)
en



