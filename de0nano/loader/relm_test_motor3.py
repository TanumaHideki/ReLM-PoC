import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

with ReLMLoader(loader="loader/output_files/relm_de0nano.svf"):
    Thread[
        pwm_speed := 200,
        pwm_count := Int(),
        pwm_motor := Int(),
        Do()[
            If(pwm_count((pwm_count + 1) & 0xFF) == pwm_speed)[IO("MOTOR", 0)].Else[
                If(pwm_count == 0)[IO("MOTOR", pwm_motor)]
            ],
        ],
    ]
    Define[
        ir_scan := Function()[
            IR_ADC(1)[ir0 := Int(Acc)],
            IR_ADC(2)[ir1 := Int(Acc)],
            IR_ADC(3)[ir2 := Int(Acc)],
            IR_ADC(4)[ir3 := Int(Acc)],
            IR_ADC(5)[ir4 := Int(Acc)],
            IR_ADC(6)[ir5 := Int(Acc)],
            IR_ADC(0)[ir6 := Int(Acc)],
            sum := Int(ir0 + ir1 + ir2 + ir3 + ir4 + ir5 + ir6),
            If(ir0 * 7 < sum)[led0 := Int(0)].Else[led0(1)],
            If(ir1 * 7 < sum)[led1 := Int(led0)].Else[led1(led0 | 2)],
            If(ir2 * 7 < sum)[led2 := Int(led1)].Else[led2(led1 | 4)],
            If(ir3 * 7 < sum)[led3 := Int(led2)].Else[led3(led2 | 8)],
            If(ir4 * 7 < sum)[led4 := Int(led3)].Else[led4(led3 | 16)],
            If(ir5 * 7 < sum)[led5 := Int(led4)].Else[led5(led4 | 32)],
            If(ir6 * 7 < sum)[led6 := Int(led5)].Else[led6(led5 | 64)],
            Out("LED", led6),
            If(ir1 > ir0)[max1 := Int(ir1)].Else[max1(ir0)],
            If(ir2 > max1)[max2 := Int(ir2)].Else[max2(max1)],
            If(ir3 > max2)[max3 := Int(ir3)].Else[max3(max2)],
            If(ir4 > max3)[max4 := Int(ir4)].Else[max4(max3)],
            If(ir5 > max4)[max5 := Int(ir5)].Else[max5(max4)],
            If(ir6 > max5)[max6 := Int(ir6)].Else[max6(max5)],
            right := Int(ir2),
            center := Int(ir3),
            left := Int(ir4),
        ],
    ]
    Thread[
        Do()[
            timer := Timer(ms=500),
            Do()[
                ir_scan(),
                If(left > right)[pwm_motor(0b0010)].Else[pwm_motor(0b1000)],
            ].While(timer.IsWaiting()),
            Do()[
                ir_scan(),
                If((left > center) & (right > center))[Break()],
                If(left > right)[pwm_motor(0b0010)].Else[pwm_motor(0b1000)],
            ],
            pwm_motor(0b0110),
            Wait(ms=700),
            Do()[
                ir_scan(),
                If(max6 == center)[Break()],
                If((max6 == ir0) | (max6 == ir1) | (max6 == ir2))[
                    pwm_motor(0b1001)
                ].Else[pwm_motor(0b0110)],
            ],
            timer := Timer(ms=500),
            Do()[
                ir_scan(),
                If(left > right)[pwm_motor(0b0010)].Else[pwm_motor(0b1000)],
            ].While(timer.IsWaiting()),
            Do()[
                ir_scan(),
                If((left > center) & (right > center))[Break()],
                If(left > right)[pwm_motor(0b0010)].Else[pwm_motor(0b1000)],
            ],
            pwm_motor(0b1001),
            Wait(ms=700),
            Do()[
                ir_scan(),
                If(max6 == center)[Break()],
                If((max6 == ir0) | (max6 == ir1) | (max6 == ir2))[
                    pwm_motor(0b1001)
                ].Else[pwm_motor(0b0110)],
            ],
        ],
    ]
