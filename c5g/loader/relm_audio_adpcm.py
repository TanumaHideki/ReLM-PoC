import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

import numpy as np
from pydub import AudioSegment
from tkinter.filedialog import askopenfilename
import tqdm

from relm_c5g import *


def compress(frames, la=6):
    history = np.array([[0] * la + [1, 0]], dtype=np.int32)
    output = []
    code = 0
    shift = 0
    for i, sample in tqdm.tqdm(enumerate(frames), total=len(frames)):
        if i >= la:
            m = int(np.argmin(history[:, -1])) & 3
            code |= m << shift
            shift += 2
            if shift == 32:
                output.append(code)
                code = 0
                shift = 0
            history = history[m::4, :]
            history[:, -1] -= np.abs(history[:, 0] - frames[i - la])
        pred = (
            history[:, la - 6]
            - history[:, la - 5] * 2
            + history[:, la - 4]
            - history[:, la - 2]
            + history[:, la - 1] * 2
        )
        history[:, : la - 1] = history[:, 1:la]
        history[:, la - 1] = pred
        history[:, la] = (np.abs(history[:, la]) + 1) >> 1
        h = history.copy()
        h[:, la] *= -1
        history = np.vstack([h, history])
        h = history.copy()
        h[:, la] *= 3
        history = np.vstack([history, h])
        history[:, la - 1] += history[:, la]
        history[:, -1] += np.abs(history[:, la - 1] - sample)
    return output


initialdir = Path(__file__).parent
filename = askopenfilename(
    initialdir=initialdir,
    filetypes=[
        (
            "Audio files",
            ["*.npy", "*.wav", "*.mp3", "*.ogg", "*.flv", "*.mp4", "*.wma"],
        ),
        ("ADPCM files", "*.npy"),
        ("All files", "*.*"),
    ],
)
if filename:
    print(filename)
    if filename[-4:] == ".npy":
        adpcm = [int(x) for x in np.load(filename)]
        if len(adpcm) > 90000:
            adpcm = adpcm[:90000]
    else:
        audio_data = AudioSegment.from_file(filename, format=filename[-3:])
        audio_data = audio_data.set_channels(1)  # Convert to mono if not already
        audio_data = audio_data.set_frame_rate(32000)  # Set to 32kHz
        samples = audio_data.get_array_of_samples()
        if len(samples) > 90000 * 16:
            samples = samples[: 90000 * 16]
        adpcm = compress(samples)
        np.save(filename + ".npy", np.array(adpcm, dtype=np.uint32))

    with ReLMLoader(loader="loader/output_files/relm_c5g.svf"):
        Define[
            i2c := I2C(),
            audio := Audio(i2c),
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
            audio.i2c(8, 0x1A),  # SAMPLING RATE: SR=0110, BOSR=1 (32kHz)
            audio.i2c(16, 0x1FB),  # ALC CONTROL 1: ALCSEL=11
            audio.i2c(17, 0x32),  # ALC CONTROL 2
            audio.i2c(18, 0x00),  # NOISE GATE
            audio.i2c(9, 0x01),  # ACTIVE: Active=1
            LED(
                hex3=0b1111110,  # A
                hex2=0b0000111,  # u
                hex1=0b0011111,  # d
                hex0=0b0001111,  # o
            ),
            fifo1 := FIFO.Alloc(),
            reset := Int(),
            Do()[
                If(fifo1.IsEmpty())[
                    If(reset != 0)[
                        pred0 := Int(0),
                        pred1 := Int(0),
                        pred2 := Int(0),
                        pred3 := Int(0),
                        pred4 := Int(0),
                        pred5 := Int(0),
                        delta := Int(1),
                        reset(0),
                    ],
                    Continue(),
                ],
                code := Int(fifo1.Pop()),
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
            Do()[
                reset(1),
                Do()[...].While(reset != 0),
                Acc(fifo1.port),
                Array(*adpcm),
            ],
        ]
