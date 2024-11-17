import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[gs := GSensor()]
    Thread[
        gs.write(0x2C, 0x0B),
        gs.write(0x31, 0x4F),
        gs.write(0x2D, 0x08),
        count := Int(0),
        Do()[
            gs.read(0x30),
            If(RegB & 0x8000 == 0)[Continue()],
            gs.read(0x32, 2),
            If(RegB ^ 0x8000 < 0x8030)[
                If(count >= 32)[signal := Int(1)], count(0)
            ].Else[count(count + 1)],
        ],
    ]
    Thread[
        signal(0),
        Do()[...].While(signal == 0),
        period := Int(0),
        signal(0),
        Do()[period(period + 1)].While(signal == 0),
        period := Int(period),
        Do()[
            signal(0),
            signal2 := Int(1),
            Acc(period),
            Do()[...].While(Acc - 1 != 0),
            If(signal == 0)[
                Do()[...].While(signal == 0),
                period(period + 1),
            ].Else[period(period - 1)],
        ],
    ]
    Thread[
        Do()[
            If(signal2 == 0)[Continue()],
            Out("RGBLED1", 0b1111111111101),
            Out("RGBLED2", 0b1111111111101),
            Acc(100000),
            Do()[...].While(Acc - 1 != 0),
            Out("RGBLED1", 0b111),
            Out("RGBLED2", 0b111),
            signal2(0),
        ]
    ]
