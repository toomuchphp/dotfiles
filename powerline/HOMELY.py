import os
from homely.ui import yesno, system, isinteractive
from homely.general import mkdir, lineinfile, WHERE_END, writefile, section
from HOMELY import HERE, HOME, wantpowerline, powerline_path


@section
def powerline():
    if wantpowerline():
        mkdir('~/.config')
        mkdir('~/.config/powerline')
        paths = [
            "%s/config_files" % powerline_path(),
            "%s/powerline" % HERE,
            "%s/.config/powerline" % HOME,
        ]
        lineinfile('~/.shellrc',
                   'export POWERLINE_CONFIG_PATHS=%s' % ":".join(paths),
                   where=WHERE_END)

        # ask the user what colour prefs they would like and put it in
        # ~/.config/powerline/colors.sh
        colourfile = os.path.join(HOME, '.config', 'powerline', 'colours.sh')
        load = False
        defaults = dict(
            bg="gray1",
            fg1="white",
            fg2="gray6",
        )
        if not os.path.exists(colourfile):
            if isinteractive() and yesno('Select base colours now?', True):
                # load available colours from colors.json
                with open("%s/config_files/colors.json" % powerline_path()) as f:
                    import simplejson
                    colors = simplejson.load(f)
                with open(colourfile, 'w') as f:
                    f.write("# primary background colour\n")
                    f.write("bg=%(bg)s\n" % defaults)
                    f.write("# foreground colour for highlighted tab\n")
                    f.write("fg1=%(fg1)s\n" % defaults)
                    f.write("# foreground colour for other tabs\n")
                    f.write("fg2=%(fg2)s\n" % defaults)
                    f.write("# possible colours:\n")
                    for name in sorted(colors.get("colors", {})):
                        f.write("#   %s\n" % name)
                system(['vim', colourfile], stdout="TTY")
                load = True
        else:
            load = True
            if isinteractive() and yesno('Select base colours now?', False):
                system(['vim', colourfile], stdout="TTY")

        colourset = defaults
        if load:
            with open(colourfile, 'r') as f:
                for line in [l.rstrip() for l in f]:
                    if len(line) and not line.startswith('#'):
                        import pprint
                        print('line = ' + pprint.pformat(line))  # noqa TODO
                        name, val = line.split('=')
                        colourset[name] = val
        data = {}
        data["groups"] = {
            "window:current":       {"bg": colourset["bg"],  "fg": colourset["fg1"], "attrs": []},
            "window_name":          {"bg": colourset["bg"],  "fg": colourset["fg1"], "attrs": ["bold"]},  # noqa
            "session:prefix":       {"bg": colourset["bg"],  "fg": "gray90", "attrs": ["bold"]},
            "active_window_status": {"fg": colourset["fg2"], "bg": "gray0", "attrs": []},
            "hostname":             {"bg": colourset["bg"],  "fg": "gray90", "attrs": []},
        }
        # write out a colorscheme override for tmux using our powerline colours
        mkdir('~/.config')
        mkdir('~/.config/powerline')
        mkdir('~/.config/powerline/colorschemes')
        mkdir('~/.config/powerline/colorschemes/tmux')
        import simplejson
        dumped = simplejson.dumps(data)
        with writefile('~/.config/powerline/colorschemes/tmux/default.json') as f:
            f.write(dumped)