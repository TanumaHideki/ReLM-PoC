import ctypes


def route_(tms1, tms0, *next0):
    r = (tms1 << 20) | (0x10 << tms0) | tms0
    for n in next0:
        r |= 0x10 << n
    return r


class JTAG:
    (
        RESET,
        IDLE,
        DRSELECT,
        DRCAPTURE,
        DRSHIFT,
        DREXIT1,
        DRPAUSE,
        DREXIT2,
        DRUPDATE,
        IRSELECT,
        IRCAPTURE,
        IRSHIFT,
        IREXIT1,
        IRPAUSE,
        IREXIT2,
        IRUPDATE,
    ) = range(16)
    route = (
        route_(RESET, IDLE) | 0xFFFE0,  # RESET
        route_(DRSELECT, IDLE),  # IDLE
        route_(
            IRSELECT, DRCAPTURE, DRSHIFT, DREXIT1, DRPAUSE, DREXIT2, DRUPDATE
        ),  # DRSELECT
        route_(DREXIT1, DRSHIFT),  # DRCAPTURE
        route_(DREXIT1, DRSHIFT),  # DRSHIFT
        route_(DRUPDATE, DRPAUSE, DREXIT2),  # DREXIT1
        route_(DREXIT2, DRPAUSE),  # DRPAUSE
        route_(DRUPDATE, DRSHIFT, DREXIT1, DRPAUSE),  # DREXIT2
        route_(DRSELECT, IDLE),  # DRUPDATE
        route_(
            RESET, IRCAPTURE, IRSHIFT, IREXIT1, IRPAUSE, IREXIT2, IRUPDATE
        ),  # IRSELECT
        route_(IREXIT1, IRSHIFT),  # IRCAPTURE
        route_(IREXIT1, IRSHIFT),  # IFSHIFT
        route_(IRUPDATE, IRPAUSE, IREXIT2),  # IREXIT1
        route_(IREXIT2, IRPAUSE),  # IRPAUSE
        route_(IRUPDATE, IRSHIFT, IREXIT1, IRPAUSE),  # IREXIT2
        route_(DRSELECT, IDLE),  # IRUPDATE
    )
    L = 0x2C
    H = 0x3C
    TMS = 0x2E
    TMS_H = 0x3E
    OFF = 0x0C
    WR = 0x80
    RD = 0xC0

    def __init__(self):
        self.memory = ctypes.create_string_buffer(64)
        self.pos = 0

    def write_bytes(self, data, length, mode=WR):
        if self.pos + length > 63:
            self.flush()
        self.memory[self.pos] = length | mode
        for i in range(1, length + 1):
            self.memory[self.pos + i] = data & 0xFF
            data >>= 8
        self.pos += length + 1
        if self.pos == 64:
            self.flush()

    def write(self, data):
        self.memory[self.pos] = data
        self.pos += 1
        if self.pos == 64:
            self.flush()
        self.memory[self.pos] = data | 1
        self.pos += 1
        if self.pos == 64:
            self.flush()

    def state(self, now, to):
        t = 0x10 << to
        while now != to:
            now = self.route[now]
            if now & t:
                now &= 0xF
                self.write(self.L)
            else:
                now >>= 20
                self.write(self.TMS)
        return to

    def reset(self, to=RESET):
        for _ in range(5):
            self.write(self.TMS)
        self.state(self.RESET, to)

    def shift_ir(self, ir):
        self.reset(self.IRSHIFT)
        self.write_bytes(ir, 1)
        self.write(self.L | (ir >> 4) & 16)
        self.write(self.TMS | (ir >> 5) & 16)
        self.state(self.IREXIT1, self.DRSHIFT)

    def write_int(self, data, length=3, mode=WR):
        self.write_bytes(data, length, mode)
        self.write(self.TMS_H)
        self.state(self.DREXIT1, self.DRSHIFT)


class USBBlaster(JTAG):
    def flush(self):
        if self.pos:
            self.dll.FT_Write(
                self.ftHandle, self.memory, self.pos, ctypes.byref(ctypes.c_int())
            )
            self.pos = 0

    def read_int(self, data, length=4):
        self.write_int(data, length, self.RD)
        self.flush()
        data = ctypes.c_int()
        self.dll.FT_Read(
            self.ftHandle, ctypes.byref(data), length, ctypes.byref(ctypes.c_int())
        )
        return data.value

    def __init__(self, dll="usbblstr32", index=0, format="IDCODE: {:X}"):
        super().__init__()
        self.dll = ctypes.cdll.LoadLibrary(dll)
        self.ftHandle = ctypes.c_void_p()
        idcode = 0
        count = 0
        while True:
            assert not self.dll.FT_Open(
                index, ctypes.byref(self.ftHandle)
            ), "USB Blaster connection failed"
            self.shift_ir(0x6)
            i = self.read_int(0)
            if idcode == i:
                count += 1
                if count == 3:
                    break
            else:
                idcode = i
                count = 0
                self.dll.FT_ResetDevice(self.ftHandle)
            self.dll.FT_Close(self.ftHandle)
        if format:
            print(format.format(idcode))

    def close(self):
        self.reset()
        self.write(self.OFF)
        self.flush()
        self.dll.FT_Close(self.ftHandle)

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    def run_test(self, tck):
        while tck > 504:
            self.flush()
            self.memory[0] = 0xBF
            self.dll.FT_Write(
                self.ftHandle, self.memory, 64, ctypes.byref(ctypes.c_int())
            )
            tck -= 504
        bytes = (tck - 1) >> 3
        if bytes:
            self.flush()
            self.memory[0] = 0x80 | bytes
            self.dll.FT_Write(
                self.ftHandle, self.memory, 1 + bytes, ctypes.byref(ctypes.c_int())
            )
            tck -= bytes << 3
        for _ in range(tck):
            self.write(self.L)
            self.write(self.L | 1)

    def shift_tdi(self, tdi, bits):
        bytes = (bits - 1) >> 3
        if bytes:
            self.flush()
            data = int(tdi[bytes * -2 :] + f"{0x80 + bytes:x}", 16).to_bytes(
                bytes + 1, "little"
            )
            tdi = tdi[: bytes * -2]
            memory = ctypes.create_string_buffer(data)
            self.dll.FT_Write(
                self.ftHandle, memory, bytes + 1, ctypes.byref(ctypes.c_int())
            )
            bits -= bytes << 3
        data = int(tdi + "0", 16)
        while bits > 1:
            bits -= 1
            self.write(data & 16 | self.L)
            data >>= 1
        self.write(data & 16 | self.TMS)

    def shift_tdi_list(self, tdi, bits):
        self.flush()
        bits_all = bits
        bits_bar = 0
        while bits > 504:
            p = tdi.pop()
            if len(p) < 126:
                q = tdi.pop().strip()
                tdi.append(q + p)
                continue
            data = int(p[-126:] + "BF", 16).to_bytes(64, "little")
            tdi.append(p[:-126])
            memory = ctypes.create_string_buffer(data)
            self.dll.FT_Write(self.ftHandle, memory, 64, ctypes.byref(ctypes.c_int()))
            bits -= 504
            if (bits_all - bits) * 50 > bits_all * bits_bar:
                print(".", end="", flush=True)
                bits_bar += 1
        self.shift_tdi("".join(t.strip() for t in tdi), bits)
        print()

    def playSVF(self, file):
        self.reset()
        current = self.RESET
        enddr = self.IDLE
        endir = self.IDLE
        runstate = self.IDLE
        endstate = self.IDLE
        stable = {
            "RESET": self.RESET,
            "IDLE": self.IDLE,
            "DRPAUSE": self.DRPAUSE,
            "IRPAUSE": self.IRPAUSE,
        }
        path = {
            "RESET": self.RESET,
            "IDLE": self.IDLE,
            "DRSELECT": self.DRSELECT,
            "DRCAPTURE": self.DRCAPTURE,
            "DRSHIFT": self.DRSHIFT,
            "DREXIT1": self.DREXIT1,
            "DRPAUSE": self.DRPAUSE,
            "DREXIT2": self.DREXIT2,
            "DRUPDATE": self.DRUPDATE,
            "IRSELECT": self.IRSELECT,
            "IRCAPTURE": self.IRCAPTURE,
            "IRSHIFT": self.IRSHIFT,
            "IREXIT1": self.IREXIT1,
            "IRPAUSE": self.IRPAUSE,
            "IREXIT2": self.IREXIT2,
            "IRUPDATE": self.IRUPDATE,
        }
        with open(file) as f:
            lines = f.readlines()
        while lines:
            line = lines.pop(0)
            if line.startswith("!"):
                continue
            split = line.split()
            if split[-1].endswith(";"):
                split[-1] = split[-1][:-1]
                match split[0]:
                    case "ENDDR":
                        enddr = stable[split[1]]
                    case "ENDIR":
                        endir = stable[split[1]]
                    case "RUNTEST":
                        if split[1] in stable.keys():
                            runstate = endstate = stable[split[1]]
                        current = self.state(current, runstate)
                        for i, s in enumerate(split[2:], 2):
                            match s:
                                case "TCK":
                                    self.run_test(int(split[i - 1]))
                                case "ENDSTATE":
                                    endstate = stable[split[i + 1]]
                        current = self.state(current, endstate)
                    case "SDR":
                        self.state(current, self.DRSHIFT)
                        self.shift_tdi(split[3][1:-1], int(split[1]))
                        current = self.state(self.DREXIT1, enddr)
                    case "SIR":
                        self.state(current, self.IRSHIFT)
                        self.shift_tdi(split[3][1:-1], int(split[1]))
                        current = self.state(self.IREXIT1, endir)
                    case "STATE":
                        for s in split[1:]:
                            current = self.state(current, path[s])
            else:
                lines.insert(0, split[3][1:])
                for i, line in enumerate(lines):
                    if ";" in line:
                        break
                tdi = lines[: i + 1]
                lines = lines[i + 1 :]
                for i, t in enumerate(tdi):
                    if ")" in t:
                        break
                tdi = tdi[: i + 1]
                tdi[i] = tdi[i].split(")", 2)[0].strip()
                self.state(current, self.DRSHIFT)
                self.shift_tdi_list(tdi, int(split[1]))
                current = self.state(self.DREXIT1, enddr)
