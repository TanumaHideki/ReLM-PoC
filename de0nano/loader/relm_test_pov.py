import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *


def pov(y, c, led):
    block = Block[
        x0 := Int(),
        x1 := Int(),
        q := Int(x1(y[0] + x0) >> 8),
        x0(x1 - q * 0xFF),
    ]
    for i in range(1, 10):
        block[
            x0 := Int(),
            x1 := Int(),
            q := Int(x1(y[0] + x0) >> 8),
            x0(x1 - q * 0xFF),
        ]
    return block[Out(led, p[9])]


with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    red = [Float() for _ in range(40)]
    green = [Float() for _ in range(40)]
    blue = [Float() for _ in range(40)]
    black = [Float() for _ in range(40)]
    Thread[
        Do()[
            pov(red[0:10], 0b011, "RGBLED4"),
            pov(red[10:20], 0b011, "RGBLED3"),
            pov(red[20:30], 0b011, "RGBLED2"),
            pov(red[30:40], 0b011, "RGBLED1"),
            pov(green[0:10], 0b101, "RGBLED4"),
            pov(green[10:20], 0b101, "RGBLED3"),
            pov(green[20:30], 0b101, "RGBLED2"),
            pov(green[30:40], 0b101, "RGBLED1"),
            pov(blue[0:10], 0b110, "RGBLED4"),
            pov(blue[10:20], 0b110, "RGBLED3"),
            pov(blue[20:30], 0b110, "RGBLED2"),
            pov(blue[30:40], 0b110, "RGBLED1"),
        ]
    ]
    Define[adc := ADC()]
    Thread[
        x_max := Int(),
        x_min := Int(x_max(adc.read())),
        state := Int(),
        Do()[
            x := Int(adc.read()),
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
            Out("LED", (1 << (x >> 3)) - 1),
        ],
    ]
    Thread[
        *[
            Block[
                red[i]((i + 1) / 40.0),
                green[i]((40 - i) / 40.0),
                blue[i]((i + 1) / 40.0),
            ]
            for i in range(40)
        ]
    ]
