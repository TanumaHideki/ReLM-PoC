import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        LED(
            hex3=0b0111110,  # H
            hex2=0b1101101,  # E
            hex1=0b0100101,  # L
            hex0=0b1110111,  # O
        ),
        Do()[
            key := Int(In("KEY")),
            red := Int((key & 0b11111111110000) << 4),
            gr0 := Int((key & 0b1) * 0b11),
            gr1 := Int((key & 0b10) * 0b110),
            gr2 := Int((key & 0b100) * 0b1100),
            gr3 := Int((key & 0b1000) * 0b11000),
            Out("LED", (red | gr0 | gr1 | gr2 | gr3) ^ -(key >> 14)),
        ],
    ]
