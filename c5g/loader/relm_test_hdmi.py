import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *


Define[i2c := I2C(),]

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        Out("HDMIPAL", *[i * 0x11111101 + 0x80 for i in range(16)]),
        Do()[
            Do()[
                i2c.read(0x72, 0x42),  # HPD State, Monitor Sense State
                Out("LED", RegB),
            ].While(
                RegB & 0x6000 != 0x6000  # wait for HPD high & clock detect
            ),
            i2c.update(0x72, 0x41, 0x40, 0),  # POWER DOWN => Normal Operation
            i2c.write(0x72, 0x98, 0x03),  # must be set to 0x03
            i2c.update(0x72, 0x9A, 0xE0, 0xE0),  # must be set to 0b1110000*
            i2c.write(0x72, 0x9C, 0x30),  # must be set to 0x30
            i2c.update(0x72, 0x9D, 0x03, 0x01),  # must be set to 1
            i2c.write(0x72, 0xA2, 0xA4),  # must be set to 0xA4
            i2c.write(0x72, 0xA3, 0xA4),  # must be set to 0xA4
            i2c.write(0x72, 0xE0, 0xD0),  # must be set to 0xD0
            Out("HDMIPAL", 0x40),  # reset counter
            Do()[
                Acc("HDMI"),
                Array(*([0xFEDCBA98, 0x01234567] * (40 * 120))),
                Acc("VRAM"),
                Array(
                    159 << 19,
                    *([(159 << 19) + (1 << 18) + 256] * 119),
                ),
                Acc("HDMI"),
                Array(*([0xFEDCBA98, 0x01234567] * (40 * 120))),
                Acc("VRAM"),
                Array(
                    159 << 19,
                    *([(159 << 19) + (1 << 18) + 256] * 119),
                ),
                i2c.read(0x72, 0x42),  # HPD State, Monitor Sense State
            ].While(
                RegB & 0x6000 == 0x6000  # detect unplug
            ),
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
