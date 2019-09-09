" Script to allow filetype specification via a comment near the top of file, for
" programs without file extension

" If type already loaded, continue
if exists("did_load_filetypes")
    finish
endif

" Looks for match of PCRE /~filetype:([^~]+)~/ on the first three lines and sets
" filetype equal to the regex group
function! DetectGeneric()
    let pattern = '\~filetype:\([^~]\+\)\~'
    for line in [1, 2, 3]
        if getline(line) =~ pattern
            let pat_arr = matchlist(getline(line), pattern)
            execute 'setfiletype ' . pat_arr[1]
            return
        endif
    endfor
    let firstlinepat = '^.*/\(env\s\+\)\=\(\w\+\)\s*$'
    let int_match = matchlist(getline(1), firstlinepat)
    if len(int_match) > 0
        " TODO: Check if necessary to remove trailing numbers
        let rawinterp = substitute(int_match[2], '\d\+$', '', '')
        if rawinterp == 'bash'
            execute 'setfiletype ' . 'sh'
        else
            execute 'setfiletype ' . rawinterp
        endif
    endif
endfunction

augroup filetypedetect
    au BufRead,BufNewFile * call DetectGeneric()
augroup END
