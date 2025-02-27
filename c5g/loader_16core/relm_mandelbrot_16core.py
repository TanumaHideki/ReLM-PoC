import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g_16core import *

with ReLMLoader(loader="loader_16core/output_files/relm_c5g_16core.svf"):
    Define[
        i2c := I2C(),
        mutex := Mutex(),
        sem1 := Semaphore(),
        sem2 := Semaphore(),
    ]
    Thread[
        Out(
            "HDMIPAL",
            0x00000080,
            0x99BB0081,
            0xAACC0082,
            0xBBDD0083,
            0x00005584,
            0x00006685,
            0x00007786,
            0x11118887,
            0x33339988,
            0x5555AA89,
            0x7777BB8A,
            0x9999CC8B,
            0xBBBBDD8C,
            0xDDDDEE8D,
            0xFFFFFF8E,
            0x00FF008F,
        ),
        scale := Float(),
        center_x := Float(),
        center_y := Float(),
        key_next := Int(0b1000),
        rows := FIFO.Alloc(480 + ReLM.ncpu),
        rows.Push(*([-1] * (ReLM.ncpu - 2)), -2),
        LED(
            hex3=0b1101100,  # F
            hex2=0b0001100,  # r
            hex1=0b1111110,  # A
            hex0=0b1100101,  # C
        ),
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
    Define[
        master := Function()[
            Do()[key := Int(In("KEY"))].While(
                (key & 0b100000000001111 == 0) & (key & 0b10000 != 0)
            ),
            If(key & (1 << 14) != 0)[scale(scale / 0.75)].Else[
                If(scale(scale * 0.75) < 1.0e-8)[key(key_next)],
            ],
            If(key & 0b1000 != 0)[
                center_x(-0.743643135),
                center_y(0.131825963),
                scale(1.0),
                key_next(0b100),
            ],
            If(key & 0b100 != 0)[
                center_x(-0.761574),
                center_y(-0.0847596),
                scale(1.0),
                key_next(0b10),
            ],
            If(key & 0b10 != 0)[
                center_x(0.42884),
                center_y(-0.231345),
                scale(1.0),
                key_next(0b1),
            ],
            If(key & 0b1 != 0)[
                center_x(-1.62917),
                center_y(-0.0203968),
                scale(1.0),
                key_next(0b1000),
            ],
            rows.Push(*[i for i in range(480)], *([-1] * (ReLM.ncpu - 2)), -2),
        ],
    ]
    for _ in range(ReLM.ncpu - 1):
        Thread[
            Do()[
                mutex[iy := Int(rows.Pop()),],
                If(iy == -1)[sem1.Release(), sem2.Acquire(), Continue()],
                If(iy == -2)[
                    sem1.Acquire(ReLM.ncpu - 2),
                    master(),
                    sem2.Release(ReLM.ncpu - 2),
                    Continue(),
                ],
                pos := Int(iy * 80),
                cy := Float((239.5 - ToFloat(iy)) * scale + center_y),
                qy2 := Float(AccF**2),
                ix := UInt(0),
                Do()[
                    pixel := UInt(),
                    pcount := Int(8),
                    Do()[
                        cx := Float((ToFloat(ix) - 319.5) * scale + center_x),
                        qx := Float(AccF - 0.25),
                        q := Float(AccF**2 + qy2),
                        If((AccF + qx) * q * 4.0 <= qy2)[color := Int(1)].Else[
                            If((cx + 1.0) ** 2 + qy2 <= (1.0 / 16.0))[color(2)].Else[
                                iter := UInt(0),
                                x2 := Float(AccF),
                                y2 := Float(AccF),
                                x := Float(AccF),
                                y := Float(AccF),
                                px := Float(AccF),
                                py := Float(AccF),
                                pindex := Int(-1),
                                period := Int(1),
                                Do()[
                                    y(y * x * 2.0 + cy),
                                    x2(x(x2 - y2 + cx) ** 2),
                                    If(pindex(pindex + 1) > 0)[
                                        If((px - x) ** 2 + (py - y) ** 2 < 1.0e-10)[
                                            iter2 := UInt(0),
                                            Break(),
                                        ],
                                        If(pindex == period)[
                                            pindex(-period(period * 2)),
                                            px(x),
                                            py(y),
                                        ],
                                    ],
                                ].While(
                                    (iter2(iter(iter + 1)) != 0xAAA)
                                    & (y2(y**2) + x2 <= math.exp(math.tau))
                                ),
                                ((+iter2).opb("BLOADX") >> 1).opb("XOR"),
                                color(Acc.bit_count() + 3),
                            ],
                        ],
                        pixel(pixel * 16 + color),
                        ix(ix + 1),
                    ].While(pcount(pcount - 1) != 0),
                    vram[pos](pixel),
                    pos(pos + 1),
                ].While(ix < 640),
            ],
        ]
