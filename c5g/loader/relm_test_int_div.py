import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import ConsoleSRAM

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
                Out(
                    "VRAM",
                    159 << 19,
                    *([(159 << 19) + (1 << 18) + 256] * 479),
                ),
                i2c.read(0x72, 0x42),
            ].While(RegB & 0x6000 == 0x6000),
        ],
    ]
    Thread[console := ConsoleSRAM(256, FIFO.Alloc(), FIFO.Alloc())]
    Define[
        digits := Function(value := UInt(), digit := UInt())[
            fill := Int(ord(" ")),
            Do()[
                q := UInt(value // digit),
                value(value - digit * q),
                If((q != 0) | (digit == 1))[
                    If(q > 9)[q(9)], p := Int(q + fill(ord("0")))
                ].Else[p(fill)],
                console.fifo_print.Push(p),
            ].While(digit(digit // 10) != 0),
        ],
    ]
    Thread[
        console.Clear(),
        i := Int(0),
        x := UInt(1),
        While(i < 48)[
            console.Print("    ", pos=i * 2560, color=0xF0),
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
            hex3=0b0010010,  # I
            hex2=0b0011111,  # d
            hex1=0b0000100,  # i
            hex0=0b0000111,  # v
        ),
    ]
