let s:save_cpo = &cpo
set cpo&vim

"variable {{{
if !exists('g:Qfstatusline#UpdateCmd')
    echohl ErrorMsg | echomsg "vim-qfstatusline: require 'g:Qfstatusline#UpdateCmd = function()'" | echohl None
    finish
endif
let g:Qfstatusline#Text = ! exists('g:Qfstatusline#Text') ? 1 :                                     g:Qfstatusline#Text
let s:checkDict         = ! exists('s:checkDict')         ? {'check': 0, 'text': '', 'wtext': ''} : s:checkDict
let s:CommonPatternWMessage = 'L%l(%n) M:%m'
let s:CommonPatternWoMessage = 'Error: L%l(%n)'
if !exists('g:Qfstatusline#ErrorConfig')
	let g:Qfstatusline#ErrorConfig = {'pattern':'e'}
	if g:Qfstatusline#Text ==# 1
		let g:Qfstatusline#ErrorConfig['format'] = s:CommonPatternWMessage
	else
		let g:Qfstatusline#ErrorConfig['format'] = s:CommonPatternWoMessage
	endif
endif
if !exists('g:Qfstatusline#WarningConfig')
	let g:Qfstatusline#WarningConfig = {'pattern':'w'}
	if g:Qfstatusline#Text ==# 1
		let g:Qfstatusline#WarningConfig['format'] = s:CommonPatternWMessage
	else
		let g:Qfstatusline#WarningConfig['format'] = s:CommonPatternWoMessage
	endif
endif
"}}}
function! qfstatusline#Qfstatusline() abort "{{{
    let s:checkDict = {'check': 1, 'text': '', 'wtext': ''}

    return g:Qfstatusline#UpdateCmd()
endfunction "}}}
function! qfstatusline#Update(...) abort "{{{
    if s:checkDict.check ==# 0
        return s:checkDict.text
    endif

    let s:errorDict = {'num': 9999, 'text': ''}
    let s:errorFnr  = []
    let s:warnDict = {'num': 9999, 'text': ''}
    let s:warnFnr  = []

    let s:type = 'error'
    if a:0 >=1 && a:1 ==# 'warning'
			let s:type = 'warning'
    endif

"		let s:pattern = '.'
"		let s:type = 'error'
"		if a:0 >= 1 && a:1 ==# 'error'
"			let s:pattern = g:Qfstatusline#ErrorConfig['pattern']
"		elseif a:0 >=1 && a:1 ==# 'warning'
"      let s:pattern = g:Qfstatusline#WarningConfig['pattern']
"      let s:type = 'warning'
"    endif

    call s:copy_from_qflist()

    return s:output_status_text()
	endfunction "}}}
function! s:copy_from_qflist() abort "{{{
    let l:bufnr = bufnr('%')

    for l:qfrow in getqflist()
				if l:qfrow.bufnr ==# l:bufnr && 0 < l:qfrow.lnum && count(s:errorFnr, l:qfrow.lnum) ==# 0 && match(l:qfrow.type, g:Qfstatusline#ErrorConfig['pattern']) !=# -1
            if l:qfrow.lnum <= s:errorDict.num
                let s:errorDict = {'num': l:qfrow.lnum, 'text': l:qfrow.text}
            endif
            call add(s:errorFnr, l:qfrow.lnum)
				endif
				if l:qfrow.bufnr ==# l:bufnr && 0 < l:qfrow.lnum && count(s:warnFnr, l:qfrow.lnum) ==# 0 && match(l:qfrow.type, g:Qfstatusline#WarningConfig['pattern']) !=# -1
            if l:qfrow.lnum <= s:warnDict.num
                let s:warnDict = {'num': l:qfrow.lnum, 'text': l:qfrow.text}
            endif
            call add(s:warnFnr, l:qfrow.lnum)
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
        let s:checkDict['check'] = 0
        let s:checkDict['text'] = l:status_text
    else
        let s:checkDict['check'] = 0
				let s:checkDict['text'] = ''
    endif

    let l:warnFnrLen = len(s:warnFnr)
    if 0 < l:warnFnrLen
        let l:status_text = g:Qfstatusline#WarningConfig['format']
        if match(l:status_text, '%n') !=# -1
            let l:status_text = substitute(l:status_text, '%n', l:warnFnrLen, 'g')
        endif
        if match(l:status_text, '%l') !=# -1
           let l:status_text = substitute(l:status_text, '%l', s:warnDict.num, 'g')
        endif
        if match(l:status_text, '%m') !=# -1
           let l:status_text = substitute(l:status_text, '%m', s:warnDict.text, 'g')
        endif
        let s:checkDict['check'] = 0
        let s:checkDict['wtext'] = l:status_text
    else
        let s:checkDict['check'] = 0
        let s:checkDict['wtext'] = ''
    endif

    if s:type ==# 'error'
        return s:checkDict.text
    else
        return s:checkDict.wtext
    endif
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

