from spacetea.datastore import buf_get_actions
from spacetea.ui import stepthru_add_action


def handle_request(nvim, name, args):
    assert name == "respond-to-word", "Unexpected notification {}".format(name)
    assert args == [''], "Unexpected args {!r}".format(args)

    # TODO: get the user to choose between these things:
    # - add a test/linter/!exe to this buffer
    # - remove a test that's already added to the buffer
    # - modify a test that's already added to the buffer
    # - reorder the tests
    # - make this buffer an output buffer

    buf = nvim.current.buffer
    #bufnr = buf.number
    actions = buf_get_actions(buf)

    # if we have no tests for the current buffer, go straight to the menu item
    # for adding an action
    if actions:
        with open('/tmp/q', 'a') as _f:  # TODO
            _f.write('actions = %r\n' % (actions, ))  # noqa
        raise Exception("TODO: show menu for adding/modifying existing actions")  # noqa
    else:
        stepthru_add_action(nvim, buf)


def handle_notification(nvim, name, args):
    raise Exception("unexpected notification {}{!r}\n".format(name, args))
