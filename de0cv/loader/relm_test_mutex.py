import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0cv import *
from relm_font import Console

with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Thread[
        Out("VGAPAL", 0x0000, 0xF001, 0x0F02, 0x00F3, 0xFFFF),
        Acc("VGA"),
        Do()[vram := Array(*([0] * (80 * 480)))],
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
            hex5=0b1010010,  # T
            hex4=0b0111110,  # H
            hex3=0b0001100,  # r
            hex2=0b1101101,  # e
            hex1=0b1111110,  # A
            hex0=0b0011111,  # d
        ),
    ],
