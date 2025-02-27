import cv2
import numpy as np
import tkinter as tk
from PIL import ImageGrab
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *


def pov(y, c, led):
    block = Block[
        x := Int(),
        p := Int(x((x & 0xFFFFFF) + y[0]) >> 24),
    ]
    for i in range(1, 10):
        block[
            x := Int(),
            p := Int((x((x & 0xFFFFFF) + y[i]) >> 24) + p * 2),
        ]
    return block[Out(led, p * 8 + c)]


def pov_filter(y1, y0, y, i, a, b):
    return Block[
        If(
            RegB(RegB((y1[i](RegB(Acc, y1[i]).swapAB()) + RegB) * b, y0[i]) * a - RegB)
            & 0xFF000000
            == 0
        )[RegB].Else[((Acc >> 8) & 0x1000000) ^ 0x1000000],
        y[i](Acc),
    ]


def pov_fifo(y1, y0, y, fifo: FIFO, a=9, b=3):
    block = Block()
    for i in range(10):
        block[
            x := UInt(),
            RegB(x(fifo.Pop(True)) & 0xFF) * RegB * RegB,
            pov_filter(y1, y0, y, i * 4, a, b),
            RegB((x >> 8) & 0xFF) * RegB * RegB,
            pov_filter(y1, y0, y, i * 4 + 1, a, b),
            RegB((x >> 16) & 0xFF) * RegB * RegB,
            pov_filter(y1, y0, y, i * 4 + 2, a, b),
            RegB(x >> 24) * RegB * RegB,
            pov_filter(y1, y0, y, i * 4 + 3, a, b),
        ]
    return block


def pov_zero(*ys):
    expr = 0
    for y in ys:
        for i in range(40):
            expr = y[i](expr)
    return expr


with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    red = [Int() for _ in range(40)]
    green = [Int() for _ in range(40)]
    blue = [Int() for _ in range(40)]
    Thread[
        Do()[
            pov(red[0:10], 0b011, "RGBLED4"),
            pov(red[10:20], 0b011, "RGBLED3"),
            pov(red[20:30], 0b011, "RGBLED2"),
            pov(red[30:40], 0b011, "RGBLED1"),
            pov(green[0:10], 0b101, "RGBLED4"),
            pov(green[10:20], 0b101, "RGBLED3"),
            pov(green[20:30], 0b101, "RGBLED2"),
            pov(green[30:40], 0b101, "RGBLED1"),
            pov(blue[0:10], 0b110, "RGBLED4"),
            pov(blue[10:20], 0b110, "RGBLED3"),
            pov(blue[20:30], 0b110, "RGBLED2"),
            pov(blue[30:40], 0b110, "RGBLED1"),
        ]
    ]
    Define[adc := ADC()]
    Thread[
        x_max := Int(),
        x_min := Int(x_max(adc.read())),
        state := Int(),
        Do()[
            x := Int(adc.read()),
            x_th := Int(),
            If(x <= x_th((x_max + x_min) >> 1))[
                If(state != 0)[
                    alter := Int(),
                    signal := Int(alter(alter ^ 1)),
                    state(0),
                    x_min(x_th),
                ],
                If(x < x_min)[x_min(x)],
            ].Else[
                If(state == 0)[
                    state(3),
                    x_max(x_th),
                ],
                If(x > x_max)[x_max(x)],
            ],
            # Out("LED", -(1 << (x >> 5))),
        ],
    ]
    red1 = [Int() for _ in range(40)]
    red0 = [Int() for _ in range(40)]
    green1 = [Int() for _ in range(40)]
    green0 = [Int() for _ in range(40)]
    blue1 = [Int() for _ in range(40)]
    blue0 = [Int() for _ in range(40)]
    fifo = FIFO.Alloc()
    width = 140
    Thread[
        Do()[
            If(signal == 0)[Continue()],
            x := Int(0),
            Do()[
                pov_fifo(red1, red0, red, fifo),
                pov_fifo(green1, green0, green, fifo),
                pov_fifo(blue1, blue0, blue, fifo),
                Acc(wait := 250),
                Do()[...].While(Acc - 1 != 0),
                pov_fifo(red0, red1, red, fifo),
                pov_fifo(green0, green1, green, fifo),
                pov_fifo(blue0, blue1, blue, fifo),
                Acc(wait),
                Do()[...].While(Acc - 1 != 0),
            ].While(x(x + 1) != (width >> 1)),
            pov_zero(red, green, blue, red0, green0, blue0, red1, green1, blue1),
            signal(0),
        ]
    ]
    Thread[
        Acc(fifo.port),
        Do()[
            vram := JTAGLoader(),
            Array(*([0] * (30 * width))),
        ],
    ]


class Grabber:
    def __init__(self, vram, width, title="Grab"):
        self.vram = vram
        self.width = width
        self.root = tk.Tk()
        self.root.config(width=1300, height=740, bg="red")
        self.root.wm_attributes("-toolwindow", True)
        self.root.title(title)
        self.frame = tk.Frame(self.root, width=1280, height=720, bg="blue")
        self.frame.place(x=10, y=10)
        self.root.wm_attributes("-transparentcolor", "blue")
        self.root.wm_attributes("-topmost", True)
        self.play = False
        self.root.bind("<Configure>", self.on_configure)
        self.root.bind("<Button-1>", self.on_click)
        self.root.mainloop()
        self.vram()

    def on_configure(self, event):
        self.play = False
        self.root.wm_attributes("-alpha", 0.5)
        w = self.root.winfo_width() - 20
        h = min(self.root.winfo_height() - 20, (w * 9) >> 4)
        w = min(w, h * 16 // 9)
        self.frame.place(width=w, height=h)

    def on_click(self, event):
        self.play = not self.play
        self.root.wm_attributes("-alpha", 1.0 if self.play else 0.5)
        if self.play:
            self.grab()

    def grab(self):
        image = cv2.resize(
            np.array(
                ImageGrab.grab(
                    bbox=(
                        self.frame.winfo_rootx(),
                        self.frame.winfo_rooty(),
                        self.frame.winfo_rootx() + self.frame.winfo_width(),
                        self.frame.winfo_rooty() + self.frame.winfo_height(),
                    ),
                    all_screens=True,
                ),
                dtype=np.uint8,
            ),
            (self.width, 40),
            interpolation=cv2.INTER_AREA,
        ).T
        red = np.frombuffer(image[0].tobytes(), dtype=np.uint32)
        green = np.frombuffer(image[1].tobytes(), dtype=np.uint32)
        blue = np.frombuffer(image[2].tobytes(), dtype=np.uint32)
        self.vram[0]
        for x in range(0, self.width * 10, 10):
            for y in range(x, x + 10):
                vram(int(red[y]))
            for y in range(x, x + 10):
                vram(int(green[y]))
            for y in range(x, x + 10):
                vram(int(blue[y]))
        if self.play:
            self.root.after(1, self.grab)


Grabber(vram, width)
