import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_float import *
from relm_jtag import USBBlaster


ReLM[:] = (
    "PUTOP",
    "LED1",
    "LED0",
    "VGAPAL",
    "VGA",
    "FIFO3",
    "FIFO2",
    "FIFO1",
    "SRAM",
)[::-1]
ReLM[:] = (
    "JTAG",
    "KEY",
    "PS2",
    "FIFO3",
    "FIFO2",
    "FIFO1",
    "SRAM",
)[::-1]
ReLM[0x18::0x20] = "ITOF", "ISIGN"
ReLM[0x19::0x20] = "FMUL", "FMULB", "FSQU", "FSQUB"
ReLM[0x1A] = "FADD"
ReLM[0x1B::0x20] = ("ROUND", "TRUNC"), "FTOI"
ReLM[0x1C] = "FCOMP"
ReLM[0x1D::0x20] = "DIV", "DIVINIT", "DIVLOOP", "DIVMOD"
ReLM[0x1E] = "FDIV"


def LED(hex5=None, hex4=None, hex3=None, hex2=None, hex1=None, hex0=None, led=None):
    hex5 = 0 if hex5 is None else ((hex5 & 0x7F) * 2 + 1)
    hex4 = 0 if hex4 is None else ((hex4 & 0x7F) * 2 + 1)
    hex3 = 0 if hex3 is None else ((hex3 & 0x7F) * 2 + 1)
    hex2 = 0 if hex2 is None else ((hex2 & 0x7F) * 2 + 1)
    hex1 = 0 if hex1 is None else ((hex1 & 0x7F) * 2 + 1)
    hex0 = 0 if hex0 is None else ((hex0 & 0x7F) * 2 + 1)
    led = 0 if led is None else ((led & 0x3FF) * 2 + 1)
    block = Block()
    led1 = (hex5 << 24) | (hex4 << 16) | (hex3 << 8) | hex2
    if led1:
        block[Out("LED1", led1)]
    led0 = (hex1 << 24) | (hex0 << 16) | led
    if led0:
        block[Out("LED0", led0)]
    return block


def RecvPS2():
    return Function()[
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
    ].Return(RegB)


def SendPS2():
    return Function(data := Int())[
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
    ]


FIFO("FIFO1", 2048)
FIFO("FIFO2", 2048)
FIFO("FIFO3", 2048)
sram = SRAM("SRAM", 0, 8192)


operand = Int()
Loader[
    Do()[
        Out("PUTOP", In("JTAG")),
        If(RegB & 0xC00000 != 0)[
            (Acc & 0x800000).opb("JEQ"),
            (+operand).opb("PUT"),
            Continue(),
        ],
        operand(operand << 16 | RegB),
    ],
]
del operand


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
            operand = self.mnemonic.get(c.operand, c.operand)
            jtag.write_int((operand >> 16) & 0xFFFF)
            jtag.write_int(operand & 0xFFFF)
            op = self.mnemonic.get(c.op, c.op) | 0b100000
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
