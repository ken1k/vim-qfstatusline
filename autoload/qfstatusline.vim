let s:save_cpo = &cpo
set cpo&vim

"variable {{{
if !exists('g:Qfstatusline#UpdateCmd')
    echohl ErrorMsg | echomsg "vim-qfstatusline: require 'g:Qfstatusline#UpdateCmd = function()'" | echohl None
    finish
endif
let g:Qfstatusline#Text = ! exists('g:Qfstatusline#Text') ? 1 :                        g:Qfstatusline#Text
let s:checkDict         = ! exists('s:checkDict')         ? {'check': 0, 'text': ''} : s:checkDict
if !exists('g:Qfstatusline#ErrorConfig')
	let g:Qfstatusline#ErrorConfig = {'pattern':'e'}
	if g:Qfstatusline#Text ==# 1
		let g:Qfstatusline#ErrorConfig['format'] = 'L%l(%n) M:%m'
	else
		let g:Qfstatusline#ErrorConfig['format'] = 'L%l(%n)'
	endif
endif
"}}}
function! qfstatusline#Qfstatusline() abort "{{{
    let s:checkDict = {'check': 1, 'text': ''}

    return g:Qfstatusline#UpdateCmd()
endfunction "}}}
function! qfstatusline#Update(...) abort "{{{
    if s:checkDict.check ==# 0
        return s:checkDict.text
    endif

    let s:errorDict = {'num': 9999, 'text': ''}
    let s:errorFnr  = []

		let s:pattern = '.'
		if a:0 >= 1 && a:1 ==# 'error'
			let s:pattern = g:Qfstatusline#ErrorConfig['pattern']
		endif

    call s:copy_from_qflist()

    return s:output_status_text()
	endfunction "}}}
function! s:copy_from_qflist() abort "{{{
    let l:bufnr = bufnr('%')

    for l:qfrow in getqflist()
				if l:qfrow.bufnr ==# l:bufnr && 0 < l:qfrow.lnum && count(s:errorFnr, l:qfrow.lnum) ==# 0 && match(l:qfrow.type, s:pattern) !=# -1
            if l:qfrow.lnum <= s:errorDict.num
                let s:errorDict = {'num': l:qfrow.lnum, 'text': l:qfrow.text}
            endif
            call add(s:errorFnr, l:qfrow.lnum)
				endif
		endfor
endfunction "}}}
function! s:output_status_text() abort "{{{
    let l:errorFnrLen = len(s:errorFnr)
    if 0 < l:errorFnrLen
        let l:status_text = g:Qfstatusline#ErrorConfig['format']
        if match(l:status_text, '%n') !=# -1
           let l:status_text = substitute(l:status_text, '%n', l:errorFnrLen, 'g')
        endif
        if match(l:status_text, '%l') !=# -1
           let l:status_text = substitute(l:status_text, '%l', s:errorDict.num, 'g')
        endif
        if match(l:status_text, '%m') !=# -1
           let l:status_text = substitute(l:status_text, '%m', s:errorDict.text, 'g')
        endif
				let s:checkDict = {'check': 0, 'text': l:status_text}
		else
        let s:checkDict = {'check': 0, 'text': ''}
		endif

    return s:checkDict.text
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

