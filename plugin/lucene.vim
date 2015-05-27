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

""
" @section Introduction, intro
" This is a folder search plugin. It uses Lucene to index a folder, via the
" https://github.com/cosminadrianpopescu/folder-indexer plugin, to index the
" folder and then it sends query to the server. 
"
" In order to use it, first download and compile the `folder-indexer` plugin,
" then start it. Set the server port in the |g:Lucene_port| variable and then
" you can start searching for terms inside files. 

""
" Sets the lucene port (default 5000)
if !exists('g:Lucene_port')
    let g:Lucene_port = 5000
endif

let g:lucene_cygwin = 0
if has("win32unix")
    let g:lucene_cygwin = 1
endif

""
" Performs a Lucene wild search 
" {argument} The query to search for
command! -nargs=1 LuceneSearch call lucene#search(<f-args>, 'wild')

""
" Performs a Lucene wild search starting from the current buffer's folder
" {argument} The query to search for
command! -nargs=1 LuceneSearchFromHere call lucene#search(<f-args>, 'wild', fnamemodify(bufname('%'), ':p:h'))

""
" Performs a Lucene wild search starting from the specified folder. The user
" will be asked for the folder
" {argument} The query to search for
command! -nargs=1 -complete=dir LuceneSearchFromFolder call lucene#search(input("Please input the search string: "), 'wild', <f-args>)

""
" Performs a Lucene regex search 
" {argument} The query to search for
command! -nargs=1 LuceneSearchRegex call lucene#search(<f-args>, 'regex')

""
" Performs a Lucene regex search starting from the current buffer's folder
" {argument} The query to search for
command! -nargs=1 LuceneSearchFromHereRegex call lucene#search(<f-args>, 'regex', fnamemodify(bufname('%'), ':p:h'))

""
" Performs a Lucene regex search starting from the specified folder. The user
" will be asked for the folder
" {argument} The query to search for
command! -nargs=1 -complete=dir LuceneSearchFromFolderRegex call lucene#search(input("Please input the search string: "), 'regex', <f-args>)
