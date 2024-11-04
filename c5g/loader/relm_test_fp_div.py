import sys
import math
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import Console

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[i2c := I2C(),]
    Thread[
        Out("HDMIPAL", *[i * 0x11111101 + 0x80 for i in range(16)]),
        Do()[
            Do()[
                i2c.read(0x72, 0x42),
                Out("LED", RegB),
            ].While(RegB & 0x6000 != 0x6000),
            i2c.update(0x72, 0x41, 0x40, 0),
            i2c.write(0x72, 0x98, 0x03),
            i2c.update(0x72, 0x9A, 0xE0, 0xE0),
            i2c.write(0x72, 0x9C, 0x30),
            i2c.update(0x72, 0x9D, 0x03, 0x01),
            i2c.write(0x72, 0xA2, 0xA4),
            i2c.write(0x72, 0xA3, 0xA4),
            i2c.write(0x72, 0xE0, 0xD0),
            Out("HDMIPAL", 0x40),
            Do()[
                Acc("HDMI"),
                vram := Array(*([0] * (80 * 480))),
                i2c.read(0x72, 0x42),
            ].While(RegB & 0x6000 == 0x6000),
        ],
    ]
    console = Console(vram, 80, FIFO.Alloc(), FIFO.Alloc())
    Thread[console.Service()]
    Define[
        digit := console.Decimal(),
        digit999999 := Function(value := Int(), fill := Int())[
            digit(
                digit(
                    digit(digit(digit(digit(value, 100000, fill), 10000), 1000), 100),
                    10,
                ),
                1,
                ord("0"),
            )
        ],
        digit_fp := Function(value := Float(), plus := Int())[
            If(value & 0x80000000 == 0)[
                va := Float(value + 0.0000005), If(plus != 0)[console.Print("+")]
            ].Else[va(-value + 0.0000005), console.Print("-")],
            vt := Float(math.trunc(va)),
            digit999999(ToInt(vt), 0),
            console.Print("."),
            digit999999(ToInt((va - vt) * 1000000.0), ord("0")),
        ],
    ]
    table = [1.0]
    table += [((1 << i) + 1) / (1 << i) for i in range(23, 1, -1)]
    table += [((1 << (i + 1)) - 1) / (1 << i) for i in range(1, 24)]
    Define[denom := ArrayF(*table)]
    Thread[
        i := Int(0),
        While(i < len(table))[
            x := Float(denom[i]),
            console.Print("x = ", pos=i * 800, color=0xF0),
            digit_fp(x, 0),
            y := Float(1.0 / x),
            console.Print("  y = "),
            digit_fp(y),
            console.Print("  xy = "),
            xy := Float(x * y),
            digit_fp(xy),
            console.Print("  xy-1 = "),
            digit_fp((xy - 1.0) * 8388608.0, 1),
            console.Print(" ulp"),
            i(i + 1),
        ],
        LED(
            hex3=0b1101100,  # F
            hex2=0b0011111,  # d
            hex1=0b0000100,  # i
            hex0=0b0000111,  # v
        ),
    ]
