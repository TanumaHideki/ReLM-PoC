import sys
import math
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import ConsoleArray

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
    Thread[console := ConsoleArray(vram, 80, FIFO.Alloc(), FIFO.Alloc())]
    Define[
        digit_fp := Function(value := Float(), plus := Int())[
            If(value & 0x80000000 == 0)[If(plus != 0)[console.Print("+"),],].Else[
                console.Print("-"),
            ],
            va := Float(abs(value) + 0.0000005),
            vt := Float(math.trunc(va)),
            console.PrintInt(ToInt(vt), "dddddd"),
            console.Print("."),
            console.PrintInt(ToInt((va - vt) * 1000000.0), "00000d"),
        ],
    ]
    Thread[
        x := Float(123456.789),
        i := Int(0),
        While(i < 9)[
            console.Print("        x = ", pos=i * (800 * 5), color=0x0F),
            digit_fp(x),
            console.Print(",        -x = "),
            digit_fp(-x),
            console.Print(" trunc(x) = ", pos=i * (800 * 5) + 800, color=0xF0),
            digit_fp(math.trunc(x)),
            console.Print(", trunc(-x) = "),
            digit_fp(math.trunc(-x)),
            console.Print("  ceil(x) = ", pos=i * (800 * 5) + 800 * 2),
            digit_fp(math.ceil(x)),
            console.Print(",  ceil(-x) = "),
            digit_fp(math.ceil(-x)),
            console.Print(" round(x) = ", pos=i * (800 * 5) + 800 * 3),
            digit_fp(round(x)),
            console.Print(", round(-x) = "),
            digit_fp(round(-x)),
            console.Print(" floor(x) = ", pos=i * (800 * 5) + 800 * 4),
            digit_fp(math.floor(x)),
            console.Print(", floor(-x) = "),
            digit_fp(math.floor(-x)),
            x(x * 0.1),
            i(i + 1),
            If(i == 8)[x(0.0)],
        ],
        LED(
            hex3=0b0001100,  # r
            hex2=0b0000111,  # u
            hex1=0b0001110,  # n
            hex0=0b0011111,  # d
        ),
    ]
