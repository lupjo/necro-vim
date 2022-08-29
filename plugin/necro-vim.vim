" Title: Necro Vim
" Author: Lou Noizet
" Maintainer: Lou Noizet (lou@noizet.fr)
" Description: This plugin handles Skel files, and uses Necro to do stuff to
" them

if exists("g:necro_vim")
	finish
endif

let g:necro_vim = 1
let _ = system("necroparse --version")
let g:has_necrolib = (v:shell_error == 0)

if !g:has_necrolib
	echoerr "Necro Lib is not installed"
	finish
endif

function! NecroParse()
	let l:oldmakeprg = &makeprg
	echo(l:oldmakeprg)
	set makeprg=necroparse
	make -d %
	exe "set makeprg=" . l:oldmakeprg
endfunction
