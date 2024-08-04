import sys
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
        digits := Function(value := UInt(), digit := UInt())[
            fill := Int(ord(" ")),
            Do()[
                q := Int(value // digit),
                value(value - digit * q),
                If((q != 0) | (digit == 1))[p := Int(q + fill(ord("0")))].Else[p(fill)],
                console.fifo_print.Push(p),
            ].While(digit(digit // 10) != 0)
        ],
    ]
    Thread[
        Out("VGAPAL", *[i * 0x1111 for i in range(16)]),
        i := Int(0),
        x := UInt(1),
        While(i < 48)[
            console.Print("    ", pos=i * 800, color=0xF0),
            digits(x, 1000000000),
            console.Print(" // 35121409 = "),
            q := UInt(x // 35121409),
            digits(q, 10),
            console.Print("        "),
            digits(x, 1000000000),
            console.Print(" % 35121409 = "),
            m := UInt(x % 35121409),
            digits(m, 10000000),
            x(m * 100),
            i(i + 1),
        ],
        LED(
            hex5=0b0010010,  # I
            hex4=0b0001110,  # n
            hex3=0b0101101,  # t
            hex2=0b0011111,  # d
            hex1=0b0000100,  # i
            hex0=0b0000111,  # v
        ),
    ]
