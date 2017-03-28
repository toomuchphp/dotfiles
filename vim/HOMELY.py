from HOMELY import HERE, HOME, wantfull, wantjerjerrod, wantnvim, whenmissing
from homely.general import section
from homely.ui import allowinteractive, yesno

VIM_TAG = 'v8.0.0503'
NVIM_TAG = 'v0.1.7'


@section
def vim_config():
    import os
    from homely.general import (
        mkdir, symlink, download, lineinfile, blockinfile, WHERE_TOP, WHERE_END,
        haveexecutable, run)
    from homely.install import InstallFromSource

    # install vim-plug into ~/.vim
    mkdir('~/.vim')
    mkdir('~/.nvim')
    mkdir('~/.config')
    mkdir('~/.config/nvim')
    symlink('~/.vimrc', '~/.config/nvim/init.vim')
    mkdir('~/.vim/autoload')
    download('https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
             '~/.vim/autoload/plug.vim')

    def mkdir_r(path):
        assert len(path)
        if os.path.islink(path):
            raise Exception("Cannot mkdir_r(%r): path already exists but is a symlink" % path)

        # if the thing already exists but isn't a dir, then we can't create it
        if os.path.exists(path) and not os.path.isdir(path):
            raise Exception("Cannot mkdir_r(%r): path already exists but is not a dir" % path)

        # create the parent then our target path
        parent = os.path.dirname(path)
        if len(parent) > 5:
            mkdir_r(parent)
        mkdir(path)

    def _static(url, dest):
        dest = HOME + '/.vimstatic/' + dest
        mkdir_r(os.path.dirname(dest))
        download(url, dest)

    vprefs = HOME + '/.vim/prefs.vim'
    nprefs = HOME + '/.nvim/prefs.vim'

    # chuck in a reference to our shiny new vimrc.vim (this will end up below the rtp magic block)
    lineinfile('~/.vimrc', 'source %s/vimrc.vim' % HERE, where=WHERE_TOP)

    # put our magic &rtp block at the top of our vimrc
    blockinfile('~/.vimrc',
                [
                    '  " reset rtp',
                    '  set runtimepath&',
                    '  " let other scripts know they\'re allowed to modify &rtp',
                    '  let g:allow_rtp_modify = 1',
                    '  " grab local preferences',
                    '  if filereadable(%r)' % vprefs,
                    '    source %s' % vprefs,
                    '  endif',
                    '  if has(\'nvim\') && filereadable(%r)' % nprefs,
                    '    source %s' % nprefs,
                    '  endif',
                ],
                '" {{{ START OF dotfiles runtimepath magic',
                '" }}} END OF dotfiles runtimepath magic',
                where=WHERE_TOP)

    # if the .vimrc.preferences file doesn't exist, create it now
    if not os.path.exists(vprefs):
        with open(vprefs, 'w') as f:
            f.write('let g:vim_peter = 1\n')

    # make sure we've made a choice about clipboard option in vprefs file
    @whenmissing(vprefs, 'clipboard')
    def addclipboard():
        if allowinteractive():
            if yesno(None, 'Use system clipboard in vim? (clipboard=unnamed)', None):
                rem = "Use system clipboard"
                val = 'unnamed'
            else:
                rem = "Don't try and use system clipboard"
                val = ''
            with open(vprefs, 'a') as f:
                f.write('" %s\n' % rem)
                f.write("set clipboard=%s\n" % val)

    # put a default value about whether we want the hacky mappings for when the
    # terminal type isn't set correctly
    @whenmissing(vprefs, 'g:hackymappings')
    def sethackymappings():
        with open(vprefs, 'a') as f:
            f.write('" Use hacky mappings for F-keys and keypad?\n')
            f.write('let g:hackymappings = 0\n')

    # in most cases we don't want insight_php_tests
    @whenmissing(vprefs, 'g:insight_php_tests')
    def setinsightphptests():
        with open(vprefs, 'a') as f:
            f.write('" Do we want to use insight to check PHP code?\n')
            f.write('let g:insight_php_tests = []\n')

    # lock down &runtimepath
    lineinfile('~/.vimrc', 'let g:allow_rtp_modify = 0', where=WHERE_END)

    # if we have jerjerrod installed, add an ALWAYSFLAG entry for git repos in ~/src/plugedit
    if False and wantjerjerrod():
        mkdir('~/.config')
        mkdir('~/.config/jerjerrod')
        lineinfile('~/.config/jerjerrod/jerjerrod.conf', 'PROJECT ~/src/plugedit/*.git ALWAYSFLAG')

    # icinga syntax/filetype
    if yesno('want_vim_icinga_stuff', 'Install vim icinga2 syntax/ftplugin?', default=False):
        files = ['syntax/icinga2.vim', 'ftdetect/icinga2.vim']
        for name in files:
            url = 'https://raw.githubusercontent.com/Icinga/icinga2/master/tools/syntax/vim/{}'
            _static(url.format(name), name)

    # <est> utility
    hasphp = haveexecutable('php')
    if yesno('install_est_utility', 'Install <vim-est>?', hasphp):
        est = InstallFromSource('https://github.com/phodge/vim-est.git',
                                '~/src/vim-est.git')
        est.select_branch('master')
        est.symlink('bin/est', '~/bin/est')
        run(est)


@section
def vim_install():
    import os
    from homely.ui import system
    from homely.general import run, mkdir
    from homely.install import InstallFromSource

    # TODO: prompt to install a better version of vim?
    # - yum install vim-enhanced
    if not yesno('compile_vim', 'Compile vim from source?', wantfull()):
        return

    local = HOME + '/src/vim.git'

    mkdir('~/.config')
    flagsfile = HOME + '/.config/vim-configure-flags'
    written = False
    if not os.path.exists(flagsfile):
        written = True
        # pull down git source code right now so that we can see what the configure flags are
        if not os.path.exists(local):
            system(['git', 'clone', 'https://github.com/vim/vim.git', local])
        out = system([local + '/configure', '--help'], stdout=True, cwd=local)[1]
        with open(flagsfile, 'w') as f:
            f.write('# put configure flags here\n')
            f.write('--with-features=huge\n')
            f.write('--enable-pythoninterp=yes\n')
            f.write('--enable-python3interp=yes\n')
            f.write('\n')
            f.write('\n')
            for line in out.decode('utf-8').split('\n'):
                f.write('# ')
                f.write(line)
                f.write('\n')
    if yesno(None, 'Edit %s now?' % flagsfile, written, noprompt=False):
        system(['vim', flagsfile], stdout="TTY")

    # NOTE: on ubuntu the requirements are:
    # apt-get install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
    inst = InstallFromSource('https://github.com/vim/vim.git', '~/src/vim.git')
    inst.select_tag(VIM_TAG)
    configure = ['./configure']
    with open(flagsfile) as f:
        for line in f:
            if not line.startswith('#'):
                configure.append(line.rstrip())
    inst.compile_cmd([
        configure,
        ['make'],
        ['sudo', 'make', 'install'],
    ])
    run(inst)


@section
def nvim_install():
    from homely.general import run
    from homely.install import InstallFromSource
    if wantnvim():
        # TODO: we suggest yum installing
        # - cmake
        # - gcc-c++
        # - unzip (seriously ... the error on this one is aweful)
        # NOTE: on ubuntu the requirements are:
        # apt-get install libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
        n = InstallFromSource('https://github.com/neovim/neovim.git', '~/src/neovim.git')
        n.select_tag(NVIM_TAG)
        n.compile_cmd([
            ['make'],
            ['sudo', 'make', 'install'],
        ])
        run(n)


@section
def nvim_devel():
    import os
    from homely.ui import system
    from homely.general import mkdir, symlink
    if not wantnvim():
        return

    if not yesno('install_nvim_devel', 'Put a dev version of neovim in playground-6?', False):
        return

    # my fork of the neovim project
    origin = 'ssh://git@github.com/phodge/neovim.git'
    # the main neovim repo - for pulling
    neovim = 'https://github.com/neovim/neovim.git'
    # where to put the local clone
    dest = HOME + '/playground-6/neovim'

    # create the symlink for the neovim project
    mkdir('~/playground-6')
    symlink(HERE + '/vimproject/neovim', dest + '/.vimproject')

    if os.path.exists(dest):
        return

    # NOTE: using system() directly means the dest directory isn't tracked by
    # homely ... this is exactly what I want
    system(['git', 'clone', origin, dest])
    system(['git', 'remote', 'add', 'neovim', neovim], cwd=dest)
    system(['git', 'fetch', 'neovim', '--prune'], cwd=dest)
