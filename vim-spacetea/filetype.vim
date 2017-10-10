if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  au! BufRead,BufNewFile .spacetea setfiletype spacetea
augroup END
