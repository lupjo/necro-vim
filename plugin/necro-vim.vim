" Title: Necro Vim
" Author: Lou Noizet
" Maintainer: Lou Noizet (lou@noizet.fr)
" Description: This plugin handles Skel files, and uses Necro to do stuff to
" them

if exists("g:necro_vim")
	finish
endif

let g:necro_vim = 1
let g:necrolib_version = 
			\ system("necroparse --version | sed \"s/^.*version: \(.*\)/\1/\"")
let g:has_necrolib = (v:shell_error == 0)

if !g:has_necrolib
	unlet g:necrolib_version
	echoerr "Necro Lib is not installed"
	finish
endif

let s:path = expand('<sfile>:p')
let l:error_file = s:path . "/errorfile"

function! NecroParse()
	" save file if necessary
	if &autowrite && &modified | write | endif
	" Check the validity of the error file
	if !empty(glob(error_file))
		echoerr error_file . " is not empty"
		return
	endif
	" call necroparse and write result in error file
	call system("necroparse -d " . expand("%") . " > " . error_file . " 2>&1")
	if v:shell_error == 0
		echo "Parsing and typing successful"
	endif
	" create location list
	let l:oldef = &errorformat
	set errorformat=%EFile\ \"%f\"\\,\ line\ %l\\,\ characters\ %c-%k:,%Z%m
	exe "cf " . error_file
	let &errorformat=l:oldef
	" remove error file
	call system("rm -f " . error_file . " 2>&1")
endfunction
