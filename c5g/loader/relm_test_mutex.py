import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import Console

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[i2c := I2C(),]
    Thread[
        Out("HDMIPAL", 0x00000080, 0xFF000081, 0x00FF0082, 0x0000FF83, 0xFFFFFF8F),
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
        sem_start := Semaphore(),
        sem_work := Semaphore(),
        mutex := Mutex(),
        pos := Int(),
    ]
    Thread[
        i := Int(1),
        sem_start.Release(),
        sem_work.Acquire(),
        Do()[
            mutex[
                console.Print("", pos=pos, color=0x11),
                j := Int(i * 5),
                Do()[console.Print(" ")].While(j(j - 1) != 0),
                console.Print("Thread1", color=0x10),
                pos(pos + 640),
            ],
        ].While(i(i + 1) < 10),
        sem_start.Release(),
    ]
    Thread[
        i := Int(1),
        sem_start.Release(),
        sem_work.Acquire(),
        Do()[
            mutex[
                console.Print("", pos=pos, color=0x22),
                j := Int(i * 4),
                Do()[console.Print(" ")].While(j(j - 1) != 0),
                console.Print("Thread2", color=0x20),
                pos(pos + 640),
            ],
        ].While(i(i + 1) < 15),
        sem_start.Release(),
    ]
    Thread[
        i := Int(1),
        sem_start.Release(),
        sem_work.Acquire(),
        Do()[
            mutex[
                console.Print("", pos=pos, color=0x33),
                j := Int(i * 3),
                Do()[console.Print(" ")].While(j(j - 1) != 0),
                console.Print("Thread3", color=0x30),
                pos(pos + 640),
            ],
        ].While(i(i + 1) < 25),
        sem_start.Release(),
    ]
    Thread[
        sem_start.Acquire(3),
        console.Print("Start", pos=0, color=0xF0),
        pos(640),
        sem_work.Release(3),
        sem_start.Acquire(),
        mutex[console.Print("Thread1 End", pos=pos, color=0xF0), pos(pos + 640)],
        sem_start.Acquire(),
        mutex[console.Print("Thread2 End", pos=pos, color=0xF0), pos(pos + 640)],
        sem_start.Acquire(),
        mutex[
            console.Print("Thread3 End", pos=pos, color=0xF0),
            pos(pos + 640),
        ],
        LED(
            hex3=0b1010010,  # T
            hex2=0b0111110,  # H
            hex1=0b0001100,  # r
            hex0=0b0011111,  # d
        ),
    ],
