if ! exists('g:vim_peter')
  let g:vim_peter = 1
endif

if ! exists('g:hackymappings')
  let g:hackymappings = 0
endif

" sensible defaults to start with
if &compatible
	setglobal nocompatible
endif

set confirm

" 256-color mode for vim8/neovim
if exists('&termguicolors')
  " NOTE: this needs to be set at startup
  set termguicolors

  " NOTE: I had to manually set these options to get truecolor to work in vim8
  " in iTerm2/tmux, but I think I actually prefer sticking with 256-color mode
  " in regular vim because it helps me figure out which one I'm using ...
  if ! has('nvim')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif

elseif has('nvim') && &term == 'screen'
  " TODO: what was this for?
  "set term=screen-256color
endif

" runtimepath modifications {{{

  if g:allow_rtp_modify

    " if we are using neovim, we have to manually add ~/.vim to rtp
    if has('nvim')
      let &runtimepath = '~/.vim,' . &runtimepath . ',~/.vim/after'
    endif

    " add our own vim/ folder to runtimepath
    let s:local = expand('<sfile>:h').'/vim'
    let &runtimepath = printf('%s,%s,%s/after', s:local, &runtimepath, s:local)
    unlet s:local

    " add the <vim-est> thing if it is present
    if isdirectory(expand('~/src/vim-est.git'))
      let &runtimepath = &runtimepath . ','.expand('~/src/vim-est.git')
    endif

    let &runtimepath = '~/.vimpathogen,' . &runtimepath . ',~/.vim/pathogen/after'

    " use pathogen to find things still hanging around in vimplug
    execute pathogen#infect(expand('<sfile>:h').'/vimplug/{}')

  endif

" }}}


" set up Vundle if it's present and not in &rtp yet
let s:plugpath = $HOME.'/.vim/autoload/plug.vim'
if filereadable(s:plugpath)
  " use different path depending on vim/nvim
  let s:plugins = has('nvim') ? '~/.nvim/plugged' : '~/.vim/plugged'

  call plugmaster#begin('~/src/plugedit', '~/src', s:plugins) " {{{

  Plug 'EinfachToll/DidYouMean'
  Plug 'FooSoft/vim-argwrap'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'davidhalter/jedi-vim'
  Plug 'hynek/vim-python-pep8-indent'
  Plug 'msanders/snipmate.vim'
  Plug 'sjl/Clam.vim'
  Plug 'tmux-plugins/vim-tmux'
  Plug 'easymotion/vim-easymotion'

  Plug 'justinmk/vim-sneak'

  " skip gutentags when there is no ctags executable installed
  let g:gutentags_tagfile = '.tags'
  Plug 'justinmk/vim-gutentags', executable('ctags') ? {} : {'on': []}

  " {{{
    " just always use Differ now that it's pretty stable
    "Plug 'nathan-hoad/differ'
    augroup UseDiffer
    augroup end
    autocmd!
    if has('nvim')
      "autocmd! UseDiffer BufWritePost * call Differ()
      "autocmd! UseDiffer BufReadPost * call Differ()
    endif
  " }}}
  
  PlugMaster 'phodge/vim-javascript-syntax'
  PlugMaster 'phodge/vim-python-syntax'
  PlugMaster 'phodge/vim-jsx'
  PlugMaster 'phodge/MicroRefactor'
  PlugMaster 'phodge/vim-shell-command'
  PlugMaster 'phodge/vim-syn-info'
  PlugMaster 'phodge/vim-split-search'
  PlugMaster 'phodge/vim-auto-spell'
  PlugMaster 'phodge/vim-vimui'
  PlugMaster 'phodge/vim-myschema'
  PlugMaster 'phodge/vim-vcs'
  PlugMaster 'phodge/vim-hiword'

  "Plug 'python-rope/ropevim'
  Plug 'rizzatti/dash.vim'
  Plug 'scrooloose/syntastic'
  Plug 'ternjs/tern_for_vim'
  Plug 'tpope/vim-fugitive', {'tag': '*'}
  Plug 'tpope/vim-obsession'
  Plug 'tpope/vim-repeat'

  let g:dispatch_quickfix_height = 10
  Plug 'tpope/vim-dispatch'

  " FIXME: I should make my own github repos from these
  Plug 'vim-scripts/StringComplete'
  Plug 'vim-scripts/InsertChar'
  Plug 'vim-scripts/AfterColors.vim'

  " custom PHP syntax - causes problems when g:php_show_semicolon_error is
  " turned on though
  Plug 'vim-scripts/php.vim--Hodge'
  let g:php_show_semicolon_error = 0
  let g:php_alt_construct_parents = 1
  let g:php_alt_arrays = 2
  let g:php_highlight_quotes = 1
  let g:php_alt_properties = 1
  let g:php_smart_members = 1


  " TODO: use frozen option for plugins on the BBVPN that we don't have access
  " to all the time
  Plug 'vim-scripts/Align', {'frozen': 0}
  
  " makes the cursor change shape when in insert mode
  if has('nvim')
    let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
  else
    " NOTE: normally you're not supposed to do this, but I have different
    " plugin paths for vim/nvim so this works for me
    Plug 'sjl/vitality.vim'
  endif

  call plug#end() " }}}
endif


" vim/tmux navigator keybindings {{{

  let g:tmux_navigator_no_mappings = 1
  if g:vim_peter
    if has('nvim')
      tnoremap <silent> <M-h> <C-\><C-n>:TmuxNavigateLeft<cr>
      tnoremap <silent> <M-j> <C-\><C-n>:TmuxNavigateDown<cr>
      tnoremap <silent> <M-k> <C-\><C-n>:TmuxNavigateUp<cr>
      tnoremap <silent> <M-l> <C-\><C-n>:TmuxNavigateRight<cr>
      nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
      nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
      nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
      nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
      "nnoremap <silent> <M-w> :TmuxNavigatePrevious<cr>
    else
      nnoremap <silent> <ESC>h :TmuxNavigateLeft<cr>
      nnoremap <silent> <ESC>j :TmuxNavigateDown<cr>
      nnoremap <silent> <ESC>k :TmuxNavigateUp<cr>
      nnoremap <silent> <ESC>l :TmuxNavigateRight<cr>
      " these don't seem to work :-(
      "nnoremap <silent> <ESC>w :TmuxNavigatePrevious<cr>
    endif
  else
    if has('nvim')
      tunmap <M-h>
      tunmap <M-h>
      tunmap <M-h>
      tunmap <M-h>
      tunmap <M-h>
    endif
    silent! nunmap <ESC>h
    silent! nunmap <ESC>j
    silent! nunmap <ESC>k
    silent! nunmap <ESC>l
    silent! nunmap <ESC>w
    silent! nunmap <M-h>
    silent! nunmap <M-j>
    silent! nunmap <M-k>
    silent! nunmap <M-l>
    silent! nunmap <M-w>
  endif

" }}}

" the most important change to my vimrc in a long long time
if has('mouse')
  set mouse=a
  " the netrw mouse mappings are annoying and not something I want
  let g:netrw_mousemaps = 0

  " mouse support in massive windows
  if has('mouse_sgr')
      set ttymouse=sgr
  endif
endif

colors elflord
set autoindent
set completeopt=menu,menuone,preview

set modeline modelines=2000
set sessionoptions+=globals,localoptions
" pretend that windows / OS X care about file name case
if exists('&fileignorecase')
  set nofileignorecase
endif

set hlsearch incsearch

" added from the VimTools wiki page
if ! exists('s:vim_entered')
  set encoding=utf-8
endif

set fileencoding=utf-8

" ESC key times out much quicker to prevent accidentally sending escape
" sequences manually
set timeoutlen=500 " 40ms

set fileformats=unix,dos,mac


" use \\ as mapleader
let g:mapleader = '\\'

" use <F5> and <F6> to run ack searches
nnoremap <F5> :Ack -w <C-R><C-W><CR>
nnoremap <F6> :Ack -wi <C-R><C-W><CR>

" use F12 for reloading :Shell windows
let g:shell_command_reload_map = '<F12>'

" use F12 in any other buffer to reload ALL shell windows
nnoremap <F12> :ShellRerun<CR>


" options for JEDI-vim
let g:jedi#use_splits_not_buffers = "winwidth"
let g:jedi#show_call_signatures = 1
let g:jedi#smart_auto_mappings = 0
let g:jedi#popup_on_dot = 0

" syntastic config
if ! exists('g:syntastic_python_checkers')
  let g:syntastic_python_checkers = ['flake8']
endif
if ! exists('g:syntastic_javascript_checkers')
  let g:syntastic_javascript_checkers = executable('eslint') ? ['eslint'] : []
endif

filetype plugin indent on
syntax on

" fix markdown filetype
augroup CustomFiletype
autocmd! BufNewFile,BufReadPost *.md set filetype=markdown
augroup end



if version >= 703
  if has('nvim')
    set undodir=~/.nvim/.undo
  else
    set undodir=~/.vim/.undo
  endif
  set undofile
endif


if g:vim_peter && version >= 700
  if ! exists('g:_matches')
    let g:_matches = []
  endif

  nnoremap gM :call <SID>AddMatch()<CR>
  function! <SID>AddMatch() " {{{
    call add(g:_matches, expand('<cword>'))
    execute 'match Error' '/' . join(g:_matches, '\|') . '/'
  endfunction " }}}
  nnoremap [33~ :let g:_matches = [] <BAR> match<CR>
  nnoremap <S-F9> :let g:_matches = [] <BAR> match<CR>
endif


nnoremap gm :let @/ = expand('<cword>')<CR>:set hls<CR>

function! ExcaliburQuitWindow() " {{{
  " what is the current buffer number?
  let l:current_bufnr = bufnr("")

  " is this the last buffer?
  let l:is_last = bufnr("$") == l:current_bufnr

  " use bwipeout to get rid of the current buffer
  bwipeout
  
  " if we are still on the same buffer, it means there was nothing else to
  " load (only other buffers are help buffers)
  if bufnr("") == l:current_bufnr
    " in this case, we just want to quit vim altogether
    echohl WarningMsg
    echo 'Exiting ...'
    echohl None
    quit
  endif

  " if a new buffer was created for us, it means we should have quit
  if l:is_last && bufnr("") > l:current_bufnr
    echohl WarningMsg
    echo 'Exiting ...'
    echohl None
    quit
  endif
endfunction " }}}

nnoremap <F8> :syn sync fromstart<CR>:exe 'setlocal foldmethod=' . &l:foldmethod<CR>
nnoremap <F9> :nohls<CR>

if version >= 700
  " StringComplete plugin
  inoremap <C-J> <C-O>:set completefunc=StringComplete#GetList<CR><C-X><C-U>
endif

nnoremap <SPACE>a :ArgWrap<CR>
nnoremap <SPACE>m :<C-R>=(exists(':Make')==2?'Make':'make')<CR><CR>

if version >= 700 && g:vim_peter
  nnoremap gss :call MySchema#GetSchema(expand('<cword>'))<CR>
endif

" use <ENTER> to activate CleverEdit in visual mode
if g:vim_peter
  if version >= 700
    vnoremap <CR> y:call CleverEdit#go()<CR>
  endif
  vnoremap <SPACE>v y:call MicroRefactor#LocalVariable()<CR>
else
  silent! vunmap <CR>
endif

" InsertChar plugin {{{

  if g:vim_peter
    if version >= 700
      nnoremap <TAB> :<C-U>call InsertChar#insert(v:count1)<CR>
    else
      nnoremap <TAB> iX<ESC>r
    endif
    " g<TAB> can be used to get the normal behaviour of <TAB>
    nnoremap g<TAB> <TAB>
  elseif strlen(maparg("\<TAB>", 'n'))
    silent! nunmap <TAB>
    silent! nunmap g<TAB>
  endif

" }}}

" nicer statusline
if g:vim_peter && version >= 700
  set statusline=
  set statusline+=%n\ \ %f
  set statusline+=\ %{(&l:ff=='dos')?':dos:\ ':''}%m%<%r%h%w
  " syntastic errors
  set statusline+=%#Error#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  set statusline+=%=
  " gutentags
  set statusline+=%{exists('*gutentags#statusline')?gutentags#statusline('[T]\ '):''}
  " ruler
  set statusline+=Line\ %l\ \ \ %v/%{col('$')-1}\ \ \ 
  " character under cursor
  set statusline+=0x%B
  set statusline+=\ %p%%
endif

" favourite options
set autoindent
set ruler
set showcmd
set laststatus=2
set wildmenu
set wildmode=longest,list,full
set backspace=indent,eol,start
set hlsearch
nohlsearch
set incsearch
set history=10000
set splitbelow splitright noequalalways winwidth=126 winminwidth=15
set number
set shiftround ts=4 sw=4 sts=0
set nolist
"set listchars=tab:\|_,trail:@,precedes:<,extends:>
set listchars=tab:\|_,trail:@
set showbreak=...

set scrolloff=2
set sidescroll=20
set sidescrolloff=20


" ninja mappings {{{

    " n for next search always searches downwards.
    if g:vim_peter
      if exists('v:searchforward')
        " n and N _always_ search forward/backward respectively
        nnoremap <silent> <expr> n (v:searchforward ? 'n' : 'N') . 'zv'
        nnoremap <silent> <expr> N (v:searchforward ? 'N' : 'n') . 'zv'
      else
        nnoremap n /<C-R>/<CR>
        nnoremap N ?<C-R>/<CR>
      endif
    else
      silent! nunmap n
      silent! nunmap N
    endif


    " backspace hides the popup menu
    if exists('*pumvisible')
      inoremap <expr> <BS> pumvisible() ? " \<BS>\<BS>" : "\<BS>"
    endif

    " use the slightly better gF instead of gf
    nnoremap gf gF
    
    " when using i{ in line-wise Visual mode, don't revert to character-wise
    " mode
    vnoremap i{ i{V
    vnoremap i} i}V
    vnoremap a{ a}V
    vnoremap a} a}V

    " make CTRL+E and CTRL+Y scroll twice as fast
    nnoremap <C-E> 2<C-E>
    nnoremap <C-Y> 2<C-Y>

    " yank and paste keeps cursor in the same column
    nnoremap <silent> yyp mtyyp`tj

    if g:vim_peter
      nnoremap <silent> $ g$
      nnoremap <silent> ^ g^
      nnoremap <silent> 0 g0
      nnoremap <silent> g$ $
      nnoremap <silent> g^ ^
      nnoremap <silent> g0 0
      nnoremap <silent> j gj
      nnoremap <silent> k gk
      nnoremap <silent> gj j
      nnoremap <silent> gk k
    else
      silent! nunmap $
      silent! nunmap ^
      silent! nunmap g$
      silent! nunmap g^
      silent! nunmap j
      silent! nunmap k
      silent! nunmap gj
      silent! nunmap gk
    endif

    if g:vim_peter
      nnoremap zl 20zl
      nnoremap zh 20zh
    else
      silent! nunmap zl
      silent! nunmap zh
    endif

    if version >= 700
      " use \u to toggle between normal and regular undo
      nnoremap <silent> \u :call <SID>ToggleUndo()<CR>
      function! <SID>ToggleUndo() " {{{
        if exists('s:undo_advanced')
          " turn super undo OFF
          unlet s:undo_advanced
          nunmap u
          nunmap <C-R>
          let l:type = 'Basic'
        else
          " turn super undo ON
          " change u and C-R to use full undo history instead
          nnoremap u g-
          nnoremap <C-R> g+
          let l:type = 'Full History'
          let s:undo_advanced = 1
        endif
        echohl Question
        echo 'Undo:' l:type
        echohl None
      endfunction " }}}
    endif

    if g:vim_peter
      " dp and do automatically jump to the next change
      nnoremap <silent> dp dp]c
      nnoremap <silent> do do]c
    else
      silent! nunmap dp
      silent! nunmap do
    endif
    
    " r(, r[, and r{ will replace BOTH brackets
    if g:vim_peter
      nnoremap r( :call <SID>ReplaceBrackets('()')<CR>
      nnoremap r[ :call <SID>ReplaceBrackets('[]')<CR>
      nnoremap r{ :call <SID>ReplaceBrackets('{}')<CR>
    elseif strlen(maparg("r(", 'n'))
      nunmap r(
      nunmap r[
      nunmap r{
    endif
    
    function! <SID>ReplaceBrackets(newbrackets) " {{{
      " if the letter under the cursor is an opening bracket, replace both at once
      let l:line = line('.')
      let l:col = col('.')
      let l:replace = strpart(getline(l:line), l:col - 1, 1)
      if l:replace =~ '[([{]'
        " can we find the matching bracket?
        normal! %

        " if the line number or column number has changed, then we found it!
        if (line('.') != l:line) || (col('.') != l:col) && (line('.') <= (l:line + 10))
          " replace this character and then go back
          execute 'normal! r' . a:newbrackets[1]
          call cursor(l:line, l:col)
        endif
      endif

      " do the original replace as requested
      execute 'normal! r' . a:newbrackets[0]
    endfunction " }}}


" }}}


" dirty hacks to make F-keys and keypad work when term type is wrong {{{

  if g:hackymappings " {{{
    map 0k +
    map 0m -
    map g0k g+
    map g0m g-

    " TODO: add F-keys
  endif

" }}}


" mappings {{{

  " toggle options quickly
  nnoremap \c :exe 'setlocal colorcolumn='.((&l:colorcolumn=='') ? '+2' : '').' colorcolumn?'<CR>
  nnoremap \d :exe 'setlocal diffopt' . ((&g:diffopt =~ 'iwhite') ? '-' : '+') . '=iwhite diffopt?'<CR>
  nnoremap \e :Sexplore<CR>:diffoff<CR>
  nnoremap \l :set list! list?<CR>
  nnoremap \n :set number! number?<CR>
  nnoremap \p :set paste! paste?<CR>
  nnoremap \w :set wrap! wrap?<CR>
  nnoremap \q :call ExcaliburQuitWindow()<CR>
  " essentially :tabclose but also works when there is only one tab
  nnoremap \t :windo quit<CR>

  " this is about the only mapping that's safe for others
  nnoremap gt :execute 'tj' expand('<cword>')<CR>zv
  nnoremap gst :execute 'stj' expand('<cword>')<CR>zv

  " fugitive
  nnoremap \g :Gstatus<CR><C-w>T
  nnoremap \i :Shell git diff --cached<CR>

  if g:vim_peter
    nnoremap <silent> go :call <SID>NewlineNoFO('o')<CR>xa
    nnoremap <silent> gO :call <SID>NewlineNoFO('O')<CR>xa
    function! <SID>NewlineNoFO(command) " {{{
      let l:foldopt = &l:formatoptions
      try
        setlocal formatoptions-=o
        execute 'normal! ' . a:command . 'x'
      finally
        " restore format options
        let &l:formatoptions = l:foldopt
      endtry
    endfunction " }}}

    nnoremap gh :tabprev<CR>
    nnoremap gl :tabnext<CR>

    nnoremap gsf :call <SID>GSF()<CR>zv
    function! <SID>GSF() " {{{
        try
            sp
            normal! gF
        catch
            close
            redraw!
            echohl Error
            echo v:exception
            echohl None
        endtry
    endfunction " }}}

    nnoremap + 4<C-W>+
    nnoremap - 4<C-W>-
    nnoremap g+ <C-W>_

    inoremap <C-L> <C-X><C-F>

    " <F8> should backspace word chunks
    inoremap <F8> _<SPACE><ESC>:call <SID>SuperBackspace()<CR>s
    function! <SID>SuperBackspace() " {{{
      normal! d?\%(_\+\zs\|\l\zs\u\|\<\zs\w\|\w\zs\>\)
    endfunction " }}}

    " map F2 to align code to '=', F3 is '=>' and F4 is ':'
    vnoremap <F1> mt:Align! p0 ,<CR>gv:s/\(\s\+\),/,\1/g<CR>gv:s/,\s\+$/,/g<CR>`t
    vnoremap <F2> mt:Align! p0P0 \s=\s<CR>`t
    vnoremap <F3> mt:Align =><CR>`t
    vnoremap <F4> mt:Align! p0 :<CR>gv:s/\(\s\+\):/:\1/g<CR>`t

    " use c" to swap quote types {{{
    
      nnoremap <silent> c" :call <SID>SwapQuotes()<CR>

      function! <SID>SwapQuotes() " {{{
          " we'll use the default register, but we want to save its contents first ...
          let l:tempZ = @z

          let l:pos = getpos('.')

          try
              " NOTE: we do a few :normal commands in here and it's probably safer if we
              " turn off the autocommands while we're doing this ...
              let l:old_ei = &eventignore
              set eventignore=all

              let l:old_paste = &paste

              " we need to work out what kind of quote we're in?
              if ! search('[^\\]\zs[''"]', 'bcW', line('.'))
                  echoerr "Quotes not found!"
                  return
              endif

              " grab the character under the cusor (should be ' or ")
              normal! "zyl
              if (@z == '"') || (@z == "'")
                  let l:quote = @z
              else
                  echoerr "No quote???"
                  return
              endif

              " now we delete the inside of the quoted region ...
              execute 'normal! "zdi' . l:quote
              " ... and store it somewhere
              let l:newQuote = (l:quote == '"') ? "'" : '"'
              let l:insert = l:newQuote . @z . l:newQuote

              " now we must delete the quotes (again, using @z register) and insert
              " everything back in.
              " NOTE: we use the 'paste' option to prevent formatting changes
              set paste
              execute 'normal! h"z2s' . l:insert

          " cleanup here
          finally
              " 1: restore our 'z' register
              if exists('l:tempZ') | let @z = l:tempZ | endif
              " 2: put the cursor back
              if exists('l:pos') | call setpos('.', l:pos) | endif
              " 3: restore 'paste' option
              if exists('l:old_paste') | let &paste = l:old_paste | endif
              " 4: restore autocommands
              if exists('l:old_ei') | let &eventignore = l:old_ei | endif
          endtry
      endfunction " }}}


    " }}}

    " use g/ in visual mode to search only in that line range
    vnoremap <expr> g/ "\<ESC>" . <SID>GetVisualSearch()

    function! <SID>GetVisualSearch() " {{{
      return printf('/\%%>%dl\&\%%<%dl\&', line("'<") - 1, line("'>") + 1)
    endfunction " }}}

  elseif strlen(maparg('go', 'n'))
    nunmap go
    nunmap gO
    nunmap gh
    nunmap gl
    nunmap gsf
    nunmap +
    nunmap -
    nunmap g+
    nunmap <UP>
    nunmap <DOWN>
    nunmap <LEFT>
    nunmap <RIGHT>
    nunmap c"
    vunmap g/
  endif

  nnoremap gF :call <SID>GFNotSetup('gF')<CR>
  nnoremap gsF :call <SID>SplitGF()<CR>
  function! <SID>GFNotSetup(cmd) " {{{
    echohl Error
    echo a:cmd . ' is not defined for filetype=' . &l:filetype
    echohl None
  endfunction " }}}
  function! <SID>SplitGF() " {{{
    let l:split = 0
    split
    let l:split = 1
    setlocal noscrollbind
    try
      normal gF
    catch
      " close the new window if the command didn't work
      if l:split
        close
      endif
      redraw!
      echohl Error
      echo 'gsF: ' . v:exception
      echohl None
    endtry
  endfunction " }}}

" }}}



" commands for navigating file history (git-only I believe)
command! -nargs=0 GitOlder call VCS#GitNavigateHistory(1)
command! -nargs=0 GitNewer call VCS#GitNavigateHistory(0)

" command for starting an SQL window
command! -nargs=0 SQLWindow call MySchema#SQLWindow()

" don't like this plugin
let g:loaded_matchparen = 1

augroup ExcaliburVCS
autocmd! BufReadPost,BufNewFile * let b:excalibur_vcs = VCS#DetermineVCS()
augroup end

if g:vim_peter
  nnoremap gD :call <SID>ShowDiff()<CR>
  function! <SID>ShowDiff()
    if exists('b:excalibur_vcs') && b:excalibur_vcs == 'hg'
      call VCS#SplitHGDiff()
    else
      call VCS#GitDiff('HEAD')
    endif
  endfunction
else
  nunmap gD
endif

if has('osx')
  " if we're running under OS X, yank into the main clipboard by default
  " NOTE: this is different in vim vs neovim
  set clipboard=unnamed
endif


command! -nargs=+ Man ConqueTermVSplit man <q-args>


function! EditRealPath()
  let l:filename = expand('%:p')
  let l:realpath = resolve(l:filename)

  " if we are editing the real file, don't try and open it up
  if l:realpath == l:filename
    return
  endif

  " if the realpath file doesn't exist, don't try and edit it
  if ! filereadable(l:realpath)
    return
  endif

  " remember local options/settings?
  let l:oldbufnr = bufnr("")
  " edit a new empty file (this will copy options/cwd etc from the buffer)
  enew
  " wipe out the old buffer
  execute 'bwipeout' l:oldbufnr
  " re-edit the old file again but with the real path
  " NOTE: because we use :edit with the new empty buffer opened, we get all
  " our local options back
  execute 'edit' l:realpath
endfunction

augroup EditRealPath
augroup end
autocmd! EditRealPath BufReadPost * nested if exists('g:edit_real_path') && g:edit_real_path | call EditRealPath() | endif


augroup PowerlineCFG
augroup end
autocmd! PowerlineCFG BufRead powerline/**/*.json setlocal sts=2 sw=2 ts=2 et


" TODO: move this into a plugin once I have a good system for doing so
augroup Jerjerrod
augroup end
au! Jerjerrod BufWritePost * call <SID>JerjerrodInit()

fun! <SID>JerjerrodInit()
  " replace or remove the autocommand
  au! Jerjerrod
  if executable('jerjerrod')
    au! Jerjerrod BufWritePost * call <SID>JerjerrodClearCache()
    call <SID>JerjerrodClearCache()
  endif
endfunction

fun! <SID>JerjerrodClearCache()
  if has('*jobstart')
    call jobstart(['jerjerrod', 'clearcache', '--local', expand('%')])
  else
    silent exe '!jerjerrod clearcache --local '.shellescape(expand('%'))
    redraw!
  endif
endfunction


fun! <SID>Hiwords()
  if ! exists(':Hiword')
    return
  endif
  syntax off
  Hiword Conditional if
  Hiword Conditional else
  Hiword Conditional elseif
  Hiword Conditional elif
  Hiword Conditional for
  Hiword Conditional while
  Hiword Conditional do
  Hiword Conditional foreach
  Hiword Operator in
  Hiword Operator not
  Hiword Operator and
  Hiword Operator or
  Hiword Macro import
  Hiword Macro from
  Hiword Macro def
  Hiword Typedef self
  Hiword Statement yield
  Hiword Statement return
  Hiword Statement break
  Hiword Statement continue
  Hiword IncSearch TODO
  Hiword IncSearch test
  Hiword IncSearch FIXME
endfun
call <SID>Hiwords()
au! VimEnter * call <SID>Hiwords()


let s:vim_entered = 1
