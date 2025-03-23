import sys
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
        usb := USB(),
        hex := console.Hex(),
    ]
    Thread[
        LED(
            hex3=0b0110111,  # U
            hex2=0b1101011,  # S
            hex1=0b0101111,  # b
            hex0=0b0000000,
        ),
        console.Print("Reset Count:", pos=0, color=0xF0),
        bus_state := Int(usb.init()),
        digits(usb.reset_count, 10000),
        console.Print("Revision: 0x", pos=800),
        hex(usb.read(18), 0x100, 0),
        pos := Int(800 * 2),
        While(pos < 800 * 48)[
            console.Print("Bus State: 0x", pos=pos),
            hex(bus_state, 0x100, 0),
            Do()[
                If(IO("USB", 0x0000C001) != 0)[Continue(),],
                If((usb.read(25) & 0x20) != 0)[Break(),],
            ],
            bus_state(usb.busprobe()),
            usb.write(25, 0x20),
            pos(pos + 800),
        ],
    ]
