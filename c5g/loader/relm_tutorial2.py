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
        Do()[
            t := UInt(In("TIMER")),
            Out("LED", t >> 14),
            disp(t >> 18),
        ],
    ]
