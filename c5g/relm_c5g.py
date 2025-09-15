import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_float import *
from relm_jtag import USBBlaster


ReLM[:] = (
    "PUTOP",
    "HDMIPAL",
    "HDMI",
    "LED",
    "HEX",
    "AUDIO",
    "FIFO1",
    "FIFO2",
    "FIFO3",
    "FIFO4",
    "FIFO5",
    "FIFO6",
)[::-1]
ReLM[:] = (
    "JTAG",
    "USB",
    "UART",
    "SRAM",
    "VRAM",
    "I2C",
    "KEY",
    "TIMER",
    "AUDIO",
    "FIFO1",
    "FIFO2",
    "FIFO3",
    "FIFO4",
    "FIFO5",
    "FIFO6",
)[::-1]
ReLM[0x18] = "FADD"
ReLM[0x19] = "FMUL"
ReLM[0x1A::0x20] = "FDIV", "FDIVLOOP"
ReLM[0x1B::0x20] = "DIV", "DIVLOOP"
ReLM[0x1C::0x20] = "ITOF", "ISIGN"
ReLM[0x1D::0x20] = ("ROUND", "TRUNC"), "FTOI"
ReLM[0x1E] = "FCOMP"

FIFO("FIFO1", 2048)
FIFO("FIFO2", 2048)
FIFO("FIFO3", 2048)
FIFO("FIFO4", 2048)
FIFO("FIFO5", 2048)
FIFO("FIFO6", 2048)


def LED(hex3=None, hex2=None, hex1=None, hex0=None, led=None):
    hex3 = 0 if hex3 is None else ((hex3 & 0x7F) * 2 + 1)
    hex2 = 0 if hex2 is None else ((hex2 & 0x7F) * 2 + 1)
    hex1 = 0 if hex1 is None else ((hex1 & 0x7F) * 2 + 1)
    hex0 = 0 if hex0 is None else ((hex0 & 0x7F) * 2 + 1)
    block = Block()
    hex = (hex3 << 24) | (hex2 << 16) | (hex1 << 8) | hex0
    if hex:
        block[Out("HEX", hex)]
    if led is not None:
        block[Out("LED", led)]
    return block


class I2C(Block):
    def io(self, sda, scl, wait=0):
        b = Block[IO("I2C", (sda << 31) | scl)]
        if wait:
            b[
                Acc(wait + 1),
                Do()[...].While(Acc - 1 != 0),
            ]
        return b

    def __init__(self):
        super().__init__()
        self.start = Function()[
            Acc(4 + 1),
            Do()[...].While(Acc - 1 != 0),
            self.io(0, 1, 2),
            self.io(0, 0, 2),
        ]
        self.stop = Function()[
            self.io(0, 0, 3),
            self.io(0, 1, 2),
            self.io(1, 1),
        ]
        self.ack = Function()[
            self.io(1, 0, 3),
            self.io(1, 1, 3),
            self.io(1, 0, 2),
        ]
        self.send = Function()[
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
            self.ack(),
        ]
        self.recv = Function()[
            self.io(1, 0, 3),
            self.io(1, 1, 3),
            RegB(IO("I2C", 0x80000000), 2 + 1),
            Do()[...].While(Acc - 1 != 0),
            *[
                Block[
                    self.io(1, 0, 3),
                    self.io(1, 1, 3),
                    RegB(IO("I2C", 0x80000000) + RegB + RegB, 2 + 1),
                    Do()[...].While(Acc - 1 != 0),
                ]
                for _ in range(7)
            ],
            self.ack(),
        ]
        self[
            self.start,
            self.stop,
            self.ack,
            self.send,
            self.recv,
        ]

    def write(self, device, address, data, mask=0):
        data = (device << 24) | (address << 16) | ((data & mask if mask else data) << 8)
        regb = RegB & ((~mask & 0xFF) << 8) | data if mask else data
        return Block[
            IO("I2C", RegB(regb, 0x80000001)),
            self.start(),
            self.send(),
            self.send(),
            self.send(),
            self.stop(),
        ]

    def read(self, device, address):
        return Block[
            IO(
                "I2C",
                RegB(
                    (device << 24) | (address << 16) | (device << 8) | 0x100, 0x80000001
                ),
            ),
            self.start(),
            self.send(),
            self.send(),
            self.io(1, 1, 0),
            self.start(),
            self.send(),
            self.recv(),
            self.stop(),
        ]

    def update(self, device, address, mask, data):
        return Block[
            self.read(device, address),
            self.write(device, address, data, mask),
        ]


class Audio(FIFO):
    def __init__(self, i2c: I2C = None, port: str = "AUDIO"):
        self.i2c_write = i2c
        self.port = port
        self.locked = True

    def i2c(self, address, data, device=0x34):
        return self.i2c_write.write(device, address << 1, data)


operand = Int()
Loader[
    Do()[
        Out("PUTOP", In("JTAG")),
        If(RegB & 0xE00000 != 0)[
            (Acc & 0xA00000).opb("JEQ"),
            (+operand).opb("PUT"),
            Continue(),
        ],
        operand(operand << 16 | RegB),
    ],
]
del operand


class JTAGLoader(Label):
    def __init__(self):
        super().__init__()
        self.jtag = None
        self.offset = 0

    def deploy(self, memory: list[Code], ncpu: int) -> bool:
        self.address = len(memory)
        return True

    def __getitem__(self, offset):
        self.offset = offset
        return self

    def __call__(self, *data):
        if data:
            if self.jtag is None:
                self.jtag = USBBlaster()
                self.jtag.shift_ir(0xE)
                self.jtag.write_int(0)
            for d in data:
                self.jtag.write_int((d >> 16) & 0xFFFF)
                self.jtag.write_int(d & 0xFFFF)
                self.jtag.write_int(0x200000 | (self.address + self.offset))
                self.offset += 1
        else:
            if self.jtag is not None:
                self.jtag.close()
                self.jtag = None
        return self


class ReLMLoader(ReLM):
    def __init__(
        self,
        *release: str,
        dump: bool = True,
        loader: str | bool = False,
        release_loader: bool = False,
        WID: int = 3,
        WAD: int = 14,
        WAD2: int = 12,
        IDCODE: int = 0x2B020DD,
    ):
        super().__init__(1 << WID, loader or release_loader)
        self.release = release
        self.dump = dump
        self.loader = loader
        self.size = (
            ((1 << (WAD - 1)) + (1 << WAD2)) << WID if WAD2 else 1 << (WID + WAD)
        )
        self.IDCODE = IDCODE

    def send(self, jtag, start, stop=None) -> None:
        for i, c in enumerate(self.memory[start:stop], start):
            operand = self.mnemonic[c.operand]
            jtag.write_int((operand >> 16) & 0xFFFF)
            jtag.write_int(operand & 0xFFFF)
            op = self.mnemonic[c.op] | 0b100000
            jtag.write_int((op << 18) | i)

    def run(self):
        start = len(self.memory)
        self.deploy()
        if self.dump:
            self.print()
        if self.loader:
            if isinstance(self.loader, str):
                path = Path(__file__, "..", self.loader)
                if path.is_file():
                    print(f"SVF configuration: {self.loader}")
                    with USBBlaster(self.IDCODE) as jtag:
                        jtag.playSVF(path)
                else:
                    print(f"SVF file not found: {self.loader}")
                    print("Please make sure the loader is running on FPGA.")
            print("Loading instructions...")
            with USBBlaster(self.IDCODE) as jtag:
                jtag.shift_ir(0xE)
                jtag.write_int(0)
                self.send(jtag, start)
                self.send(jtag, 0, self.ncpu)
                jtag.write_int(0x400000 + self.ncpu - 1)
        used = len(self.memory)
        print(
            f"{used} / {self.size} instructions ({used * 100 / self.size:.1f} % used)"
        )
        if not self.loader and self.release:
            self.save(*self.release)
        return self

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.run()


if __name__ == "__main__":
    with ReLMLoader(__file__, "..", "loader", release_loader=True):
        pass
