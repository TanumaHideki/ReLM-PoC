import cv2
import numpy as np
from tkinter.filedialog import askopenfilename
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *

srgb = np.array(
    [c / 255.0 / 12.92 for c in range(11)]
    + [((c / 255.0 + 0.055) / 1.055) ** 2.4 for c in range(11, 256)]
)


def dither(image, vram):
    h, w = image.shape[:2]
    image = srgb[image]
    Eb = np.zeros(w)
    Eg = np.zeros(w)
    Er = np.zeros(w)
    for y in range(h):
        eB = eG = eR = 0.0
        pixel = 0
        for x in range(w):
            eB += Eb[x] + image[y, x, 0]
            eG += Eg[x] + image[y, x, 1]
            eR += Er[x] + image[y, x, 2]
            qB, cB = (1.0, 8) if eB >= 1.0 else (0.0, 0)
            qG, cG = (
                (1.0, 6)
                if eG >= 1.0
                else (srgb[188], 3) if eG >= srgb[188] else (0.0, 0)
            )
            qR, cR = (
                (1.0, 1)
                if eR >= 1.0
                else (srgb[188], 2) if cG != 6 and eR >= srgb[188] else (0.0, 0)
            )
            pixel = (pixel << 4) | (cB + cG + cR)
            if x & 7 == 7:
                vram(pixel)
                pixel = 0
            Eb[x] = (eB := (eB - qB) * 0.5)
            Eg[x] = (eG := (eG - qG) * 0.5)
            Er[x] = (eR := (eR - qR) * 0.5)
        Eb[w - 1] = (Eb[w - 1] + eB) * 0.5
        Eg[w - 1] = (Eg[w - 1] + eG) * 0.5
        Er[w - 1] = (Er[w - 1] + eR) * 0.5
        for x in range(w - 2, 0, -1):
            Eb[x] = (Eb[x] + Eb[x + 1]) * 0.5
            Eg[x] = (Eg[x] + Eg[x + 1]) * 0.5
            Er[x] = (Er[x] + Er[x + 1]) * 0.5
        Eb[0] += Eb[1]
        Eg[0] += Eg[1]
        Er[0] += Er[1]


with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Define[i2c := I2C(),]
    Thread[
        Out(
            "HDMIPAL",
            0x00000080,
            0xFF000081,
            0xBC000082,
            0x00BC0083,
            0xFFBC0084,
            0xBCBC0085,
            0x00FF0086,
            0xFFFF0087,
            0x0000FF88,
            0xFF00FF89,
            0xBC00FF8A,
            0x00BCFF8B,
            0xFFBCFF8C,
            0xBCBCFF8D,
            0x00FFFF8E,
            0xFFFFFF8F,
        ),
        Do()[
            Do()[
                i2c.read(0x72, 0x42),
                Out("LED", RegB),
            ].While(RegB & 0x6000 != 0x6000),
            i2c.update(0x72, 0x41, 0x40, 0),
            i2c.write(0x72, 0x98, 0x03),
            i2c.update(0x72, 0x9A, 0xE0, 0xE0),
            i2c.write(0x72, 0x9C, 0x30),
            i2c.update(0x72, 0x9D, 0x03, 0x01),
            i2c.write(0x72, 0xA2, 0xA4),
            i2c.write(0x72, 0xA3, 0xA4),
            i2c.write(0x72, 0xE0, 0xD0),
            Out("HDMIPAL", 0x40),
            Do()[
                Acc("HDMI"),
                vram := JTAGLoader(),
                Array(*([0xFEDCBA98, 0x76543210] * (40 * 480))),
                i2c.read(0x72, 0x42),
            ].While(RegB & 0x6000 == 0x6000),
        ],
    ]
    Thread[
        LED(
            hex3=0b0111110,  # H
            hex2=0b1010111,  # D
            hex1=0b1110110,  # M
            hex0=0b0110110,  # I
        ),
    ]

filename = __file__
while True:
    initialdir = Path(filename).parent
    filename = askopenfilename(
        initialdir=initialdir,
        filetypes=[("Image files", ["*.jpg", "*.png", "*.gif", "*.bmp", "*.tiff"]), ("All files", "*.*")],
    )
    if not filename:
        break
    print(filename)
    image = cv2.imread(filename)
    h, w = image.shape[:2]
    image = cv2.resize(image, (640, 480))
    dither(image, vram[0])
vram()
