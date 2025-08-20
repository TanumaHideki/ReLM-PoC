import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import font8x8, Console
from relm_usb import USB
import numpy as np

loader = "loader/output_files/relm_c5g.svf" if __name__ == "__main__" else False

with ReLMLoader(__file__, loader=loader):
    Define[
        i2c := I2C(),
        audio := Audio(i2c),
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
        audio.i2c(8, sr_table[48000]),  # SAMPLING RATE: SR=xxxx, BOSR=1 (48kHz)
        audio.i2c(16, 0x1FB),  # ALC CONTROL 1: ALCSEL=11
        audio.i2c(17, 0x32),  # ALC CONTROL 2
        audio.i2c(18, 0x00),  # NOISE GATE
        audio.i2c(9, 0x01),  # ACTIVE: Active=1
        Out(
            "HDMIPAL",
            0x00000080,
            0x88888881,
            0x88880082,
            0x88000083,
            0x00880084,
            0x00008885,
            0xFFFF0086,
            0xFF000087,
            0x00FF0088,
            0x0000FF89,
            0x8800888E,
            0xFFFFFF8F,
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
                i2c.read(0x72, 0x42),
            ].While(RegB & 0x6000 == 0x6000),
        ],
    ]
    fifo_audio = FIFO.Alloc()
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
    Thread[
        audio_state := Int(NO_SOUND := Label()),
        Do()[
            If(audio_ready == 0)[Continue(),],
            Code("JUMP", audio_state.put()),
            CAST_DICE := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/cast_dice.npy")[1:]]),
            Continue(),
            BONUS := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/bonus.npy")[1:]]),
            Continue(),
            WALK := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/walk.npy")[1:]]),
            Continue(),
            CANCEL := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/cancel.npy")[1:]]),
            Continue(),
            BUY := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/buy.npy")[1:]]),
            Continue(),
            PURCHASE := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/purchase.npy")[1:]]),
            Continue(),
            CRISIS := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/crisis.npy")[1:]]),
            Continue(),
            SELL := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/sell.npy")[1:]]),
            Continue(),
            WIN := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/win.npy")[1:]]),
            Continue(),
            LOSE := Label(),
            audio_state(NO_SOUND),
            Acc(fifo_audio.port),
            Array(*[int(x) for x in np.load("c5g/loader/lose.npy")[1:]]),
            Continue(),
            NO_SOUND,
        ],
    ]
    Thread[console := Console(vram, 80, FIFO.Alloc(), FIFO.Alloc()),]
    Define[
        font8x8.Case(ord("\x01")),
        Array(
            0x11111111,
            0x11111111,
            0x01111110,
            0x01111110,
            0x00111100,
            0x00111100,
            0x00011000,
            0x00011000,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x02")),
        Array(
            0x00000011,
            0x00001111,
            0x00111111,
            0x11111111,
            0x11111111,
            0x00111111,
            0x00001111,
            0x00000011,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x03")),
        Array(
            0x00011000,
            0x00011000,
            0x00111100,
            0x00111100,
            0x01111110,
            0x01111110,
            0x11111111,
            0x11111111,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x04")),
        Array(
            0x11000000,
            0x11110000,
            0x11111100,
            0x11111111,
            0x11111111,
            0x11111100,
            0x11110000,
            0x11000000,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x05")),
        Array(
            0x00000000,
            0x00001110,
            0x00011111,
            0x00011111,
            0x00011111,
            0x00011111,
            0x00000100,
            0x00111111,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x06")),
        Array(
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x10000000,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x07")),
        Array(
            0x01111111,
            0x01111111,
            0x01011111,
            0x01011111,
            0x01011111,
            0x01011111,
            0x01011111,
            0x01011111,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x08")),
        Array(
            0x11000000,
            0x11000000,
            0x01000000,
            0x01000000,
            0x01000000,
            0x01000000,
            0x01000000,
            0x01000000,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x09")),
        Array(
            0x01011111,
            0x00011011,
            0x00011011,
            0x00011011,
            0x00011011,
            0x00011011,
            0x00011011,
            0x00000000,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x0a")),
        Array(
            0x01000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
            0x00000000,
        ),
        font8x8.Return(),
        font8x8.Case(ord("\x0b")),
        Array(
            0x00000000,
            0x00000000,
            0x00011000,
            0x00111100,
            0x00111100,
            0x00011000,
            0x00000000,
            0x00000000,
        ),
        font8x8.Return(),
    ]
    Define[
        owner := Array(
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 0),
            *(0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0),
            *(0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0),
            *(0, 1, 2, 1, 0, 0, 0, 2, 0, 0, 0, 1, 2, 1, 0),
            *(0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0),
            *(0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0),
            *(0, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        ),
        dir := Array(
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 2, 2, 2, 6, 2, 2, 2, 2, 2, 2, 2, 2, 4, 0),
            *(0, 1, 0, 0, 4, 0, 0, 0, 0, 0, 1, 0, 0, 4, 0),
            *(0, 1, 0, 2, 2, 2, 2, 2, 2, 2, 3, 4, 0, 4, 0),
            *(0, 1, 8, 9, 0, 0, 0, 0, 0, 0, 0, 4, 8, 12, 0),
            *(0, 1, 0, 1, 8, 8, 8, 8, 8, 8, 12, 8, 0, 4, 0),
            *(0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 4, 0, 0, 4, 0),
            *(0, 1, 8, 8, 9, 8, 8, 8, 8, 8, 8, 8, 8, 8, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        ),
        pawn := Array(
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            *(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        ),
        money := Array(*(2000, 2000, 2000)),
        goal := 100000,
        price := Array(*([0] * (15 * 9))),
        total := Array(*([0] * (15 * 9))),
        total2 := Array(*([0] * (15 * 9))),
        dispMap := Function(bonus := Int())[
            y := Int(0),
            While(y < 7)[
                cy := Int(y * (6 * 640) + 640 * 3),
                x := Int(0),
                While(x < 13)[
                    i := Int(y * 15 + x + 16),
                    o := Int(owner[i]),
                    If(o != 0)[
                        pos := Int(cy + x * 6 + (1 + 640)),
                        rgb := Int(pawn[i]),
                        console.Print("", color=0x90 + o),
                        If(rgb & 1 != 0)[
                            console.Print(" \x05\x06  ", pos),
                            console.Print(" \x07\x08  ", pos + 640),
                            console.Print(" \x09\x0a  ", pos + 640 * 2),
                        ].Else[
                            console.Print("     ", pos),
                            console.Print("     ", pos + 640),
                            console.Print("     ", pos + 640 * 2),
                        ],
                        console.Print("", color=0x80 + o),
                        If(rgb & 2 != 0)[
                            console.Print("\x05\x06", pos + 2),
                            console.Print("\x07\x08", pos + (2 + 640)),
                            console.Print("\x09\x0a", pos + (2 + 640 * 2)),
                        ],
                        console.Print("", color=0x70 + o),
                        If(rgb & 4 != 0)[
                            console.Print("\x05\x06", pos + 3),
                            console.Print("\x07\x08", pos + (3 + 640)),
                            console.Print("\x09\x0a", pos + (3 + 640 * 2)),
                        ],
                        p := Int(price[i]),
                        If(p != 0)[
                            If(o == 2)[
                                console.Print("BONUS", pos + 640 * 3, bonus),
                                If(bonus == 0x22)[console.Print("", color=0x02)],
                            ].Else[
                                If(o == 0xF)[c := Int(0x0F)].Else[c(0xF0 + o)],
                                console.Print("", pos + 640 * 3, c).Dec(
                                    total[i], "    d"
                                ),
                            ],
                            console.Print("", pos + 640 * 4).Dec(p, "    d"),
                        ],
                    ],
                    x(x + 1),
                ],
                y(y + 1),
            ],
        ],
    ]
    random = UInt()
    Thread[Do()[RegB(AccU + 1, 2), AccU * RegB, random((AccU + 3) * RegB)]]
    Define[
        nrand := Function(n := UInt())[
            r := UInt(random),
            x := UInt((r >> 16) * n + (((r & 0xFFFF) * n) >> 16)),
        ].Return(x >> 16),
        pos := (3 * 6 + 5) * 640 + 7 * 6 + 2 + 0x80000000,
        dispDice := Table(7),
        dispDice.Case(0),
        confirm := Array(
            0xC0000084,
            pos,
            0x202020,
            pos + 640,
            0x203F20,
            pos + 640 * 2,
            0x202020,
        ),
        dispDice.Return(),
        dispDice.Case(1),
        Array(
            0xC000003F,
            pos,
            0x202020,
            pos + 640,
            0x200B20,
            pos + 640 * 2,
            0x202020,
        ),
        dispDice.Return(),
        dispDice.Case(2),
        Array(
            0xC000000F,
            pos,
            0x20200B,
            pos + 640,
            0x202020,
            pos + 640 * 2,
            0x0B2020,
        ),
        dispDice.Return(),
        dispDice.Case(3),
        Array(
            0xC000000F,
            pos,
            0x0B2020,
            pos + 640,
            0x200B20,
            pos + 640 * 2,
            0x20200B,
        ),
        dispDice.Return(),
        dispDice.Case(4),
        Array(
            0xC000000F,
            pos,
            0x0B200B,
            pos + 640,
            0x202020,
            pos + 640 * 2,
            0x0B200B,
        ),
        dispDice.Return(),
        dispDice.Case(5),
        Array(
            0xC000000F,
            pos,
            0x0B200B,
            pos + 640,
            0x200B20,
            pos + 640 * 2,
            0x0B200B,
        ),
        dispDice.Return(),
        dispDice.Case(6),
        Array(
            0xC000000F,
            pos,
            0x0B200B,
            pos + 640,
            0x0B200B,
            pos + 640 * 2,
            0x0B200B,
        ),
        dispDice.Return(),
    ]
    keyboard = FIFO.Alloc()
    LEFT = 0x5C
    DOWN = 0x5A
    UP = 0x60
    RIGHT = 0x5E
    ENTER = 0x58
    Define[
        usb := USB(),
        fifo_usb := FIFO.Alloc(),
        scan_hid := Function(
            now := Int(),
            prev1 := Int(),
            prev2 := Int(),
            prev3 := Int(),
            prev4 := Int(),
            prev5 := Int(),
            prev6 := Int(),
        )[
            If(now == 0)[Return()],
            If(prev1 != 0)[
                If(prev1 == now)[Return()],
                If(prev2 != 0)[
                    If(prev2 == now)[Return()],
                    If(prev3 != 0)[
                        If(prev3 == now)[Return()],
                        If(prev4 != 0)[
                            If(prev4 == now)[Return()],
                            If(prev5 != 0)[
                                If(prev5 == now)[Return()],
                                If(prev6 == now)[Return()],
                            ],
                        ],
                    ],
                ],
            ],
            If((now == LEFT) | (now == 0x50))[keyboard.Push(LEFT)],
            If((now == DOWN) | (now == 0x51))[keyboard.Push(DOWN)],
            If((now == UP) | (now == 0x52))[keyboard.Push(UP)],
            If((now == RIGHT) | (now == 0x4F))[keyboard.Push(RIGHT)],
            If((now == ENTER) | (now == 0x28))[keyboard.Push(ENTER)],
        ],
        scan_sw := Function(led := Int(), prev := Int())[
            now := Int(),
            Out("LED", ((now(In("KEY")) & 0x3FF0) << 4) | led),
            make := Int(now & ~prev),
            If(make & 0b1000 != 0)[keyboard.Push(LEFT)],
            If(make & 0b0100 != 0)[keyboard.Push(DOWN)],
            If(make & 0b0010 != 0)[keyboard.Push(UP)],
            If(make & 0b0001 != 0)[keyboard.Push(RIGHT)],
            If(make & (1 << 14) != 0)[keyboard.Push(ENTER)],
            prev(now),
        ],
    ],
    Thread[
        scan_sw(0, 0),
        If((usb.PowerOn() == 0) | (usb.RegRd(usb.REVISION) != 0x13))[
            Do()[scan_sw(0x55),],
        ].Else[
            Do()[
                Do()[
                    scan_sw(0),
                    usb.Task(fifo_usb.port),
                    Continue(),
                    usb.USB_STATE_ERROR,
                    usb.PowerOn(),
                    Continue(),
                    usb.USB_STATE_CONFIGURING,
                    usb.MaxPktSize[1](8),
                    usb.SndToggle[1](usb.SNDTOG0),
                    usb.RcvToggle[1](usb.RCVTOG0),
                    If(usb.SetConf(1, 0, 1) != 0)[
                        usb.usb_task_state(usb.USB_STATE_ERROR),
                        Continue(),
                    ],
                    If(usb.SetProto(1, 0, 0, 0) != 0)[
                        usb.usb_task_state(usb.USB_STATE_ERROR),
                        Continue(),
                    ],
                    If(usb.SetIdle(1, 0, 0, 0, 1) != 0)[
                        usb.usb_task_state(usb.USB_STATE_ERROR),
                        Continue(),
                    ],
                    usb.usb_task_state(usb.USB_STATE_RUNNING),
                    Continue(),
                    usb.USB_STATE_RUNNING,
                    key1 := Int(0),
                    key2 := Int(),
                    key3 := Int(),
                    key4 := Int(),
                    key5 := Int(),
                    key6 := Int(),
                    Do()[
                        scan_sw(0xFF),
                        If(usb.InTransfer(1, 8, fifo_usb) != 0)[Break(),],
                        fifo_usb.Pop(),
                        fifo_usb.Pop(),
                        now := Int(),
                        scan_hid(
                            now(fifo_usb.Pop()), key1, key2, key3, key4, key5, key6
                        ),
                        key1(now),
                        now := Int(),
                        scan_hid(now(fifo_usb.Pop())),
                        key2(now),
                        now := Int(),
                        scan_hid(now(fifo_usb.Pop())),
                        key3(now),
                        now := Int(),
                        scan_hid(now(fifo_usb.Pop())),
                        key4(now),
                        now := Int(),
                        scan_hid(now(fifo_usb.Pop())),
                        key5(now),
                        now := Int(),
                        scan_hid(now(fifo_usb.Pop())),
                        key6(now),
                    ],
                ],
                Do()[scan_sw(0),].While(usb.IntHandler() == 0),
            ],
        ],
    ],
    Define[
        distance := Array(*([0] * (15 * 9))),
        group := Array(*([0] * (15 * 9))),
        estate := Array(*([0] * 3)),
        eval := Array(*([0] * (15 * 9))),
        eval_money := Array(*([0] * 3)),
        eval_estate := Array(*([0] * 3)),
        dice_pos := Array(*([0] * 7)),
        dispBar := Function(index := Int())[
            a0 := Int(estate[0] + money[0]),
            a1 := Int(estate[1] + money[1]),
            a2 := Int(estate[2] + money[2]),
            If(a0 > a1)[a01 := Int(a0)].Else[a01(a1)],
            If(a2 > a01)[a012 := Int(a2)].Else[a012(a01)],
            If(a012 >= goal)[scale := Int(a012)].Else[
                If(a012 * 2 >= goal)[scale(goal)].Else[scale(a012 * 2)]
            ],
            If(money[index] < 0)[
                e := Int(estate[index] + money[index]),
                If(e < 0)[e(0)],
                m := Int(0),
            ].Else[
                e(estate[index]),
                m(money[index]),
            ],
            ec := Int(e * 80 // scale),
            mc := Int((e + m) * 80 // scale),
            i := Int(0),
            While(i < ec)[console.Print(" "), i(i + 1)],
            While(i < mc)[console.Print("$"), i(i + 1)],
            console.Print("", color=0x00),
            While(i < 80)[console.Print(" "), i(i + 1)],
        ],
        fillMessage := Function(color := Int())[
            console.Print("                             ", 640 * 10 + 25, color),
            console.Print("                             ", 640 * 11 + 25),
            console.Print("                             ", 640 * 12 + 25),
            console.Print("                             ", 640 * 13 + 25),
            console.Print("                             ", 640 * 14 + 25),
        ],
        dispColor := Function(value := Int())[
            If(value < 0)[console.Print("-", color=0xF3).Dec(-value, "    d")].Else[
                console.Print("", color=0xF0).Dec(value, "     d")
            ],
        ].Return(value),
        dispStatus := Function()[
            console.Print("", 640 * 49 + 10),
            dispColor(estate[1]),
            console.Print("", 640 * 49 + 21),
            dispColor(money[1]),
            console.Print("", 640 * 49 + 32),
            dispColor(estate[1] + money[1]),
            console.Print("", 640 * 50, 0x84),
            dispBar(1),
            console.Print("", 640 * 51 + 320 + 10),
            dispColor(estate[0]),
            console.Print("", 640 * 51 + 320 + 21),
            dispColor(money[0]),
            console.Print("", 640 * 51 + 320 + 32),
            dispColor(estate[0] + money[0]),
            console.Print("", 640 * 52 + 320, 0x73),
            dispBar(0),
            console.Print("", 640 * 54 + 10),
            dispColor(estate[2]),
            console.Print("", 640 * 54 + 21),
            dispColor(money[2]),
            console.Print("", 640 * 54 + 32),
            dispColor(estate[2] + money[2]),
            console.Print("", 640 * 55, 0x95),
            dispBar(2),
        ],
        playTurn := Function(
            index := Int(),
            human := Int(),
            color := Int(),
            pawn_bit := Int(),
        )[
            dispStatus(),
            min_asset := Int(money[0] + estate[0]),
            asset := Int(money[1] + estate[1]),
            If(min_asset > asset)[min_asset(asset)],
            asset := Int(money[2] + estate[2]),
            If(min_asset > asset)[min_asset(asset)],
            If(min_asset == money[index] + estate[index])[bonus := Int(0x62)].Else[
                bonus(0x22)
            ],
            dispMap(bonus),
            blink(color),
            own := Int((color & 0xF) - 4),
            confirm[0](own * 0x11 + 0xC0000040),
            Do()[...].While(audio_ready == 0),
            If(human != 0)[
                fillMessage((color & 0xF) * 16 + 0x0E),
                console.Print("Enter key:  Roll the dice", 640 * 12 + 27),
                timer := Timer(),
                dice := Int(1),
                keyboard.Clear(),
                Do()[
                    If(timer.IsTimeout())[
                        dispDice.Switch(dice, console.fifo_print.port),
                        If(dice == 6)[dice(1)].Else[dice(dice + 1)],
                        timer.After(ms=250),
                    ],
                ].While(keyboard.IsEmpty() | (keyboard.Pop() != ENTER)),
            ],
            audio_state(CAST_DICE),
            Do()[...].While(audio_ready != 0),
            Do()[
                If(vsync != 0)[
                    dispDice.Switch(nrand(6) + 1, console.fifo_print.port),
                    vsync(0),
                ],
            ].While(audio_ready == 0),
            dice := Int(nrand(6) + 1),
            dispDice.Switch(dice, console.fifo_print.port),
            i := Int(16),
            Do()[
                distance[i](0),
                i(i + 1),
            ].While(i < 15 * 7 + 14),
            i := Int(15),
            Do()[i(i + 1),].While(pawn[i] & pawn_bit == 0),
            pawn_i := Int(i),
            distance[pawn_i](dice + 1),
            flag := Int(),
            Do()[
                flag(0),
                i := Int(16),
                Do()[
                    dist := Int(distance[i] - 1),
                    If(dist != -1)[
                        dir_i := Int(dir[i]),
                        If(dir_i & 1 == 0)[
                            j := Int(i - 15),
                            If(owner[j] != 0)[
                                If(distance[j] < dist)[
                                    distance[j](dist),
                                    flag(1),
                                ],
                            ],
                        ],
                        If(dir_i & 2 == 0)[
                            j := Int(i + 1),
                            If(owner[j] != 0)[
                                If(distance[j] < dist)[
                                    distance[j](dist),
                                    flag(1),
                                ],
                            ],
                        ],
                        If(dir_i & 4 == 0)[
                            j := Int(i + 15),
                            If(owner[j] != 0)[
                                If(distance[j] < dist)[
                                    distance[j](dist),
                                    flag(1),
                                ],
                            ],
                        ],
                        If(dir_i & 8 == 0)[
                            j := Int(i - 1),
                            If(owner[j] != 0)[
                                If(distance[j] < dist)[
                                    distance[j](dist),
                                    flag(1),
                                ],
                            ],
                        ],
                    ],
                    i(i + 1),
                ].While(i < 15 * 7 + 14),
            ].While(flag != 0),
            If(human != 0)[
                Do()[
                    fillMessage(0xFE),
                    If(distance[pawn_i] != 1)[
                        console.Print("Cursor keys:", 640 * 10 + 160 + 26),
                        console.Print("Step ahead or back", 640 * 11 + 160 + 35),
                        console.Print("Enter key:", 640 * 12 + 480 + 26),
                        console.Print("Fix your position", 640 * 13 + 480 + 35),
                    ].Else[
                        o := Int(owner[pawn_i]),
                        If(o == 1)[
                            If(price[pawn_i] <= money[index])[
                                console.Print(
                                    "Buy the vacant lot.", 640 * 10 + 320 + 26
                                ),
                                console.Print(
                                    "The price of the lot will", 640 * 12 + 320 + 26
                                ),
                                console.Print("increase by 50%.", 640 * 13 + 320 + 26),
                            ].Else[
                                console.Print("Nothing occurs.", 640 * 10 + 320 + 26),
                                console.Print(
                                    "Unable to buy the vacant", 640 * 12 + 320 + 26
                                ),
                                console.Print(
                                    "lot due to lack of money.", 640 * 13 + 320 + 26
                                ),
                            ],
                        ].Else[
                            If(o == 2)[
                                If(bonus == 0x62)[
                                    console.Print(
                                        "Get the bonus for the", 640 * 11 + 26
                                    ),
                                    console.Print(
                                        "player with the smallest", 640 * 12 + 26
                                    ),
                                    console.Print("assets.", 640 * 13 + 26),
                                ].Else[
                                    console.Print(
                                        "Nothing occurs.", 640 * 10 + 320 + 26
                                    ),
                                    console.Print(
                                        "Unable to get the bonus for",
                                        640 * 11 + 320 + 26,
                                    ),
                                    console.Print(
                                        "the player with the",
                                        640 * 12 + 320 + 26,
                                    ),
                                    console.Print(
                                        "smallest assets.", 640 * 13 + 320 + 26
                                    ),
                                ],
                            ].Else[
                                If(o == own)[
                                    console.Print("Nothing occurs.", 640 * 11 + 26),
                                    console.Print("It's your own land.", 640 * 13 + 26),
                                ].Else[
                                    If(total[pawn_i] <= money[index])[
                                        console.Print(
                                            "Buy all adjoining lots of",
                                            640 * 10 + 26,
                                        ),
                                        console.Print(
                                            "the same player.",
                                            640 * 11 + 26,
                                        ),
                                        console.Print(
                                            "The above value in the cell",
                                            640 * 12 + 26,
                                        ),
                                        console.Print(
                                            "is total price of the",
                                            640 * 13 + 26,
                                        ),
                                        console.Print(
                                            "adjoining lots.",
                                            640 * 14 + 26,
                                        ),
                                    ].Else[
                                        fillMessage((color & 0xF) * 16 + 0x0E),
                                        console.Print(
                                            "Buy all adjoining lots of",
                                            640 * 10 + 26,
                                        ),
                                        console.Print(
                                            "the same player.",
                                            640 * 11 + 26,
                                        ),
                                        console.Print(
                                            "Must sell some of your lots",
                                            640 * 12 + 26,
                                        ),
                                        console.Print(
                                            "at 50% discount to redeem",
                                            640 * 13 + 26,
                                        ),
                                        console.Print(
                                            "your debt.",
                                            640 * 14 + 26,
                                        ),
                                    ]
                                ]
                            ],
                        ],
                    ],
                    k := Int(keyboard.Pop()),
                    If(k == UP)[pawn_j := Int(pawn_i - 15),].Else[
                        If(k == RIGHT)[pawn_j(pawn_i + 1),].Else[
                            If(k == DOWN)[pawn_j(pawn_i + 15),].Else[
                                If(k == LEFT)[pawn_j(pawn_i - 1),].Else[
                                    If((k == ENTER) & (distance[pawn_i] == 1))[Break()],
                                    Continue(),
                                ],
                            ],
                        ],
                    ],
                    If(distance[pawn_j] == 0)[Continue()],
                    pawn[pawn_i](pawn[pawn_i] & (pawn_bit ^ 7)),
                    pawn[pawn_j](pawn[pawn_j] | pawn_bit),
                    If(distance[pawn_j] < distance[pawn_i])[audio_state(WALK),].Else[
                        audio_state(CANCEL),
                    ],
                    dispMap(bonus),
                    dispDice.Switch(distance[pawn_j] - 1, console.fifo_print.port),
                    pawn_i(pawn_j),
                ],
                fillMessage(0x00),
                dest := Int(pawn_i),
            ].Else[  # human == 0
                If(index == 0)[index0 := Int(1)].Else[index0(0)],
                If(index == 2)[index2 := Int(1)].Else[index2(2)],
                max_eval := Int(0x80000000),
                d := Int(16),
                Do()[
                    If(distance[d] == 1)[
                        eval_estate[0](estate[0]),
                        eval_estate[1](estate[1]),
                        eval_estate[2](estate[2]),
                        eval_money[0](money[0]),
                        eval_money[1](money[1]),
                        eval_money[2](money[2]),
                        o := Int(owner[d]),
                        If(o == 1)[
                            pd := Int(price[d]),
                            If(pd <= eval_money[index])[
                                eval_money[index](eval_money[index] - pd),
                                pd := Int((pd * 3 + 1) >> 1),
                                eval_estate[index](eval_estate[index] + pd),
                            ],
                        ].Else[
                            If(o == 2)[
                                If(bonus == 0x62)[
                                    eval_money[index](eval_money[index] + price[d]),
                                ],
                            ].Else[
                                If(o != own)[
                                    t := Int(total[d]),
                                    index_dest := Int(o - 3),
                                    eval_estate[index_dest](
                                        eval_estate[index_dest] - t
                                    ),
                                    eval_money[index_dest](eval_money[index_dest] + t),
                                    eval_money[index](eval_money[index] - t),
                                    t := Int((t * 3 + 1) >> 1),
                                    eval_estate[index](eval_estate[index] + t),
                                    t := Int(eval_money[index]),
                                    If(t < 0)[
                                        eval_estate[index](eval_estate[index] + t * 2),
                                        eval_money[index](0),
                                    ],
                                ],
                            ],
                        ],
                        e0 := Int(eval_estate[index0] * 2 + eval_money[index0] * 3),
                        e2 := Int(eval_estate[index2] * 2 + eval_money[index2] * 3),
                        If(e0 < e2)[e0(e2)],
                        e1 := Int(eval_estate[index] * 2 + eval_money[index] * 3 - e0),
                        eval[d](e1),
                        If(max_eval < e1)[max_eval(e1)],
                    ],
                    d(d + 1),
                ].While(d < 15 * 7 + 14),
                Do()[d := Int(nrand(15 * 7 + 14 - 16) + 16),].While(
                    (distance[d] != 1) | (eval[d] != max_eval)
                ),
                dest(d),
                dice_pos[0](d),
                d := Int(d),
                i := Int(1),
                Do()[
                    i1 := Int(i + 1),
                    If(distance[d - 15] == i1)[d(d - 15)].Else[
                        If(distance[d - 1] == i1)[d(d - 1)].Else[
                            If(distance[d + 1] == i1)[d(d + 1)].Else[d(d + 15)]
                        ]
                    ],
                    dice_pos[i](d),
                    i(i1),
                ].While(i <= dice),
                i := Int(dice),
                timer := Timer(ms=250),
                Do()[
                    pawn_i := Int(dice_pos[i]),
                    j := Int(i - 1),
                    pawn_j := Int(dice_pos[j]),
                    pawn[pawn_i](pawn[pawn_i] & (pawn_bit ^ 7)),
                    pawn[pawn_j](pawn[pawn_j] | pawn_bit),
                    audio_state(WALK),
                    dispMap(bonus),
                    dispDice.Switch(j, console.fifo_print.port),
                    Do()[...].While(audio_ready == 0),
                    i(j),
                    timer.Wait(),
                    timer.After(ms=250),
                ].While(i != 0),
            ],
            o := Int(owner[dest]),
            If(o == 1)[
                If(price[dest] <= money[index])[
                    money[index](money[index] - price[dest]),
                    price[dest]((price[dest] * 3 + 1) >> 1),
                    total[dest](price[dest]),
                    estate[index](estate[index] + price[dest]),
                    owner[dest](own),
                    audio_state(BUY),
                    dispMap(bonus),
                    dispStatus(),
                    Do()[...].While(audio_ready == 0),
                ]
            ].Else[
                If(o == 2)[
                    If(bonus == 0x62)[
                        money[index](money[index] + price[dest]),
                        price[dest]((price[dest] * 3 + 1) >> 1),
                        audio_state(BONUS),
                        dispMap(bonus),
                        dispStatus(),
                        Do()[...].While(audio_ready == 0),
                    ],
                ].Else[
                    If(o != own)[
                        t := Int(total[dest]),
                        index_dest := Int(o - 3),
                        estate[index_dest](estate[index_dest] - t),
                        money[index_dest](money[index_dest] + t),
                        money[index](money[index] - t),
                        g := Int(group[dest]),
                        p := Int((price[dest] * 3 + 1) >> 1),
                        price[dest](p),
                        total[dest](total2[dest]),
                        estate[index](estate[index] + p),
                        owner[dest](own),
                        audio_state(PURCHASE),
                        dispMap(bonus),
                        dispStatus(),
                        Do()[...].While(audio_ready == 0),
                        i := Int(16),
                        Do()[
                            If((i != dest) & (group[i] == g))[
                                p := Int((price[i] * 3 + 1) >> 1),
                                price[i](p),
                                total[i](total2[i]),
                                estate[index](estate[index] + p),
                                owner[i](own),
                                audio_state(BUY),
                                dispMap(bonus),
                                dispStatus(),
                                Do()[...].While(audio_ready == 0),
                            ],
                            i(i + 1),
                        ].While(i < 15 * 7 + 14),
                        If(money[index] < 0)[
                            audio_state(CRISIS),
                            Do()[...].While(audio_ready != 0),
                            Do()[...].While(audio_ready == 0),
                        ],
                        While((money[index] < 0) & (estate[index] != 0))[
                            Do()[i := Int(nrand(15 * 7 + 14 - 16) + 16),].While(
                                owner[i] != own
                            ),
                            owner[i](0xF),
                            group[i](0),
                            p := Int(price[i]),
                            estate[index](estate[index] - p),
                            p := Int((p + 1) >> 1),
                            price[i](p),
                            total[i](p),
                            money[index](money[index] + p),
                            audio_state(SELL),
                            dispMap(bonus),
                            dispStatus(),
                            Do()[...].While(audio_ready == 0),
                        ],
                        i := Int(16),
                        Do()[
                            If(owner[i] == 0xF)[owner[i](1)],
                            i(i + 1),
                        ].While(i < 15 * 7 + 14),
                    ],
                ],
            ],
            i := Int(16),
            Do()[
                If(owner[i] == own)[
                    group[i](i),
                    total[i](0),
                    total2[i](0),
                ],
                i(i + 1),
            ].While(i < 15 * 7 + 14),
            flag := Int(),
            Do()[
                flag(0),
                i := Int(16),
                Do()[
                    If(owner[i] == own)[
                        g := Int(group[i]),
                        If(owner[i + 15] == own)[
                            gy := Int(group[i + 15]),
                            If(g < gy)[
                                g(gy),
                                group[i](gy),
                                flag(1),
                            ].Else[
                                If(g > gy)[
                                    group[i + 15](g),
                                    flag(1),
                                ],
                            ],
                        ].Else[gy(0)],
                        If(owner[i + 1] == own)[
                            gx := Int(group[i + 1]),
                            If(g < gx)[
                                group[i](gx),
                                If(gy != 0)[group[i + 15](gx)],
                                flag(1),
                            ].Else[
                                If(g > gx)[
                                    group[i + 1](g),
                                    flag(1),
                                ],
                            ],
                        ],
                    ],
                    i(i + 1),
                ].While(i < 15 * 7 + 14),
            ].While(flag != 0),
            i := Int(16),
            Do()[
                If(owner[i] == own)[
                    g := Int(group[i]),
                    p := Int(price[i]),
                    q := Int((p * 3 + 1) >> 1),
                    total[g](total[g] + p),
                    total2[g](total2[g] + q),
                ],
                i(i + 1),
            ].While(i < 15 * 7 + 14),
            i := Int(16),
            Do()[
                If(owner[i] == own)[
                    g := Int(group[i]),
                    total[i](total[g]),
                    total2[i](total2[g]),
                ],
                i(i + 1),
            ].While(i < 15 * 7 + 14),
            asset := Int(money[index] + estate[index]),
            If((asset < 0) | (asset >= goal))[
                fillMessage((color & 0xF) * 16 + 0x0E),
                console.Print("", 640 * 12 + 25),
            ],
        ].Return(
            asset
        ),
        clear := Function()[
            i := Int(3),
            Do()[
                console.Print(
                    "                                                                                ",
                    640 * i,
                    0xF0,
                ),
                i(i + 1),
            ].While(i <= 59),
        ],
    ]
    Thread[
        LED(
            hex3=0b1111100,
            hex2=0b0100101,
            hex1=0b1111110,
            hex0=0b0111011,
        ),
        blink(0x00FF0088),
        console.Print(
            "                                                                               ",
            0,
            0x6E,
        ),
        console.Print(
            "      Bubble Estate - Playable Proof of Concept for the ReLM Architecture      ",
            640,
        ),
        console.Print(
            "                                                                               ",
            640 * 2,
        ),
        Do()[
            clear(),
            console.Print("Introduction:", 640 * 4),
            console.Print(
                "This game, running on a ring topology multiprocessor system built on an FPGA,",
                640 * 6 + 3,
            ),
            console.Print(
                "is a playable demo application based on the ReLM architecture.",
                640 * 7 + 3,
            ),
            console.Print(
                "It shows how the ReLM architecture makes parallel processing simple and",
                640 * 9 + 3,
            ),
            console.Print(
                "building stand-alone applications easy, in need of no operating system.",
                640 * 10 + 3,
            ),
            console.Print("Playable Demo:", 640 * 13),
            console.Print(
                "Bubble Estate is a simple Monopoly-like dice game.",
                640 * 15 + 3,
            ),
            console.Print(
                "Just roll dice and choose the next cell to go, and only that.",
                640 * 17 + 3,
            ),
            console.Print("Let's play the new technology!", 640 * 20 + 3),
            console.Print("Goal:", 640 * 23),
            console.Print(
                "You win when your total assets (real estate + money) reach %d." % goal,
                640 * 25 + 3,
            ),
            console.Print(
                "However, when one of the players goes bankrupt, the game is over.",
                640 * 27 + 3,
            ),
            console.Print("Move:", 640 * 30),
            console.Print(
                "Roll dice and move forward according to the number on the dice.",
                640 * 32 + 3,
            ),
            console.Print('Roll dice by pressing "Enter",', 640 * 34 + 3),
            console.Print(
                "and then choose the next cell with the cursor keys.", 640 * 35 + 3
            ),
            console.Print("     ", 640 * 37 + 3, 0xF1),
            console.Print("     ", 640 * 38 + 3),
            console.Print("     ", 640 * 39 + 3),
            console.Print("  200", 640 * 40 + 3),
            console.Print("  200", 640 * 41 + 3),
            console.Print("     ", 640 * 37 + 9),
            console.Print("     ", 640 * 38 + 9),
            console.Print("     ", 640 * 39 + 9),
            console.Print("  200", 640 * 40 + 9),
            console.Print("  200", 640 * 41 + 9),
            console.Print("     ", 640 * 37 + 15),
            console.Print("     ", 640 * 38 + 15),
            console.Print("     ", 640 * 39 + 15),
            console.Print("  200", 640 * 40 + 15),
            console.Print("  200", 640 * 41 + 15),
            console.Print(" ", 640 * 39 + 14, 0xFF),
            console.Print("\x02", 640 * 39 + 8, 0xF0),
            console.Print(
                "\x02 between cells shows one-way traffic.",
                640 * 38 + 21,
            ),
            console.Print(" ", 640 * 40 + 21, 0xFF),
            console.Print(" between cells shows two-way traffic.", color=0xF0),
            console.Print(
                "On reaching a cell, you will see an event description in the message window",
                640 * 43 + 3,
            ),
            console.Print(
                "and have the event to occur.",
                640 * 44 + 3,
            ),
            console.Print(
                'You can change your way to go until pressing "Enter" to fix your position.',
                640 * 46 + 3,
            ),
            console.Print(
                'Press "Right" or "Down" to go to the next page.', 640 * 50, 0x80
            ),
            console.Print('Press "Enter" to start the game.', 640 * 52),
            Do()[k := Int(keyboard.Pop())].While(
                (k != DOWN) & (k != RIGHT) & (k != ENTER)
            ),
            If(k == ENTER)[Break()],
            clear(),
            console.Print("Events:", 640 * 4),
            console.Print("Gray cells represent vacant lots of land.", 640 * 6 + 3),
            console.Print("     ", 640 * 8 + 3, 0xF1),
            console.Print("     ", 640 * 9 + 3),
            console.Print("     ", 640 * 10 + 3),
            console.Print("  200", 640 * 11 + 3),
            console.Print("  200", 640 * 12 + 3),
            console.Print(
                "The number in each cell shows the land price.", 640 * 11 + 9, 0xF0
            ),
            console.Print(
                "Once you stay in a gray cell, you are to automatically buy that lot as long",
                640 * 14 + 3,
            ),
            console.Print(
                "as you have enough money.",
                640 * 15 + 3,
            ),
            console.Print(
                "If you are short of money, you will not be forced to buy.",
                640 * 17 + 3,
            ),
            console.Print(
                "Cells in other colors than yellow represent owned lots.", 640 * 20 + 3
            ),
            console.Print("     ", 640 * 22 + 3, 0xF3),
            console.Print("     ", 640 * 23 + 3),
            console.Print("     ", 640 * 24 + 3),
            console.Print("  750", 640 * 25 + 3),
            console.Print("  300", 640 * 26 + 3),
            console.Print("     ", 640 * 22 + 9),
            console.Print("     ", 640 * 23 + 9),
            console.Print("     ", 640 * 24 + 9),
            console.Print("  750", 640 * 25 + 9),
            console.Print("  450", 640 * 26 + 9),
            console.Print("\x02", 640 * 24 + 8, 0xF0),
            console.Print(
                "The upper value is the total price of adjoining lots,", 640 * 25 + 15
            ),
            console.Print(
                "and the lower value is the price of each lot.", 640 * 26 + 15
            ),
            console.Print(
                "When you stay in an owned lot except yours, you are to buy all adjoining",
                640 * 28 + 3,
            ),
            console.Print(
                "lots of the same owner in disregard to the amount of your money.",
                640 * 29 + 3,
            ),
            console.Print(
                "Once you buy a lot, the land price increases by 50%, bringing the same",
                640 * 31 + 3,
            ),
            console.Print("increase in your total assets.", 640 * 32 + 3),
            console.Print(
                "However, if you get short of money due to forced purchase, your lots are to",
                640 * 34 + 3,
            ),
            console.Print(
                "be randomly sold at 50% discount to redeem your debt.",
                640 * 35 + 3,
            ),
            console.Print(
                "The player with the smallest assets is to get a bonus on getting into a",
                640 * 38 + 3,
            ),
            console.Print("yellow cell.", 640 * 39 + 3),
            console.Print("     ", 640 * 41 + 3, 0x62),
            console.Print("     ", 640 * 42 + 3),
            console.Print("     ", 640 * 43 + 3),
            console.Print("BONUS", 640 * 44 + 3),
            console.Print("  100", 640 * 45 + 3),
            console.Print('The "', 640 * 44 + 9, 0xF0),
            console.Print("BONUS", color=0x62),
            console.Print(
                '" message will disappear and nothing will happen unless you',
                color=0xF0,
            ),
            console.Print("are the owner of the smallest assets.", 640 * 45 + 9),
            console.Print(
                "Once you get a bonus, you will have next bonus to increase by 50%.",
                640 * 47 + 3,
            ),
            console.Print("Tip:", 640 * 49),
            console.Print(
                "A tip to reverse the game is not to make the top player richer.",
                640 * 51 + 3,
            ),
            console.Print(
                "When you are to buy lots, try to buy from the other player than the top one.",
                640 * 53 + 3,
            ),
            console.Print(
                'Press "Left" or "Up" to go back to the previous page.', 640 * 56, 0x80
            ),
            console.Print('Press "Enter" to start the game.', 640 * 58),
            Do()[k := Int(keyboard.Pop())].While(
                (k != LEFT) & (k != UP) & (k != ENTER)
            ),
        ].While(k != ENTER),
        clear(),
        console.Print(
            "                                                                               ",
            640 * 46,
            0xFE,
        ),
        console.Print(
            "                                                                               ",
            640 * 47,
        ),
        console.Print(
            "         RealEstate + Money = TotalAssets (Goal: %d)" % goal,
            640 * 46 + 320,
        ),
        console.Print(
            " You   ",
            640 * 49,
            0x84,
        ),
        console.Print(
            " Alice ",
            640 * 51 + 320,
            0x73,
        ),
        console.Print(
            " Bob   ",
            640 * 54,
            0x95,
        ),
        y := Int(0),
        While(y < 7)[
            cy := Int(y * (6 * 640) + 640 * 3),
            x := Int(0),
            While(x < 13)[
                i := Int(y * 15 + x + 16),
                o := Int(owner[i]),
                If(o != 0)[
                    pos := Int(cy + x * 6),
                    If(o == 1)[
                        price[i](200),
                        total[i](200),
                    ].Else[
                        price[i](100),
                    ],
                    d := Int(dir[i]),
                    If(d & 1 != 0)[console.Print("\x01", pos + 3, 0xF0),],
                    If(owner[i + 1] != 0)[
                        c := Int(0xFF),
                        If(d & 2 != 0)[c(0xF0)],
                        console.Print("\x02", pos + (6 + 640 * 3), c),
                    ],
                    If(owner[i + 15] != 0)[
                        c := Int(0xFF),
                        If(d & 4 != 0)[c(0xF0)],
                        console.Print("\x03", pos + (3 + 640 * 6), c),
                    ],
                    If(d & 8 != 0)[console.Print("\x04", pos + (640 * 3), 0xF0),],
                ],
                x(x + 1),
            ],
            y(y + 1),
        ],
        Do()[
            LED(
                hex3=0b0111011,
                hex2=0b0001111,
                hex1=0b0000111,
                hex0=0b0000000,
            ),
            asset := Int(playTurn(1, In("KEY") & 0b10000, 0x00FF0088, 0b010)),
            If(asset < 0)[
                audio_state(LOSE),
                console.Print("   GAME OVER: You Go Broke"),
                bonus := Int(0x62),
                Break(),
            ],
            If(asset >= goal)[
                audio_state(WIN),
                console.Print("    GAME OVER:  You Win!!"),
                bonus(0x22),
                Break(),
            ],
            LED(
                hex3=0b1111110,
                hex2=0b0100101,
                hex1=0b0100101,
                hex0=0b0111011,
            ),
            asset := Int(playTurn(0, In("KEY") & 0b100000, 0xFF000087, 0b100)),
            If(asset < 0)[
                audio_state(LOSE),
                console.Print(" GAME OVER: Alice Goes Broke"),
                bonus(0x62),
                Break(),
            ],
            If(asset >= goal)[
                audio_state(WIN),
                console.Print("   GAME OVER:  Alice Win!!"),
                bonus(0x22),
                Break(),
            ],
            LED(
                hex3=0b1111111,
                hex2=0b0001111,
                hex1=0b0101111,
                hex0=0b0000000,
            ),
            asset := Int(playTurn(2, In("KEY") & 0b1000000, 0x0000FF89, 0b001)),
            If(asset < 0)[
                audio_state(LOSE),
                console.Print("  GAME OVER: Bob Goes Broke"),
                bonus(0x62),
                Break(),
            ],
            If(asset >= goal)[
                audio_state(WIN),
                console.Print("    GAME OVER:  Bob Win!!"),
                bonus(0x22),
                Break(),
            ],
        ],
        dispStatus(),
        dispMap(bonus),
    ]
