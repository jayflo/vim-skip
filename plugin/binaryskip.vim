" binaryskip.vim - move horizontally binarily
" Maintainer:   Jaret Flores <jarflores@gmail.com>
" Version:      0.1

if ( exists("g:binaryskip_disable") && g:binaryskip_disable )
    finish
endif
let g:binaryskip_disable = 0

if !exists("g:binaryskip_factor") || g:binaryskip_factor < 1 || g:binaryskip_factor > 25
    let g:binary_skip_factor = 2.0
endif

if !exists("g:binaryskip_fixed")
    let g:binary_skip_fixed = 0
endif

if !exists("g:binaryskip_continuation")
    let g:binaryskip_continuation = 0
endif

function! s:trailingwsstart()
    return strlen(substitute(getline('.'),'\s\+$','','g'))
endfunction

function! s:initialwsend()
    return match(getline('.'),'\S')
endfunction

function! s:distancetotrailingws()
    return strlen(substitute(getline('.'),'\s\+$','','g'))-getpos('.')[2]
endfunction

function! s:distancetoinitialws()
    return getpos('.')[2]-s:InitialWSEnd()-1
endfunction

function! s:skipforward()
    return string(float2nr(ceil(s:distancetotrailingws()/2.0))).'l'
endfunction

function! s:skipbackward()
    return string(float2nr(ceil(s:distancetoinitialws()/2.0))).'h'
endfunction

function! s:fixedskipforward()
    return string(float2nr(ceil(strlen(getline('.'))/2.0))).'l'
endfunction

function! s:fixedskipbackward()
    return string(float2nr(ceil(strlen(getline('.'))/2.0))).'h'
endfunction

function! s:trim(string)
    return substitute(substitute(a:string,'\s\+$','','g'),'^\s\+','','g')
endfunction

nnoremap <expr> s s:distancetotrailingws() ? s:skipforward() : s:initialwsend() ? '0'.string(s:initialwsend()).'l' : '0'
nnoremap <expr> S s:distancetoinitialws() ? s:skipbackward() : '0'.string(s:trailingwsstart()).'l'
nnoremap <expr> gs '0'.string(s:initialwsend() + strlen(s:trim(getline('.')))/2).'l'

" xnoremap <silent> <Plug>Commentary     :<C-U>call <SID>go(line("'<"),line("'>"))<CR>
" nnoremap <silent> <Plug>Commentary     :<C-U>set opfunc=<SID>go<CR>g@
" nnoremap <silent> <Plug>CommentaryLine :<C-U>set opfunc=<SID>go<Bar>exe 'norm! 'v:count1.'g@_'<CR>
" nnoremap <silent> <Plug>CommentaryUndo :<C-U>call <SID>undo()<CR>

" if !hasmapto('<Plug>Commentary') || maparg('gc','n') ==# ''
"     xmap gc  <Plug>Commentary
"     nmap gc  <Plug>Commentary
"     nmap gcc <Plug>CommentaryLine
"     nmap gcu <Plug>CommentaryUndo
" endif

" if maparg('\\','n') ==# '' && maparg('\','n') ==# ''
"     xmap \\  <Plug>Commentary
"     nmap \\  <Plug>Commentary
"     nmap \\\ <Plug>CommentaryLine
"     nmap \\u <Plug>CommentaryUndo
" endif

