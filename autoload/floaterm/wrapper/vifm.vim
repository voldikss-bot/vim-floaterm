" vim:sw=2:
" ============================================================================
" FileName: vifm.vim
" Author: kazhala <kevin7441@gmail.com>
" GitHub: https://github.com/kazhala
" ============================================================================

function! floaterm#wrapper#vifm#(cmd) abort
  let s:vifm_tmpfile = tempname()
  let original_dir = getcwd()
  lcd %:p:h

  let cmdlist = split(a:cmd)
  let cmd = 'vifm --choose-files "' . s:vifm_tmpfile . '"'
  if len(cmdlist) > 1
    let cmd .= ' ' . join(cmdlist[1:], ' ')
  else
    let cmd .= ' "' . getcwd() . '"'
  endif

  exe "lcd " . original_dir
  let cmd = [&shell, &shellcmdflag, cmd]
  return [cmd, {'on_exit': funcref('s:vifm_callback')}, v:false]
endfunction

function! s:vifm_callback(...) abort
  if filereadable(s:vifm_tmpfile)
    let filenames = readfile(s:vifm_tmpfile)
    if !empty(filenames)
      if has('nvim')
        call floaterm#window#hide(bufnr('%'))
      endif
      let locations = []
      for filename in filenames
        let dict = {'filename': fnamemodify(filename, ':p')}
        call add(locations, dict)
      endfor
      call floaterm#util#open(g:floaterm_open_command, locations)
    endif
  endif
endfunction
