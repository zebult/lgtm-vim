if !exists("g:lgtm_random_list_count")
  let g:lgtm_random_list_count = 5
endif

function! s:lgtm()
  let res = webapi#http#get("http://www.lgtm.in/g", {}, {"Accept": "application/json"})
  if &ft == 'markdown'
    let content = webapi#json#decode(res.content)['markdown']
    let content = '![LGTM](' . webapi#json#decode(res.content)['imageUrl'] . ')'
  elseif &ft == 'html'
    let content = '<img src="' . webapi#json#decode(res.content)['imageUrl'] . '" alt="LGTM">'
  else
    let content = webapi#json#decode(res.content)['imageUrl']
  endif
  let line = getline('.')
  let indent = matchstr(line, '^\s\+')
  let content = join(map(split(content, "\n"), 'indent . v:val'))
  if line =~ '^\s*$'
    call setline('.', split(content, "\n"))
  else
    put! =content
  endif
  return ''
endfunction

function! s:lgtm_random_list()
  for i in range(1,g:lgtm_random_list_count,1)
    let res = webapi#http#get("http://www.lgtm.in/g", {}, {"Accept": "application/json"})
    let content = webapi#json#decode(res.content)['markdown']
    let content = '![LGTM](' . webapi#json#decode(res.content)['imageUrl'] . ')'
    let line = getline('.')
    let indent = matchstr(line, '^\s\+')
    let content = join(map(split(content, "\n"), 'indent . v:val'))
    let content_text = "\n\n`".content."`\n\n"
    put =content_text
    put =content
  endfor
  return ''
endfunction

inoremap <plug>(lgtm) <c-r>=<sid>lgtm()<cr>
nnoremap <plug>(lgtm) :<c-u>call <sid>lgtm()<cr>

if !hasmapto('<Plug>(lgtm)')
\  && (!exists('g:lgtm_no_default_key_mappings')
\      || !g:lgtm_no_default_key_mappings)
  silent! map <unique> <leader>lgtm <plug>(lgtm)
endif

command! LGTM call s:lgtm()
command! LGTMRandomList call s:lgtm_random_list()
