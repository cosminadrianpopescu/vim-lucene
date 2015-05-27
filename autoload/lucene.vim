"============================================================================"
"
"  Vim Lucene
"
"  Copyright (c) Cosmin Popescu
"
"  Author:      Cosmin Popescu <cosminadrianpopescu at gmail dot com>
"  Version:     1.00 (2015-01-08)
"  Requires:    Vim 7
"  License:     GPL
"
"  Description:
"
"  Indexes a folder using the lucene-indexer project and performs searches
"  from Vim
"
"============================================================================"

let s:script_path = expand('<sfile>:p:h') . '/../'

""
" Function communicating with the Lucene indexer. 
" 
" Parameters:
"
" {cmd} The command to execute (see the folder indexer protocol)
function! s:pipe_execute(cmd)
    execute "silent !echo 'Running " . a:cmd . "'. Please wait..."
    let port = g:Lucene_port

    python << SCRIPT
import vim
import socket
import re
cmd = vim.eval('a:cmd') + "\n"
port = int(vim.eval('port'))
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('127.0.0.1', port))
s.sendall(cmd + ".\n")
result = ''
while 1:
    data = s.recv(4096)
    if not data:
        break
    #end if
    result += data
#end while
s.close()
lines = result.split("\n")
vim.command("let result = ''")
lines = result.split("\n")
for line in lines:
    vim.command("let result = result . '%s\n'" % line.replace("'", "''"))
#end for
SCRIPT
    return substitute(result, '\r', '', 'g')
endfunction

""
" This is the main function. It performs a search. 
" It connects to the port set by g:Lucene_port and it queries for 
" {pattern}. 
"
" Parameters:
" {pattern} The pattern to search
" {type} The type of search to perform (wild, regex or regular) See the Lucene
"        search syntax if you are not familiar with what a wild search is. If the
"        type if wild, then the pattern will be prefixed and suffixed with `*`
" [path] If set, then return only the files which are found in the specified
"        folder
" @public
function! lucene#search(pattern, type, ...)
	let path = ''

	if a:0
		let path = a:1
	endif

	let @/ = '\c\V' . a:pattern
    if (a:type == 'regex')
        let @/ = '\c\v' . substitute(a:pattern, '\c\v^\.\*(.*)\.\*$', '\1', 'g')
    endif
    let pattern = tolower(a:pattern)
    if (a:type == 'wild')
        let pattern = '*' . pattern . '*'
    endif
    if (path == "")
        let cmd = ".query-" . a:type . " " . pattern
    else
        let cmd = ".query-" . a:type . " -folder=" . path . " -query=" . pattern
    endif

    let result = s:pipe_execute(cmd)
    if result == ""
        let result = "No files found"
    endif
    let files = split(result, "\n")
    let grep = ''
    for file in files
        let grep = grep . substitute(file, "\\", "/", 'g') . ' '
    endfor
    if g:lucene_cygwin == 1
        let cmd = "!" . s:script_path . "resources/cygwin_grep "
    else 
        let cmd = "grep! -niI "
    endif
    let grep = cmd . '"' . a:pattern . '" ' . grep
    silent! execute grep
    copen
    if (g:lucene_cygwin == 1)
        cfile /tmp/grep-result
    endif
	redraw!
endfunction

function! lucene#test()
    let result = s:pipe_execute(".index-all")
    echomsg result
    redraw!
endfunction
