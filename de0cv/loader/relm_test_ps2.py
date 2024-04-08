import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0cv import *

with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Define[
        # sendPS2 := SendPS2(),
        sendPS2 := Function(data := Int())[
            IO("PS2", 0x80000001),
            Acc(1 - (-100 * 1000) // (20 * ReLM.ncpu)),  # 100us
            Do()[...].While(Acc - 1 != 0),
            IO("PS2", 0x40000000),
            data & 0xFF,
            IO("PS2", 0x0, load="BLOAD"),
            IO("PS2", RegB | 0x40000000),
            IO("PS2", RegB),
            IO("PS2", (RegB >> 1) | 0x40000000),
            IO("PS2", RegB >> 1),
            IO("PS2", (RegB >> 2) | 0x40000000),
            IO("PS2", RegB >> 2),
            IO("PS2", (RegB >> 3) | 0x40000000),
            IO("PS2", RegB >> 3),
            IO("PS2", (RegB >> 4) | 0x40000000),
            IO("PS2", RegB >> 4),
            IO("PS2", (RegB >> 5) | 0x40000000),
            IO("PS2", RegB >> 5),
            IO("PS2", (RegB >> 6) | 0x40000000),
            IO("PS2", RegB >> 6),
            IO("PS2", (RegB >> 7) | 0x40000000),
            IO("PS2", RegB >> 7),
            RegB((RegB >> 1) ^ RegB),
            RegB((RegB >> 2) ^ RegB),
            RegB((RegB >> 4) ^ RegB),
            IO("PS2", RegB ^ 0x40000001),
            IO("PS2", RegB ^ 0x1),
            IO("PS2", 0x40000001),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001),
        ],
        # recvPS2 := RecvPS2(),
        recvPS2 := Function()[
            Do()[IO("PS2", 0x40000001),].While(IO("PS2", 0x1) != 0),
            IO("PS2", 0x40000001),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 1) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 2) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 3) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 4) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 5) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 6) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            (IO("PS2", 0x1) << 7) | RegB,
            IO("PS2", 0x40000001, load="BLOAD"),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001),
            IO("PS2", 0x1),
            IO("PS2", 0x40000001),
        ].Return(RegB),
    ]
    Thread[
        LED(
            hex5=0b1111100,  # P
            hex4=0b1101011,  # S
            hex3=0b1011101,  # 2
            hex2=0b1111100,  # P
            hex1=0b1101011,  # S
            hex0=0b1011101,  # 2
        ),
        sendPS2(0xED),  # Keyboard LED command
        sendPS2(0x7),  # Keyboard LED command
        # sendPS2(0xF4),  # Mouse Enable
        Do()[Out("LED0", recvPS2() * 2 + 1),],
    ]
