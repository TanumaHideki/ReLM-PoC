import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Thread[
        pwm_speed := 200,
        pwm_count := Int(),
        pwm_motor := Int(),
        Do()[
            If(pwm_count((pwm_count + 1) & 0xFF) == pwm_speed)[IO("MOTOR", 0)].Else[
                If(pwm_count == 0)[IO("MOTOR", pwm_motor)]
            ],
        ],
    ]
    Thread[
        timer := Timer(),
        Do()[
            timer.After(0.4),
            pwm_motor(0b1010),
            timer.Wait(),
            timer.After(0.4),
            pwm_motor(0b0101),
            timer.Wait(),
        ],
    ]
