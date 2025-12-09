import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[
        i2c := I2C(),
        audio := Audio(i2c),
    ]
    Thread[
        audio.Push(0),  # wait for PLL lock
        audio.i2c(15, 0x00),  # SOFTWARE RESET
        audio.i2c(9, 0x00),  # ACTIVE: Active=0
        audio.i2c(0, 0x3F),  # LEFT-CHANNEL ADC INPUT VOLUME: LINMUTE=0
        audio.i2c(1, 0x3F),  # RIGHT-CHANNEL ADC INPUT VOLUME: RINMUTE=0
        audio.i2c(2, 0x7F),  # LEFT-CHANNEL DAC VOLUME
        audio.i2c(3, 0x7F),  # RIGHT-CHANNEL DAC VOLUME
        audio.i2c(
            4, 0x15
        ),  # ANALOG AUDIO PATH: SIDETONE_EN=0, DACSEL=1, Bypass=0, INSEL=1, MUTEMIC=0, MICBOOST=1
        audio.i2c(5, 0x01),  # DIGITAL AUDIO PATH: ADCHPF=1
        audio.i2c(
            6, 0x61
        ),  # POWER MANAGEMENT: PWROFF=0, CLKOUT=1, OSC=1, Out=0, DAC=0, ADC=0, MIC=0
        audio.i2c(7, 0x42),  # DIGITAL AUDIO I/F: MS=1, WL=00
        audio.i2c(8, 0x02),  # SAMPLING RATE: SR=0000, BOSR=1 (48kHz)
        audio.i2c(16, 0x07B),  # ALC CONTROL 1: ALCSEL=00
        audio.i2c(17, 0x32),  # ALC CONTROL 2
        audio.i2c(18, 0x00),  # NOISE GATE
        audio.i2c(9, 0x01),  # ACTIVE: Active=1
        LED(
            hex3=0b1111110,  # A
            hex2=0b0000111,  # u
            hex1=0b0011111,  # d
            hex0=0b0001111,  # o
        ),
        Do()[
            x := Int(audio.Pop() >> 16),
            If(x > 0x400)[y := Int(1024**3 * 2)].Else[
                If(x < -0x400)[y(1024**3 * -2)].Else[y(x * ((1024**2 * 3) - x * x))]
            ],
            audio.Push((((y + (1 << 15)) >> 16) & 0xFFFF) * 0x10001),
        ],
    ]
