import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[gs := GSensor()]
    n = 32
    Thread[
        gs.write(0x2C, 0x0D),
        gs.write(0x31, 0x40),
        gs.write(0x2D, 0x08),
        c := Int(3),
        i := Int(0),
        s1 := Int(0),
        s2 := Int(0),
        Do()[
            gs.read(0x30),
            If(RegB & 0x80000000 == 0)[Continue()],
            gs.read(0x32),
            y := Int(RegB >> 24),
            x := Int(sram[i]),
            sram[i](y),
            i((i + 1) & (n - 1)),
            s1(s1 + y - x),
            s2(s2 + y * y - x * x),
            v := Int(s2 * n - s1 * s1),
            RegB((v << 3) | c, "RGBLED1").opb("OUT"),
            RegB((v >> 7) & ~7 | c, "RGBLED2").opb("OUT"),
            c(((c * 9) >> 1) & 7),
        ],
    ]
