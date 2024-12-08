import cv2
import numpy as np
from tkinter.filedialog import askopenfilename
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *


def pov(y, c, led):
    block = Block[
        x0 := Int(),
        x1 := Int(),
        q := Int(x1(x0 + y[0]) >> 8),
        x0(x1 - q * 0xFF),
    ]
    for i in range(1, 10):
        block[
            x0 := Int(),
            x1 := Int(),
            p := Int(),
            q := Int(p(x1(x0 + y[i]) >> 8) + q * 2),
            x0(x1 - p * 0xFF),
        ]
    return block[Out(led, q * 8 + c)]


def pov_fifo(y, fifo: FIFO):
    block = Block()
    for i in range(10):
        block[
            x := UInt(),
            y[i * 4](x(fifo.Pop(True)) & 0xFF),
            y[i * 4 + 1]((x >> 8) & 0xFF),
            y[i * 4 + 2]((x >> 16) & 0xFF),
            y[i * 4 + 3]((x >> 24)),
        ]
    return block


def pov_zero(y, value):
    for i in range(40):
        value = y[i](value)
    return value


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
                    signal := Int(1),
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
            Out("LED", -(1 << (x >> 5))),
        ],
    ]
    fifo = FIFO.Alloc()
    Thread[
        Do()[
            If(signal == 0)[Continue()],
            Acc(100000),
            Do()[...].While(Acc - 1 != 0),
            x := Int(0),
            Do()[
                pov_fifo(red, fifo),
                pov_fifo(green, fifo),
                pov_fifo(blue, fifo),
                Acc(5000),
                Do()[...].While(Acc - 1 != 0),
            ].While(x(x + 1) != 40),
            pov_zero(blue, pov_zero(green, pov_zero(red, 0))),
            signal(0),
        ]
    ]
    Thread[
        Acc(fifo.port),
        Do()[
            vram := JTAGLoader(),
            Array(*[(i & 0xFF) * 0x1010101 for i in range(30 * 40)]),
        ],
    ]

filename = __file__
gamma = np.array([round((i / 255.0) ** 3 * 255.0) for i in range(256)], dtype=np.uint8)
while True:
    initialdir = Path(filename).parent
    filename = askopenfilename(
        initialdir=initialdir,
        filetypes=[
            ("Image files", ["*.jpg", "*.png", "*.gif", "*.bmp", "*.tiff"]),
            ("All files", "*.*"),
        ],
    )
    if not filename:
        break
    print(filename)
    image = cv2.imread(filename)
    image = gamma[cv2.resize(image, (40, 40))].T
    red = np.frombuffer(image[2].tobytes(), dtype=np.uint32)
    green = np.frombuffer(image[1].tobytes(), dtype=np.uint32)
    blue = np.frombuffer(image[0].tobytes(), dtype=np.uint32)
    vram[0]
    for x in range(390, -10, -10):
        for y in range(x, x + 10):
            vram(int(red[y]))
        for y in range(x, x + 10):
            vram(int(green[y]))
        for y in range(x, x + 10):
            vram(int(blue[y]))
vram()
