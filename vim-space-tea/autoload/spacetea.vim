let s:root = expand('<sfile>:h:h')

fun! spacetea#activate(word)
  try
    call <SID>StartOrRestartHelper(a:word == "restart-helper")
  catch
    echohl Error
    echo v:exception
    echohl None
    return
  endtry

  " if the command was restart-helper, then we're already done
  redraw!
  if a:word == "restart-helper"
    echohl Question
    echo "Helper [re]started"
    echohl None
    return
  endif

  " everything else is handled by the helper directly
  call rpcrequest(s:helper, "respond-to-word", a:word)
  call rpcnotify(s:helper, "opportunity-to-do-things")
endfun

fun! <SID>StartOrRestartHelper(force_restart)
  if exists('s:helper')
    " if the helper already exists, check to see if it's still valid
    let l:result = jobwait([s:helper], 0)

    " -1 means the helper is still alive
    if l:result[0] == -1
      if a:force_restart
        call jobstop(s:helper)
      else
        return
      endif
    endif

    " literally anything else means the job has ended and we need to make a
    " new one (presumably the process has already died)
    unlet s:helper
  endif

  " Start up the python helper if it isn't already running
  " raises an exception if it doesn't work for some reason
  let l:pythonpath = s:root.'/python3'
  let l:helper = s:root.'/python3/bin/spaceteahelper'
  let l:cmd = 'PYTHONPATH='.l:pythonpath.' '.l:helper
  let s:helper = jobstart(l:cmd, {"rpc": v:true, "on_stderr": "spacetea#stderr"})
endfun

fun! spacetea#stderr(...)
  silent exe '!echo -e '.shellescape(join(a:2, '\n')).' >> ~/.nvimlog'
  redraw!
  echohl Error
  echo 'spaceteahelper: stderr copied to ~/.nvimlog'
  echohl None
endfun
