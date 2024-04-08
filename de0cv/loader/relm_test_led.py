import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0cv import *

with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Thread[
        LED(
            hex5=0b0111110,  # H
            hex4=0b1101101,  # E
            hex3=0b0100101,  # L
            hex2=0b0100101,  # L
            hex1=0b1110111,  # O
            hex0=0b0000001,  # _
        ),
        Do()[
            key := Int(In("KEY")),
            Out("LED0", ((key & 0b11111) ^ (key >> 5)) * 2 + 1),
        ],
    ]
