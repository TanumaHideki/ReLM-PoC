import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[gs := GSensor()]
    Thread[
        gs.Write(0x2C, 0x0F),
        gs.Write(0x31, 0x47),
        gs.Write(0x2D, 0x08),
        Do()[
            If(gs.Read(0x30) & 0x80 == 0)[Continue()],
            a := Int(gs.Read(0x33)),
            Out("LED", 1 << (a + 4)),
        ],
    ]
