import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_usb import USB
import numpy as np

loader = "loader/output_files/relm_c5g.svf" if __name__ == "__main__" else False


with ReLMLoader(__file__, loader=loader):
    Define[
        i2c := I2C(),
        audio := Audio(i2c),
        mouse_mutex := Mutex(),
    ]
    sr_table = {
        8000: 0b001110,
        12000: 0b010010,
        16000: 0b010110,
        24000: 0b111010,
        32000: 0b011010,
        48000: 0b000010,
        96000: 0b011110,
    }

    def s2(pattern):
        return [
            (pattern >> 32) & 0xFFFFFFFF,
            pattern & 0xFFFFFFFF,
        ]

    Define[
        fontFire := Table(8),
        fontFire.Case(0),
        Array(
            *s2(0x0002020000000000),
            *s2(0x0202020200000000),
            *s2(0x0020202000000000),
            *s2(0x2202220220000000),
            *s2(0x0022022000000000),
            *s2(0x2202220220000000),
            *s2(0x0020202000000000),
            *s2(0x0202020200000000),
            *s2(0x0002020000000000),
        ),
        fontFire.Return(),
        fontFire.Case(1),
        Array(
            *s2(0x0002020000000000 >> 4),
            *s2(0x0202020200000000 >> 4),
            *s2(0x0020202000000000 >> 4),
            *s2(0x2202220220000000 >> 4),
            *s2(0x0022022000000000 >> 4),
            *s2(0x2202220220000000 >> 4),
            *s2(0x0020202000000000 >> 4),
            *s2(0x0202020200000000 >> 4),
            *s2(0x0002020000000000 >> 4),
        ),
        fontFire.Return(),
        fontFire.Case(2),
        Array(
            *s2(0x0002020000000000 >> 8),
            *s2(0x0202020200000000 >> 8),
            *s2(0x0020202000000000 >> 8),
            *s2(0x2202220220000000 >> 8),
            *s2(0x0022022000000000 >> 8),
            *s2(0x2202220220000000 >> 8),
            *s2(0x0020202000000000 >> 8),
            *s2(0x0202020200000000 >> 8),
            *s2(0x0002020000000000 >> 8),
        ),
        fontFire.Return(),
        fontFire.Case(3),
        Array(
            *s2(0x0002020000000000 >> 12),
            *s2(0x0202020200000000 >> 12),
            *s2(0x0020202000000000 >> 12),
            *s2(0x2202220220000000 >> 12),
            *s2(0x0022022000000000 >> 12),
            *s2(0x2202220220000000 >> 12),
            *s2(0x0020202000000000 >> 12),
            *s2(0x0202020200000000 >> 12),
            *s2(0x0002020000000000 >> 12),
        ),
        fontFire.Return(),
        fontFire.Case(4),
        Array(
            *s2(0x0002020000000000 >> 16),
            *s2(0x0202020200000000 >> 16),
            *s2(0x0020202000000000 >> 16),
            *s2(0x2202220220000000 >> 16),
            *s2(0x0022022000000000 >> 16),
            *s2(0x2202220220000000 >> 16),
            *s2(0x0020202000000000 >> 16),
            *s2(0x0202020200000000 >> 16),
            *s2(0x0002020000000000 >> 16),
        ),
        fontFire.Return(),
        fontFire.Case(5),
        Array(
            *s2(0x0002020000000000 >> 20),
            *s2(0x0202020200000000 >> 20),
            *s2(0x0020202000000000 >> 20),
            *s2(0x2202220220000000 >> 20),
            *s2(0x0022022000000000 >> 20),
            *s2(0x2202220220000000 >> 20),
            *s2(0x0020202000000000 >> 20),
            *s2(0x0202020200000000 >> 20),
            *s2(0x0002020000000000 >> 20),
        ),
        fontFire.Return(),
        fontFire.Case(6),
        Array(
            *s2(0x0002020000000000 >> 24),
            *s2(0x0202020200000000 >> 24),
            *s2(0x0020202000000000 >> 24),
            *s2(0x2202220220000000 >> 24),
            *s2(0x0022022000000000 >> 24),
            *s2(0x2202220220000000 >> 24),
            *s2(0x0020202000000000 >> 24),
            *s2(0x0202020200000000 >> 24),
            *s2(0x0002020000000000 >> 24),
        ),
        fontFire.Return(),
        fontFire.Case(7),
        Array(
            *s2(0x0002020000000000 >> 28),
            *s2(0x0202020200000000 >> 28),
            *s2(0x0020202000000000 >> 28),
            *s2(0x2202220220000000 >> 28),
            *s2(0x0022022000000000 >> 28),
            *s2(0x2202220220000000 >> 28),
            *s2(0x0020202000000000 >> 28),
            *s2(0x0202020200000000 >> 28),
            *s2(0x0002020000000000 >> 28),
        ),
        fontFire.Return(),
    ]

    def s3(pattern):
        return [
            (pattern >> 64) & 0xFFFFFFFF,
            (pattern >> 32) & 0xFFFFFFFF,
            pattern & 0xFFFFFFFF,
        ]

    Define[
        fontUFO := Table(8),
        fontUFO.Case(0),
        Array(
            *s3(0x000000331330000000000000),
            *s3(0x000031111111300000000000),
            *s3(0x000111111111110000000000),
            *s3(0x001111111111111000000000),
            *s3(0x031111111111111300000000),
            *s3(0x011111111111111100000000),
            *s3(0x311111111111111130000000),
            *s3(0x311111111111111130000000),
            *s3(0x111111111111111110000000),
            *s3(0x311111111111111130000000),
            *s3(0x311111111111111130000000),
            *s3(0x011111111111111100000000),
            *s3(0x031111111111111300000000),
            *s3(0x001111111111111000000000),
            *s3(0x000111111111110000000000),
            *s3(0x000031111111300000000000),
            *s3(0x000000331330000000000000),
        ),
        fontUFO.Return(),
        fontUFO.Case(1),
        Array(
            *s3(0x000000331330000000000000 >> 4),
            *s3(0x000031111111300000000000 >> 4),
            *s3(0x000111111111110000000000 >> 4),
            *s3(0x001111111111111000000000 >> 4),
            *s3(0x031111111111111300000000 >> 4),
            *s3(0x011111111111111100000000 >> 4),
            *s3(0x311111111111111130000000 >> 4),
            *s3(0x311111111111111130000000 >> 4),
            *s3(0x111111111111111110000000 >> 4),
            *s3(0x311111111111111130000000 >> 4),
            *s3(0x311111111111111130000000 >> 4),
            *s3(0x011111111111111100000000 >> 4),
            *s3(0x031111111111111300000000 >> 4),
            *s3(0x001111111111111000000000 >> 4),
            *s3(0x000111111111110000000000 >> 4),
            *s3(0x000031111111300000000000 >> 4),
            *s3(0x000000331330000000000000 >> 4),
        ),
        fontUFO.Return(),
        fontUFO.Case(2),
        Array(
            *s3(0x000000331330000000000000 >> 8),
            *s3(0x000031111111300000000000 >> 8),
            *s3(0x000111111111110000000000 >> 8),
            *s3(0x001111111111111000000000 >> 8),
            *s3(0x031111111111111300000000 >> 8),
            *s3(0x011111111111111100000000 >> 8),
            *s3(0x311111111111111130000000 >> 8),
            *s3(0x311111111111111130000000 >> 8),
            *s3(0x111111111111111110000000 >> 8),
            *s3(0x311111111111111130000000 >> 8),
            *s3(0x311111111111111130000000 >> 8),
            *s3(0x011111111111111100000000 >> 8),
            *s3(0x031111111111111300000000 >> 8),
            *s3(0x001111111111111000000000 >> 8),
            *s3(0x000111111111110000000000 >> 8),
            *s3(0x000031111111300000000000 >> 8),
            *s3(0x000000331330000000000000 >> 8),
        ),
        fontUFO.Return(),
        fontUFO.Case(3),
        Array(
            *s3(0x000000331330000000000000 >> 12),
            *s3(0x000031111111300000000000 >> 12),
            *s3(0x000111111111110000000000 >> 12),
            *s3(0x001111111111111000000000 >> 12),
            *s3(0x031111111111111300000000 >> 12),
            *s3(0x011111111111111100000000 >> 12),
            *s3(0x311111111111111130000000 >> 12),
            *s3(0x311111111111111130000000 >> 12),
            *s3(0x111111111111111110000000 >> 12),
            *s3(0x311111111111111130000000 >> 12),
            *s3(0x311111111111111130000000 >> 12),
            *s3(0x011111111111111100000000 >> 12),
            *s3(0x031111111111111300000000 >> 12),
            *s3(0x001111111111111000000000 >> 12),
            *s3(0x000111111111110000000000 >> 12),
            *s3(0x000031111111300000000000 >> 12),
            *s3(0x000000331330000000000000 >> 12),
        ),
        fontUFO.Return(),
        fontUFO.Case(4),
        Array(
            *s3(0x000000331330000000000000 >> 16),
            *s3(0x000031111111300000000000 >> 16),
            *s3(0x000111111111110000000000 >> 16),
            *s3(0x001111111111111000000000 >> 16),
            *s3(0x031111111111111300000000 >> 16),
            *s3(0x011111111111111100000000 >> 16),
            *s3(0x311111111111111130000000 >> 16),
            *s3(0x311111111111111130000000 >> 16),
            *s3(0x111111111111111110000000 >> 16),
            *s3(0x311111111111111130000000 >> 16),
            *s3(0x311111111111111130000000 >> 16),
            *s3(0x011111111111111100000000 >> 16),
            *s3(0x031111111111111300000000 >> 16),
            *s3(0x001111111111111000000000 >> 16),
            *s3(0x000111111111110000000000 >> 16),
            *s3(0x000031111111300000000000 >> 16),
            *s3(0x000000331330000000000000 >> 16),
        ),
        fontUFO.Return(),
        fontUFO.Case(5),
        Array(
            *s3(0x000000331330000000000000 >> 20),
            *s3(0x000031111111300000000000 >> 20),
            *s3(0x000111111111110000000000 >> 20),
            *s3(0x001111111111111000000000 >> 20),
            *s3(0x031111111111111300000000 >> 20),
            *s3(0x011111111111111100000000 >> 20),
            *s3(0x311111111111111130000000 >> 20),
            *s3(0x311111111111111130000000 >> 20),
            *s3(0x111111111111111110000000 >> 20),
            *s3(0x311111111111111130000000 >> 20),
            *s3(0x311111111111111130000000 >> 20),
            *s3(0x011111111111111100000000 >> 20),
            *s3(0x031111111111111300000000 >> 20),
            *s3(0x001111111111111000000000 >> 20),
            *s3(0x000111111111110000000000 >> 20),
            *s3(0x000031111111300000000000 >> 20),
            *s3(0x000000331330000000000000 >> 20),
        ),
        fontUFO.Return(),
        fontUFO.Case(6),
        Array(
            *s3(0x000000331330000000000000 >> 24),
            *s3(0x000031111111300000000000 >> 24),
            *s3(0x000111111111110000000000 >> 24),
            *s3(0x001111111111111000000000 >> 24),
            *s3(0x031111111111111300000000 >> 24),
            *s3(0x011111111111111100000000 >> 24),
            *s3(0x311111111111111130000000 >> 24),
            *s3(0x311111111111111130000000 >> 24),
            *s3(0x111111111111111110000000 >> 24),
            *s3(0x311111111111111130000000 >> 24),
            *s3(0x311111111111111130000000 >> 24),
            *s3(0x011111111111111100000000 >> 24),
            *s3(0x031111111111111300000000 >> 24),
            *s3(0x001111111111111000000000 >> 24),
            *s3(0x000111111111110000000000 >> 24),
            *s3(0x000031111111300000000000 >> 24),
            *s3(0x000000331330000000000000 >> 24),
        ),
        fontUFO.Return(),
        fontUFO.Case(7),
        Array(
            *s3(0x000000331330000000000000 >> 28),
            *s3(0x000031111111300000000000 >> 28),
            *s3(0x000111111111110000000000 >> 28),
            *s3(0x001111111111111000000000 >> 28),
            *s3(0x031111111111111300000000 >> 28),
            *s3(0x011111111111111100000000 >> 28),
            *s3(0x311111111111111130000000 >> 28),
            *s3(0x311111111111111130000000 >> 28),
            *s3(0x111111111111111110000000 >> 28),
            *s3(0x311111111111111130000000 >> 28),
            *s3(0x311111111111111130000000 >> 28),
            *s3(0x011111111111111100000000 >> 28),
            *s3(0x031111111111111300000000 >> 28),
            *s3(0x001111111111111000000000 >> 28),
            *s3(0x000111111111110000000000 >> 28),
            *s3(0x000031111111300000000000 >> 28),
            *s3(0x000000331330000000000000 >> 28),
        ),
        fontUFO.Return(),
    ]
    Thread[
        audio.Push(0),  # wait for PLL lock
        audio.i2c(15, 0x00),  # SOFTWARE RESET
        audio.i2c(9, 0x00),  # ACTIVE: Active=0
        audio.i2c(0, 0x17),  # LEFT-CHANNEL ADC INPUT VOLUME: LINMUTE=0
        audio.i2c(1, 0x17),  # RIGHT-CHANNEL ADC INPUT VOLUME: RINMUTE=0
        audio.i2c(2, 0x79),  # LEFT-CHANNEL DAC VOLUME
        audio.i2c(3, 0x79),  # RIGHT-CHANNEL DAC VOLUME
        audio.i2c(
            4, 0x15
        ),  # ANALOG AUDIO PATH: SIDETONE_EN=0, DACSEL=1, Bypass=0, INSEL=1, MUTEMIC=0, MICBOOST=1
        audio.i2c(5, 0x01),  # DIGITAL AUDIO PATH: ADCHPF=1
        audio.i2c(
            6, 0x61
        ),  # POWER MANAGEMENT: PWROFF=0, CLKOUT=1, OSC=1, Out=0, DAC=0, ADC=0, MIC=0
        audio.i2c(7, 0x42),  # DIGITAL AUDIO I/F: MS=1, WL=00
        audio.i2c(8, sr_table[96000]),  # SAMPLING RATE: SR=xxxx, BOSR=1 (96kHz)
        audio.i2c(16, 0x1FB),  # ALC CONTROL 1: ALCSEL=11
        audio.i2c(17, 0x32),  # ALC CONTROL 2
        audio.i2c(18, 0x00),  # NOISE GATE
        audio.i2c(9, 0x01),  # ACTIVE: Active=1
        Out(
            "HDMIPAL",
            0x00000080,
            0x00FFFF81,
            0x00BBBB83,
            0xFF00FF82,
        ),
        blink := Int(),
        blink_state := Int(blink(0)),
        Do()[
            Do()[i2c.read(0x72, 0x42),].While(RegB & 0x6000 != 0x6000),
            i2c.update(0x72, 0x41, 0x40, 0),
            i2c.write(0x72, 0x98, 0x03),
            i2c.update(0x72, 0x9A, 0xE0, 0xE0),
            i2c.write(0x72, 0x9C, 0x30),
            i2c.update(0x72, 0x9D, 0x03, 0x01),
            i2c.write(0x72, 0xA2, 0xA4),
            i2c.write(0x72, 0xA3, 0xA4),
            i2c.write(0x72, 0xE0, 0xD0),
            mouse_mutex[
                mouse_click := Int(0),
                mouse_x := Int(320),
                mouse_y := Int(240),
            ],
            Out("HDMIPAL", 0x40),
            Do()[
                Acc("HDMI"),
                vram := Array(*([0] * (80 * 480))),
                vsync := Int(Acc),
                If(blink_state((blink_state + 1) & 0x1F) == 0)[
                    b := Int(),
                    Out("HDMIPAL", b(blink) & 0xFF),
                ].Else[
                    If(blink_state == 0x10)[Out("HDMIPAL", b),],
                ],
                usbProtocol := Int(),
                If(usbProtocol == 2)[
                    mouse_mutex[
                        Out(
                            "HDMIPAL",
                            mouse_x * 256 + 0x8F10,
                        ),
                        Out("HDMIPAL", mouse_y * 256 + 0x2320),
                    ],
                ].Else[
                    Out("HDMIPAL", 0x10, 0x20),
                ],
                i2c.read(0x72, 0x42),
            ].While(RegB & 0x6000 == 0x6000),
        ],
    ]
    fifo_audio = FIFO.Alloc()
    audio_shift = Array(*([0] * 11), op="OPB")
    Thread[
        audio_ready := Int(0),
        Do()[
            If(fifo_audio.IsEmpty())[
                pred0 := Int(0),
                pred1 := Int(0),
                pred2 := Int(0),
                pred3 := Int(0),
                pred4 := Int(0),
                pred5 := Int(0),
                delta := Int(1),
                audio_ready(1),
                Continue(),
            ],
            audio_ready(0),
            code := Int(fifo_audio.Pop()),
            i := Int(16),
            Do()[
                pred6 := Int(),
                audio.Push(
                    (
                        pred6(
                            pred0
                            - pred1 * 2
                            + pred2
                            - pred4
                            + pred5 * 2
                            + delta(((code & 3) | 1) * ((delta + 1) >> 1))
                            * ((code & 1) * 2 - 1)
                        )
                        & 0xFFFF
                    )
                    * 0x10001
                ),
                audio_shift,
                code(code >> 2),
                pred0(pred1),
                pred1(pred2),
                pred2(pred3),
                pred3(pred4),
                pred4(pred5),
                pred5(pred6),
            ].While(i(i - 1) != 0),
        ],
    ]

    def Play(freq: Array, fifo: FIFO, file: str) -> Block:
        data = np.load(file)
        b = Block()
        f = 96000 // int(data[0])
        for i in range(1, 12):
            b[freq[i - 1]("PUSH" if i < f else "LOAD"),]
        return b[
            Acc(fifo.port),
            Array(*[int(x) for x in data[1:]]),
        ]

    Thread[
        audio_state := Int(NO_SOUND := Label()),
        Do()[
            If(audio_ready == 0)[Continue(),],
            Code("JUMP", audio_state.put()),
            CANCEL := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/bubble/cancel.npy"),
            Continue(),
            SELL := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/bubble/sell.npy"),
            Continue(),
            NO_SOUND,
        ],
    ]
    Define[
        nrand := Function(n := UInt(), random := UInt())[
            RegB(random + 1, 2),
            AccU * RegB,
            r := UInt(random((AccU + 3) * RegB)),
        ].Return(((r >> 16) * n + (((r & 0xFFFF) * n) >> 16)) >> 16),
    ]
    Define[
        usb := USB(),
        fifo_usb := FIFO.Alloc(),
    ],
    Thread[
        If((usb.PowerOn() == 0) | (usb.RegRd(usb.REVISION) != 0x13))[
            LED(led=0x55),
        ].Else[
            Do()[
                LED(led=0),
                usb.Task(fifo_usb.port),
                Continue(),
                usb.USB_STATE_ERROR,
                usb.PowerOn(),
                Continue(),
                usb.USB_STATE_CONFIGURING,
                If(usb.rcode(usb.GetConfDescr(1, 0, 18, 0, fifo_usb.port)) != 0)[
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                If(fifo_usb.Pop() != 9)[
                    fifo_usb.Clear(),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                If(fifo_usb.Pop() != usb.USB_DESCRIPTOR_CONFIGURATION)[
                    fifo_usb.Clear(),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                If(fifo_usb.Pop() != 9)[
                    fifo_usb.Clear(),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                If(fifo_usb.Pop() != usb.USB_DESCRIPTOR_INTERFACE)[
                    fifo_usb.Clear(),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                fifo_usb.Pop(),
                If(fifo_usb.Pop() != 3)[  # HID
                    fifo_usb.Clear(),
                    usb.usb_task_state(usb.USB_STATE_ERROR),
                    Continue(),
                ],
                fifo_usb.Pop(),
                usbProtocol(fifo_usb.Pop()),
                fifo_usb.Pop(),
                If(usbProtocol == 2)[  # mouse
                    usb.MaxPktSize[1](8),
                    usb.SndToggle[1](usb.SNDTOG0),
                    usb.RcvToggle[1](usb.RCVTOG0),
                    If(usb.rcode(usb.SetConf(1, 0, 1)) != 0)[
                        usb.usb_task_state(usb.USB_STATE_ERROR),
                        Continue(),
                    ],
                    If(usb.rcode(usb.SetProto(1, 0, 0, 0)) != 0)[  # boot protocol
                        usb.usb_task_state(usb.USB_STATE_ERROR),
                        Continue(),
                    ],
                    usb.usb_task_state(usb.USB_STATE_RUNNING),
                    Continue(),
                ],
                usb.usb_task_state(usb.USB_STATE_ERROR),
                Continue(),
                usb.USB_STATE_RUNNING,
                If(usbProtocol == 2)[  # mouse
                    Do()[
                        If(usb.InTransfer(1, 3, fifo_usb) != 0)[Break(),],
                        click := Int(),
                        Out(
                            "LED",
                            ((In("KEY") & 0x3FF0) << 4)
                            | (click(fifo_usb.Pop()) ^ 0xFF),
                        ),
                        dx := Int((fifo_usb.Pop() ^ 0x80) - 0x80),
                        dy := Int((fifo_usb.Pop() ^ 0x80) - 0x80),
                        mouse_mutex[
                            mouse_click(click),
                            mouse_x(mouse_x + dx),
                            mouse_y(mouse_y + dy),
                        ],
                    ],
                ],
                fifo_usb.Clear(),
                usb.usb_task_state(usb.USB_STATE_ERROR),
            ],
        ],
    ],
    Thread[
        LED(
            hex3=0b1111100,
            hex2=0b0100101,
            hex1=0b1111110,
            hex0=0b0111011,
        ),
        play := Int(0),
        collision := Int(0),
        ufo_x := Int(320),
        ufo_y := Int(240),
        ufo_vx := Int(),
        ufo_vy := Int(),
        fifo_ufo := FIFO.Alloc(51),
        fifo_track := FIFO.Alloc(2),
        Do()[
            Do()[...].While(vsync == 0),
            If(play == 0)[
                nrand(0, In("TIMER")),
                ufo_x(320),
                ufo_y(240),
                ufo_vx(0),
                ufo_vy(0),
            ],
            If(collision == 0)[
                addr := Int(ufo_y * 80 + (ufo_x >> 3)),
                i := Int(80 * -8),
                Do()[
                    vram[addr + i - 1](0),
                    vram[addr + i](0),
                    vram[addr + i + 1](0),
                ].While(i(i + 80) != (80 * 9)),
            ],
            mouse_mutex[
                mx := Int(mouse_x),
                If(mx < 8)[mouse_x(mx(8)),].Else[If(mx > 631)[mouse_x(mx(631)),],],
                my := Int(mouse_y),
                If(my < 8)[mouse_y(my(8)),].Else[If(my > 471)[mouse_y(my(471)),],],
                play(play | mouse_click),
            ],
            x_stop := Int(((ufo_vx * (abs(ufo_vx) + 1)) >> 1) + ufo_x),
            If(ufo_vx < 0)[
                If(x_stop < mx)[ufo_vx(ufo_vx + 1),].Else[
                    If(x_stop + ufo_vx - 1 >= mx)[ufo_vx(ufo_vx - 1),],
                ],
            ].Else[
                If(ufo_vx != 0)[
                    If(x_stop > mx)[ufo_vx(ufo_vx - 1),].Else[
                        If(x_stop + ufo_vx + 1 <= mx)[ufo_vx(ufo_vx + 1),],
                    ],
                ].Else[
                    dx := Int(),
                    If(dx(mx - ufo_x) < 0)[ufo_vx(-1),].Else[If(dx != 0)[ufo_vx(1),],],
                ],
            ],
            y_stop := Int(((ufo_vy * (abs(ufo_vy) + 1)) >> 1) + ufo_y),
            If(ufo_vy < 0)[
                If(y_stop < my)[ufo_vy(ufo_vy + 1),].Else[
                    If(y_stop + ufo_vy - 1 >= my)[ufo_vy(ufo_vy - 1),],
                ],
            ].Else[
                If(ufo_vy != 0)[
                    If(y_stop > my)[ufo_vy(ufo_vy - 1),].Else[
                        If(y_stop + ufo_vy + 1 <= my)[ufo_vy(ufo_vy + 1),],
                    ],
                ].Else[
                    dy := Int(),
                    If(dy(my - ufo_y) < 0)[ufo_vy(-1),].Else[If(dy != 0)[ufo_vy(1),],],
                ],
            ],
            If(play != 0)[
                fifo_track.Clear(),
                fifo_track.Push(ufo_x(ufo_x + ufo_vx)),
                fifo_track.Push(ufo_y(ufo_y + ufo_vy)),
            ],
            If(collision == 0)[
                addr := Int(ufo_y * 80 + (ufo_x >> 3)),
                fontUFO.Switch(ufo_x & 7, fifo_ufo.port),
                i := Int(80 * -8),
                Do()[
                    vram[addr + i - 1](fifo_ufo.Pop()),
                    vram[addr + i](fifo_ufo.Pop()),
                    vram[addr + i + 1](fifo_ufo.Pop()),
                ].While(i(i + 80) != (80 * 9)),
            ],
            vsync(0),
        ],
    ]
    Define[
        n_max := 256,
        fire_f := Array(*([0] * n_max)),
        fire_x := Array(*([0] * n_max)),
        fire_y := Array(*([0] * n_max)),
        fire_vx := Array(*([0] * n_max)),
        fire_vy := Array(*([1] * n_max)),
    ]
    Thread[
        fifo_fire := FIFO.Alloc(18),
        n_fire := Int(),
        n0 := Int(),
        n_fire(n0(1)),
        r_min1 := Int(4096),
        r_min2 := Int(4096),
        Do()[
            Do()[...].While(vsync == 0),
            j := Int(0),
            Do()[
                If(fire_f[j] != 0)[
                    addr := Int(fire_y[j] * 80 + ((fire_x[j] - 4) >> 3)),
                    i := Int(80 * -4),
                    Do()[
                        vram[addr + i](0),
                        vram[addr + i + 1](0),
                    ].While(i(i + 80) != (80 * 5)),
                ],
            ].While(j(j + 1) != n_fire),
            ufo_x := Int(fifo_track.Pop()),
            ufo_y := Int(fifo_track.Pop()),
            r_min := Int(4096),
            f := Int(0),
            j := Int(0),
            Do()[
                If(fire_f[j] == 0)[
                    If(collision != 0)[Continue(),],
                    f(1),
                    x := Int(nrand(640 - 8) + 4),
                    y := Int(4),
                    dx := Int(ufo_x - x),
                    dy := Int(ufo_y - 4),
                    vy := Int(fire_vy[j]),
                    If(vy < 5)[
                        If(vy == 2)[
                            If((n0(n0 - 1) == 0) & (n_fire < n_max))[
                                fire_f[n_fire](0),
                                fire_vy[n_fire](1),
                                n_fire(n_fire + 1),
                                n0(1),
                            ],
                        ],
                        fire_vy[j](vy(vy + 1)),
                    ],
                    vx := Int(vy * abs(dx) // dy),
                    If(dx < 0)[vx(-vx),],
                    fire_vx[j](vx),
                    fire_f[j](1),
                ].Else[
                    x(fire_x[j] + fire_vx[j]),
                    y(fire_y[j] + fire_vy[j]),
                    If((x < 4) | (x > 635) | (y < 4) | (y > 475))[
                        fire_f[j](0),
                        Continue(),
                    ],
                    f(1),
                    If(collision == 0)[
                        dx := Int(ufo_x - x),
                        dy := Int(ufo_y - y),
                        r := Int(),
                        If(r(dx * dx + dy * dy) < r_min)[r_min(r),],
                        If(r < 144)[
                            audio_state(SELL),
                            collision(1),
                            k := Int(0),
                            Do()[
                                If(fire_f[k] == 0)[
                                    fire_f[k](1),
                                    fire_x[k](ufo_x),
                                    fire_y[k](ufo_y),
                                    Do()[
                                        vx := Int(nrand(33) - 16),
                                        vy := Int(nrand(33) - 16),
                                        r := Int(vx * vx + vy * vy),
                                    ].While((r > 256) | (r < 16)),
                                    fire_vx[k](vx),
                                    fire_vy[k](vy),
                                ],
                            ].While(k(k + 1) != n_max),
                            n_fire(n_max),
                        ],
                    ],
                ],
                fire_x[j](x),
                fire_y[j](y),
                addr := Int(y * 80 + ((x - 4) >> 3)),
                fontFire.Switch((x - 4) & 7, fifo_fire.port),
                i := Int(80 * -4),
                Do()[
                    vram[addr + i](fifo_fire.Pop()),
                    vram[addr + i + 1](fifo_fire.Pop()),
                ].While(i(i + 80) != (80 * 5)),
            ].While(j(j + 1) != n_fire),
            vsync(0),
            If((collision == 0) & (r_min > r_min1) & (r_min1 <= r_min2))[
                audio_state(CANCEL),
            ],
            r_min2(r_min1),
            r_min1(r_min),
            If((collision != 0) & (f == 0))[
                collision(0),
                n_fire(n0(1)),
                fire_vy[0](1),
                play(0),
            ],
        ],
    ]
