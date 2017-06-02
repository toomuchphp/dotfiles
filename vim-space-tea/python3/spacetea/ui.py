import os
from enum import Enum
from functools import partial

from spacetea.datastore import ShellCommand, buf_add_action

HEADING_HL = 'Statement'
NUMBER_HL = 'Macro'
OPTION_HL = 'Normal'
SHELL_PROMPT_HL = 'Operator'


def _quote(string):
    return "'{}'".format(string.replace("'", "''"))


def hlnone(callback):
    """
    A decorator that ensures `echohl None` is called at the end of the
    function, regardless of wether it works or not
    """
    def wrapper(nvim, *args, **kwargs):
        try:
            callback(nvim, *args, **kwargs)
        finally:
            try:
                nvim.command('echohl None')
            except Exception:
                pass

    wrapper.__doc__ = callback.__doc__
    wrapper.__name__ = callback.__name__
    return wrapper


def stepthru_add_action(nvim, buf):
    # TODO: choose from the following actions:
    # - run python unit tests
    # !shell-cmd
    # - Make / Neomake
    options = []
    basename = os.path.basename(buf.name)
    if basename.startswith('test_') and basename.endswith('.py'):
        options.append((
            #Actions.py_unit_tests,
            "Run python unit tests",
            partial(stepthru_add_py_unit_tests, nvim, buf),
        ))

    options.append((
        #Actions.shell_cmd,
        "Execute a shell command",
        partial(stepthru_add_shell_command, nvim, buf),
    ))

    #options.append((
        #Actions.shell_cmd,
        #"Make / Neomake or something",
        #partial(stepthru_add_neomake, nvim, buf),
    #))
    act_on_user_choice(nvim, "Choose an Action", options)


def stepthru_add_py_unit_tests(nvim, buf):
    raise Exception("TODO: show menu")  # noqa


@hlnone
def stepthru_add_shell_command(nvim, buf):
    nvim.command('echo " "')
    nvim.command('echohl {}'.format(HEADING_HL))
    nvim.command('echo {}'.format(_quote("Run a Shell Command")))
    nvim.command('echohl {}'.format(SHELL_PROMPT_HL))

    shell_command = nvim.call('input', ':!', '', 'shellcmd')

    def save_action(action):
        buf_add_action(buf, action)

    if len(shell_command):
        action = ShellCommand(shell_command)
        stepthru_select_output(nvim, buf, action, save_action)


def stepthru_select_output(nvim, buf, action, save_action):
    next = partial(stepthru_select_window, nvim, buf, action, save_action)
    options = []
    options.append((
        'Immediately',
        lambda: (action.output_immediately(), next()),
    ))
    options.append((
        'On completion',
        lambda: (action.output_always(), next()),
    ))
    options.append((
        'Only on failure',
        lambda: (action.output_on_failure(), next()),
    ))
    act_on_user_choice(nvim, "Show output window", options)


def stepthru_select_window(nvim, buf, action, save_action):
    # TODO: options are:
    # - a new nvim :terminal window (if we are showing immediately)
    # - a new regular buffer (if we are showing on completion)
    # - a new tmux pane in the current window session/window/pane
    # - a new tmux pane in the different window
    # - a new tmux pane in an existing window
    options = []
    options.append((
        'Buffer',
        lambda: (action.target_buffer_right(), save_action(action)),
    ))
    return options


@hlnone
def act_on_user_choice(nvim, heading, options):
    error = None
    while True:
        nvim.command('redraw!')
        nvim.command('echohl {}'.format(HEADING_HL))
        nvim.command('echo {}'.format(_quote(heading)))

        callbacks = []
        for label, func in options:
            nvim.command('echohl {}'.format(NUMBER_HL))
            nvim.command('echo "{} "'.format(len(callbacks) + 1))
            nvim.command('echohl {}'.format(OPTION_HL))
            nvim.command('echon {}'.format(_quote(label)))
            callbacks.append(func)

        if error:
            nvim.command('echohl Error')
            nvim.command('echo {}'.format(_quote(error)))

        nvim.command('echohl None')

        choice = nvim.call('input', 'Enter a number: ')
        if choice == '':
            return

        try:
            choice = int(choice)
        except (TypeError, ValueError):
            error = "Please enter a number"
            continue

        if choice < 1 or choice > len(callbacks):
            error = "Not a valid choice"
            continue

        callbacks[choice - 1]()
