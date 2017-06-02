if exists('g:loaded_spacetea') && g:loaded_spacetea
  finish
endif

if has('nvim')
  com! -nargs=? SpaceTea call spacetea#activate('<args>')
else
  com! -nargs=? SpaceTea echoerr "Requires neovim"
endif

aug SpaceTea
aug end

" TODO: move these mappings out of here
nnoremap <space>t :SpaceTea<CR>

