import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_serial import Serial
from relm_usb import USB, USBDebug

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[Do()[serial := Serial(0, 0),],]
    Define[usb := USBDebug(serial),]
    Thread[
        LED(
            hex3=0b0110111,  # U
            hex2=0b1101011,  # S
            hex1=0b0101111,  # b
            hex0=0b0000000,
        ),
        serial.Handshake().Println("Serial terminal: Press ESC to exit"),
        serial.Print("Power On (Reset Count: ").Hex(usb.PowerOn()).Println(")"),
        serial.Print("Revision: 0x").Hex(usb.RegRd(usb.REVISION)).Println(),
        fifo := FIFO.Alloc(0x12),
        Do()[
            Do()[
                usb.Task(fifo.port),
                Continue(),
                usb.USB_STATE_ERROR,
                serial.Print("rcode: 0x").Hex(usb.rcode).Println(),
                serial.Println("USB_STATE_ERROR"),
                usb.PowerOn(),
                Continue(),
                usb.USB_STATE_CONFIGURING,
                serial.Println("USB_STATE_CONFIGURING"),
                usb.MaxPktSize[1](8),
                usb.SndToggle[1](usb.SNDTOG0),
                usb.RcvToggle[1](usb.RCVTOG0),
                If(usb.rcode(usb.SetConf(1, 0, 1)) != 0)[
                    serial.Println("Error attempting to configure keyboard."),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                If(usb.rcode(usb.SetProto(1, 0, 0, 0)) != 0)[
                    serial.Println("Error attempting to configure boot protocol."),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                If(usb.rcode(usb.SetIdle(1, 0, 0, 0, 1)) != 0)[
                    serial.Println("Error attempting to configure boot protocol."),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                usb.usb_task_state(usb.USB_STATE_RUNNING),
                serial.Println("USB_STATE_RUNNING"),
                Continue(),
                usb.USB_STATE_RUNNING,
                Do()[
                    rcode := Int(),
                    If(rcode(usb.InTransfer(1, 8, fifo)) != 0)[
                        serial.Print("InTransfer rcode: 0x").Hex(rcode).Println(),
                        Break(),
                    ],
                    LED(led=fifo.Pop()),
                    fifo.Pop(),
                    serial.Print("Key code:"),
                    i := Int(6),
                    Do()[serial.Print(" ").Hex(fifo.Pop(), "0X")].While(i(i - 1) != 0),
                    serial.Println(),
                ],
            ],
            serial.Print("Bus State: 0x").Hex(usb.bus_state),
            If(usb.bus_state == usb.MODE_FS_HOST)[serial.Print(" (Full speed)"),].Else[
                If(usb.bus_state == usb.MODE_LS_HOST)[serial.Print(" (Low speed)"),],
            ],
            serial.Println(),
            Do()[...].While(usb.IntHandler() == 0),
        ],
    ]

serial.console()
