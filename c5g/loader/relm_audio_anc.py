import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

sr_table = {
    8000: 0b001110,
    12000: 0b010010,
    16000: 0b010110,
    24000: 0b111010,
    32000: 0b011010,
    48000: 0b000010,
    96000: 0b011110,
}

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
        audio.i2c(8, sr_table[48000]),  # SAMPLING RATE: SR=0000, BOSR=1 (48kHz)
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
        N := 16,
        Xn := FIFO.Alloc(N),
        Hn := FIFO.Alloc(N),
        f1 := Float(1.0),
        i := Int(N),
        Do()[
            Xn.Push(f1),
            Hn.Push(f1),
        ].While(i(i - 1) != 0),
        Do()[
            ssxn := Float(1.0),
            rn1 := Float(0.0),
            i := Int(N),
            Do()[
                xn := Float(AsFloat(Xn.Pop())),
                Xn.Push(AsInt(xn)),
                ssxn(ssxn + xn**2),
                hn := Float(AsFloat(Hn.Pop())),
                Hn.Push(AsInt(hn)),
                rn1(rn1 + xn * hn),
            ].While(i(i - 1) != 0),
            en1 := Float(ToFloat(audio.Pop() >> 16) - rn1),
            a := Float(en1 * 0.5 / ssxn),
            xn := Float(AsFloat(Xn.Pop())),
            hn := Float(AsFloat(Hn.Pop()) + a * xn),
            Hn.Push(AsInt(hn)),
            smhn1 := Float(-hn),
            i := Int(N - 1),
            Do()[
                xn := Float(AsFloat(Xn.Pop())),
                Xn.Push(AsInt(xn)),
                hn := Float(AsFloat(Hn.Pop()) + a * xn),
                Hn.Push(AsInt(hn)),
                smhn1(smhn1 - hn),
            ].While(i(i - 1) != 0),
            xn1 := Float(smhn1 * en1),
            #xn1 := Float(en1),
            Xn.Push(AsInt(xn1)),
            audio.Push(ToInt(xn1) & 0xFFFF),
        ],
    ]
