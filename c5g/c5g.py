from verilog import Verilog, reg_, posedge_, wire_, input_, output_, inout_, if_, else_, file_, case_, when_, default_, always_
import altera
import relm


class c5g(Verilog):

    clk = input_(chip_pin="R20")
    key_in = input_(5, useioff=1, chip_pin="AB24, Y16, Y15, P12, P11")
    sw_in = input_(10, useioff=1, chip_pin="AE19, Y11, AC10, V10, AB10, W11, AC8, AD13, AE10, AC9")
    ledr_out = output_('reg', 10, useioff=1, chip_pin="J10, H7, K8, K10, J7, J8, G7, G6, F6, F7")(0)
    ledg_out = output_('reg', 8, useioff=1, chip_pin="H9, H8, B6, A5, E9, D8, K6, L7")(0)
    hex0_out = output_('reg', 7, useioff=1, chip_pin="Y18, Y19, Y20, W18, V17, V18, V19")(0b1111111)
    hex1_out = output_('reg', 7, useioff=1, chip_pin="AF24, AC19, AE25, AE26, AB19, AD26, AA18")(0b1111111)
    hex2_out = reg_(7)(0b1111111)
    hex3_out = output_('reg', 7, useioff=1, chip_pin="AC22, AC23, AC24, AA22, AA23, Y23, Y24")(0b1111111)

    class keyled_io(relm.relm_io):

        def __init__(self, WD=32):
            super().__init__(WD=WD)
            self.key = reg_(5)(0)
            self.sw = reg_(10)(0)
            with posedge_(c5g.clk):
                c5g.ledg_out[:] = [self.p_io[0], self.d_io[:0:8]]
                c5g.ledr_out[:] = [self.p_io[1], self.d_io[:0:10]]
                c5g.hex0_out[:] = [self.p_io[2], ~self.d_io[:0:7]]
                c5g.hex1_out[:] = [self.p_io[3], ~self.d_io[:0:7]]
                c5g.hex2_out[:] = [self.p_io[4], ~self.d_io[:0:7]]
                c5g.hex3_out[:] = [self.p_io[5], ~self.d_io[:0:7]]
                self.key[:] = [c5g.key_in]
                self.sw[:] = [c5g.sw_in]
            self.q_io[:] = ({18:0}, ~self.key[4], self.sw, ~self.key[3:0])

    hdmi_r_out = output_('reg', 8, useioff=1, chip_pin="AD25, AC25, AB25, AA24, AB26, R26, R24, P21")(0)
    hdmi_g_out = output_('reg', 8, useioff=1, chip_pin="P26, N25, P23, P22, R25, R23, T26, T24")(0)
    hdmi_b_out = output_('reg', 8, useioff=1, chip_pin="T23, U24, V25, V24, W26, W25, AA26, V23")(0)
    hdmi_clk_out = output_(useioff=1, chip_pin="Y25")
    hdmi_de_out = output_('reg', useioff=1, chip_pin="Y26")(0)
    hdmi_hs_out = output_('reg', useioff=1, chip_pin="U26")(0)
    hdmi_vs_out = output_('reg', useioff=1, chip_pin="U25")(0)
    hdmi_int_in = input_(useioff=1, chip_pin="T12")

    class vga_io(relm.relm_io):

        def __init__(self, WD=32):
            super().__init__(WD=WD)
            self.vga_count = reg_(11)(0)
            c5g.hdmi_clk_out[:] = self.vga_count[0]
            self.vga_re = wire_()(self.vga_count == {11:1})
            self.vga_rgb = reg_(32)(0)
            f = altera.fifo(
                clk=c5g.clk,
                we=self.p_io[-1],
                re=self.vga_re,
                d=(self.d_io[9:2], self.p_io[:0:32]),
                WAD=8,
                WD=40,
                ramstyle="M10K")
            with posedge_(c5g.clk):
                with if_(self.vga_re):
                    c5g.hdmi_de_out[:] = f.q[-8]
                    c5g.hdmi_hs_out[:] = f.q[-8] | ~f.q[0]
                    c5g.hdmi_vs_out[:] = f.q[-8] | ~f.q[1]
                    self.vga_rgb[:] = (f.q[:2:30], f.q[1:0] & {2:f.q[-8]})
                    self.vga_count[:] = (f.q[-1::8], {3:0})
                with else_:
                    with if_(self.vga_count[0]):
                        self.vga_rgb[:] = self.vga_rgb << 8
                    self.vga_count[:] = self.vga_count - {11:1}
                with case_(self.vga_rgb[-1:-3]):
                    with when_({3:0}):
                        c5g.hdmi_r_out[:] = {8:0}
                    with when_({3:1}):
                        c5g.hdmi_r_out[:] = {8:99}
                    with when_({3:2}):
                        c5g.hdmi_r_out[:] = {8:116}
                    with when_({3:3}):
                        c5g.hdmi_r_out[:] = {8:136}
                    with when_({3:4}):
                        c5g.hdmi_r_out[:] = {8:159}
                    with when_({3:5}):
                        c5g.hdmi_r_out[:] = {8:186}
                    with when_({3:6}):
                        c5g.hdmi_r_out[:] = {8:218}
                    with default_:
                        c5g.hdmi_r_out[:] = {8:255}
                with case_(self.vga_rgb[-4:-6]):
                    with when_({3:0}):
                        c5g.hdmi_g_out[:] = {8:0}
                    with when_({3:1}):
                        c5g.hdmi_g_out[:] = {8:99}
                    with when_({3:2}):
                        c5g.hdmi_g_out[:] = {8:116}
                    with when_({3:3}):
                        c5g.hdmi_g_out[:] = {8:136}
                    with when_({3:4}):
                        c5g.hdmi_g_out[:] = {8:159}
                    with when_({3:5}):
                        c5g.hdmi_g_out[:] = {8:186}
                    with when_({3:6}):
                        c5g.hdmi_g_out[:] = {8:218}
                    with default_:
                        c5g.hdmi_g_out[:] = {8:255}
                with case_(self.vga_rgb[-7:-8]):
                    with when_({2:0}):
                        c5g.hdmi_b_out[:] = {8:0}
                    with when_({2:1}):
                        c5g.hdmi_b_out[:] = {8:136}
                    with when_({2:2}):
                        c5g.hdmi_b_out[:] = {8:186}
                    with default_:
                        c5g.hdmi_b_out[:] = {8:255}
            self.q_io[:] = (f.full, {32:4})

    hdmi_scl_out = output_('reg', useioff=1, chip_pin="B7")(1)
    hdmi_sda_out = output_('reg', useioff=1, chip_pin="G11")(1)
    hex2_inout = inout_(7, useioff=1, chip_pin="W20, W21, V20, V22, U20, AD6, AD7")
    cam_active = reg_()(1)

    class i2c_io(relm.relm_io):

        def __init__(self, WD=32):
            super().__init__(WD=WD)
            self.mix_out = reg_(7)({7:'bzzz11zz'})
            c5g.hex2_inout[:] = self.mix_out
            with posedge_(c5g.clk):
                with if_(self.p_io[WD]):
                    c5g.hdmi_scl_out[:] = [self.p_io[0]]
                    c5g.hdmi_sda_out[:] = [[self.p_io[1], {1:'bz'}] ** (self.p_io[WD - 1] | self.d_io[WD - 1])]
                with if_(c5g.cam_active):
                    self.mix_out[6:4] = [{3:'bzzz'}]
                    self.mix_out[1:0] = [{2:'bzz'}]
                    with if_(self.p_io[WD]):
                        self.mix_out[2] = [self.p_io[0]]
                        self.mix_out[3] = [[self.p_io[1], {1:'bz'}] ** (self.p_io[WD - 1] | self.d_io[WD - 1])]
                with else_:
                    self.mix_out[:] = [c5g.hex2_out]
            self.q_io[:] = {33:3}

    cam_xclk_out = output_('reg', useioff=1, chip_pin="AA6")(0)
    cam_d_in = input_(8, useioff=1, chip_pin="G26, Y8, F26, Y9, R9, R10, P8, R8")
    cam_reset_out = output_(useioff=1, chip_pin="U19")({1:'bz'})
    cam_pwdn_out = output_(useioff=1, chip_pin="U22")({1:'bz'})
    cam_href_in = input_(useioff=1, chip_pin="AA7")

    class cam_io(relm.relm_io):

        def __init__(self, WD=32):
            super().__init__(WD=WD)
            self.cam_q = reg_(33)(0)
            self.cam_q_io = reg_(33)(0)
            self.q_io[:] = self.cam_q_io
            with posedge_(c5g.clk):
                c5g.cam_xclk_out[:] = [~c5g.cam_xclk_out]
                self.cam_q_io[:] = [self.cam_q]
                with if_(self.p_io[WD]):
                    c5g.cam_active[:] = [self.p_io[0]]
            cam_pclk_in = c5g.hex2_inout[1]
            cam_vsync_in = c5g.hex2_inout[0]
            self.cam_d = reg_(25)(0)
            with posedge_(cam_pclk_in):
                with if_(c5g.cam_href_in):
                    with if_(self.cam_d[-1]):
                        self.cam_q[:] = [({1:0}, self.cam_d[23:], c5g.cam_d_in)]
                        self.cam_d[:] = [{25:1}]
                    with else_:
                        self.cam_d[:] = [(self.cam_d[16:], c5g.cam_d_in)]
                with else_:
                    self.cam_q[-1] = [{1:1}]
                    self.cam_q[-2] = [cam_vsync_in]

    sram_a_out = output_(18, useioff=1, chip_pin="M24, N24, J26, J25, F22, E21, F21, G20, E23, D22, J21, J20, C25, D25, H20, H19, B26, B25")
    sram_d_inout = inout_(16, useioff=1, chip_pin="K21, L22, G22, F23, J23, H22, H24, H23, L24, L23, G24, F24, K23, K24, E25, E24")
    sram_ce_n_out = output_(useioff=1, chip_pin="N23")(0)
    sram_oe_n_out = output_(useioff=1, chip_pin="M22")
    sram_we_n_out = output_(useioff=1, chip_pin="G25")
    sram_be_n_out = output_(2, useioff=1, chip_pin="M25, H25")(0)

    class sram_io(relm.relm_io):

        def __init__(self, WD=32):
            super().__init__(WD=WD)
            c5g.sram_oe_n_out[:] = ~c5g.clk
            self.sram_we = reg_()(0)
            c5g.sram_we_n_out[:] = ~self.sram_we | c5g.clk
            self.sram_ra = reg_(18)(0)
            self.sram_wa = reg_(18)(0)
            c5g.sram_a_out[:] = [c5g.clk, self.sram_ra] ** self.sram_wa
            self.sram_wd = reg_(16)(0)
            c5g.sram_d_inout[:] = [c5g.clk, {16:'hzzzz'}] ** self.sram_wd
            self.sram_q = reg_(16)(0)
            self.sram_rd = reg_(16)(0)
            with always_():
                self.sram_q[:] = [c5g.clk, c5g.sram_d_inout]
            with posedge_(c5g.clk):
                self.sram_rd[:] = [self.sram_q]
                self.sram_we[:] = [self.p_io[0]]
                self.sram_wa[:] = [(self.p_io[15:1] + self.d_io[31:21], self.d_io[20:18])]
                self.sram_ra[:] = [self.d_io[17:0]]
                self.sram_wd[:] = [self.p_io[31:16]]
            self.q_io[:] = ({1:0}, self.sram_rd, {16:0})

    def __init__(self, WID=4, WAD=13, WD=32, FILE='mem{:02d}.txt', SIZE=0x1900):
        super().__init__()
        devices = [
            self.keyled_io(WD),
            altera.jtag_io(self.clk, ramstyle="MLAB"),
            self.vga_io(WD),
            self.i2c_io(WD),
            self.cam_io(WD),
            self.sram_io(WD),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K"),
            altera.fifo_io(clk=self.clk, WAD=10, WD=WD, ramstyle="M10K")]
        relm.relm(self.clk, devices, WID=WID, WAD=WAD, WD=WD, FILE=FILE, SIZE=SIZE, ramstyle="M10K", max_depth=2048)


if __name__ == '__main__':
    with file_(open('c5g.v', mode='w')), c5g():
        pass
