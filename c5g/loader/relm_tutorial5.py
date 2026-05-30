import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[
        digit := Array(
            0x1010100 + 0b11101111, # 0
            0x1010100 + 0b00100101, # 1
            0x1010100 + 0b10111011, # 2
            0x1010100 + 0b10110111, # 3
            0x1010100 + 0b01110101, # 4
            0x1010100 + 0b11010111, # 5
            0x1010100 + 0b11011111, # 6
            0x1010100 + 0b10100101, # 7
            0x1010100 + 0b11111111, # 8
            0x1010100 + 0b11110111, # 9
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
        s := Int(0),
        Do()[
            s(s + i),
            s(s + i + 1),
        ].While(i(i + 2) <= 100),
        tend := UInt(In("TIMER")),
        disp(tend - tstart),
        Out("LED", s),
    ]
print(sum(range(1, 101)))
print(bin(sum(range(1, 101))))
