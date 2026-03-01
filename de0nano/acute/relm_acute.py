import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from relm_de0nano import *

loader = "loader/output_files/relm_de0nano.svf" if __name__ == "__main__" else False

with ReLMLoader(__file__, loader=loader):
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
            If(ir1 < ir0)[min1 := Int(ir1), max1 := Int(ir0)].Else[
                min1(ir0), max1(ir1)
            ],
            If(ir2 < min1)[min2 := Int(ir2)].Else[min2(min1)],
            If(ir3 < min2)[min3 := Int(ir3)].Else[min3(min2)],
            If(ir4 < min3)[min4 := Int(ir4)].Else[min4(min3)],
            If(ir5 < min4)[min5 := Int(ir5)].Else[min5(min4)],
            If(ir6 < min5)[min6 := Int(ir6)].Else[min6(min5)],
            th := Int(),
            If(ir0 >= th((min6 + 0x100) >> 1))[led0 := Int(1)].Else[led0(0)],
            If(ir1 >= th)[led1 := Int(led0 | 2)].Else[led1(led0)],
            If(ir2 >= th)[led2 := Int(led1 | 4)].Else[led2(led1)],
            If(ir3 >= th)[led3 := Int(led2 | 8)].Else[led3(led2)],
            If(ir4 >= th)[led4 := Int(led3 | 16)].Else[led4(led3)],
            If(ir5 >= th)[led5 := Int(led4 | 32)].Else[led5(led4)],
            If(ir6 >= th)[led6 := Int(led5 | 64)].Else[led6(led5)],
            Out("LED", led6),
            If(ir2 > max1)[max2 := Int(ir2)].Else[max2(max1)],
            If(ir3 > max2)[max3 := Int(ir3)].Else[max3(max2)],
            If(ir4 > max3)[max4 := Int(ir4)].Else[max4(max3)],
            If(ir5 > max4)[max5 := Int(ir5)].Else[max5(max4)],
            If(ir6 > max5)[max6 := Int(ir6)].Else[max6(max5)],
        ],
        cruise := Function()[
            Do()[
                ir_scan(),
                If(max6 < th)[Break()],
                If(max6 == max1)[pwm_motor(0b1001)].Else[
                    If(max6 == max4)[
                        If(ir2 > ir4)[pwm_motor(0b1000)].Else[pwm_motor(0b0010)],
                    ].Else[pwm_motor(0b0110)]
                ],
            ],
        ],
        turn := Function()[Do()[ir_scan()].While(ir3 < th),],
    ]
    Thread[
        Do()[
            cruise(),
            pwm_motor(0b0110),
            turn(),
            cruise(),
            pwm_motor(0b1001),
            turn(),
        ],
    ]
