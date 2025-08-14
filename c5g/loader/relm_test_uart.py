import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_serial import Serial

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[Do()[serial := Serial(0, 0),],]
    Thread[
        LED(
            hex3=0b0110111,  # U
            hex2=0b1111110,  # A
            hex1=0b0001100,  # r
            hex0=0b0101101,  # t
        ),
        serial.Handshake().Println("Serial terminal: Press ESC to exit"),
        timer := Time.After(1),
        count := Int(),
        Do()[
            If(serial.fifo_recv.IsEmpty())[
                If(timer.IsTimeout())[
                    serial.Print("Count: ").Dec(count(count + 1)).Println(),
                    timer(timer + Time.Offset(1)),
                ],
                Continue(),
            ],
            x := Int(),
            Out("LED", x(serial.fifo_recv.Pop())),
            serial.fifo_send.Push(x),
        ],
    ]

serial.console()
