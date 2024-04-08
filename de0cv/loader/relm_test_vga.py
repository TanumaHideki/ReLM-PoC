import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0cv import *
from relm_font import Console

with ReLMLoader(loader="loader/output_files/relm_de0cv.svf"):
    Thread[
        Acc("VGA"),
        Do()[vram := Array(*([0xFEDCBA98] * 80 * 480))],
    ]
    console = Console(vram, 80, FIFO.Alloc(), FIFO.Alloc())
    Thread[console.Service()]
    Thread[
        Out("VGAPAL", *[i * 0x1111 for i in range(16)]),
        console.Print(" !\"#$%&'()*+,-./0123456789:;<=>?", pos=0, color=0xF0),
        console.Print(" !\"#$%&'()*+,-./0123456789:;<=>?", pos=640, color=0xF0),
        console.Print(" !\"#$%&'()*+,-./0123456789:;<=>?", pos=640 * 2, color=0x0F),
        console.Print(" !\"#$%&'()*+,-./0123456789:;<=>?", pos=640 * 3, color=0x0F),
        console.Print("@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_", pos=640 * 4, color=0xF0),
        console.Print("@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_", pos=640 * 5, color=0xF0),
        console.Print("@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_", pos=640 * 6, color=0x0F),
        console.Print("@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_", pos=640 * 7, color=0x0F),
        console.Print("`abcdefghijklmnopqrstuvwxyz{|}~", pos=640 * 8, color=0xF0),
        console.Print("`abcdefghijklmnopqrstuvwxyz{|}~", pos=640 * 9, color=0xF0),
        console.Print("`abcdefghijklmnopqrstuvwxyz{|}~", pos=640 * 10, color=0x0F),
        console.Print("`abcdefghijklmnopqrstuvwxyz{|}~", pos=640 * 11, color=0x0F),
        LED(
            hex5=0b0011111,  # d
            hex4=0b0010010,  # I
            hex3=0b1101011,  # S
            hex2=0b1111100,  # P
            hex1=0b0100101,  # L
            hex0=0b0111011,  # y
        ),
    ]
