import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        Out("HEX", 0b11101111_00100101_10111011_10110111), # 0123
        Do()[
            Out("LED", In("TIMER") >> 14),
        ],
    ]
