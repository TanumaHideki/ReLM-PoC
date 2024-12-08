import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[adc := ADC()]
    Thread[
        x_max := Int(),
        x_min := Int(x_max(adc.read())),
        state := Int(),
        Do()[
            x := Int(adc.read()),
            Out("RGBLED1", x << 3 | 6),
            x_th := Int(),
            If(x <= x_th((x_max + x_min) >> 1))[
                If(state != 0)[
                    signal := Int(1),
                    state(0),
                    x_min(x_th),
                ],
                If(x < x_min)[x_min(x)],
            ].Else[
                If(state == 0)[
                    state(3),
                    x_max(x_th),
                ],
                If(x > x_max)[x_max(x)],
            ],
            Out("RGBLED2", ((1 << (x >> 5)) - 1) << 3 | state),
        ],
    ]
    Thread[
        Do()[
            If(signal == 0)[Continue()],
            Out("RGBLED4", 0b1111111111101),
            Acc(200000),
            Do()[...].While(Acc - 1 != 0),
            Out("RGBLED4", 0b111),
            signal(0),
        ]
    ]
