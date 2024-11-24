import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[adc := ADC()]
    Thread[
        Do()[
            Out("RGBLED1", adc.read()<<3),
        ],
    ]
