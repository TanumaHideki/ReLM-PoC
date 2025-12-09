from __future__ import annotations
from relm import *
import serial
import serial.tools.list_ports
import curses


class SerialPrint(Block):
    def __init__(
        self,
        parent: Serial,
    ):
        super().__init__()
        self.parent = parent

    def print(self) -> SerialPrint:
        return self

    def Println(self, *text: str, sep: str = " ", end: str = "\n") -> SerialPrint:
        p = []
        text = sep.join(text) + end
        while text:
            p.append(sum(ord(ch) << (i * 8) for i, ch in enumerate(text[:4])))
            text = text[4:]
        return self.print()[self.parent.fifo_send.Push(*p)]

    def Print(self, *text: str, sep: str = " ") -> SerialPrint:
        return self.Println(*text, sep=sep, end="")

    def PrintInt(self, value: int | str | BinaryOp, format: str) -> SerialPrint:
        find = format.find("-")
        if find != -1:
            value = self.parent.PrintSign(value, format[:find])
            format = format[find + 1 :]
        base = format[-1]
        fill = 0 if format[0] == base else ord(format[0])
        if base in "Dd":
            return self.print()[
                self.parent.Decimal(value, fill, 10 ** (len(format) - 1))
            ]
        else:
            assert base in "Xx"
            case = ord(base) - ord("X") + ord("A") - 10
            return self.print()[
                self.parent.Hexadecimal(value, fill, 16 ** (len(format) - 1), case)
            ]

    def Dec(
        self, value: int | str | BinaryOp, format: str = "-dddddddddd"
    ) -> SerialPrint:
        return self.PrintInt(value, format)

    def UDec(
        self, value: int | str | BinaryOp, format: str = "dddddddddd"
    ) -> SerialPrint:
        return self.PrintInt(value, format)

    def Hex(
        self, value: int | str | BinaryOp, format: str = "-XXXXXXXX"
    ) -> SerialPrint:
        return self.PrintInt(value, format)

    def UHex(
        self, value: int | str | BinaryOp, format: str = "XXXXXXXX"
    ) -> SerialPrint:
        return self.PrintInt(value, format)

    def Handshake(self) -> SerialPrint:
        return self.print()[
            Do()[...].While(self.parent.fifo_recv.Pop() != 0xAA),
            self.parent.fifo_send.Push(0xAA),
            Do()[...].While(self.parent.fifo_recv.Pop() != 0x55),
        ]


class Serial(SerialPrint):
    def __init__(
        self,
        fifo_send: FIFO | int | None = None,
        fifo_recv: FIFO | int | None = None,
        port: str = "UART",
    ):
        super().__init__(self)
        self.fifo_send = (
            FIFO.Alloc(fifo_send) if isinstance(fifo_send, int) else fifo_send
        )
        self.fifo_recv = (
            FIFO.Alloc(fifo_recv) if isinstance(fifo_recv, int) else fifo_recv
        )
        if self.fifo_recv is not None:
            self[
                uin := Int(),
                If(uin(IO(port, 0x40000000) & 0x400000FF) != 0)[
                    self.fifo_recv.Push(uin & 0xFF),
                ],
            ]
        if self.fifo_send is not None:
            self[
                usend := UInt(),
                If((usend == 0) & ~self.fifo_send.IsEmpty())[
                    usend(self.fifo_send.Pop()),
                ],
                uout := Int(),
                If((uout == 0) | (IO(port, uout) & 0x80000000 != 0))[
                    If(usend != 0)[
                        uout(usend & 0xFF | 0x80000000),
                        usend(usend >> 8),
                    ].Else[
                        uout(0),
                    ],
                ],
            ]
        self.Sign = Function(_value := Int(), _plus := Int())[
            sign := UInt(),
            If(sign(_value >> 31) != 0)[self.fifo_send.Push(ord("-")),].Else[
                If(_plus != 0)[self.fifo_send.Push(_plus),],
            ],
        ].Return((sign | 1) * _value)
        self.Decimal = Function(_value := UInt(), _fill := Int(), _digit := UInt())[
            v := UInt(_value),
            f := Int(_fill),
            d := UInt(_digit),
            Do()[
                q := UInt(),
                If(q(v // d) == 0)[
                    If(d == 1)[f(ord("0"))],
                    If(f != 0)[self.fifo_send.Push(f),],
                ].Else[
                    f(ord("0")),
                    If(q < 10)[self.fifo_send.Push(q + ord("0")),],
                ],
                v(v - q * d),
            ].While(d(d // 10) != 0),
        ]
        self.Hexadecimal = Function(
            value := UInt(), fill := Int(), digit := UInt(), case := Int()
        )[
            v := UInt(value),
            f := Int(fill),
            d := UInt(digit),
            Do()[
                q := UInt(),
                If(q(RegB(d, v).opb("SHR") & 0xF) == 0)[
                    If(d == 1)[f(ord("0"))],
                    If(f != 0)[self.fifo_send.Push(f),],
                ].Else[
                    f(ord("0")),
                    If(q < 10)[self.fifo_send.Push(q + ord("0")),].Else[
                        self.fifo_send.Push(q + case),
                    ],
                ],
                v(v - q * d),
            ].While(d(d >> 4) != 0),
        ]
        Define[
            self.Sign,
            self.Decimal,
            self.Hexadecimal,
        ]

    def print(self) -> SerialPrint:
        return SerialPrint(self)

    def PrintSign(self, value: int | str | BinaryOp, plus: str) -> ExprB:
        return self.Sign(value, ord(plus) if plus else 0)

    @staticmethod
    def handshake(ser: serial.Serial):
        while True:
            if ser.in_waiting:
                if ser.read(1) == b"\xaa":
                    ser.write(b"\x55")
                    break
            else:
                ser.write(b"\xaa")

    @staticmethod
    def window_main(stdscr, ser):
        stdscr.nodelay(True)  # Non-blocking input
        stdscr.scrollok(True)  # Allow scrolling
        stdscr.clear()
        while True:
            ch = stdscr.getch()
            if ch == 27:  # ESC key
                break
            elif ch != -1:
                if ch < 256:
                    ser.write(bytes([ch]))
            elif ser.in_waiting > 0:
                data = ser.read(1)
                stdscr.addch(data)
                stdscr.refresh()

    def console(self, window=window_main):
        for p in serial.tools.list_ports.comports():
            print(p)
            if "USB Serial Port" in p.description:
                ser = serial.Serial(p.device, 115200, timeout=1)
                self.handshake(ser)
                curses.wrapper(window, ser)
                ser.close()
                break

    def dump(self, file):
        for p in serial.tools.list_ports.comports():
            print(p)
            if "USB Serial Port" in p.description:
                ser = serial.Serial(p.device, 115200, timeout=1)
                self.handshake(ser)
                with open(file, "wb") as f:
                    while True:
                        if ser.in_waiting > 0:
                            data = ser.read(1)
                            if data == b"\xaa":
                                break
                            f.write(data)
                ser.close()
                break
