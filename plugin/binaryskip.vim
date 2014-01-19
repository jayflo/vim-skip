" binaryskip.vim - move horizontally binarily
" Maintainer:   Jaret Flores <github.com/jayflo>
" Version:      0.1

" ====[ Options ]====
if ( exists("g:binaryskip_disable") && g:binaryskip_disable )
    finish
endif
let g:binaryskip_disable = 0

if !exists("g:binaryskip_disable_default_maps")
    let g:binaryskip_disable_default_maps = 0
endif

if !exists("g:binaryskip_multiplier") || g:binaryskip_multiplier < 0
    let g:binaryskip_multiplier = 0.5
endif
let s:factor = g:binaryskip_multiplier

if !exists("g:binaryskip_mode")
    let g:binaryskip_mode = "normal"
endif

if !exists("g:binaryskip_pass_through")
    let g:binaryskip_pass_through = 1
endif

if !exists("g:binaryskip_continuation")
    let g:binaryskip_continuation = 0
endif

if !exists("g:binaryskip_ignore_initial_ws")
    let g:binaryskip_ignore_initial_ws= 1
endif

if !exists("g:binaryskip_ignore_trailing_ws")
    let g:binaryskip_ignore_trailing_ws= 1
endif

" ====[ Helpers ]====
if s:factor > 1
    s:factor = 1.0/(s:factor * 1.0)
endif

if g:binaryskip_continuation
    let s:nextfirstcol = "0j"
    let s:prevfirstcol = "0k"
    let s:safenext = 1
    let s:safeprevious = -1
else
    let s:nextfirstcol = "0"
    let s:prevfirstcol = "0"
    let s:safenext = 0
    let s:safeprevious = 0
endif

let s:current = 0
let s:cursor = ""
let s:firstcol = "0"
let s:switchmode = "normal"

" ====[ Getters ]====
function! s:Cursor()
    return getpos('.')[2]
endfunction

function! s:Line(offset)
    return getline(line('.') + a:offset)
endfunction

function! s:DistanceTo(destination)
    return abs(s:Cursor()-a:destination)
endfunction

function! s:Scale(value, by_x)
    return float2nr(ceil(a:value * 1.0 * a:by_x))
endfunction

function! s:BeginningOf(line)
    if g:binaryskip_ignore_initial_ws
        return match(a:line,'\S')+1
    else
        return 0
    endif
endfunction

function! s:EndOf(line)
    if g:binaryskip_ignore_trailing_ws
        return strlen(substitute(a:line,'\s\+$','','g'))
    else
        return strlen(a:line)
    endif
endfunction

function! s:CenterOf(line)
    let l:beginningofline = s:BeginningOf(a:line)
    return l:beginningofline + s:Scale(s:EndOf(a:line)-l:beginningofline, 0.5)
endfunction

" ====[ Setters ]====
"                str , int     , str
function! s:Skip(wrap, distance, direction)
execute "normal! ".a:wrap.string(a:distance).a:direction
endfunction

" ====[ Center of Line ]====
function! s:ToCenter()
    return s:Skip(s:firstcol, s:CenterOf(s:Line(s:current)), "l")
endfunction

" ====[ Normal Mode ]====
function! s:BinarySkipForward()
    let l:dist = s:DistanceTo(s:EndOf(s:Line(s:current)))
    if l:dist
        call s:Skip(s:cursor, s:Scale(l:dist, s:factor), "l")
    else
        call s:Skip(s:nextfirstcol, s:BeginningOf(s:Line(s:safenext)), "l")
    endif
endfunction

function! s:BinarySkipBackward()
    let l:dist = s:DistanceTo(s:BeginningOf(s:Line(s:current)))
    if l:dist
        call s:Skip(s:cursor, s:Scale(l:dist, s:factor), "h")
    else
        call s:Skip(s:prevfirstcol, s:EndOf(s:Line(s:safeprevious)), "l")
    endif
endfunction

" " ====[ Split Mode ]====
" function! s:BinarySkipForwardSplit()
"     let l:cursor = s:Cursor()
"     let l:center= s:CenterOf(s:Line(s:current))

"     if l:cursor < l:center
"         call s:Skip(s:cursor, s:Scale(l:center-l:cursor,s:factor), "l")
"     elseif l:cursor > l:center
"         let l:dist = s:DistanceTo(s:EndOf(s:Line(s:current)))

"         if l:dist
"             call s:Skip(s:cursor, s:Scale(l:dist,s:factor), "l")
"         else
"             if g:binaryskip_pass_through
"                 call s:Skip(s:nextfirstcol, s:BeginningOf(s:Line(s:safenext)), "l")
"             else
"                 call s:Skip(s:firstcol, l:center, "l")
"             endif
"         endif
"     else
"         if g:binaryskip_pass_through
"             call s:Skip(s:cursor, s:Scale(s:DistanceTo(s:EndOf(s:Line(s:current))),s:factor), "l")
"         else
"             call s:Skip(s:firstcol, s:BeginningOf(s:Line(s:current)), "l")
"         endif
"     endif
" endfunction

" function! s:BinarySkipBackwardSplit()
"     let l:cursor = s:Cursor()
"     let l:center= s:CenterOf(s:Line(s:current))

"     if l:cursor > l:center
"         call s:Skip(s:cursor, s:Scale(l:cursor-l:center,s:factor), "h")
"     elseif l:cursor < l:center
"         let l:dist = s:DistanceTo(s:BeginningOf(s:Line(s:current)))

"         if l:dist
"             call s:Skip(s:cursor, s:Scale(l:dist,s:factor), "h")
"         else
"             if g:binaryskip_pass_through
"                 call s:Skip(s:prevfirstcol, s:EndOf(s:Line(s:safeprevious)), "l")
"             else
"                 call s:Skip(s:firstcol, l:center, "l")
"             endif
"         endif
"     else
"         if g:binaryskip_pass_through
"             call s:Skip(s:cursor, s:Scale(s:DistanceTo(s:BeginningOf(s:Line(s:current))),s:factor), "h")
"         else
"             call s:Skip(s:firstcol, s:EndOf(s:Line(s:current)), "l")
"         endif
"     endif
" endfunction

" " ====[ Helix Mode ]====
" function! s:BinarySkipForwardHelix()
"     let l:cursor = s:Cursor()
"     let l:center= s:CenterOf(s:Line(s:current))

"     if l:cursor < l:center
"         call s:Skip(s:cursor, s:Scale(l:center-l:cursor,s:factor), "l")
"     else
"         let l:distancetoend = s:DistanceTo(s:EndOf(s:Line(s:current)))
"         let l:beginningofline = s:BeginningOf(s:Line(s:safenext))
"         if g:binaryskip_continuation
"             l:center = s:CenterOf(s:Line(s:safenext))
"         endif
"         let l:skipdist = s:Scale(l:distancetoend + (l:center - l:beginningofline),s:factor)

"         if l:skipdist <= l:distancetoend
"             call s:Skip(s:cursor, l:skipdist, "l")
"         else
"             call s:Skip(s:nextfirstcol , s:BeginningOf(s:Line(s:safenext)) + (l:skipdist - l:distancetoend), "l")
"         endif
"     endif
" endfunction

" function! s:BinarySkipBackwardHelix()
"     let l:cursor = s:Cursor()
"     let l:center= s:CenterOf(s:Line(s:current))

"     if l:cursor > l:center
"         call s:Skip(s:cursor, s:Scale(l:cursor-l:center,s:factor), "h")
"     else
"         let l:distancetobeginning = s:DistanceTo(s:BeginningOf(s:Line(s:current)))
"         let l:endofline = s:EndOf(s:Line(s:safeprevious))
"         if g:binaryskip_continuation
"             l:center = s:CenterOf(s:Line(s:safeprevious))
"         endif
"         let l:skipdist = s:Scale(l:distancetobeginning + (l:endofline-l:center),s:factor)

"         if l:skipdist <= l:distancetobeginning
"             call s:Skip(s:cursor, l:skipdist, "h")
"         else
"             call s:Skip(s:nextfirstcol , s:EndOf(s:Line(s:safeprevious)) - (l:skipdist-l:distancetobeginning), "l")
"         endif
"     endif
" endfunction

" " ====[ Fixed Skip Mode ]====
" function! s:BinarySkipForwardFixed()
"     let l:line = s:Line(s:current)
"     let l:distancetoend = s:DistanceTo(s:EndOf(l:line))
"     let l:skipdist = s:Scale(strlen(l:line),s:factor)

"     if l:skipdist <= l:distancetoend
"         call s:Skip(s:cursor, l:skipdist, "l")
"     else
"         call s:Skip(s:nextfirstcol, s:BeginningOf(s:Line(s:safenext)) + (l:skipdist - l:distancetoend), "l")
"     endif
" endfunction

" function! s:BinarySkipBackwardFixed()
"     let l:line = s:Line(s:current)
"     let l:distancetobeginning = s:DistanceTo(s:BeginningOf(l:line))
"     let l:skipdist = s:Scale(strlen(l:line),s:factor)

"     if l:skipdist <= l:distancetobeginning
"         call s:Skip(s:cursor, l:skipdist, "h")
"     else
"         call s:Skip(s:prevfirstcol, s:EndOf(s:Line(s:safeprevious)) + (l:skipdist - l:distancetobeginning), "l")
"     endif
" endfunction

" ====[ Dynamic Option Changing ]====
function! s:IncreaseMultiplier()
    s:factor += 1.0
endfunction

function! s:DecreaseMultiplier()
    s:factor -= 1.0
endfunction

function! s:SetMaps(...)
    if a:0
        if a:1 == "fixed"
            nmap s <Plug>FixedForward
            nmap S <Plug>FixedBackward
        elseif a:1 == "split"
            nmap s <Plug>SplitForward
            nmap S <Plug>SplitForward
        elseif a:1 == "helix"
            nmap s <Plug>HelixForward
            nmap S <Plug>HelixBackward
        else
            nmap s <Plug>NormalForward
            nmap S <Plug>NormalBackward
        endif
    else
        if s:switchmode == "normal"
            s:switchmode = "split"
        elseif s:switchmode == "split"
            s:switchmode = "helix"
        elseif s:switchmode == "helix"
            s:switchmode = "fixed"
        elseif s:switchmode == "fixed"
            s:switchmode = "normal"
        else
            s:switchmode = "fixed"
        endif
        call s:SetMaps(s:switchmode)
    endif

    nmap gs <Plug>ToCenter
endfunction

" ====[ Bindings ]====
nnoremap <silent> <Plug>ToCenter                :<C-u>call <SID>ToCenter()<CR>
nnoremap <silent> <Plug>NormalForward :<C-u>call <SID>BinarySkipForward()<CR>
nnoremap <silent> <Plug>NormalBackward :<C-u>call <SID>BinarySkipBackward()<CR>
nnoremap <silent> <Plug>HelixForward  :<C-u>call <SID>BinarySkipForwardHelix()<CR>
nnoremap <silent> <Plug>HelixBackward :<C-u>call <SID>BinarySkipBackwardHelix()<CR>
nnoremap <silent> <Plug>SplitForward  :<C-u>call <SID>BinarySkipForwardSplit()<CR>
nnoremap <silent> <Plug>SplitBackward :<C-u>call <SID>BinarySkipBackwardSplit()<CR>
nnoremap <silent> <Plug>FixedForward  :<C-u>call <SID>BinarySkipForwardFixed()<CR>
nnoremap <silent> <Plug>FixedBackward :<C-u>call <SID>BinarySkipBackwardFixed()<CR>
nnoremap <silent> <Plug>SwitchMode    :<C-u>call <SID>SetMaps()<CR>
nnoremap <silent> <Plug>IncreaseMultiplier    :<C-u>call <SID>IncreaseMultiplier()<CR>
nnoremap <silent> <Plug>DecreaseMultiplier    :<C-u>call <SID>DecreaseMultiplier()<CR>

if !hasmapto('<Plug>BinarySkipForward') && !g:binaryskip_disable_default_maps
    call s:SetMaps(g:binaryskip_mode)
endif



