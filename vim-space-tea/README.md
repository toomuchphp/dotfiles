VIM SPACE TEA
=============

<space>-t
---------

Space Tea is a plugin that allows you to set up one or more generic mappings
that quickly performs some action to build or test your code.

TYPES OF ACTIONS
- run unit test(s)
- run a linter
- `!make [something]` and async variants
- run arbitrary script

USEFUL FEATURES
- automatically detect py.test tests and give you a UI for picking one or more
  of them. If you pick a py.test script, it gives you the option of also
  running a) the other tests in that file and b) all the project's tests if the
  first test passes.
- automatically detect nudge sockets and give you a UI for telling it to poke one
- can add a BufWritePost autocmd for you
- <space>o makes a buffer an "output" buffer - this sets the 'autoread' option,
  and the plugin will even connect to neovim for you and tell it to reopen the
  buffer every 100ms.
- You can tell space tea to show the output of the thing:
  - as soon as it starts; or
  - when it's done; or
  - only when it fails
  ... and you can have the output:
  - in a vim buffer; or
  - in a neovim :terminal window; or
  - in a tmux session+window (a new or existing pane will be used)
  - in a new iTerm window (with customisable profile)
  And the output pane/vim window:
  - is reused on subsequent runs
  - can be configured to be opened to the Left/Right/Top/Bottom
- The last [N] outputs are recorded in separate files so that you can jump back
  to an old copy of the output quickly, either in the output pane, or a new vim
  buffer (in case you wanted to diff)
- puts a msg in the tmux statusline or neovim statusline while it is working
  (and by message, I do of course mean U+1F375 'TEACUP WITHOUT HANDLE')
- remembers how you had things set up last time and asks if you want to do it
  again that way.
- if the command was a py.test run and a traceback occurs, checks to see if the
  traceback is from one of our buffers
- if you re-invoke testing procedure

TEST TRIGGER
- BufWritePost
- <space>t mapping -> :SpaceTea runtests<CR>

ENDPOINTS
- :SpaceTea runtests
  - runs the configured tests for the current buffer, or runs :SpaceTea if none configured
- :SpaceTea
  Asks user how they want to configure test procedure for the current buffer.
  - create/add something to the test procedure for this buffer
  - use the procedure from <other buffer>
  - modify the procedure from <other buffer>
  - use an old test procedure from <list of old procedures that might be relevant>
  - remove something from the test procedure
  - change something existing in the test procedure (probably just pop it in an editable JSON file)
  - register an output window (type: tmux/vim-buffer/iterm profile)
  - deregister an output window
- :SpaceTea history
  - open one of the old output buffers
- :SpaceTea toggle-output [N]
