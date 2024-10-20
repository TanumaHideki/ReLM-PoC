import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *


def I2C(sda, scl, wait=0, init=None):
    b = Block[IO("I2C", (sda << 31) | scl)]
    if wait:
        b[
            Acc(wait + 1),
            Do()[...].While(Acc - 1 != 0),
        ]
    return b


Define[
    I2C_start := Function()[
        Acc(4 + 1),
        Do()[...].While(Acc - 1 != 0),
        I2C(0, 1, 2),
        I2C(0, 0, 2),
    ],
    I2C_stop := Function()[
        I2C(0, 0, 3),
        I2C(0, 1, 2),
        I2C(1, 1),
    ],
    I2C_ack := Function()[
        I2C(1, 0, 3),
        I2C(1, 1, 3),
        I2C(1, 0, 2),
    ],
    I2C_send := Function()[
        *[
            Block[
                IO("I2C", +RegB),
                Acc(3 + 1),
                Do()[...].While(Acc - 1 != 0),
                IO("I2C", RegB | 1),
                Acc(3 + 1),
                Do()[...].While(Acc - 1 != 0),
                IO("I2C", (RegB * 2).swapAB()),
                Acc(2 + 1),
                Do()[...].While(Acc - 1 != 0),
            ]
            for _ in range(8)
        ],
        I2C_ack(),
    ],
    I2C_recv := Function()[
        I2C(1, 0, 3),
        I2C(1, 1, 3),
        RegB(IO("I2C", 0x80000000), 2 + 1),
        Do()[...].While(Acc - 1 != 0),
        *[
            Block[
                I2C(1, 0, 3),
                I2C(1, 1, 3),
                RegB(IO("I2C", 0x80000000) + RegB + RegB, 2 + 1),
                Do()[...].While(Acc - 1 != 0),
            ]
            for _ in range(7)
        ],
        I2C_ack(),
    ],
]


def I2C_write(device, address, data, mask=0):
    data = (device << 24) | (address << 16) | ((data & mask if mask else data) << 8)
    regb = RegB & ((~mask & 0xFF) << 8) | data if mask else data
    return Block[
        IO("I2C", RegB(regb, 0x80000001)),
        I2C_start(),
        I2C_send(),
        I2C_send(),
        I2C_send(),
        I2C_stop(),
    ]


def I2C_read(device, address):
    return Block[
        IO(
            "I2C",
            RegB((device << 24) | (address << 16) | (device << 8) | 0x100, 0x80000001),
        ),
        I2C_start(),
        I2C_send(),
        I2C_send(),
        I2C(1, 1, 0),
        I2C_start(),
        I2C_send(),
        I2C_recv(),
        I2C_stop(),
    ]


def I2C_update(device, address, mask, data):
    return Block[
        I2C_read(device, address),
        I2C_write(device, address, data, mask),
    ]


with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[
        LED(
            hex3=0b0111110,  # H
            hex2=0b1101101,  # E
            hex1=0b0100101,  # L
            hex0=0b1110111,  # O
        ),
    ]
