" Title: Necro Vim
" Author: Lou Noizet
" Maintainer: Lou Noizet (lou@noizet.fr)
" Description: This plugin handles Skel files, and uses Necro to do stuff to
" them

if exists("g:necro_vim")
	finish
endif
let g:necro_vim = 1

function NecroParse()
