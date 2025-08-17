from __future__ import annotations
from relm import *
from relm_serial import Serial


class Debug(Block):
    def __init__(self):
        super().__init__()

    def Println(self, *text: str, sep: str = " ", end: str = "\n"):
        return Debug()

    def Print(self, *text: str, sep: str = " "):
        return self.Println(*text, sep=sep, end="")


class USB(Debug):
    RCVFIFO = 1
    SNDFIFO = 2
    SUDFIFO = 4
    RCVBC = 6
    SNDBC = 7
    USBIRQ = 13
    VBUSIRQ = 0x40
    NOVBUSIRQ = 0x20
    OSCOKIRQ = 0x01
    USBIEN = 14
    VBUSIE = 0x40
    NOVBUSIE = 0x20
    OSCOKIE = 0x01
    USBCTL = 15
    CHIPRES = 0x20
    PWRDOWN = 0x10
    CPUCTL = 16
    PUSLEWID1 = 0x80
    PULSEWID0 = 0x40
    IE = 0x01
    PINCTL = 17
    FDUPSPI = 0x10
    INTLEVEL = 0x08
    POSINT = 0x04
    GPXB = 0x02
    GPXA = 0x01
    REVISION = 18
    HIRQ = 25
    BUSEVENTIRQ = 0x01
    RWUIRQ = 0x02
    RCVDAVIRQ = 0x04
    SNDBAVIRQ = 0x08
    SUSDNIRQ = 0x10
    CONDETIRQ = 0x20
    FRAMEIRQ = 0x40
    HXFRDNIRQ = 0x80
    HIEN = 26
    BUSEVENTIE = 0x01
    RWUIE = 0x02
    RCVDAVIE = 0x04
    SNDBAVIE = 0x08
    SUSDNIE = 0x10
    CONDETIE = 0x20
    FRAMEIE = 0x40
    HXFRDNIE = 0x80
    PERADDR = 28
    HCTL = 29
    BUSRST = 0x01
    FRMRST = 0x02
    SAMPLEBUS = 0x04
    SIGRSM = 0x08
    RCVTOG0 = 0x10
    RCVTOG1 = 0x20
    SNDTOG0 = 0x40
    SNDTOG1 = 0x80
    HXFR = 30
    TOKSETUP = 0x10
    TOKIN = 0x00
    TOKOUT = 0x20
    TOKINHS = 0x80
    TOKOUTHS = 0xA0
    TOKISOIN = 0x40
    TOKISOOUT = 0x60
    HRSL = 31
    RCVTOGRD = 0x10
    SNDTOGRD = 0x20
    KSTATUS = 0x40
    JSTATUS = 0x80
    SE0 = 0x00
    SE1 = JSTATUS | KSTATUS
    MODE = 27
    HOST = 0x01
    LOWSPEED = 0x02
    HUBPRE = 0x04
    SOFKAENAB = 0x08
    SEPIRQ = 0x10
    DELAYISO = 0x20
    DMPULLDN = 0x40
    DPPULLDN = 0x80
    MODE_SE0 = DPPULLDN | DMPULLDN | HOST | SEPIRQ
    MODE_SE1 = -1
    MODE_FS_HOST = DPPULLDN | DMPULLDN | HOST | SOFKAENAB
    MODE_LS_HOST = MODE_FS_HOST | LOWSPEED

    def __init__(self, port: str = "USB"):
        super().__init__()
        self.port = port
        self.SendRegByte = Function(regdata := Int())[
            IO(port, IO(port, regdata)),
            *[IO(port, Acc << 1) for _ in range(15)],
            IO(port, 0x6000),
        ]
        self[self.SendRegByte]
        self.RecvRegByte = Function(reg := Int())[
            IO(port, IO(port, reg)),
            *[IO(port, Acc << 1) for _ in range(7)],
            IO(port, 0),
            *[IO(port, Acc << 1) for _ in range(7)],
        ].Return(IO(port, (Acc << 1) | 0x6000))
        self[self.RecvRegByte]
        self.BeginReg = Function(reg := Int())[
            IO(port, IO(port, reg)),
            *[IO(port, Acc << 1) for _ in range(7)],
        ]
        self[self.BeginReg]
        self.SendByte = Function(data := Int())[
            IO(port, data << 16),
            *[IO(port, Acc << 1) for _ in range(7)],
        ]
        self[self.SendByte]
        self.RecvByte = Function()[
            IO(port, 0),
            *[IO(port, Acc << 1) for _ in range(7)],
        ].Return(IO(port, (Acc << 1) | 0x2000))
        self[self.RecvByte]
        self.SendWord = Function(data := Int())[
            IO(port, data << 16),
            *[IO(port, Acc << 1) for _ in range(15)],
        ]
        self[self.SendWord]
        self.Reset = Function()[
            self.RegWr(self.USBCTL, self.CHIPRES),
            self.RegWr(self.USBCTL, 0x00),
            reset_count := Int(1),
            Do()[
                If((self.RegRd(self.USBIRQ) & self.OSCOKIRQ) != 0)[
                    Return(reset_count),
                ],
            ].While(reset_count(reset_count + 1) != 0x10000),
        ].Return(0)
        self[self.Reset]
        usb_task_state = Int()
        self.usb_task_state = usb_task_state
        usb_attached = Int()
        self.bus_state = Int()
        self.Busprobe = Function()[
            status := Int(),
            If(status(self.RegRd(self.HRSL) & self.SE1) == self.SE1)[
                self.bus_state(self.MODE_SE1),
                usb_attached(0),
                usb_task_state(USB_DETACHED_SUBSTATE_ILLEGAL := Label()),
            ].Else[
                If(status == self.SE0)[
                    self.bus_state(self.MODE_SE0),
                    If(usb_attached != 0)[
                        usb_attached(0),
                        usb_task_state(USB_DETACHED_SUBSTATE_INITIALIZE := Label()),
                    ],
                ].Else[
                    self.bus_state(
                        ((self.RegRd(self.MODE) ^ (status >> 5)) & self.LOWSPEED)
                        ^ self.MODE_FS_HOST
                    ),
                    If(usb_attached == 0)[
                        delay_attach := Timer(ms=200),
                        usb_attached(1),
                        usb_task_state(USB_ATTACHED_SUBSTATE_SETTLE := Label()),
                    ],
                ],
                self.SendRegByte(self.write_reg_data(self.MODE, self.bus_state)),
            ],
        ]
        self[self.Busprobe]
        self.PowerOn = Function()[
            self.RegWr(self.PINCTL, self.FDUPSPI | self.INTLEVEL | self.GPXB),
            reset_count := Int(),
            If(reset_count(self.Reset()) != 0)[
                self.RegWr(
                    self.MODE, self.DPPULLDN | self.DMPULLDN | self.HOST | self.SEPIRQ
                ),
                self.RegWr(self.HIEN, self.FRAMEIE | self.CONDETIE),
                self.RegWr(self.HCTL, self.SAMPLEBUS),
                Do()[...].While((self.RegRd(self.HCTL) & self.SAMPLEBUS) == 0),
                usb_attached(0),
                usb_task_state(USB_DETACHED_SUBSTATE_INITIALIZE),
                self.Busprobe(),
                self.RegWr(self.HIRQ, self.CONDETIRQ),
                self.RegWr(self.CPUCTL, self.IE),
                Wait(ms=200),
            ],
        ].Return(reset_count)
        self[self.PowerOn]
        self.IntHandler = Function()[
            If(IO(self.port, 0xC001) == 0)[
                If((self.RegRd(self.HIRQ) & self.CONDETIRQ) != 0)[
                    self.Busprobe(),
                    self.RegWr(self.HIRQ, self.CONDETIRQ),
                    Return(1),
                ],
            ],
        ].Return(0)
        self[self.IntHandler]
        self.MaxPktSize = Array(*([0] * 16))
        self.SndToggle = Array(*([0] * 16))
        self.RcvToggle = Array(*([0] * 16))
        self[self.MaxPktSize, self.SndToggle, self.RcvToggle]
        self.DispatchPkt = Function(token := Int(), ep := Int())[
            timeout := Timer(ms=5000),
            retry_count := Int(0),
            Do()[
                self.RegWr(self.HXFR, token | ep),
                Do()[
                    If(self.RegRd(self.HIRQ) & self.HXFRDNIRQ != 0)[
                        self.RegWr(self.HIRQ, self.HXFRDNIRQ),
                        Break(),
                    ],
                ].While(timeout.IsWaiting()),
                rcode := Int(),
                If(rcode(self.RegRd(self.HRSL) & 0x0F) == 0x04)[Continue(),],  # NAK
                If(rcode == 0x0E)[  # TIMEOUT
                    If(retry_count(retry_count + 1) != 3)[Continue(),],
                ],
                Break(),
            ].While(timeout.IsWaiting()),
        ].Return(rcode)
        self[self.DispatchPkt]
        self.InTransferFIFO = Function(
            ep := Int(), nbytes := Int(), fifo_port := Int()
        )[
            maxpktsize := Int(self.MaxPktSize[ep]),
            xfrlen := Int(0),
            self.RegWr(self.HCTL, self.RcvToggle[ep]),
            Do()[
                rcode := Int(),
                If(rcode(self.DispatchPkt(self.TOKIN, ep)) != 0)[Return(rcode),],
                If(self.RegRd(self.HIRQ) & self.RCVDAVIRQ == 0)[Return(0xF0),],
                pktsize := Int(),
                i := Int(pktsize(self.RegRd(self.RCVBC))),
                self.BytesRd(self.RCVFIFO),
                While(i != 0)[
                    FIFO.PushPort(fifo_port, self.RecvByte()),
                    i(i - 1),
                ],
                self.BytesEnd(),
                self.RegWr(self.HIRQ, self.RCVDAVIRQ),
                If((pktsize < maxpktsize) | (xfrlen(xfrlen + pktsize) >= nbytes))[
                    If((self.RegRd(self.HRSL) & self.RCVTOGRD) != 0)[
                        self.RcvToggle[ep](self.RCVTOG1),
                    ].Else[
                        self.RcvToggle[ep](self.RCVTOG0),
                    ],
                    Break(),
                ],
            ],
        ].Return(
            0
        )
        self[self.InTransferFIFO]
        self.OutTransferFIFO = Function(
            ep := Int(),
            nbytes := Int(),
            fifo_port := Int(),
        )[
            bytes_left := Int(nbytes),
            timeout := Timer(ms=5000),
            maxpktsize := Int(),
            If(maxpktsize(self.MaxPktSize[ep]) == 0)[Return(0xFE),],
            self.RegWr(self.HCTL, self.SndToggle[ep]),
            While(bytes_left != 0)[
                retry_count := Int(0),
                If(bytes_left >= maxpktsize)[bytes_tosend := Int(maxpktsize),].Else[
                    bytes_tosend(bytes_left),
                ],
                self.BytesWr(self.SNDFIFO),
                data_p := Int(),
                self.SendByte(data_p(FIFO.PopPort(fifo_port))),
                i := Int(),
                If(i(bytes_tosend - 1) != 0)[
                    Do()[
                        x := Int(FIFO.PopPort(fifo_port)),
                        If(i == 1)[
                            self.SendByte(x),
                            Break(),
                        ],
                        self.SendWord((FIFO.PopPort(fifo_port) << 8) | x),
                    ].While(i(i - 2) != 0),
                ],
                self.BytesEnd(),
                self.RegWr(self.SNDBC, bytes_tosend),
                self.RegWr(self.HXFR, self.TOKOUT | ep),
                Do()[...].While(self.RegRd(self.HIRQ) & self.HXFRDNIRQ == 0),
                self.RegWr(self.HIRQ, self.HXFRDNIRQ),
                rcode := Int(),
                While((rcode(self.RegRd(self.HRSL) & 0x0F) != 0) & timeout.IsWaiting())[
                    If(rcode == 0x0E)[  # TIMEOUT
                        If(retry_count(retry_count + 1) == 3)[Return(rcode),],
                    ].Else[
                        If(rcode != 0x04)[Return(rcode),],  # NAK
                    ],
                    self.RegWr(self.SNDBC, 0),
                    self.RegWr(self.SNDFIFO, data_p),
                    self.RegWr(self.SNDBC, bytes_tosend),
                    self.RegWr(self.HXFR, self.TOKOUT | ep),
                    Do()[...].While(self.RegRd(self.HIRQ) & self.HXFRDNIRQ == 0),
                    self.RegWr(self.HIRQ, self.HXFRDNIRQ),
                ],
                bytes_left(bytes_left - bytes_tosend),
            ],
            If(self.RegRd(self.HRSL) & self.SNDTOGRD != 0)[
                self.SndToggle[ep](self.SNDTOG1),
            ].Else[
                self.SndToggle[ep](self.SNDTOG0),
            ],
        ].Return(
            rcode
        )
        self[self.OutTransferFIFO]
        self.CtrlReqIn = Function(
            addr := Int(),
            ep := Int(),
            bReqType := Int(),
            bRequest := Int(),
            wValue := Int(),
            wIndex := Int(),
            nbytes := Int(),
            fifo_port := Int(),
        )[
            self.RegWr(self.PERADDR, addr),
            self.BytesWr(self.SUDFIFO),
            self.SendByte(bReqType),
            self.SendByte(bRequest),
            self.SendWord(wValue),
            self.SendWord(wIndex),
            self.SendWord(nbytes),
            self.BytesEnd(),
            rcode := Int(),
            If(rcode(self.DispatchPkt(self.TOKSETUP, ep)) != 0)[
                self.Println("Setup packet error"),
                Return(rcode),
            ],
            If(nbytes != 0)[
                self.RcvToggle[ep](self.RCVTOG1),
                rcode := Int(),
                If(rcode(self.InTransferFIFO(ep, nbytes, fifo_port)) != 0)[
                    self.Println("Data packet error"),
                    Return(rcode),
                ],
            ],
        ].Return(
            self.CtrlStatusIn(ep)
        )
        self.CtrlReqOut = Function(
            addr := Int(),
            ep := Int(),
            bReqType := Int(),
            bRequest := Int(),
            wValue := Int(),
            wIndex := Int(),
            wLength := Int(),
            nbytes := Int(),
            fifo_port := Int(),
        )[
            self.RegWr(self.PERADDR, addr),
            self.BytesWr(self.SUDFIFO),
            self.SendByte(bReqType),
            self.SendByte(bRequest),
            self.SendWord(wValue),
            self.SendWord(wIndex),
            self.SendWord(wLength),
            self.BytesEnd(),
            rcode := Int(),
            If(rcode(self.DispatchPkt(self.TOKSETUP, ep)) != 0)[
                self.Println("Setup packet error"),
                Return(rcode),
            ],
            If(nbytes != 0)[
                self.SndToggle[ep](self.SNDTOG1),
                rcode := Int(),
                If(rcode(self.OutTransferFIFO(ep, nbytes, fifo_port)) != 0)[
                    self.Println("Data packet error"),
                    Return(rcode),
                ],
            ],
        ].Return(
            self.CtrlStatusOut(ep)
        )
        self[self.CtrlReqIn, self.CtrlReqOut]
        self.GetString = Function(
            addr := Int(), idx := Int(), langid := Int(), fifo_port := Int()
        )[
            If(idx == 0)[Return(0),],
            If(langid == 0)[
                rcode := Int(),
                If(rcode(self.GetStrDescr(addr, 0, 4, 0, 0, fifo_port)) != 0)[
                    self.Println("Error retrieving LangID"),
                    Return(rcode),
                ],
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                langid(FIFO.PopPort(fifo_port) + FIFO.PopPort(fifo_port) * 0x100),
            ],
            rcode := Int(),
            If(rcode(self.GetStrDescr(addr, 0, 1, idx, langid, fifo_port)) != 0)[
                self.Println("Error retrieving string length"),
                Return(rcode),
            ],
            rcode := Int(),
            If(
                rcode(
                    self.GetStrDescr(
                        addr, 0, FIFO.PopPort(fifo_port), idx, langid, fifo_port
                    )
                )
                != 0
            )[
                self.Println("Error retrieving string"),
                Return(rcode),
            ],
            FIFO.PopPort(fifo_port),
            FIFO.PopPort(fifo_port),
        ].Return(
            0
        )
        self[self.GetString]
        self.rcode = Int()
        self.USB_STATE_ERROR = Label()
        self.USB_STATE_CONFIGURING = Label()
        self.USB_STATE_RUNNING = Label()
        self.Task = Function(fifo_port := Int())[
            self.IntHandler(),
            Code("JUMP", usb_task_state.put()),
            USB_DETACHED_SUBSTATE_INITIALIZE,
            self.Println("USB_DETACHED_SUBSTATE_INITIALIZE"),
            self.SndToggle[0](self.SNDTOG0),
            self.RcvToggle[0](self.RCVTOG0),
            usb_task_state(USB_DETACHED_SUBSTATE_WAIT_FOR_DEVICE := Label()),
            Return(),
            USB_DETACHED_SUBSTATE_WAIT_FOR_DEVICE,
            self.Println("USB_DETACHED_SUBSTATE_WAIT_FOR_DEVICE"),
            Return(),
            USB_DETACHED_SUBSTATE_ILLEGAL,
            self.Println("USB_DETACHED_SUBSTATE_ILLEGAL"),
            Return(),
            USB_ATTACHED_SUBSTATE_SETTLE,
            self.Println("USB_ATTACHED_SUBSTATE_SETTLE"),
            If(delay_attach.IsTimeout())[
                usb_task_state(USB_ATTACHED_SUBSTATE_RESET_DEVICE := Label()),
            ],
            Return(),
            USB_ATTACHED_SUBSTATE_RESET_DEVICE,
            self.Println("USB_ATTACHED_SUBSTATE_RESET_DEVICE"),
            self.RegWr(self.HCTL, self.BUSRST),
            usb_task_state(USB_ATTACHED_SUBSTATE_WAIT_RESET_COMPLETE := Label()),
            Return(),
            USB_ATTACHED_SUBSTATE_WAIT_RESET_COMPLETE,
            self.Println("USB_ATTACHED_SUBSTATE_WAIT_RESET_COMPLETE"),
            If(self.RegRd(self.HCTL) & self.BUSRST == 0)[
                self.RegWr(self.MODE, self.RegRd(self.MODE) | self.SOFKAENAB),
                usb_task_state(USB_ATTACHED_SUBSTATE_WAIT_SOF := Label()),
                delay_sof := Timer(ms=20),
            ],
            Return(),
            USB_ATTACHED_SUBSTATE_WAIT_SOF,
            self.Println("USB_ATTACHED_SUBSTATE_WAIT_SOF"),
            If(delay_sof.IsTimeout())[
                If(self.RegRd(self.HIRQ) & self.FRAMEIRQ != 0)[
                    usb_task_state(
                        USB_ATTACHED_SUBSTATE_GET_DEVICE_DESCRIPTOR_SIZE := Label()
                    ),
                ],
            ],
            Return(),
            USB_ATTACHED_SUBSTATE_GET_DEVICE_DESCRIPTOR_SIZE,
            self.Println("USB_ATTACHED_SUBSTATE_GET_DEVICE_DESCRIPTOR_SIZE"),
            self.MaxPktSize[0](8),
            If(self.rcode(self.GetDevDescr(0, 0, 8, fifo_port)) == 0)[
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                FIFO.PopPort(fifo_port),
                self.MaxPktSize[0](FIFO.PopPort(fifo_port)),
                usb_task_state(USB_STATE_ADDRESSING := Label()),
            ].Else[
                FIFO.ClearPort(fifo_port),
                usb_task_state(self.USB_STATE_ERROR),
            ],
            Return(),
            USB_STATE_ADDRESSING,
            self.Println("USB_STATE_ADDRESSING"),
            If(self.rcode(self.SetAddr(0, 0, 1)) == 0)[
                usb_task_state(self.USB_STATE_CONFIGURING),
            ].Else[
                usb_task_state(self.USB_STATE_ERROR),
            ],
        ]
        self[self.Task]

    @staticmethod
    def write_reg(reg):
        return (reg << 19) | 0x022000

    @staticmethod
    def write_reg_data(reg, data):
        return (data << 24) | USB.write_reg(reg)

    @staticmethod
    def read_reg(reg):
        return (reg << 19) | 0x2000

    def RegWr(self, reg, data) -> ExprB:
        return self.SendRegByte(self.write_reg_data(reg, data))

    def RegRd(self, reg) -> ExprB:
        return self.RecvRegByte(self.read_reg(reg))

    def BytesWr(self, reg) -> ExprB:
        return self.BeginReg(self.write_reg(reg))

    def BytesRd(self, reg) -> ExprB:
        return self.BeginReg(self.read_reg(reg))

    def BytesEnd(self) -> ExprB:
        return IO(self.port, 0x6000)

    def CtrlStatusIn(self, ep: int) -> ExprB:
        return self.DispatchPkt(self.TOKOUTHS, ep)

    def CtrlStatusOut(self, ep: int) -> ExprB:
        return self.DispatchPkt(self.TOKINHS, ep)

    def InTransfer(self, ep: int, nbytes: int, fifo: FIFO) -> ExprB:
        return self.InTransferFIFO(ep, nbytes, fifo.port)

    def OutTransfer(self, ep: int, nbytes: int, fifo: FIFO) -> ExprB:
        hxfr_out_ep = self.write_reg_data(self.HXFR, self.TOKOUT | ep)
        return self.OutTransferFIFO(ep, hxfr_out_ep, nbytes, fifo.port)

    def CtrlReqFIFO(
        self,
        addr: int,
        ep: int,
        bReqType: int,
        bRequest: int,
        wValue: int,
        wIndex: int,
        nbytes: int,
        fifo_port: str,
    ) -> ExprB:
        if bReqType & 0x80:
            return self.CtrlReqIn(
                addr,
                ep,
                bReqType,
                bRequest,
                wValue,
                wIndex,
                nbytes,
                fifo_port,
            )
        else:
            return self.CtrlReqOut(
                addr,
                ep,
                bReqType,
                bRequest,
                wValue,
                wIndex,
                nbytes,
                fifo_port,
            )

    def CtrlReq(
        self,
        addr: int,
        ep: int,
        bReqType: int,
        bRequest: int,
        wValLo: int,
        wValHi: int,
        wIndex: int,
        nbytes: int = 0,
        fifo_port: str | None = None,
    ) -> ExprB:
        wValue = (wValHi << 8) | wValLo
        if nbytes:
            return self.CtrlReqFIFO(
                addr,
                ep,
                bReqType,
                bRequest,
                wValue,
                wIndex,
                nbytes,
                fifo_port,
            )
        if bReqType & 0x80:
            return self.CtrlReqIn(
                addr,
                ep,
                bReqType,
                bRequest,
                wValue,
                wIndex,
                0,
            )
        else:
            return self.CtrlReqOut(
                addr,
                ep,
                bReqType,
                bRequest,
                wValue,
                wIndex,
                0,
            )

    USB_REQUEST_GET_STATUS = 0  # Standard Device Request - GET STATUS
    USB_REQUEST_CLEAR_FEATURE = 1  # Standard Device Request - CLEAR FEATURE
    USB_REQUEST_SET_FEATURE = 3  # Standard Device Request - SET FEATURE
    USB_REQUEST_SET_ADDRESS = 5  # Standard Device Request - SET ADDRESS
    USB_REQUEST_GET_DESCRIPTOR = 6  # Standard Device Request - GET DESCRIPTOR
    USB_REQUEST_SET_DESCRIPTOR = 7  # Standard Device Request - SET DESCRIPTOR
    USB_REQUEST_GET_CONFIGURATION = 8  # Standard Device Request - GET CONFIGURATION
    USB_REQUEST_SET_CONFIGURATION = 9  # Standard Device Request - SET CONFIGURATION
    USB_REQUEST_GET_INTERFACE = 10  # Standard Device Request - GET INTERFACE
    USB_REQUEST_SET_INTERFACE = 11  # Standard Device Request - SET INTERFACE
    USB_REQUEST_SYNCH_FRAME = 12  # Standard Device Request - SYNCH FRAME

    USB_FEATURE_ENDPOINT_HALT = 0  # CLEAR/SET FEATURE - Endpoint Halt
    USB_FEATURE_DEVICE_REMOTE_WAKEUP = 1  # CLEAR/SET FEATURE - Device remote wake-up
    USB_FEATURE_TEST_MODE = 2  # CLEAR/SET FEATURE - Test mode

    USB_SETUP_HOST_TO_DEVICE = 0x00  # transfer direction - host to device transfer
    USB_SETUP_DEVICE_TO_HOST = 0x80  # transfer direction - device to host transfer
    USB_SETUP_TYPE_STANDARD = 0x00  # type - standard
    USB_SETUP_TYPE_CLASS = 0x20  # type - class
    USB_SETUP_TYPE_VENDOR = 0x40  # type - vendor
    USB_SETUP_RECIPIENT_DEVICE = 0x00  # recipient - device
    USB_SETUP_RECIPIENT_INTERFACE = 0x01  # recipient - interface
    USB_SETUP_RECIPIENT_ENDPOINT = 0x02  # recipient - endpoint
    USB_SETUP_RECIPIENT_OTHER = 0x03  # recipient - other

    USB_DESCRIPTOR_DEVICE = 0x01  # Device Descriptor
    USB_DESCRIPTOR_CONFIGURATION = 0x02  # Configuration Descriptor
    USB_DESCRIPTOR_STRING = 0x03  # String Descriptor
    USB_DESCRIPTOR_INTERFACE = 0x04  # Interface Descriptor
    USB_DESCRIPTOR_ENDPOINT = 0x05  # Endpoint Descriptor
    USB_DESCRIPTOR_DEVICE_QUALIFIER = 0x06  # Device Qualifier
    USB_DESCRIPTOR_OTHER_SPEED = 0x07  # Other Speed Configuration
    USB_DESCRIPTOR_INTERFACE_POWER = 0x08  # Interface Power
    USB_DESCRIPTOR_OTG = 0x09  # OTG Descriptor

    HID_REQUEST_GET_REPORT = 0x01
    HID_REQUEST_GET_IDLE = 0x02
    HID_REQUEST_GET_PROTOCOL = 0x03
    HID_REQUEST_SET_REPORT = 0x09
    HID_REQUEST_SET_IDLE = 0x0A
    HID_REQUEST_SET_PROTOCOL = 0x0B

    HID_DESCRIPTOR_HID = 0x21
    HID_DESCRIPTOR_REPORT = 0x22
    HID_DESRIPTOR_PHY = 0x23

    REQ_GET_DESCR = (
        USB_SETUP_DEVICE_TO_HOST | USB_SETUP_TYPE_STANDARD | USB_SETUP_RECIPIENT_DEVICE
    )  # get descriptor request type
    REQ_SET = (
        USB_SETUP_HOST_TO_DEVICE | USB_SETUP_TYPE_STANDARD | USB_SETUP_RECIPIENT_DEVICE
    )  # set request type for all but 'set feature' and 'set interface'
    REQ_CL_GET_INTF = (
        USB_SETUP_DEVICE_TO_HOST | USB_SETUP_TYPE_CLASS | USB_SETUP_RECIPIENT_INTERFACE
    )  # get interface request type

    REQ_HIDOUT = (
        USB_SETUP_HOST_TO_DEVICE | USB_SETUP_TYPE_CLASS | USB_SETUP_RECIPIENT_INTERFACE
    )
    REQ_HIDIN = (
        USB_SETUP_DEVICE_TO_HOST | USB_SETUP_TYPE_CLASS | USB_SETUP_RECIPIENT_INTERFACE
    )
    REQ_HIDREPORT = (
        USB_SETUP_DEVICE_TO_HOST
        | USB_SETUP_TYPE_STANDARD
        | USB_SETUP_RECIPIENT_INTERFACE
    )

    def GetDevDescr(self, addr: int, ep: int, nbytes: int, fifo_port: str) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_GET_DESCR,
            self.USB_REQUEST_GET_DESCRIPTOR,
            0,
            self.USB_DESCRIPTOR_DEVICE,
            0,
            nbytes,
            fifo_port,
        )

    def GetConfDescr(
        self, addr: int, ep: int, nbytes: int, conf: int, fifo_port: str
    ) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_GET_DESCR,
            self.USB_REQUEST_GET_DESCRIPTOR,
            conf,
            self.USB_DESCRIPTOR_CONFIGURATION,
            0,
            nbytes,
            fifo_port,
        )

    def GetStrDescr(
        self, addr: int, ep: int, nbytes: int, index: int, langid: int, fifo_port: str
    ) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_GET_DESCR,
            self.USB_REQUEST_GET_DESCRIPTOR,
            index,
            self.USB_DESCRIPTOR_STRING,
            langid,
            nbytes,
            fifo_port,
        )

    def SetAddr(self, oldaddr: int, ep: int, newaddr: int) -> ExprB:
        return self.CtrlReq(
            oldaddr, ep, self.REQ_SET, self.USB_REQUEST_SET_ADDRESS, newaddr, 0, 0
        )

    def SetConf(self, addr: int, ep: int, conf_value: int) -> ExprB:
        return self.CtrlReq(
            addr, ep, self.REQ_SET, self.USB_REQUEST_SET_CONFIGURATION, conf_value, 0, 0
        )

    def SetProto(self, addr: int, ep: int, interface: int, protocol: int) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDOUT,
            self.HID_REQUEST_SET_PROTOCOL,
            protocol,
            0,
            interface,
        )

    def GetProto(self, addr: int, ep: int, interface: int, fifo_port: str) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDIN,
            self.HID_REQUEST_GET_PROTOCOL,
            0,
            0,
            interface,
            1,
            fifo_port,
        )

    def GetReportDescr(self, addr: int, ep: int, nbytes: int, fifo_port: str) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDREPORT,
            self.USB_REQUEST_GET_DESCRIPTOR,
            0,
            self.HID_DESCRIPTOR_REPORT,
            0,
            nbytes,
            fifo_port,
        )

    def SetReport(
        self,
        addr: int,
        ep: int,
        nbytes: int,
        interface: int,
        report_type: int,
        report_id: int,
        fifo_port: str,
    ) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDOUT,
            self.HID_REQUEST_SET_REPORT,
            report_id,
            report_type,
            interface,
            nbytes,
            fifo_port,
        )

    def GetReport(
        self,
        addr: int,
        ep: int,
        nbytes: int,
        interface: int,
        report_type: int,
        report_id: int,
        fifo_port: str,
    ) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDIN,
            self.HID_REQUEST_GET_REPORT,
            report_id,
            report_type,
            interface,
            nbytes,
            fifo_port,
        )

    def GetIdle(
        self, addr: int, ep: int, interface: int, report_id: int, fifo_port: str
    ) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDIN,
            self.HID_REQUEST_GET_IDLE,
            report_id,
            0,
            interface,
            1,
            fifo_port,
        )

    def SetIdle(
        self, addr: int, ep: int, interface: int, report_id: int, duration: int
    ) -> ExprB:
        return self.CtrlReq(
            addr,
            ep,
            self.REQ_HIDOUT,
            self.HID_REQUEST_SET_IDLE,
            report_id,
            duration,
            interface,
        )


class USBDebug(USB):
    def __init__(self, serial: Serial, port: str = "USB"):
        self.serial = serial
        super().__init__(port)

    def Println(self, *text: str, sep: str = " ", end: str = "\n"):
        return self.serial.Println(*text, sep=sep, end=end)
