from spacetea.const import BUFVARNAME


class Action:
    """An action attached to a buffer"""


class ShellCommand(Action):
    def __init__(self, shell_command):
        self._cmd = shell_command

    def to_args(self):
        return [self._cmd], {}


def buf_get_actions(buf):
    actions = []
    if BUFVARNAME in buf.vars:
        config = buf.vars[BUFVARNAME]
        actions = config['actions']
    return actions


def buf_add_action(buf, action):
    assert isinstance(action, Action)

    config = buf.vars.setdefault(BUFVARNAME, {})
    args, kwargs = action.to_args()

    actions = config.setdefault("actions", [])
    actions.append({
        "class": action.__class__.__name__,
        "args": args,
        "kwargs": kwargs,
    })
