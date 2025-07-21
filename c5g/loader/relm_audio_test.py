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
        audio.i2c(0, 0x17),  # LEFT-CHANNEL ADC INPUT VOLUME: LINMUTE=0
        audio.i2c(1, 0x17),  # RIGHT-CHANNEL ADC INPUT VOLUME: RINMUTE=0
        audio.i2c(2, 0x79),  # LEFT-CHANNEL DAC VOLUME
        audio.i2c(3, 0x79),  # RIGHT-CHANNEL DAC VOLUME
        audio.i2c(
            4, 0x15
        ),  # ANALOG AUDIO PATH: SIDETONE_EN=0, DACSEL=1, Bypass=0, INSEL=1, MUTEMIC=0, MICBOOST=1
        audio.i2c(5, 0x01),  # DIGITAL AUDIO PATH: ADCHPF=1
        audio.i2c(
            6, 0x61
        ),  # POWER MANAGEMENT: PWROFF=0, CLKOUT=1, OSC=1, Out=0, DAC=0, ADC=0, MIC=0
        audio.i2c(7, 0x42),  # DIGITAL AUDIO I/F: MS=1, WL=00
        audio.i2c(8, 0x02),  # SAMPLING RATE: SR=0000, BOSR=1 (48kHz)
        audio.i2c(16, 0x1FB),  # ALC CONTROL 1: ALCSEL=11
        audio.i2c(17, 0x32),  # ALC CONTROL 2
        audio.i2c(18, 0x00),  # NOISE GATE
        audio.i2c(9, 0x01),  # ACTIVE: Active=1
        LED(
            hex3=0b1111110,  # A
            hex2=0b0000111,  # u
            hex1=0b0011111,  # d
            hex0=0b0001111,  # o
        ),
        fifo1 := FIFO.Alloc(2000),
        Do()[
            Acc(fifo1.port),
            a := Array(*([0] * 2000)),
            i := Int(1000),
            Do()[fifo1.Push((audio.Pop() >> 16) + (audio.Pop() >> 16)),].While(
                i(i - 1) != 0
            ),
            i := Int(0),
            Do()[
                x := Int(),
                fifo1.Push(x((audio.Pop() >> 16) + (audio.Pop() >> 16))),
                a[999 - i](x),
                a[1000 + i](x),
            ].While(i(i + 1) != 1000),
        ],
    ]
    Thread[Do()[audio.Push(((fifo1.Pop() >> 1) & 0xFFFF) * 0x10001),],]
