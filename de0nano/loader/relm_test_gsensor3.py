import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[gs := GSensor()]
    Define[
        picture := Array(
            0b11111111,
            0b00110001,
            0b01010001,
            0b10001110,
            0b00000000,
            0b01111000,
            0b10010100,
            0b10010100,
            0b01001000,
            0b00000000,
            0b11111111,
            0b10000000,
            0b10000000,
            0b10000000,
            0b00000000,
            0b11111111,
            0b00000010,
            0b00000100,
            0b00000010,
            0b11111111,
        ),
    ]
    Thread[
        gs.Write(0x2C, 0x0F),
        gs.Write(0x31, 0x47),
        gs.Write(0x2D, 0x08),
        x := Int(-32),
        Do()[
            If(gs.Read(0x30) & 0x80 == 0)[Continue()],
            a := Int(gs.Read(0x35)),
            If(a >= 16)[x(-32)].Else[x(x + 1)],
            i := Int(x >> 3),
            If((i >= 0) & (i < len(picture.data)))[Out("LED", picture[i])].Else[Out("LED", 0)],
        ],
    ]
