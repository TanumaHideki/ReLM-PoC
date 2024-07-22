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
        digit := console.Decimal(),
        digits := Function(value := Int(), fill := Int())[
            digit(
                digit(
                    digit(
                        digit(
                            digit(
                                digit(
                                    digit(
                                        digit(digit(value, 100000000, fill), 10000000),
                                        1000000,
                                    ),
                                    100000,
                                ),
                                10000,
                            ),
                            1000,
                        ),
                        100,
                    ),
                    10,
                ),
                1,
                ord("0"),
            )
        ],
    ]
    Thread[
        Out("VGAPAL", *[i * 0x1111 for i in range(16)]),
        i := Int(0),
        x := Int(10),
        While(i < 48)[
            console.Print("x = ", pos=i * 800, color=0xF0),
            digits(x, ord(" ")),
            console.Print(",     x // 35121409 = "),
            q := Int(x // 35121409),
            digits(q, 0),
            console.Print(",     x % 35121409 = "),
            m := Int(x % 35121409),
            digits(m, ord(" ")),
            x(m * 10),
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
