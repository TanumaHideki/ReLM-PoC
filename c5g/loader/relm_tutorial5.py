import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[
        digit := Array(
            0x1010100 + 0b11101111,
            0x1010100 + 0b00100101,
            0x1010100 + 0b10111011,
            0x1010100 + 0b10110111,
            0x1010100 + 0b01110101,
            0x1010100 + 0b11010111,
            0x1010100 + 0b11011111,
            0x1010100 + 0b10100101,
            0x1010100 + 0b11111111,
            0x1010100 + 0b11110111,
        ),
        disp := Function(n := UInt())[
            pos := UInt(1),
            Do()[
                q := UInt(),
                Out("HEX", digit[n - q(n // 10) * 10] * pos),
                pos(pos << 8),
            ].While(n(q) != 0),
        ],
    ]
    Thread[
        tstart := UInt(In("TIMER")),
        i := Int(1),
        s0 := Int(0),
        s1 := Int(0),
        Do()[
            s1(s0 + i),
            s0(s1 + i + 1),
        ].While(i(i + 2) <= 100),
        tend := UInt(In("TIMER")),
        disp(tend - tstart),
        Out("LED", s0),
    ]
print(sum(range(1, 101)))
print(bin(sum(range(1, 101))))
