import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[gs := GSensor()]
    n = 64
    Thread[
        gs.write(0x2C, 0x0D),
        gs.write(0x31, 0x40),
        gs.write(0x2D, 0x08),
        i := Int(0),
        s1 := Int(0),
        s2 := Int(0),
        w := Int(0),
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
            Out("LED", v >> 14),
            If((w >= (1 << 18)) & (v < (1 << 18)))[
                signal := Int(1), Out("RGBLED1", 0b1111111111000)
            ].Else[Out("RGBLED1", 0b111), signal(0)],
            w(v),
        ],
    ]
    Thread[
        c := Int(3),
        Do()[
            If(signal == 0)[Continue()],
            Out("RGBLED2", 0b1111111111000 | c),
            c(((c * 9) >> 1) & 7),
            Acc(100000),
            Do()[...].While(Acc - 1 != 0),
            Out("RGBLED2", 0b111),
        ],
    ]
