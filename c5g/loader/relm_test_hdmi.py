import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *


Define[
    i2c := I2C(),
]

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
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
                vram := Array(*([0xFEDCBA98, 0x01234567] * (40 * 480))),
                i2c.read(0x72, 0x42),
            ].While(RegB & 0x6000 == 0x6000),
        ],
    ]
    Thread[
        LED(
            hex3=0b0111110,  # H
            hex2=0b1010111,  # D
            hex1=0b1110110,  # M
            hex0=0b0110110,  # I
        ),
    ]
