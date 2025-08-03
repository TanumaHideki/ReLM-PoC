import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_serial import Serial

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[Do()[serial := Serial(0, 0),],]
    Define[
        usb := USB(),
    ]
    Thread[
        LED(
            hex3=0b0110111,  # U
            hex2=0b1101011,  # S
            hex1=0b0101111,  # b
            hex0=0b0000000,
        ),
        serial.Handshake().Println("Serial terminal: Press ESC to exit"),
        bus_state := Int(usb.Init()),
        serial.Print("Reset Count: ").Dec(usb.reset_count).Println(),
        serial.Print("Revision: 0x").Hex(usb.Read(18)).Println(),
        Do()[
            serial.Print("Bus State: 0x").Hex(bus_state).Println(),
            Do()[
                If(IO("USB", 0x0000C001) != 0)[Continue(),],
                If((usb.Read(25) & 0x20) != 0)[Break(),],
            ],
            bus_state(usb.Busprobe()),
            usb.Write(25, 0x20),
        ],
    ]

serial.console()
