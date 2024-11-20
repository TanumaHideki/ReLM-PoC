import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm import *
from relm_jtag import USBBlaster


ReLM[:] = (
    "PUTOP",
    "RGBLED4",
    "RGBLED3",
    "RGBLED2",
    "RGBLED1",
    "LED",
    "FIFO1",
    "SRAM",
)[::-1]
ReLM[:] = (
    "JTAG",
    "I2C",
    "KEY",
    "FIFO1",
    "SRAM",
)[::-1]
ReLM[0x18] = "FADD"
ReLM[0x19] = "FMUL"
ReLM[0x1A::0x20] = "FDIV", "FDIVLOOP"
ReLM[0x1B::0x20] = "DIV", "DIVLOOP"
ReLM[0x1C::0x20] = "ITOF", "ISIGN"
ReLM[0x1D::0x20] = ("ROUND", "TRUNC"), "FTOI"
ReLM[0x1E] = "FCOMP"

FIFO("FIFO1", 256)
sram = SRAM("SRAM", 0, 256)


class GSensor(Block):
    def io(self, sda, scl, wait=0, rd=0, cs=1):
        expr = IO("I2C", (sda << 31) | (cs << 2) | (rd << 1) | scl)
        if isinstance(wait, int):
            if wait:
                wait = Acc(wait + 1)
            else:
                return expr
        return Block[
            expr,
            wait,
            Do()[...].While(Acc - 1 != 0),
        ]

    def __init__(self):
        super().__init__()
        self.send = Function()[
            *[
                Block[
                    IO("I2C", RegB | 4),
                    Acc(1 + 1),
                    Do()[...].While(Acc - 1 != 0),
                    IO("I2C", (RegB * 2).swapAB() | 5),
                    Acc(1 + 1),
                    Do()[...].While(Acc - 1 != 0),
                ]
                for _ in range(8)
            ],
        ]
        self.recv = Function()[
            *[
                Block[
                    self.io(1, 0, 1, rd=1),
                    self.io(1, 1, RegB(Acc + RegB + RegB, 1 + 1), rd=1),
                ]
                for _ in range(8)
            ],
        ]
        self[
            self.send,
            self.recv,
        ]

    def write(self, address, data):
        return Block[
            self.io(1, 1, RegB((address << 24) | (data << 16), 1 + 1), rd=1, cs=0),
            self.io(1, 1, 0, rd=1, cs=1),
            self.send(),
            self.send(),
            self.io(1, 1, 0, rd=1, cs=1),
            self.io(1, 1, 0, rd=1, cs=0),
        ]

    def read(self, address, length=1):
        return Block[
            self.io(1, 1, RegB(0xC0000000 | (address << 24), 1 + 1), rd=1, cs=0),
            self.io(1, 1, 0, rd=1, cs=1),
            self.send(),
            *[self.recv() for _ in range(length)],
            self.io(1, 1, 0, rd=1, cs=1),
            self.io(1, 1, 0, rd=1, cs=0),
        ]


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
        WAD: int = 13,
    ):
        super().__init__(1 << WID, loader or release_loader)
        self.release = release
        self.dump = dump
        self.loader = loader
        self.size = 1 << (WID + WAD)

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
                    with USBBlaster() as jtag:
                        jtag.playSVF(path)
                else:
                    print(f"SVF file not found: {self.loader}")
                    print("Please make sure the loader is running on FPGA.")
            print("Loading instructions...")
            with USBBlaster() as jtag:
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
