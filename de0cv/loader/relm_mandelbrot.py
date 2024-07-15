import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0cv import *

with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Thread[
        Out(
            "VGAPAL",
            0x0000,
            0x0021,
            0x0032,
            0x0043,
            0x0054,
            0x0065,
            0x0076,
            0x1187,
            0x3398,
            0x55A9,
            0x77BA,
            0x99CB,
            0xBBDC,
            0xDDED,
            0xFFFE,
            0x0F0F,
        ),
        LED(
            hex5=0b1011011,  # m
            hex4=0b1111110,  # A
            hex3=0b0001110,  # n
            hex2=0b0011111,  # d
            hex1=0b1101101,  # E
            hex0=0b0100101,  # L
        ),
        Acc("VGA"),
        Do()[vram := Array(*([0] * 80 * 480))],
    ]
    Define[
        rows := FIFO.Alloc(487),
        mutex := Mutex(),
        sem_start := Semaphore(),
        sem_work := Semaphore(),
        scale := Float(),
        center_x := Float(),
        center_y := Float(),
    ]

    def task(master: bool = False) -> None:
        Define[
            px := ArrayF(*([0.0] * 60)),
            py := ArrayF(*([0.0] * 60)),
        ]
        Thread[
            (
                Block[
                    sem_start.Acquire(6),
                    scale(1.0),
                    center_x(-0.743643135),
                    center_y(0.131825963),
                    sem_work.Release(6),
                ]
                if master
                else Block[
                    sem_start.Release(),
                    sem_work.Acquire(),
                ]
            ),
            Do()[
                (
                    Block[
                        sem_start.Acquire(6),
                        Do()[...].While(
                            (In("KEY") & 0b11111 == 0) & (In("KEY") & 0b100000 != 0)
                        ),
                        If(In("KEY") & 0b1 != 0)[scale(scale / 0.75)].Else[
                            scale(scale * 0.75)
                        ],
                        If(In("KEY") & 0b10000 != 0)[
                            center_x(-0.743643135),
                            center_y(0.131825963),
                            scale(1.0),
                        ],
                        If(In("KEY") & 0b1000 != 0)[
                            center_x(-0.761574),
                            center_y(-0.0847596),
                            scale(1.0),
                        ],
                        If(In("KEY") & 0b100 != 0)[
                            center_x(0.42884),
                            center_y(-0.231345),
                            scale(1.0),
                        ],
                        If(In("KEY") & 0b10 != 0)[
                            center_x(-1.62917),
                            center_y(-0.0203968),
                            scale(1.0),
                        ],
                        rows.Push(*[i for i in range(480)], *([-1] * 7)),
                        sem_work.Release(6),
                    ]
                    if master
                    else Block[
                        sem_start.Release(),
                        sem_work.Acquire(),
                    ]
                ),
                Do()[
                    mutex[iy := Int(rows.Pop())],
                    If(iy == -1)[Break()],
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
                            If(
                                ((AccF + qx) * q * 4.0 <= qy2)
                                | ((cx + 1.0) ** 2 + qy2 <= (1.0 / 16.0))
                            )[
                                pixel(pixel * 16 + 15),
                            ].Else[
                                iter := UInt(0),
                                pindex := Int(Acc),
                                x2 := Float(AccF),
                                y2 := Float(AccF),
                                x := Float(AccF),
                                y := Float(AccF),
                                Do()[
                                    iter(iter + 1),
                                    If(Acc == 0xAAA)[Break()],
                                    y(y * x * 2.0 + cy),
                                    x(x2 - y2 + cx),
                                    x2(AccF**2),
                                    If(pindex == 60)[
                                        pi := Int(0),
                                        While(
                                            (pi != 60)
                                            & (
                                                (px[pi] - x) ** 2 + (py[pi] - y) ** 2
                                                > 1.0e-10
                                            )
                                        )[pi(pi + 1)],
                                        If(pi != 60)[iter(0xAAA), Break()],
                                        pindex(0),
                                    ],
                                    px[pindex](x),
                                    py[pindex](y),
                                    pindex(pindex + 1),
                                ].While(y2(y**2) + x2 <= math.exp(math.tau)),
                                ((+iter).opb("BLOADX") >> 1).opb("XOR"),
                                pixel(Acc.bit_count() + 3 + pixel * 16),
                            ],
                            ix(ix + 1),
                        ].While(pcount(pcount - 1) != 0),
                        vram[pos](pixel),
                        pos(pos + 1),
                    ].While(ix < 640),
                ],
            ],
        ]

    for _ in range(6):
        task()
    task(True)
