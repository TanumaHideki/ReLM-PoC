import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Define[adc := ADC()]
    n = 32
    sram_n = sram.Alloc(n)
    Thread[
        d_th := Int(1),
        d_max := Int(),
        i := Int(),
        Do()[
            x := Int(sram_n[i]),
            y := Int(),
            sram_n[i](y(adc.read())),
            d := Int(x - y),
            If(d >= d_th)[signal := Int(1)],
            If(d > d_max)[d_max(d)],
            Out("RGBLED1", d << 3),
            i((i + 1) & (n - 1)),
        ],
    ]
    Thread[
        Do()[
            If(signal == 0)[Continue()],
            Out("RGBLED2", 0b1111111111011),
            Out("RGBLED3", 0b1111111111101),
            Out("RGBLED4", 0b1111111111110),
            d_max(0),
            Acc(300000),
            Do()[...].While(Acc - 1 != 0),
            Out("RGBLED2", 0b111),
            Out("RGBLED3", 0b111),
            Out("RGBLED4", 0b111),
            d_th((d_max + 1) >> 1),
            signal(0),
        ]
    ]
