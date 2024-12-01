import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Thread[
        Do()[
            Acc("RGBLED1"),
            Code("OUT", 0b1010101010011),
            Acc(3),
            Do()[...].While(Acc - 1 != 0),
            Acc("RGBLED1"),
            Code("OUT", 0b0011001100101),
            Acc(3),
            Do()[...].While(Acc - 1 != 0),
            Acc("RGBLED1"),
            Code("OUT", 0b0011110000110),
            Acc(3),
            Do()[...].While(Acc - 1 != 0),
        ],
    ]
