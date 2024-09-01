from relm import *
from altera import ReLM

LED, USB, VGA, I2C, CAMERA, SRAM, *FIFO = range(15)
KEY = LED


class C5G(ReLM):

    def wait_msecs(self, msecs):
        self.wait_clocks(msecs * 50000)

    def init_vga(self, pattern=0x1c1c1c1c):

        def i2c(*value, keep=True):
            if keep:
                with acc.keep():
                    i2c(*value, keep=False)
            else:
                for v in value:
                    io_(I2C, v)[:] = acc
                    with do_() as L:
                        L.until_(acc - 1 == 0)

        def init():
            fifo_(FIFO[0]).push(0x72980300)  # Must be set to 0x03 for proper operation
            fifo_(FIFO[0]).push(0x729ae000)  # Must be set to 0b1110000
            fifo_(FIFO[0]).push(0x729c3000)  # Must be set to 0x30 for proper operation
            fifo_(FIFO[0]).push(0x729d6100)  # Set clock divide
            fifo_(FIFO[0]).push(0x72a2a400)  # Must be set to 0xA4 for proper operation
            fifo_(FIFO[0]).push(0x72a3a400)  # Must be set to 0xA4 for proper operation
            fifo_(FIFO[0]).push(0x72e0d000)  # Must be set to 0xD0 for proper operation
            fifo_(FIFO[0]).push(0x72f90000)  # Must be set to 0x00 for proper operation
            fifo_(FIFO[0]).push(0x72550200)  # Scan PC in AVI infoframe
            acc[:] = 0x72411000  # Power down control
            with do_() as L:
                i2c(0x80000001, 1, 0)
                for _ in range(7):
                    i2c(0)
                    i2c(1)
                    i2c(0)
                    acc[:] = acc << 1
                i2c(0)
                i2c(1)
                i2c(0, 2, 3, 2)
                acc[:] = acc << 1
                for _ in range(7):
                    i2c(0)
                    i2c(1)
                    i2c(0)
                    acc[:] = acc << 1
                i2c(0)
                i2c(1)
                i2c(0, 2, 3, 2)
                acc[:] = acc << 1
                for _ in range(7):
                    i2c(0)
                    i2c(1)
                    i2c(0)
                    acc[:] = acc << 1
                i2c(0)
                i2c(1)
                i2c(0, 2, 3, 2, 0, 1, 0x80000001, keep=False)
                L.until_(fifo_(FIFO[0]).pop().isempty())
            yield

        self.run_(init())

        def fill(pattern):
            self.fill_(Code.IOR | VGA, pattern, 166 * 480)
            yield

        self.run_(fill(pattern))

        def vram_640x480():
            self.fork_()
            with do_() as L:
                for i in range(480):
                    ior_(VGA, 1)[:] = 96
                    ior_(VGA, 0)[:] = 48
                    if i == 0:
                        self.VRAM = ior_(VGA)
                        acc[:] = self.VRAM
                    elif i == 1:
                        self.VRAM_LINE = here_() - self.VRAM.addr
                    here_(here_() + 160)
                    ior_(VGA, 0)[:] = 16
                with for_(10):
                    ior_(VGA, 1)[:] = 96
                    ior_(VGA, 0)[:] = 704
                ior_(VGA, 3)[:] = 96
                ior_(VGA, 2)[:] = 704
                ior_(VGA, 3)[:] = 96
                ior_(VGA, 2)[:] = 704
                with for_(33):
                    ior_(VGA, 1)[:] = 96
                    ior_(VGA, 0)[:] = 704
                L.while_()
            yield

        self.send_(vram_640x480())

    def init_camera(self, CLKRC=0):

        def i2c(*value, keep=True):
            if keep:
                with acc.keep():
                    i2c(*value, keep=False)
            else:
                for v in value:
                    io_(I2C, v)[:] = acc
                    with do_() as L:
                        L.until_(acc - 1 == 0)

        def init(CLKRC=0):
            io_(CAMERA, 1)[:] = acc
            fifo_(FIFO[0]).push(0x60110000 | (CLKRC & 0xff) << 8)  # Clock pre-scalar
            fifo_(FIFO[0]).push(0x60120300)  # RGB format
            fifo_(FIFO[0]).push(0x6040D000)  # RGB 565
            fifo_(FIFO[0]).push(0x60414200)  # Enhance color
            fifo_(FIFO[0]).push(0x601E3000)  # Mirror & VFlip
            acc[:] = 0x60128000  # Reset
            with do_() as L:
                i2c(0x80000001, 1, 0)
                for _ in range(7):
                    i2c(0)
                    i2c(1)
                    i2c(0)
                    acc[:] = acc << 1
                i2c(0)
                i2c(1)
                i2c(0, 2, 3, 2)
                acc[:] = acc << 1
                for _ in range(7):
                    i2c(0)
                    i2c(1)
                    i2c(0)
                    acc[:] = acc << 1
                i2c(0)
                i2c(1)
                i2c(0, 2, 3, 2)
                acc[:] = acc << 1
                for _ in range(7):
                    i2c(0)
                    i2c(1)
                    i2c(0)
                    acc[:] = acc << 1
                i2c(0)
                i2c(1)
                i2c(0, 2, 3, 2, 0, 1, 0x80000001, keep=False)
                self.wait_msecs(300)
                L.until_(fifo_(FIFO[0]).pop().isempty())
            yield

        self.run_(init(CLKRC))


class hello(C5G):

    def main(self):
        io_(CAMERA, 0)[:] = acc
        io_(LED, 0b11111)[:] = 0
        io_(LED, 0b100000)[:] = 8
        self.wait_msecs(500)
        io_(LED, 0b100000)[:] = 0x76  # H
        io_(LED, 0b10000)[:] = 8
        self.wait_msecs(500)
        io_(LED, 0b10000)[:] = 0x79  # E
        io_(LED, 0b1000)[:] = 8
        self.wait_msecs(500)
        io_(LED, 0b1000)[:] = 0x38  # L
        io_(LED, 0b100)[:] = 8
        self.wait_msecs(500)
        io_(LED, 0b100)[:] = 0x3f  # O
        dot = 0b1000000000
        while True:
            io_(LED, 0b10)[:] = dot
            if not dot:
                break
            dot >>= 1
            self.wait_msecs(100)
        dot = 0b10000000
        while True:
            io_(LED, 0b1)[:] = dot
            if not dot:
                break
            dot >>= 1
            self.wait_msecs(100)
        yield

    def __init__(self):
        self.run_(self.main())


class timer(C5G):

    def count6(self, digit, tick):
        io_(LED, digit)[:] = 0x3f  # 0
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x06  # 1
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x5b  # 2
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x4f  # 3
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x66  # 4
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x6d  # 5
        yield from tick[0]
        tick[0] = None

    def count10(self, digit, tick):
        yield from self.count6(digit, tick)
        io_(LED, digit)[:] = 0x7d  # 6
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x27  # 7
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x7f  # 8
        yield from tick[0]
        tick[0] = None
        io_(LED, digit)[:] = 0x6f  # 9
        yield from tick[0]
        tick[0] = None

    def led_1min(self):
        self.fork_()
        with do_() as L:
            yield from self.count10(0b100000, self.tick_1min)
            L.while_()

    def led_10sec(self):
        self.fork_()
        with do_() as L:
            yield from self.count6(0b10000, self.tick_10sec)
            self.tick_1min[0] = acc
            L.while_()

    def led_1sec(self):
        self.fork_()
        with do_() as L:
            yield from self.count10(0b1000, self.tick_1sec)
            self.tick_10sec[0] = acc
            L.while_()

    def led_100ms(self):
        self.fork_()
        with do_() as L:
            yield from self.count10(0b100, self.tick_100ms)
            self.tick_1sec[0] = acc
            L.while_()

    def clk_100ms(self):
        self.fork_()
        io_(CAMERA, 0)[:] = acc
        with do_() as L1:
            acc[:] = 5000000 // self.ncpu
            with do_() as L2:
                L2.until_(acc - 1 == 0)
            self.tick_100ms[0] = 0
            L1.while_()
        yield

    def __init__(self):
        self.tick_1min = data_(None)
        self.tick_10sec = data_(None)
        self.tick_1sec = data_(None)
        self.tick_100ms = data_(None)
        self.send_(self.led_1min(), self.led_10sec(), self.led_1sec(), self.led_100ms(), self.clk_100ms())


class mandelbrot(C5G):

    def fsquare(self):
        with acc.keep():
            low = var_((acc * acc).shr(27).adc(0))
        acc[:] = (acc.imulh(acc) << 5) + low

    def iteration(self, cy):  # acc: cx
        cx, x, x_ = var_(acc, acc, 0)
        cy_ = var_(cy)
        y, y_ = var_(acc, 0)
        io_(KEY, 0)[:] = acc
        n = var_(acc & 0x3ff0)
        with do_() as L:
            x_[:] = x
            self.fsquare()
            x2, x2_ = var_(acc, acc)
            y_[:] = y
            self.fsquare()
            y2 = var_(acc)
            r2 = var_(acc + x2)
            with if_(acc & 0xe0000000 != 0):  # x^2 + y^2 >= 4
                acc[:] = 0x80000000
            L.break_(acc + n - 1 <= 0)
            n[:] = acc
            acc[:] = x_ + y_
            self.fsquare()
            y[:] = acc - r2 + cy_  # y := (x + y)^2 - (x^2 + y^2) + cy
            x[:] = x2_ - y2 + cx  # x := x^2 - y^2 + cx
            L.while_()
            yield L
        with if_(acc != 0):
            acc[:] = ((acc & 7) * 0x20000000) ^ 0xff000000
        acc[:] = acc ^ 0x1c000000

    def drawline(self):  # acc: iy
        iy = var_(acc)
        vbase = var_(acc * self.VRAM_LINE)
        yield from self.DELTA[0]
        delta, delta_ = var_(acc, acc)
        dy = var_(acc * iy)
        yield from self.CY0[0]
        cy = var_(acc - dy)
        yield from self.CX0[0]
        cx = var_(acc - delta)
        with for_(0, self.W // 4 - 1):
            vaddr = var_(acc + vbase)
            pixel, pixel_ = var_(0, 0)
            pixel[:] = 0
            acc[:] = 4
            with do_() as L:
                with acc.keep():
                    cx[:] = cx + delta_
                    yield from self.iteration(cy)
                    pixel[:] = (acc | pixel).rol(8)
                    pixel_[:] = acc
                L.until_(acc - 1 == 0)
            self.VRAM[vaddr] = pixel_

    def worker(self):
        if self.ALIGN is None:
            self.ALIGN = here_()
        else:
            yield self.ALIGN
        self.fork_()
        with do_() as L:
            acc[:] = fifo_(FIFO[0])
            yield from self.drawline()
            L.while_()

    def caster(self):
        self.fork_()
        with do_() as L1:
            with for_(0, self.H - 1):
                fifo_(FIFO[0]).push()
            with do_() as L2:
                io_(KEY, 0)[:] = acc
                L2.while_(acc & 0xf != 0)
            yield from self.DELTA[0]
            delta, delta_ = var_(acc, acc)
            mx, my = var_(0, 0)
            with do_() as L2:
                io_(KEY, 0)[:] = acc
                acc[:] = acc & 0xf
                with if_(acc ^ 0b1001 == 0):
                    mx[:] = -self.W // 2
                    my[:] = self.H // 2
                    yield from self.DELTA[0]
                    acc[0] = acc << 1
                    L2.break_()
                with do_() as L3:
                    with if_(acc ^ (0b0011 ^ 0b1001) == 0):
                        mx[:] = self.W // 2
                        my[:] = 0
                        L3.break_()
                    with if_(acc ^ (0b0101 ^ 0b0011) == 0):
                        mx[:] = self.W // 2
                        my[:] = -self.H // 2
                        L3.break_()
                    with if_(acc ^ (0b0110 ^ 0b0101) == 0):
                        mx[:] = self.W // 4
                        my[:] = -self.H // 4
                        L3.break_()
                    with if_(acc ^ (0b1010 ^ 0b0110) == 0):
                        mx[:] = 0
                        my[:] = -self.H // 2
                        L3.break_()
                    with if_(acc ^ (0b1100 ^ 0b1010) == 0):
                        mx[:] = 0
                        my[:] = 0
                        L3.break_()
                    L2.while_()
                yield from self.DELTA[0]
                acc[0] = acc >> 1
            self.DELTA[0] = acc
            yield from self.CX0[0]
            self.CX0[0] = acc + delta * mx
            yield from self.CY0[0]
            self.CY0[0] = acc + delta_ * my
            if self.ALIGN is None:
                self.ALIGN = here_()
            else:
                yield [self.ALIGN]
            with do_() as L2:
                L2.until_(fifo_(FIFO[0]).pop().isempty())
            L1.while_()

    def __init__(self, W=640, H=480):
        self.W, self.H = W, H
        self.init_vga()
        self.DELTA = data_(0x00080000)
        self.CY0 = data_(0x00080000 * self.H // 2)
        self.CX0 = data_(-0x10000000)
        self.ALIGN = None
        worker = [self.worker() for _ in range(13)]
        self.send_(self.caster(), *worker)


class camera_vga(C5G):

    def capture(self):
        self.fork_()
        with do_() as L1:
            with do_() as L2:
                io_(CAMERA, 1)[:] = acc
                L2.until_(carry & (acc < 0))  # detect vsync
            ior_(CAMERA, 1)[:] = acc  # skip vblank
            with do_() as L2:
                io_(CAMERA, 1)[:] = acc
                L2.until_(carry)  # skip one line
            with for_(480):
                ior_(CAMERA, 1)[:] = acc  # skip hblank
                with for_(-400, 542, 2):
                    with if_(acc >= 0):
                        io_(CAMERA, 1)[:] = acc
                        with acc.keep():
                            fifo_(FIFO[0]).push(acc & 0xffff0000)
                        fifo_(FIFO[0]).push(acc << 16)
                with do_() as L2:
                    io_(CAMERA, 1)[:] = acc
                    L2.until_(carry)  # skip right side
            L1.while_()
        yield

    def buffer(self):
        self.fork_()
        with do_() as L1:
            with for_(1, 1 + 479 * (544 >> 2), 544 >> 2):
                y0, y1 = var_(acc, acc)
                with for_(0, 542 << 18, 2 << 18):
                    x0, x1 = var_(acc, acc)
                    io_(SRAM, fifo_(FIFO[0]) + y0)[:] = x0
                    io_(SRAM, fifo_(FIFO[0]) + y1)[:] = x1 + (1 << 18)
            L1.while_()
        yield

    def dither_r(self):
        self.fork_()
        with do_() as L1:
            with for_(0, 480 * 544 - 4, 4, fast=True):
                with acc.keep():
                    ior_(SRAM, 0)[:] = acc
                    p = var_(acc & 0xe0000000)
                with acc.keep():
                    acc[:] = acc + 1
                    ior_(SRAM, 0)[:] = acc
                    p = var_((acc & 0xe0000000).shr(8) | p)
                with acc.keep():
                    acc[:] = acc + 2
                    ior_(SRAM, 0)[:] = acc
                    p = var_((acc & 0xe0000000).shr(16) | p)
                with acc.keep():
                    acc[:] = acc + 3
                    ior_(SRAM, 0)[:] = acc
                    fifo_(FIFO[1])[:] = (acc & 0xe0000000).shr(24) | p
            L1.while_()
        yield

    def disp(self):
        self.fork_()
        with do_() as L:
            with for_(0, self.VRAM_LINE * 479, self.VRAM_LINE):
                y = var_(acc)
                with for_(12, 135 + 12):
                    x = var_(acc)
                    self.VRAM[y + x] = fifo_(FIFO[1])
            L.while_()
        yield

    def __init__(self):
        self.init_vga()
        self.init_camera()
        self.send_(self.buffer(), self.dither_r(), self.disp())
        self.send_(self.capture())


camera_vga()

