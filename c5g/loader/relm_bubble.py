import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import font8x8, ConsoleSRAM, ConsoleArray
from relm_usb import USB
import numpy as np
from relm_bubble_map1 import (
    map_owner,
    map_dir,
    map_pawn,
    map_money,
    map_goal,
    map_price,
    map_bonus,
)

loader = "loader/output_files/relm_c5g.svf" if __name__ == "__main__" else False


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
        audio.i2c(8, sr_table[96000]),  # SAMPLING RATE: SR=xxxx, BOSR=1 (96kHz)
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
                Acc("VRAM"),
                vaddr := Array(
                    *(
                        sum(
                            [
                                [(67 << 19) + i * 256, (91 << 19) + i * 256 + 68]
                                for i in range(40)
                            ],
                            start=[],
                        )
                    ),
                    (159 << 19) + (1 << 18) + 188,
                    *([(159 << 19) + (1 << 18) + 256] * (439 - 80)),
                ),
                Acc("HDMI"),
                vram := Array(*([0] * (80 * 80))),
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
    scrollX = Int()
    scrollY = Int()
    MAPW = 23
    MAPH = 23
    Define[
        scroll := Function()[
            If(scrollX < 0)[scrollX(0)].Else[
                If(scrollX > 256 - 160)[scrollX(256 - 160)],
            ],
            If(scrollY < 0)[scrollY(0)].Else[
                If(scrollY > 1024 - 400)[scrollY(1024 - 400)],
            ],
            vsync(0),
            Do()[...].While(vsync == 0),
            addr := Int(),
            vaddr[1](addr((scrollY << 8) + scrollX + ((91 << 19) + 68))),
            *([vaddr[1 + i * 2](addr + i * 256) for i in range(1, 40)]),
        ],
        focus := Function(index := Int())[
            y := Int(),
            goalX := Int((index - y(index // MAPW) * MAPW) * 12 - 83),
            If(goalX < 0)[goalX(0)].Else[If(goalX > 256 - 160)[goalX(256 - 160)],],
            goalY := Int(y * 48 - 208),
            If(goalY < 0)[goalY(0)].Else[If(goalY > 1024 - 400)[goalY(1024 - 400)],],
            Do()[
                If(scrollX < goalX - 2)[scrollX(scrollX + 2)].Else[
                    If(scrollX > goalX + 2)[scrollX(scrollX - 2)].Else[scrollX(goalX)],
                ],
                If(scrollY < goalY - 8)[scrollY(scrollY + 8)].Else[
                    If(scrollY > goalY + 8)[scrollY(scrollY - 8)].Else[scrollY(goalY)],
                ],
                scroll(),
            ].While((scrollX != goalX) | (scrollY != goalY)),
        ],
    ]
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
    Thread[
        audio_state := Int(NO_SOUND := Label()),
        Do()[
            If(audio_ready == 0)[Continue(),],
            Code("JUMP", audio_state.put()),
            CAST_DICE := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/cast_dice.npy"),
            Continue(),
            BONUS := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/bonus.npy"),
            Continue(),
            WALK := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/walk.npy"),
            Continue(),
            BUY := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/buy.npy"),
            Continue(),
            PURCHASE := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/purchase.npy"),
            Continue(),
            CRISIS := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/crisis.npy"),
            Continue(),
            SELL := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/sell.npy"),
            Continue(),
            WIN := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/win.npy"),
            Continue(),
            LOSE := Label(),
            audio_state(NO_SOUND),
            Play(audio_shift, fifo_audio, "c5g/loader/lose.npy"),
            Continue(),
            NO_SOUND,
        ],
    ]
    V1 = 256 * 1
    V2 = 256 * 2
    V4 = 256 * 4
    V6 = 256 * 6
    V8 = 256 * 8
    H6 = 2 * 6
    Thread[console := ConsoleSRAM(V1, FIFO.Alloc(), FIFO.Alloc()),]
    Thread[consoleStatus := ConsoleArray(vram, 80, FIFO.Alloc(), FIFO.Alloc()),]
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
        clear := Function()[
            i := Int(80 * 80),
            Do()[vram[i(i - 1)](0),].While(i != 0),
            vsync(0),
            Do()[...].While(vsync == 0),
            console.Clear(),
        ],
        nrand := Function(n := UInt(), random := UInt())[
            RegB(random + 1, 2),
            AccU * RegB,
            r := UInt(random((AccU + 3) * RegB)),
            x := UInt((r >> 16) * n + (((r & 0xFFFF) * n) >> 16)),
        ].Return(x >> 16),
        pos := V8 + 30 * 2 + 0x80000000,
        dispDice := Table(7),
        dispDice.Default(),
        confirm := Array(
            0xC0000084,
            pos,
            0x202020,
            pos + V8,
            0x203F20,
            pos + V8 * 2,
            0x202020,
        ),
        dispDice.Return(),
        dispDice.Case(1),
        Array(
            0xC000003F,
            pos,
            0x202020,
            pos + V8,
            0x200B20,
            pos + V8 * 2,
            0x202020,
        ),
        dispDice.Return(),
        dispDice.Case(2),
        Array(
            0xC000000F,
            pos,
            0x20200B,
            pos + V8,
            0x202020,
            pos + V8 * 2,
            0x0B2020,
        ),
        dispDice.Return(),
        dispDice.Case(3),
        Array(
            0xC000000F,
            pos,
            0x0B2020,
            pos + V8,
            0x200B20,
            pos + V8 * 2,
            0x20200B,
        ),
        dispDice.Return(),
        dispDice.Case(4),
        Array(
            0xC000000F,
            pos,
            0x0B200B,
            pos + V8,
            0x202020,
            pos + V8 * 2,
            0x0B200B,
        ),
        dispDice.Return(),
        dispDice.Case(5),
        Array(
            0xC000000F,
            pos,
            0x0B200B,
            pos + V8,
            0x200B20,
            pos + V8 * 2,
            0x0B200B,
        ),
        dispDice.Return(),
        dispDice.Case(6),
        Array(
            0xC000000F,
            pos,
            0x0B200B,
            pos + V8,
            0x0B200B,
            pos + V8 * 2,
            0x0B200B,
        ),
        dispDice.Return(),
    ]
    Define[
        owner := Array(*map_owner),
        dir := Array(*map_dir),
        pawn := Array(*map_pawn),
        money := Array(*map_money),
        goal := map_goal,
        price := Array(*([0] * (MAPW * MAPH))),
        total := Array(*([0] * (MAPW * MAPH))),
        total2 := Array(*([0] * (MAPW * MAPH))),
        distance := Array(*([0] * (MAPW * MAPH))),
        initMap := Function()[
            consoleStatus.Print(
                "                                                                                ",
                640 * 0,
                0xFE,
            ),
            consoleStatus.Print(
                "                                                                                ",
                640 * 1,
            ),
            consoleStatus.Print(
                "         RealEstate + Money = TotalAssets (Goal: %d)" % goal,
                640 * 0 + 320,
            ),
            consoleStatus.Print(
                " You   ",
                640 * 2 + 320,
                0x84,
            ),
            consoleStatus.Print(
                " Alice ",
                640 * 5,
                0x73,
            ),
            consoleStatus.Print(
                " Bob   ",
                640 * 7 + 320,
                0x95,
            ),
            y := Int(0),
            Do()[
                cy := Int(y * (6 * V8) + (V8 + 2)),
                x := Int(0),
                Do()[
                    i := Int(),
                    o := Int(),
                    If(o(owner[i(y * MAPW + x + (MAPW + 1))]) != 0)[
                        pos := Int(cy + x * H6),
                        If(o == 1)[
                            price[i](map_price),
                            total[i](map_price),
                        ].Else[
                            price[i](map_bonus),
                        ],
                        d := Int(),
                        If((d(dir[i]) & 1 != 0) & (dir[i - MAPW] & 4 == 0))[
                            console.Print("\x01", pos + 3 * 2, 0xF0),
                        ],
                        If((owner[i + 1] != 0) & (dir[i + 1] & 8 == 0))[
                            If(d & 2 != 0)[c := Int(0xF0)].Else[c(0xFF)],
                            console.Print("\x02", pos + (6 * 2 + V8 * 3), c),
                        ],
                        If((owner[i + MAPW] != 0) & (dir[i + MAPW] & 1 == 0))[
                            If(d & 4 != 0)[c := Int(0xF0)].Else[c(0xFF)],
                            console.Print("\x03", pos + (3 * 2 + V8 * 6), c),
                        ],
                        If((d & 8 != 0) & (dir[i - 1] & 2 == 0))[
                            console.Print("\x04", pos + (V8 * 3), 0xF0),
                        ],
                    ],
                ].While(x(x + 1) < MAPW - 2),
            ].While(y(y + 1) < MAPH - 2),
        ],
        dispMap := Function(bonus := Int())[
            y := Int(0),
            Do()[
                cy := Int(y * (6 * V8) + (V8 + 2)),
                x := Int(0),
                Do()[
                    i := Int(),
                    o := Int(),
                    If(o(owner[i(y * MAPW + x + (MAPW + 1))]) != 0)[
                        pos := Int(cy + x * H6 + (2 + V8)),
                        rgb := Int(),
                        console.Print("", color=0x90 + o),
                        If(rgb(pawn[i]) & 1 != 0)[
                            console.Print(" \x05\x06  ", pos),
                            console.Print(" \x07\x08  ", pos + V8),
                            console.Print(" \x09\x0a  ", pos + V8 * 2),
                        ].Else[
                            console.Print("     ", pos),
                            console.Print("     ", pos + V8),
                            console.Print("     ", pos + V8 * 2),
                        ],
                        console.Print("", color=0x80 + o),
                        If(rgb & 2 != 0)[
                            console.Print("\x05\x06", pos + 4),
                            console.Print("\x07\x08", pos + (4 + V8)),
                            console.Print("\x09\x0a", pos + (4 + V8 * 2)),
                        ],
                        console.Print("", color=0x70 + o),
                        If(rgb & 4 != 0)[
                            console.Print("\x05\x06", pos + 6),
                            console.Print("\x07\x08", pos + (6 + V8)),
                            console.Print("\x09\x0a", pos + (6 + V8 * 2)),
                        ],
                        p := Int(),
                        If(p(price[i]) != 0)[
                            If(o == 2)[
                                console.Print("BONUS", pos + V8 * 3, bonus),
                                If(bonus == 0x22)[console.Print("", color=0x02)],
                            ].Else[
                                If(o == 0xF)[c := Int(0x0F)].Else[c(0xF0 + o)],
                                console.Print("", pos + V8 * 3, c).Dec(
                                    total[i], "    d"
                                ),
                            ],
                            console.Print("", pos + V8 * 4).Dec(p, "    d"),
                        ],
                        If(distance[i] & 1 != 0)[
                            console.fifo_print.Push(confirm[0]),
                            console.Print("?", pos),
                        ],
                    ],
                ].While(x(x + 1) < MAPW - 2),
            ].While(y(y + 1) < MAPH - 2),
        ],
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
        group := Array(*([0] * (MAPW * MAPH))),
        estate := Array(*([0] * 3)),
        eval := Array(*([0] * (MAPW * MAPH))),
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
            While(i < ec)[consoleStatus.Print(" "), i(i + 1)],
            While(i < mc)[consoleStatus.Print("$"), i(i + 1)],
            consoleStatus.Print("", color=0x00),
            While(i < 80)[consoleStatus.Print(" "), i(i + 1)],
        ],
        fillMessage := Function(color := Int())[
            console.Print("                             ", V8 * 0, color),
            console.Print("                             ", V8 * 1),
            console.Print("                             ", V8 * 2),
            console.Print("                             ", V8 * 3),
            console.Print("                             ", V8 * 4),
        ],
        dispMoney := Function(value := Int(), pos := Int())[
            If(value < 0)[consoleStatus.Print("", pos, 0xF3)].Else[
                consoleStatus.Print(" ", pos, 0xF0)
            ],
            consoleStatus.Dec(value, "-     d"),
        ],
        dispStatus := Function()[
            dispMoney(estate[1], 640 * 2 + 320 + 9),
            dispMoney(money[1], 640 * 2 + 320 + 20),
            dispMoney(estate[1] + money[1], 640 * 2 + 320 + 31),
            consoleStatus.Print("", 640 * 3 + 320, 0x84),
            dispBar(1),
            dispMoney(estate[0], 640 * 5 + 9),
            dispMoney(money[0], 640 * 5 + 20),
            dispMoney(estate[0] + money[0], 640 * 5 + 31),
            consoleStatus.Print("", 640 * 6, 0x73),
            dispBar(0),
            dispMoney(estate[2], 640 * 7 + 320 + 9),
            dispMoney(money[2], 640 * 7 + 320 + 20),
            dispMoney(estate[2] + money[2], 640 * 7 + 320 + 31),
            consoleStatus.Print("", 640 * 8 + 320, 0x95),
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
            i := Int(MAPW + 1),
            Do()[distance[i](0),].While(i(i + 1) < MAPW * (MAPH - 1) - 1),
            blink(color),
            own := Int((color & 0xF) - 4),
            confirm[0](own * 0x11 + 0xC0000040),
            dispMap(bonus),
            i := Int(MAPW),
            Do()[...].While(pawn[i(i + 1)] & pawn_bit == 0),
            pawn_i := Int(i),
            focus(pawn_i),
            Do()[...].While(audio_ready == 0),
            fillMessage((color & 0xF) * 16 + 0x0E),
            If(human != 0)[
                console.Print("Cursor keys:  Explore map", V8 * 1 + 2 * 2),
                console.Print("Enter key:  Roll the dice", V8 * 3 + 2 * 2),
                timer := Timer(),
                dice := Int(1),
                keyboard.Clear(),
                Do()[
                    If(timer.IsTimeout())[
                        dispDice.Switch(dice, console.fifo_print.port),
                        If(dice == 6)[dice(1)].Else[dice(dice + 1)],
                        timer.After(ms=250),
                    ],
                    If(keyboard.IsEmpty())[
                        k := Int(0),
                        Continue(),
                    ],
                    If(k(keyboard.Pop()) == UP)[scrollY(scrollY - 8 * 6), scroll()],
                    If(k == DOWN)[scrollY(scrollY + 8 * 6), scroll()],
                    If(k == LEFT)[scrollX(scrollX - 2 * 6), scroll()],
                    If(k == RIGHT)[scrollX(scrollX + 2 * 6), scroll()],
                ].While(k != ENTER),
            ].Else[
                If(index == 0)[
                    console.Print("Auto play:  Alice's turn", V8 * 2 + 3 * 2),
                ].Else[
                    If(index == 1)[
                        console.Print("Auto play:   Your turn", V8 * 2 + 3 * 2),
                    ].Else[
                        console.Print("Auto play:   Bob's turn", V8 * 2 + 3 * 2),
                    ],
                ],
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
            distance[pawn_i](1 << dice),
            flag := Int(),
            Do()[
                flag(0),
                i := Int(MAPW + 1),
                Do()[
                    dist_i := Int(),
                    If(dist_i(distance[i] >> 1) != 0)[
                        dir_i := Int(),
                        If(dir_i(dir[i]) & 1 == 0)[
                            j := Int(),
                            If(owner[j(i - MAPW)] != 0)[
                                dist_j := Int(distance[j]),
                                dist_ij := Int(),
                                If(dist_ij(dist_j | dist_i) != dist_j)[
                                    distance[j](dist_ij),
                                    flag(1),
                                ],
                            ],
                        ],
                        If(dir_i & 2 == 0)[
                            j := Int(),
                            If(owner[j(i + 1)] != 0)[
                                dist_j := Int(distance[j]),
                                dist_ij := Int(),
                                If(dist_ij(dist_j | dist_i) != dist_j)[
                                    distance[j](dist_ij),
                                    flag(1),
                                ],
                            ],
                        ],
                        If(dir_i & 4 == 0)[
                            j := Int(),
                            If(owner[j(i + MAPW)] != 0)[
                                dist_j := Int(distance[j]),
                                dist_ij := Int(),
                                If(dist_ij(dist_j | dist_i) != dist_j)[
                                    distance[j](dist_ij),
                                    flag(1),
                                ],
                            ],
                        ],
                        If(dir_i & 8 == 0)[
                            j := Int(),
                            If(owner[j(i - 1)] != 0)[
                                dist_j := Int(distance[j]),
                                dist_ij := Int(),
                                If(dist_ij(dist_j | dist_i) != dist_j)[
                                    distance[j](dist_ij),
                                    flag(1),
                                ],
                            ],
                        ],
                    ],
                    i(i + 1),
                ].While(i < MAPW * (MAPH - 1) - 1),
            ].While(flag != 0),
            dispMap(bonus),
            If(human != 0)[
                Do()[
                    fillMessage(0xFE),
                    If(distance[pawn_i] & 1 == 0)[
                        console.Print("Cursor keys:", V8 * 0 + V2 + 1 * 2),
                        console.Print("Step ahead or back", V8 * 1 + V2 + 10 * 2),
                        console.Print("Enter key:", V8 * 2 + V6 + 1 * 2),
                        console.Print("Fix your position", V8 * 3 + V6 + 10 * 2),
                    ].Else[
                        o := Int(owner[pawn_i]),
                        If(o == 1)[
                            If(price[pawn_i] <= money[index])[
                                console.Print(
                                    "Buy the vacant lot.", V8 * 0 + V4 + 1 * 2
                                ),
                                console.Print(
                                    "The price of the lot will", V8 * 2 + V4 + 1 * 2
                                ),
                                console.Print("increase by 50%.", V8 * 3 + V4 + 1 * 2),
                            ].Else[
                                console.Print("Nothing occurs.", V8 * 0 + V4 + 1 * 2),
                                console.Print(
                                    "Unable to buy the vacant", V8 * 2 + V4 + 1 * 2
                                ),
                                console.Print(
                                    "lot due to lack of money.", V8 * 3 + V4 + 1 * 2
                                ),
                            ],
                        ].Else[
                            If(o == 2)[
                                If(bonus == 0x62)[
                                    console.Print(
                                        "Get the bonus for the", V8 * 1 + 1 * 2
                                    ),
                                    console.Print(
                                        "player with the smallest", V8 * 2 + 1 * 2
                                    ),
                                    console.Print("assets.", V8 * 3 + 1 * 2),
                                ].Else[
                                    console.Print(
                                        "Nothing occurs.", V8 * 0 + V4 + 1 * 2
                                    ),
                                    console.Print(
                                        "Unable to get the bonus for",
                                        V8 * 1 + V4 + 1 * 2,
                                    ),
                                    console.Print(
                                        "the player with the",
                                        V8 * 2 + V4 + 1 * 2,
                                    ),
                                    console.Print(
                                        "smallest assets.", V8 * 3 + V4 + 1 * 2
                                    ),
                                ],
                            ].Else[
                                If(o == own)[
                                    console.Print("Nothing occurs.", V8 * 1 + 1 * 2),
                                    console.Print(
                                        "It's your own land.", V8 * 3 + 1 * 2
                                    ),
                                ].Else[
                                    If(total[pawn_i] <= money[index])[
                                        console.Print(
                                            "Buy all adjoining lots of",
                                            V8 * 0 + 1 * 2,
                                        ),
                                        console.Print(
                                            "the same player.",
                                            V8 * 1 + 1 * 2,
                                        ),
                                        console.Print(
                                            "The above value in the cell",
                                            V8 * 2 + 1 * 2,
                                        ),
                                        console.Print(
                                            "is total price of the",
                                            V8 * 3 + 1 * 2,
                                        ),
                                        console.Print(
                                            "adjoining lots.",
                                            V8 * 4 + 1 * 2,
                                        ),
                                    ].Else[
                                        fillMessage((color & 0xF) * 16 + 0x0E),
                                        console.Print(
                                            "Buy all adjoining lots of",
                                            V8 * 0 + 1 * 2,
                                        ),
                                        console.Print(
                                            "the same player.",
                                            V8 * 1 + 1 * 2,
                                        ),
                                        console.Print(
                                            "Must sell some of your lots",
                                            V8 * 2 + 1 * 2,
                                        ),
                                        console.Print(
                                            "at 50% discount to redeem",
                                            V8 * 3 + 1 * 2,
                                        ),
                                        console.Print(
                                            "your debt.",
                                            V8 * 4 + 1 * 2,
                                        ),
                                    ]
                                ]
                            ],
                        ],
                    ],
                    k := Int(keyboard.Pop()),
                    If(k == UP)[pawn_j := Int(pawn_i - MAPW),].Else[
                        If(k == RIGHT)[pawn_j(pawn_i + 1),].Else[
                            If(k == DOWN)[pawn_j(pawn_i + MAPW),].Else[
                                If(k == LEFT)[pawn_j(pawn_i - 1),].Else[
                                    If((k == ENTER) & (distance[pawn_i] & 1 != 0))[
                                        Break()
                                    ],
                                    Continue(),
                                ],
                            ],
                        ],
                    ],
                    dist_j := Int(),
                    If(dist_j(distance[pawn_j]) == 0)[Continue()],
                    pawn[pawn_i](pawn[pawn_i] & (pawn_bit ^ 7)),
                    pawn[pawn_j](pawn[pawn_j] | pawn_bit),
                    audio_state(WALK),
                    dispMap(bonus),
                    If(dist_j & 1 != 0)[
                        dispDice.Switch(0, console.fifo_print.port),
                    ].Else[
                        dispDice.Switch(dice, console.fifo_print.port),
                    ],
                    focus(pawn_i(pawn_j)),
                ],
                dest := Int(pawn_i),
            ].Else[  # human == 0
                If(index == 0)[index0 := Int(1)].Else[index0(0)],
                If(index == 2)[index2 := Int(1)].Else[index2(2)],
                max_eval := Int(0x80000000),
                d := Int(MAPW + 1),
                Do()[
                    If(distance[d] & 1 != 0)[
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
                ].While(d < MAPW * (MAPH - 1) - 1),
                Do()[d := Int(nrand(MAPW * (MAPH - 2) + 2) + MAPW + 1),].While(
                    (eval[d] != max_eval) | (distance[d] & 1 == 0)
                ),
                dest(d),
                dice_pos[0](d),
                d := Int(d),
                i := Int(1),
                Do()[
                    di := Int(1 << i),
                    If((distance[d + MAPW] & di != 0) & (dir[d + MAPW] & 1 == 0))[
                        d(d + MAPW)
                    ].Else[
                        If((distance[d - 1] & di != 0) & (dir[d - 1] & 2 == 0))[
                            d(d - 1)
                        ].Else[
                            If(
                                (distance[d - MAPW] & di != 0)
                                & (dir[d - MAPW] & 4 == 0)
                            )[d(d - MAPW)].Else[d(d + 1)]
                        ]
                    ],
                    dice_pos[i](d),
                    i(i + 1),
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
                    focus(pawn_j),
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
                        ].While(i < MAPW * (MAPH - 1) - 1),
                        If(money[index] < 0)[
                            audio_state(CRISIS),
                            Do()[...].While(audio_ready != 0),
                            Do()[...].While(audio_ready == 0),
                        ],
                        While((money[index] < 0) & (estate[index] != 0))[
                            Do()[
                                i := Int(nrand(MAPW * (MAPH - 2) - 2) + MAPW + 1),
                            ].While(owner[i] != own),
                            focus(i),
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
                        Do()[If(owner[i] == 0xF)[owner[i](1)],].While(
                            i(i + 1) < MAPW * (MAPH - 1) - 1
                        ),
                    ],
                ],
            ],
            i := Int(MAPW + 1),
            Do()[
                If(owner[i] == own)[
                    group[i](i),
                    total[i](0),
                    total2[i](0),
                ],
                i(i + 1),
            ].While(i < MAPW * (MAPH - 1) - 1),
            flag := Int(),
            Do()[
                flag(0),
                i := Int(MAPW + 1),
                Do()[
                    If(owner[i] == own)[
                        g := Int(group[i]),
                        If(owner[i + MAPW] == own)[
                            gy := Int(group[i + MAPW]),
                            If(g < gy)[
                                g(gy),
                                group[i](gy),
                                flag(1),
                            ].Else[
                                If(g > gy)[
                                    group[i + MAPW](g),
                                    flag(1),
                                ],
                            ],
                        ].Else[gy(0)],
                        If(owner[i + 1] == own)[
                            gx := Int(group[i + 1]),
                            If(g < gx)[
                                group[i](gx),
                                If(gy != 0)[group[i + MAPW](gx)],
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
                ].While(i < MAPW * (MAPH - 1) - 1),
            ].While(flag != 0),
            i := Int(MAPW + 1),
            Do()[
                If(owner[i] == own)[
                    g := Int(group[i]),
                    p := Int(price[i]),
                    q := Int((p * 3 + 1) >> 1),
                    total[g](total[g] + p),
                    total2[g](total2[g] + q),
                ],
                i(i + 1),
            ].While(i < MAPW * (MAPH - 1) - 1),
            i := Int(MAPW + 1),
            Do()[
                If(owner[i] == own)[
                    g := Int(group[i]),
                    total[i](total[g]),
                    total2[i](total2[g]),
                ],
                i(i + 1),
            ].While(i < MAPW * (MAPH - 1) - 1),
            asset := Int(money[index] + estate[index]),
            If((asset < 0) | (asset >= goal))[
                fillMessage((color & 0xF) * 16 + 0x0E),
                console.Print("", V8 * 2 + 0 * 2),
            ],
        ].Return(
            asset
        ),
    ]
    Thread[
        LED(
            hex3=0b1111100,
            hex2=0b0100101,
            hex1=0b1111110,
            hex0=0b0111011,
        ),
        clear(),
        console.Print(
            "                                  ",
            0,
            0x6E,
        ),
        console.Print(
            "   Bubble Estate - Playable PoC   ",
            V8 * 1,
        ),
        console.Print(
            "                                  ",
            V8 * 2,
        ),
        console.Print(
            "     for the ReLM Architecture    ",
            V8 * 3,
        ),
        console.Print(
            "                                  ",
            V8 * 4,
        ),
        console.Print("Introduction:", V8 * 6, 0xF0),
        console.Print(
            "This game, running on a ring topology multiprocessor system built on an FPGA,",
            V8 * 8 + 3 * 2,
        ),
        console.Print(
            "is a playable demo application based on the ReLM architecture.",
            V8 * 9 + 3 * 2,
        ),
        console.Print(
            "It shows how the ReLM architecture makes parallel processing simple and",
            V8 * 11 + 3 * 2,
        ),
        console.Print(
            "building stand-alone applications easy, in need of no operating system.",
            V8 * 12 + 3 * 2,
        ),
        console.Print("Playable Demo:", V8 * 15),
        console.Print(
            "Bubble Estate is a simple Monopoly-like dice game.",
            V8 * 17 + 3 * 2,
        ),
        console.Print(
            "Just roll dice and choose the next cell to go, and only that.",
            V8 * 19 + 3 * 2,
        ),
        console.Print("Let's play the new technology!", V8 * 22 + 3 * 2),
        console.Print("Goal:", V8 * 25),
        console.Print(
            "You win when your total assets (real estate + money) reach %d." % goal,
            V8 * 27 + 3 * 2,
        ),
        console.Print(
            "However, when one of the players goes bankrupt, the game is over.",
            V8 * 29 + 3 * 2,
        ),
        console.Print("Move:", V8 * 32),
        console.Print(
            "Roll dice and move forward according to the number on the dice.",
            V8 * 34 + 3 * 2,
        ),
        console.Print('Roll dice by pressing "Enter",', V8 * 36 + 3 * 2),
        console.Print(
            "and then choose the next cell with the cursor keys.", V8 * 37 + 3 * 2
        ),
        console.Print("     ", V8 * 39 + 3 * 2, 0xF1),
        console.Print("     ", V8 * 40 + 3 * 2),
        console.Print("     ", V8 * 41 + 3 * 2),
        console.Print("  200", V8 * 41 + 3 * 2),
        console.Print("  200", V8 * 42 + 3 * 2),
        console.Print("     ", V8 * 39 + 9 * 2),
        console.Print("     ", V8 * 40 + 9 * 2),
        console.Print("     ", V8 * 41 + 9 * 2),
        console.Print("  200", V8 * 42 + 9 * 2),
        console.Print("  200", V8 * 43 + 9 * 2),
        console.Print("     ", V8 * 39 + 15 * 2),
        console.Print("     ", V8 * 40 + 15 * 2),
        console.Print("     ", V8 * 41 + 15 * 2),
        console.Print("  200", V8 * 42 + 15 * 2),
        console.Print("  200", V8 * 43 + 15 * 2),
        console.Print(" ", V8 * 41 + 14 * 2, 0xFF),
        console.Print("\x02", V8 * 41 + 8 * 2, 0xF0),
        console.Print(
            "\x02 between cells shows one-way traffic.",
            V8 * 40 + 21 * 2,
        ),
        console.Print(" ", V8 * 42 + 21 * 2, 0xFF),
        console.Print(" between cells shows two-way traffic.", color=0xF0),
        console.Print(
            "On reaching a cell, you will see an event description in the message window",
            V8 * 45 + 3 * 2,
        ),
        console.Print(
            "and have the event to occur.",
            V8 * 46 + 3 * 2,
        ),
        console.Print(
            'You can change your way to go until pressing "Enter" to fix your position.',
            V8 * 48 + 3 * 2,
        ),
        console.Print("Events:", V8 * 51),
        console.Print("Gray cells represent vacant lots of land.", V8 * 53 + 3 * 2),
        console.Print("     ", V8 * 55 + 3 * 2, 0xF1),
        console.Print("     ", V8 * 56 + 3 * 2),
        console.Print("     ", V8 * 57 + 3 * 2),
        console.Print("  200", V8 * 58 + 3 * 2),
        console.Print("  200", V8 * 59 + 3 * 2),
        console.Print(
            "The number in each cell shows the land price.", V8 * 58 + 9 * 2, 0xF0
        ),
        console.Print(
            "Once you stay in a gray cell, you are to automatically buy that lot as long",
            V8 * 61 + 3 * 2,
        ),
        console.Print(
            "as you have enough money.",
            V8 * 62 + 3 * 2,
        ),
        console.Print(
            "If you are short of money, you will not be forced to buy.",
            V8 * 64 + 3 * 2,
        ),
        console.Print(
            "Cells in other colors than yellow represent owned lots.",
            V8 * 67 + 3 * 2,
        ),
        console.Print("     ", V8 * 69 + 3 * 2, 0xF3),
        console.Print("     ", V8 * 70 + 3 * 2),
        console.Print("     ", V8 * 71 + 3 * 2),
        console.Print("  750", V8 * 72 + 3 * 2),
        console.Print("  300", V8 * 73 + 3 * 2),
        console.Print("     ", V8 * 69 + 9 * 2),
        console.Print("     ", V8 * 70 + 9 * 2),
        console.Print("     ", V8 * 71 + 9 * 2),
        console.Print("  750", V8 * 72 + 9 * 2),
        console.Print("  450", V8 * 73 + 9 * 2),
        console.Print("\x02", V8 * 71 + 8 * 2, 0xF0),
        console.Print(
            "The upper value is the total price of adjoining lots,",
            V8 * 72 + 15 * 2,
        ),
        console.Print(
            "and the lower value is the price of each lot.", V8 * 73 + 15 * 2
        ),
        console.Print(
            "When you stay in an owned lot except yours, you are to buy all adjoining",
            V8 * 75 + 3 * 2,
        ),
        console.Print(
            "lots of the same owner in disregard to the amount of your money.",
            V8 * 76 + 3 * 2,
        ),
        console.Print(
            "Once you buy a lot, the land price increases by 50%, bringing the same",
            V8 * 78 + 3 * 2,
        ),
        console.Print("increase in your total assets.", V8 * 79 + 3 * 2),
        console.Print(
            "However, if you get short of money due to forced purchase, your lots are to",
            V8 * 81 + 3 * 2,
        ),
        console.Print(
            "be randomly sold at 50% discount to redeem your debt.",
            V8 * 82 + 3 * 2,
        ),
        console.Print(
            "The player with the smallest assets is to get a bonus on getting into a",
            V8 * 85 + 3 * 2,
        ),
        console.Print("yellow cell.", V8 * 86 + 3 * 2),
        console.Print("     ", V8 * 88 + 3 * 2, 0x62),
        console.Print("     ", V8 * 89 + 3 * 2),
        console.Print("     ", V8 * 90 + 3 * 2),
        console.Print("BONUS", V8 * 91 + 3 * 2),
        console.Print("  100", V8 * 92 + 3 * 2),
        console.Print('The "', V8 * 91 + 9 * 2, 0xF0),
        console.Print("BONUS", color=0x62),
        console.Print(
            '" message will disappear and nothing will happen unless you',
            color=0xF0,
        ),
        console.Print("are the owner of the smallest assets.", V8 * 92 + 9 * 2),
        console.Print(
            "Once you get a bonus, you will have next bonus to increase by 50%.",
            V8 * 94 + 3 * 2,
        ),
        console.Print("Tip:", V8 * 97),
        console.Print(
            "A tip to reverse the game is not to make the top player richer.",
            V8 * 99 + 3 * 2,
        ),
        console.Print(
            "When you are to buy lots, try to buy from the other player than the top one.",
            V8 * 101 + 3 * 2,
        ),
        consoleStatus.Print(
            'Press "Up" or "Down" to scroll this instruction.', 640 * 1, 0x80
        ),
        consoleStatus.Print(
            'Press "Left" or "Right" to go back or forward a page.', 640 * 3
        ),
        consoleStatus.Print('Press "Enter" to start the game.', 640 * 5),
        vsync(0),
        Do()[...].While(vsync == 0),
        blink(0x00FF0088),
        Do()[
            k := Int(),
            If(k(keyboard.Pop()) == UP)[scrollY(scrollY - 8), scroll()],
            If(k == DOWN)[scrollY(scrollY + 8), scroll()],
            If(k == LEFT)[scrollY(scrollY - (51 - 6) * 8), scroll()],
            If(k == RIGHT)[scrollY(scrollY + (51 - 6) * 8), scroll()],
        ].While(k != ENTER),
        clear(),
        initMap(),
        nrand(0, In("TIMER")),
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
        Do()[
            k := Int(),
            If(k(keyboard.Pop()) == UP)[scrollY(scrollY - 8 * 6), scroll()],
            If(k == DOWN)[scrollY(scrollY + 8 * 6), scroll()],
            If(k == LEFT)[scrollX(scrollX - 2 * 6), scroll()],
            If(k == RIGHT)[scrollX(scrollX + 2 * 6), scroll()],
        ],
    ]
