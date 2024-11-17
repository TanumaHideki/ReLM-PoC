import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    green = Label()
    blue = Label()
    Thread[
        Do()[
            Acc("RGBLED1"),
            align := Label(),
            Code("OUT", 0b1010101010011),
            green << "JUMP",
            Align(align),
            green,
            Code("OUT", 0b0011001100101),
            blue << "JUMP",
            Align(align),
            blue,
            Code("OUT", 0b0011110000110),
            Acc(2),
            Do()[...].While(Acc - 1 != 0),
        ],
    ]
