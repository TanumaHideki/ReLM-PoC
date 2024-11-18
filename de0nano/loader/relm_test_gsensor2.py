import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[gs := GSensor()]
    Thread[
        gs.write(0x2C, 0x0D),
        gs.write(0x31, 0x40),
        gs.write(0x2D, 0x08),
        c := Int(3),
        Do()[
            gs.read(0x30),
            If(RegB & 0x80000000 == 0)[Continue()],
            gs.read(0x32),
            RegB((RegB >> 21) | c, "RGBLED1").opb("OUT"),
            c((c << 1) & 7 | (c >> 2) & 1),
        ],
    ]
