import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        Out("HEX", 0b11000001 << 24, 0b00110001 << 16, 0b00001101 << 8, 0b00000011),
        Do()[
            Out("LED", In("TIMER") >> 14),
        ],
    ]
