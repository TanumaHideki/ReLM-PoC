import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[
        i2c := I2C(),
        audio := Audio(i2c),
        array_ma := Array(*([0] * 16)),
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
        sum1 := Int(),
        i := Int(0),
        Do()[
            x := Int(),
            sum1(sum1 + x(audio.Pop() >> 16)),
            array_ma[i](x),
        ].While(i(i + 1) != 16),
        center0 := Int(array_ma[7]),
        center1 := Int(array_ma[8]),
        center_i := Int(9),
        sum_ma := Int(sum1),
        sum_i := Int(0),
        fifo_pitch := FIFO.Alloc(),
        fifo_formant := FIFO.Alloc(),
        Do()[
            fifo_pitch.Push(sum_ma),
            fifo_formant.Push((center0 + center1) * 8 - sum_ma),
            x := Int(),
            sum_ma(sum_ma + x(audio.Pop() >> 16) - array_ma[sum_i]),
            array_ma[sum_i](x),
            If(sum_i == 15)[sum_i(0),].Else[sum_i(sum_i + 1),],
            center0(center1),
            center1(array_ma[center_i]),
            If(center_i == 15)[center_i(0),].Else[center_i(center_i + 1),],
        ],
    ]
    Thread[
        fifo_pitch2 := FIFO.Alloc(),
        Do()[
            Acc(fifo_pitch2.port),
            a := Array(*([0] * 2000)),
            While(In("KEY") & 2 != 0)[
                led1 := Int(0b1100),
                fifo_pitch2.Push(fifo_pitch.Pop() * 2),
            ],
            led1(0),
            i := Int(1000),
            Do()[fifo_pitch2.Push(fifo_pitch.Pop() + fifo_pitch.Pop())].While(
                i(i - 1) != 0
            ),
            i := Int(0),
            Do()[
                x := Int(),
                fifo_pitch2.Push(x(fifo_pitch.Pop() + fifo_pitch.Pop())),
                a[999 - i](x),
                a[1000 + i](x),
            ].While(i(i + 1) != 1000),
        ],
    ]
    Thread[
        fifo_formant2 := FIFO.Alloc(),
        Do()[
            Acc(fifo_formant2.port),
            a := Array(*([0] * 1000)),
            While(In("KEY") & 1 != 0)[
                led2 := Int(0b11),
                fifo_formant2.Push(fifo_formant.Pop() * 2),
            ],
            led2(0),
            i := Int(750),
            Do()[
                y := Int(),
                fifo_formant2.Push(fifo_formant.Pop() + y(fifo_formant.Pop())),
                fifo_formant2.Push(y + fifo_formant.Pop()),
            ].While(i(i - 1) != 0),
            i := Int(0),
            Do()[
                xy := Int(),
                y := Int(),
                fifo_formant2.Push(xy(fifo_formant.Pop() + y(fifo_formant.Pop()))),
                a[499 - i * 2](xy),
                a[500 + i * 2](xy),
                yz := Int(),
                fifo_formant2.Push(yz(y + fifo_formant.Pop())),
                a[498 - i * 2](yz),
                a[501 + i * 2](yz),
            ].While(i(i + 1) != 250),
        ],
    ]
    Define[array_echo := Array(*([0] * 4800)),]
    Thread[
        echo_i := Int(0),
        s := Int(0),
        Do()[
            x := Int(),
            array_echo[echo_i](
                x(array_echo[echo_i] + fifo_pitch2.Pop() + fifo_formant2.Pop()) >> 1
            ),
            If(echo_i == 4799)[echo_i(0),].Else[echo_i(echo_i + 1),],
            xs := Int(),
            audio.Push((xs(x >> s) & 0xFFFF) * 0x10001),
            If((xs + 0x10000) & 0xFFFE0000 != 0)[s(s + 1),],
        ],
    ]
    Thread[Do()[Out("LED", led1 | led2),],]
