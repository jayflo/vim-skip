
    {               

Plugins such as Easymotion, Stupid-Easymotion, vim-sneak try to close the gap
between the normal commands $0 and wWeEbE.  These are nice plugins but have one
thing in common: they all mimic f and / which require additional input AND
pressing yet another key to repeat.


" move forward (distance between cursor and end of line)/2 characters
nnoremap <expr> s strlen(getline('.'))-getpos('.')[2] ?  string(float2nr(ceil((strlen(getline('.'))-getpos('.')[2])/2.0))) . 'l' : '0'

" move backward (distance between cursor and end of line)/2 characters
nnoremap <expr> S getpos('.')[2]-1 ? string(float2nr(ceil(getpos('.')[2]/2.0))) .  'h': '$'

" place cursor at center of line, ignoring white space at beginning/end of line
nnoremap <expr> gs '0' . string( match(getline('.'),'\S') + (strlen(Trim(getline('.')))/2) ) . 'l'

function! Trim(string)
    return substitute(substitute(a:string,'\s\+$','','g'),'^\s\+','','g')
endfunction

How it works: starting at...

begining of line, move **forward** from cursor position
1/2 line: s (or gs)
1/4 line: sS (or gsS)
3/4 line: ss (or gss)
1/8 line: sSS
etc...

end of line, move **backward** from cursor position
1/2 line: S (or gs)
1/4 line: Ss (or gss)
3/4 line: SS (or gsS)
1/8 line: Sss (or gsss)
etc...

anywhere, move to
middle of non-whitespace (i.e. line, ignoring whitespace): gs
1/4 distance from beginning of line: gsS
3/4 distance from beginning of line: gss
etc...

Of course, you don't always need to start at the beginning/end of a line, or
begin with gs, but tapping s (resp. S) will move you *quickly* across a line
with jumps that become successively with repitiion.
