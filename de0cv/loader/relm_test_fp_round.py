import sys
import math
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0cv import *
from relm_font import Console

with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Thread[
        Acc("VGA"),
        Do()[vram := Array(*([0] * 80 * 480))],
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
        digit_fp := Function(value := Float())[
            If(value & 0x80000000 == 0)[va := Float(value + 0.0000005)].Else[
                va(-value + 0.0000005), console.Print("-")
            ],
            vt := Float(math.trunc(va)),
            digit999999(ToInt(vt), 0),
            console.Print("."),
            digit999999(ToInt((va - vt) * 1000000.0), ord("0")),
        ],
    ]
    Thread[
        Out("VGAPAL", *[i * 0x1111 for i in range(16)]),
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
            hex5=0b0001100,  # r
            hex4=0b0001111,  # o
            hex3=0b0000111,  # u
            hex2=0b0001110,  # n
            hex1=0b0011111,  # d
            hex0=0b0000000,  #
        ),
    ]
