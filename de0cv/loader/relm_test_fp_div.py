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
    cos = [1.5 - 0.5 * math.cos(i * math.pi / 12.0) for i in range(12)]
    cos = (
        [-(c - 1.0) for c in cos[1:]]
        + cos
        + [-(c + 1.0) for c in cos]
        + [c + 2.0 for c in cos]
        + [-4.0]
    )
    Define[denom := ArrayF(*cos)]
    Thread[
        Out("VGAPAL", *[i * 0x1111 for i in range(16)]),
        i := Int(0),
        While(i < len(cos))[
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
            hex5=0b1101100,  # F
            hex4=0b1111100,  # P
            hex3=0b0000001,  # _
            hex2=0b0011111,  # d
            hex1=0b0000100,  # i
            hex0=0b0000111,  # v
        ),
    ]
