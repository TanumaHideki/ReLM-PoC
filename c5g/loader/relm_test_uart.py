import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        LED(
            hex3=0b0110111,  # U
            hex2=0b1111110,  # A
            hex1=0b0001100,  # r
            hex0=0b0101101,  # t
        ),
        Do()[
            Do()[uin := Int(IO("UART", 0x40000000) & 0x400000FF),].While(uin == 0),
            Out("LED", uin),
            uout := Int((uin & 0xFF) | 0x80000000),
            Do()[IO("UART", uout) & 0x80000000].While(Acc == 0),
            Do()[IO("UART", uout) & 0x80000000].While(Acc == 0),
        ],
    ]
