" Title: Necro Vim
" Author: Lou Noizet
" Maintainer: Lou Noizet (lou@noizet.fr)
" Description: This plugin handles Skel files, and uses Necro to do stuff to
" them

if exists("g:necro_vim")
	finish
endif
let g:necro_vim = 1

"""" Variables
let g:necro_autoopen="vertical"



""" Detect Necro Lib, Necro ML, Necro Coq
let g:necrolib_version = 
		\ system("necroparse --version | sed \"s/^.*version: \\(.*\\)/\\1/\"")[:-2]
let g:has_necrolib = (v:shell_error == 0)
" fail without Necro Lib
if !g:has_necrolib
	unlet g:necrolib_version
	echoerr "Necro Lib is not installed"
	finish
endif


let g:necroml_version = 
		\ system("necroml --version | sed \"s/^.*version: \\(.*\\)/\\1/\"")[:-2]
let g:has_necroml = (v:shell_error == 0)
if !g:has_necroml
	unlet g:necroml_version
endif

let g:necrocoq_version = 
		\ system("necrocoq --version | sed \"s/^.*version: \\(.*\\)/\\1/\"")[:-2]
let g:has_necrocoq = (v:shell_error == 0)
if !g:has_necrocoq
	unlet g:necrocoq_version
endif

let s:path = expand('<sfile>:p:h')
let s:error_file = s:path . "/errorfile"


"""""""""""""""""""""""""""""""
"          Functions          "
"""""""""""""""""""""""""""""""

""" Necro Parse 

function! NecroParse(...)
	if a:0 >= 2
		echoerr "NecroParse expects 0 or 1 argument"
		return v:false
	endif
	" save file if necessary
	if &autowrite && &modified | write | endif
	" Check the validity of the error file
	if !empty(glob(s:error_file))
		echoerr s:error_file . " is not empty"
		return v:false
	endif
	" call necroparse and write result in error file
	call system("necroparse -d " . expand("%") . " > " . s:error_file . " 2>&1")
	if v:shell_error == 0 && a:0 == 0
		echo "Parsing and typing successful"
	elseif v:shell_error == 0 && a:0 == 1 && a:1
		echo "Parsing and typing successful"
	endif
	let l:success= v:shell_error==0
	" create location list
	let l:oldef = &errorformat
	set errorformat=%EFile\ \"%f\"\\,\ line\ %l\\,\ characters\ %c-%k:,%Z%m
	exe "cf " . s:error_file
	let &errorformat=l:oldef
	" remove error file
	call system("rm -f " . s:error_file . " 2>&1")
	return l:success
endfunction



""" Necro ML 

function! NecroML(...)
	if a:0 >= 2
		echoerr "NecroML expects 0 or 1 argument"
		return v:false
	endif
	if a:0 == 1
		let l:write = a:1
	else
		let l:write = expand('%:p:r'). ".ml"
	endif
	if !g:has_necroml
		echoerr "Necro ML is not installed"
		return v:false
	endif
	call system("necroml -d ".expand("%")." -o ".l:write." 2>".s:error_file)
	if (v:shell_error != 0)
		let l:error = readfile("s:error_file", '', 1)[0]
		echoerr l:error
		call system("rm -f " . s:error_file . " 2>&1")
		return v:false
	endif
	call system("rm -f " . s:error_file . " 2>&1")
	if g:necro_autoopen=="vertical"
		exe "vsplit" l:write
	elseif g:necro_autoopen=="horizontal"
		exe "split" l:write
	elseif g:necro_autoopen=="tab"
		exe "tabedit" l:write
	endif
	return v:true
endfunction

function! NecroMLPrompt()
	if !g:has_necroml
		echoerr "Necro ML is not installed"
		return
	endif
	let l:write = input("Output file: ")
	call NecroML(l:write)
endfunction



""" Necro Coq

function! NecroCoq(...)
	if a:0 >= 2
		echoerr "NecroCoq expects 0 or 1 argument"
		return v:false
	endif
	if a:0 == 1
		let l:write = a:1
	else
		let l:filename = substitute(expand('%:p:t:r'), "^.", "\\u&", "")
		let l:write = expand('%:p:h') . "/" . l:filename . ".v"
	endif
	if !g:has_necrocoq
		echoerr "Necro Coq is not installed"
		return
	endif
	call system("necrocoq ".expand("%")." -o ".l:write." 2>". s:error_file)
	echo l:write
	if (v:shell_error != 0)
		let l:error = readfile("s:error_file", '', 1)[0]
		echoerr l:error
		call system("rm -f " . s:error_file . " 2>&1")
		return v:false
	endif
	call system("rm -f " . s:error_file . " 2>&1")
	if g:necro_autoopen=="vertical"
		exe "vsplit" l:write
	elseif g:necro_autoopen=="horizontal"
		exe "split" l:write
	elseif g:necro_autoopen=="tab"
		exe "tabedit" l:write
	endif
	return v:true
endfunction

function! NecroCoqPrompt()
	if !g:has_necrocoq
		echoerr "Necro Coq is not installed"
		return
	endif
	let l:write = input("Output file: ")
	call NecroCoq(l:write)
endfunction


""""""""""""""""""""""""""""""
"          Commands          "
""""""""""""""""""""""""""""""

command! -nargs=* NecroParse call necro-vim#NecroParse(<args>)
command! -nargs=* NecroML call necro-vim#NecroML(<args>)
command! -nargs=* NecroCoq call necro-vim#NecroCoq(<args>)
command! -nargs=0 NecroMLPrompt call necro-vim#NecroMLPrompt(>)
command! -nargs=0 NecroCoqPrompt call necro-vim#NecroCoqPrompt()
