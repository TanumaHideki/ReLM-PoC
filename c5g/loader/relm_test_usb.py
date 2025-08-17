import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_serial import Serial
from relm_usb import USB, USBDebug

with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
    Thread[Do()[serial := Serial(0, 0),],]
    Define[usb := USB(),]
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
        fifo_str := FIFO.Alloc(255),
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
                serial.Println("Device descriptor:"),
                If(usb.rcode(usb.GetDevDescr(1, 0, 0x12, fifo.port)) != 0)[
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                serial.Print("\tDescriptor length: 0x").Hex(fifo.Pop()).Println(),
                serial.Print("\tDescriptor type: 0x").Hex(fifo.Pop()).Println(),
                low := Int(fifo.Pop()),
                serial.Print("\tUSB version: ")
                .Hex(fifo.Pop())
                .Print(".")
                .Hex(low)
                .Println(),
                serial.Print("\tClass: 0x").Hex(fifo.Pop()).Println(),
                serial.Print("\tSubclass: 0x").Hex(fifo.Pop()).Println(),
                serial.Print("\tProtocol: 0x").Hex(fifo.Pop()).Println(),
                serial.Print("\tMax packet size: 0x").Hex(fifo.Pop()).Println(),
                serial.Print("\tVendor ID: 0x")
                .Hex(fifo.Pop() + fifo.Pop() * 0x100)
                .Println(),
                serial.Print("\tProduct ID: 0x")
                .Hex(fifo.Pop() + fifo.Pop() * 0x100)
                .Println(),
                serial.Print("\tRevision ID: 0x")
                .Hex(fifo.Pop() + fifo.Pop() * 0x100)
                .Println(),
                serial.Print("\tManufacturer: "),
                If(usb.rcode(usb.GetString(1, fifo.Pop(), 0x0409, fifo_str.port)) != 0)[
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                While(~fifo_str.IsEmpty())[serial.fifo_send.Push(fifo_str.Pop()),],
                serial.Println(),
                serial.Print("\tProduct: "),
                If(usb.rcode(usb.GetString(1, fifo.Pop(), 0x0409, fifo_str.port)) != 0)[
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                While(~fifo_str.IsEmpty())[serial.fifo_send.Push(fifo_str.Pop()),],
                serial.Println(),
                serial.Print("\tSerial number: "),
                If(usb.rcode(usb.GetString(1, fifo.Pop(), 0x0409, fifo_str.port)) != 0)[
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                While(~fifo_str.IsEmpty())[serial.fifo_send.Push(fifo_str.Pop()),],
                serial.Println(),
                serial.Print("\tNumber of configurations: ").Dec(fifo.Pop()).Println(),
                usb.usb_task_state(usb.USB_STATE_RUNNING),
                Continue(),
                usb.USB_STATE_RUNNING,
                serial.Println("USB_STATE_RUNNING"),
            ].Break(),
            serial.Print("Bus State: 0x").Hex(usb.bus_state),
            If(usb.bus_state == usb.MODE_FS_HOST)[serial.Print(" (Full speed)"),].Else[
                If(usb.bus_state == usb.MODE_LS_HOST)[serial.Print(" (Low speed)"),],
            ],
            serial.Println(),
            Do()[...].While(usb.IntHandler() == 0),
        ],
    ]

serial.console()
