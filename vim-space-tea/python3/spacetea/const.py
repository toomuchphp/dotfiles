from enum import Enum

BUFVARNAME = '_spacetea_config'


class Actions(Enum):
    py_unit_tests = 1
    shell_cmd = 2
    Make = 3
    Neomake = 4
