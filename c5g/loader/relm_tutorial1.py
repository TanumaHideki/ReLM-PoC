import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        Do()[
            Out("LED", In("TIMER") >> 14),
        ],
    ]
