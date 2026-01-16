import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_c5g import *
from relm_font import font8x8, ConsoleSRAM, ConsoleArray
from relm_usb import USB
from relm_serial import Serial
from relm_bubble_map import (
    map_owner,
    map_dir,
    map_pawn,
    map_money,
    map_goal,
    map_price,
    map_bonus,
)

loader = "loader/output_files/relm_c5g.svf" if __name__ == "__main__" else False

with ReLMLoader(__file__, loader=loader):
    Define[i2c := I2C(),]
    Thread[
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
            console.Clear(),
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
                    o := Int(owner[i(y * MAPW + x + (MAPW + 1))]),
                    If((o != 0) | (pawn[i] != 0))[
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
    ]
    Thread[Do()[serial := Serial(0, 0),],]
    Thread[
        LED(
            hex3=0b1101101,
            hex2=0b0011111,
            hex1=0b0010010,
            hex0=0b0101101,
        ),
        blink(0x00FF0088),
        console.Clear(),
        initMap(),
        dispStatus(),
        dispMap(0x62),
        i := Int(MAPW),
        Do()[...].While(pawn[i(i + 1)] & 2 == 0),
        pawn_i := Int(i),
        focus(pawn_i),
        Do()[
            Do()[
                fillMessage(0x8E),
                console.Print("[Explore Mode]", 0),
                console.Print("Cursor keys: Move the piece", V8 * 2 + 1 * 2),
                console.Print("Enter key: Next mode", V8 * 4 + 1 * 2),
                y := Int(pawn_i // MAPW),
                x := Int(pawn_i - y * MAPW),
                k := Int(keyboard.Pop()),
                If(k == UP)[
                    If(y != 1)[
                        pawn[pawn_i](8),
                        dispMap(0x62),
                        pawn[pawn_i](0),
                        pawn[pawn_i(pawn_i - MAPW)](7),
                    ]
                ],
                If(k == DOWN)[
                    If(y != MAPH - 2)[
                        pawn[pawn_i](8),
                        dispMap(0x62),
                        pawn[pawn_i](0),
                        pawn[pawn_i(pawn_i + MAPW)](7),
                    ]
                ],
                If(k == LEFT)[
                    If(x != 1)[
                        pawn[pawn_i](8),
                        dispMap(0x62),
                        pawn[pawn_i](0),
                        pawn[pawn_i(pawn_i - 1)](7),
                    ]
                ],
                If(k == RIGHT)[
                    If(x != MAPW - 2)[
                        pawn[pawn_i](8),
                        dispMap(0x62),
                        pawn[pawn_i](0),
                        pawn[pawn_i(pawn_i + 1)](7),
                    ]
                ],
                dispStatus(),
                dispMap(0x62),
                focus(pawn_i),
            ].While(k != ENTER),
            i := Int(pawn_i),
            If(owner[i] != 0)[
                Do()[
                    fillMessage(0x8E),
                    console.Print("[Direction Mode]", 0),
                    console.Print("Cursor keys: Toggle oneway", V8 * 2 + 1 * 2),
                    console.Print("Enter key: Next mode", V8 * 4 + 1 * 2),
                    y := Int(i // MAPW),
                    x := Int(i - y * MAPW),
                    k := Int(keyboard.Pop()),
                    If(k == UP)[
                        j := Int(i - MAPW),
                        If(owner[j] != 0)[
                            If(dir[i](dir[i] ^ 1) & 1 == 0)[dir[j](dir[j] ^ 4)]
                        ],
                    ],
                    If(k == RIGHT)[
                        j := Int(i + 1),
                        If(owner[j] != 0)[
                            If(dir[i](dir[i] ^ 2) & 2 == 0)[dir[j](dir[j] ^ 8)]
                        ],
                    ],
                    If(k == DOWN)[
                        j := Int(i + MAPW),
                        If(owner[j] != 0)[
                            If(dir[i](dir[i] ^ 4) & 4 == 0)[dir[j](dir[j] ^ 1)]
                        ],
                    ],
                    If(k == LEFT)[
                        j := Int(i - 1),
                        If(owner[j] != 0)[
                            If(dir[i](dir[i] ^ 8) & 8 == 0)[dir[j](dir[j] ^ 2)]
                        ],
                    ],
                    initMap(),
                    dispStatus(),
                    dispMap(0x62),
                    focus(i),
                ].While(k != ENTER),
            ],
            i := Int(i),
            flag := Int(0),
            Do()[
                fillMessage(0x8E),
                console.Print("[Estate Mode]", 0),
                console.Print("Up, Right: Add bonus, land", V8 * 1 + 1 * 2),
                console.Print("Left: Delete land", V8 * 2 + 1 * 2),
                console.Print("Down: Next Enter to exit", V8 * 3 + 1 * 2),
                console.Print("Enter key: Next mode", V8 * 4 + 1 * 2),
                y := Int(i // MAPW),
                x := Int(i - y * MAPW),
                k := Int(keyboard.Pop()),
                If(k == UP)[
                    owner[i](2),
                    total[i](0),
                    price[i](map_bonus),
                    flag(0),
                ],
                If(k == RIGHT)[
                    owner[i](1),
                    total[i](map_price),
                    price[i](map_price),
                    flag(0),
                ],
                If(k == LEFT)[
                    owner[i](0),
                    total[i](0),
                    price[i](0),
                    flag(0),
                    dir[i](0),
                    dir[i - MAPW](dir[i - MAPW] & ~4),
                    dir[i + 1](dir[i + 1] & ~8),
                    dir[i + MAPW](dir[i + MAPW] & ~1),
                    dir[i - 1](dir[i - 1] & ~2),
                ],
                If(k == DOWN)[If(owner[i] != 0)[flag(1),],],
                initMap(),
                dispStatus(),
                dispMap(0x62),
                focus(i),
            ].While(k != ENTER),
        ].While(flag == 0),
        serial.Handshake(),
        serial.Println("map_owner = ( []"),
        y := Int(0),
        Do()[
            serial.Print("+["),
            x := Int(0),
            Do()[serial.Dec(owner[y * MAPW + x]).Print(", "),].While(
                x(x + 1) != MAPW - 1
            ),
            serial.Dec(owner[y * MAPW + (MAPW - 1)]).Println("]"),
        ].While(y(y + 1) != MAPH),
        serial.Println(")"),
        serial.Println("A = 10"),
        serial.Println("B = 11"),
        serial.Println("C = 12"),
        serial.Println("D = 13"),
        serial.Println("E = 14"),
        serial.Println("F = 15"),
        serial.Println("map_dir = ( []"),
        y := Int(0),
        Do()[
            serial.Print("+["),
            x := Int(0),
            Do()[serial.Hex(dir[y * MAPW + x]).Print(", "),].While(
                x(x + 1) != MAPW - 1
            ),
            serial.Hex(owner[y * MAPW + (MAPW - 1)]).Println("]"),
        ].While(y(y + 1) != MAPH),
        serial.Println(")"),
        serial.Println("map_pawn = ( []"),
        y := Int(0),
        Do()[
            serial.Print("+["),
            x := Int(0),
            Do()[serial.Dec(pawn[y * MAPW + x]).Print(", "),].While(
                x(x + 1) != MAPW - 1
            ),
            serial.Dec(pawn[y * MAPW + (MAPW - 1)]).Println("]"),
        ].While(y(y + 1) != MAPH),
        serial.Println(")"),
        serial.Print("map_money = [")
        .Dec(money[0])
        .Print(", ")
        .Dec(money[1])
        .Print(", ")
        .Dec(money[2])
        .Println("]"),
        serial.Print("map_goal = ").Dec(goal).Println(""),
        serial.Print("map_price = ").Dec(map_price).Println(""),
        serial.Print("map_bonus = ").Dec(map_bonus).Println(""),
        serial.Print("\xaa"),
    ]

serial.dump("relm_bubble_map.py")
