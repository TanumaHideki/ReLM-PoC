import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Thread[
        Do()[
            motor := Int((In("KEY") & 0b11) * 0b101),
            Out("LED", motor),
            IO("MOTOR", motor),
        ],
    ]
