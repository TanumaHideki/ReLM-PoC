import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm import *
from relm_jtag import USBBlaster


ReLM[:] = (
    "PUTOP",
    "HEX",
    "LED",
)[::-1]
ReLM[:] = (
    "JTAG",
    "KEY",
    "UART",
)[::-1]
ReLM[0x1D::0x20] = "DIV", "DIVX"
BinaryOp.useB.add("DIV")


def Div():
    return Function(num := UInt(), denom := UInt())[
        D := UInt(denom),
        s := UInt(RegBU(AccU, num).opb("DIVX")),
        d := UInt(RegBU - AccU),
        RegBU(0, 0),
        Do()[
            Code("DIV", D.put()),
            Code("SHR", s.put()),
            (AccU * d).opb("DIV"),
            Code("SHR", s.put()),
        ].While(AccU != 0),
    ].Return(RegBU)


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
        WID: int = 4,
        WAD: int = 12,
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
