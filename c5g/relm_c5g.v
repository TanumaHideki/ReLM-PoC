module relm_dpmem(clk, we_in, wa_in, ra_in, d_in, q_out);
	parameter WAD = 0;
	parameter WAD2 = 0;
	parameter WD = 0;
	parameter FILEH = 0;
	parameter FILEB = 0;
	input clk, we_in;
	input [WAD-1:0] wa_in, ra_in;
	input [WD-1:0] d_in;
	output reg [WD-1:0] q_out = 0;
	generate
		if (WAD2) begin
			reg [WD-1:0] q1 = 0;
			reg [WD-1:0] q2 = 0;
			reg q_sel = 0;
			always @* q_out <= q_sel ? q2 : q1;
			(* ramstyle = "M10K", max_depth = 2048 *) reg [WD-1:0] mem [0:2**(WAD-1)-1];
			(* ramstyle = "M10K", max_depth = 2048 *) reg [WD-1:0] mem2 [0:2**WAD2-1];
			always @(posedge clk) begin
				if (we_in && !wa_in[WAD-1]) mem[wa_in[0+:WAD-1]] <= d_in;
				if (we_in && wa_in[WAD-1]) mem2[wa_in[0+:WAD2]] <= d_in;
				q1 <= mem[ra_in[0+:WAD-1]];
				q2 <= mem2[ra_in[0+:WAD2]];
				q_sel <= ra_in[WAD-1];
			end
		end
		else begin
			(* ramstyle = "M10K", max_depth = 2048 *) reg [WD-1:0] mem [0:2**WAD-1];
			always @(posedge clk) begin
				if (we_in) mem[wa_in] <= d_in;
				q_out <= mem[ra_in];
			end
		end
	endgenerate
	initial if (FILEH) $readmemh(FILEH, mem);
	initial if (FILEB) $readmemb(FILEB, mem);
endmodule

module relm_unused(d_in, q_out);
	parameter WD = 32;
	input [WD:0] d_in;
	output [WD:0] q_out = d_in;
endmodule

module relm_c5g(clk, sw_in, key_in, uart_in, uart_out,
		hex3_out, hex2_out, hex1_out, hex0_out, ledr_out, ledg_out,
		hdmi_r_out, hdmi_g_out, hdmi_b_out, hdmi_clk_out, hdmi_de_out, hdmi_hs_out, hdmi_vs_out,
		hdmi_int_in, hdmi_scl_out, hdmi_sda_inout,
		sram_a_out, sram_d_inout, sram_ce_n_out, sram_oe_n_out, sram_we_n_out, sram_lb_n_out, sram_ub_n_out,
		aud_xck_out, aud_bclk, aud_dacdat_out, aud_daclrck_in, aud_adcdat_in, aud_adclrck_in,
		usb_int_in, usb_ss_out, usb_mosi_out, usb_miso_in, usb_sck_out);
	parameter WD = 32;
	parameter WC = `WC;

	(* chip_pin = "R20" *)
	input clk;

	wire [WD:0] timer_d;
	relm_unused unused_timer(timer_d);
	reg [WD-1:0] timer = 0;
	always @(posedge clk) timer <= timer + 1;
	wire [WD:0] timer_q = {1'b0, timer};

	(* chip_pin = "AE19, Y11, AC10, V10, AB10, W11, AC8, AD13, AE10, AC9" *)
	input [9:0] sw_in;
	(* chip_pin = "AB24, Y16, Y15, P12, P11" *)
	input [4:0] key_in;
	wire [WD:0] key_d;
	relm_unused unused_key(key_d);
	reg [14:0] key;
	always @(posedge clk) key <= {~key_in[4], sw_in, ~key_in[3:0]};
	wire [WD:0] key_q = {{WD-14{1'b0}}, key};

	(* chip_pin = "J10, H7, K8, K10, J7, J8, G7, G6, F6, F7" *)
	output reg [9:0] ledr_out;
	(* chip_pin = "H9, H8, B6, A5, E9, D8, K6, L7" *)
	output reg [7:0] ledg_out;
	wire [WD:0] led_d;
	always @(posedge clk) begin
		if (led_d[WD]) {ledr_out, ledg_out} <= led_d[0+:18];
	end
	wire led_retry = 0;

	(* chip_pin = "Y24, AC23, Y23, AC22, AC24, AA23, AA22" *)
	output reg [6:0] hex3_out;
	(* chip_pin = "AD7, W21, AD6, W20, V20, U20, V22" *)
	output reg [6:0] hex2_out;
	(* chip_pin = "AA18, AC19, AD26, AF24, AE25, AB19, AE26" *)
	output reg [6:0] hex1_out;
	(* chip_pin = "V19, Y19, V18, Y18, Y20, V17, W18" *)
	output reg [6:0] hex0_out;
	wire [WD:0] hex_d;
	always @(posedge clk) begin
		if (hex_d[0]) hex0_out <= ~hex_d[1+:7];
		if (hex_d[8]) hex1_out <= ~hex_d[9+:7];
		if (hex_d[16]) hex2_out <= ~hex_d[17+:7];
		if (hex_d[24]) hex3_out <= ~hex_d[25+:7];
	end
	wire hex_retry = 0;

	(* chip_pin = "M9" *)
	input uart_in;
	(* chip_pin = "L9" *)
	output reg uart_out = 1;
	wire [WD:0] uart_d;
	reg [1:0] uart_reg = 3;
	reg [7:0] uart_count = 128;
	wire [7:0] uart_cnext = uart_count + {7'd0, uart_reg[1]};
	reg [7:0] uart_rclk = 255;
	wire [8:0] uart_rnext = {1'b0, uart_rclk} + 9'd1;
	reg [1:0] uart_tclk = 1;
	wire [2:0] uart_tnext = {1'b0, uart_tclk} + 3'd1;
	reg [28:0] uart_r = ~29'd0;
	reg [8:0] uart_rdata = 0;
	reg [8:0] uart_t = 0;
	reg [8:0] uart_tdata = 0;
	wire [WD:0] uart_q = {1'b0, ~uart_tdata[8], uart_rdata[8], {WD-10{1'b0}}, uart_rdata[7:0]};
	always @(posedge clk) begin
		uart_reg <= {uart_reg[0], uart_in};
		if (uart_rnext[8]) begin
			uart_rclk <= 111;
			uart_count <= 55;
			if (uart_tnext[2]) uart_tclk <= 1;
			else uart_tclk <= uart_tnext[1:0];
		end
		else begin
			uart_rclk <= uart_rnext[7:0];
			uart_count <= uart_cnext;
		end
		if (uart_rnext[8] && uart_r[2:0] == 3'b001 && uart_reg[1]) begin
			uart_r <= ~29'd0;
			uart_rdata <= {1'b1, uart_r[26], uart_r[23], uart_r[20], uart_r[17], uart_r[14], uart_r[11], uart_r[8], uart_r[5]};
		end
		else begin
			if (uart_rnext[8]) uart_r <= {uart_reg[1], uart_r[28:1]};
			if (uart_d[WD-2]) uart_rdata <= 0;
		end
		if (uart_rnext[8] && uart_tnext[2]) begin
			if (uart_t) begin
				uart_out <= uart_t[0];
				uart_t <= {1'b0, uart_t[8:1]};
			end
			else if (uart_tdata[8]) begin
				uart_out <= 0;
				uart_t <= {1'b1, uart_tdata[7:0]};
				uart_tdata[8] <= 0;
			end
			else uart_out <= 1;
		end
		if (!uart_tdata[8] && uart_d[WD-1]) uart_tdata <= {1'b1, uart_d[7:0]};
	end

	(* chip_pin = "M24, N24, J26, J25, F22, E21, F21, G20, E23, D22, J21, J20, C25, D25, H20, H19, B26, B25" *)
	output reg [17:0] sram_a_out;
	(* chip_pin = "K21, L22, G22, F23, J23, H22, H24, H23, L24, L23, G24, F24, K23, K24, E25, E24" *)
	inout [15:0] sram_d_inout;
	(* chip_pin = "N23" *)
	output sram_ce_n_out;
	(* chip_pin = "M22" *)
	output sram_oe_n_out;
	(* chip_pin = "G25" *)
	output sram_we_n_out;
	(* chip_pin = "H25" *)
	output sram_lb_n_out;
	(* chip_pin = "M25" *)
	output sram_ub_n_out;
	assign sram_ce_n_out = 0;
	reg sram_oe = 0;
	assign sram_oe_n_out = !sram_oe;
	reg sram_we = 0;
	assign sram_we_n_out = !sram_we;
	assign sram_lb_n_out = 0;
	assign sram_ub_n_out = 0;
	wire [WD:0] sram_d;
	wire [WD:0] sram_q = {2'b00, sram_d[16+:15] + 15'd1, 16'd0};
	reg [17:0] sram_a_reg = 0;
	wire [WD:0] vram_d;
	reg [17:0] vram_a_reg = 0;
	reg [16:0] vram_d_reg = 0;
	reg vram_busy = 0;
	reg [12:0] vram_count = 0;
	reg [12:0] vram_width = 0;
	wire vram_retry = vram_busy;
	wire vram_full;
	wire [WD:0] vram_send = (sram_oe && vram_d_reg[16]) ? {1'b1, vram_d_reg[15:0], sram_d_inout} : 0;
	reg [16:0] sram_wd = 0;
	assign sram_d_inout = sram_wd[16] ? sram_wd[0+:16] : 16'hzzzz;
	always @(posedge clk) begin
		if (sram_d[WD-1]) begin
			sram_a_reg <= sram_d[0+:18];
		end
		if (sram_d[WD:WD-1] == 2'b10) begin
			sram_a_out <= sram_a_reg + {3'd0, sram_d[16+:15]};
			sram_oe <= 0;
			sram_we <= 1;
			sram_wd <= {1'b1, sram_d[0+:16]};
		end
		else begin
			sram_a_out <= vram_a_reg + {5'd0, vram_count};
			if (vram_busy && !vram_full) begin
				sram_oe <= 1;
				if (vram_count == vram_width) begin
					vram_busy <= 0;
				end
				vram_count <= vram_count + 1;
			end
			else begin
				sram_oe <= 0;
			end
			sram_we <= 0;
			sram_wd <= {1'b0, 16'hxxxx};
		end
		if (sram_oe) begin
			vram_d_reg <= {!vram_d_reg[16], sram_d_inout};
		end
		if (!vram_busy && vram_d[WD]) begin
			vram_count <= 0;
			vram_busy <= 1;
			vram_width <= vram_d[19+:13];
			vram_a_reg <= vram_d[0+:18] + (vram_d[18] ? vram_a_reg : 18'd0);
		end
	end

	(* chip_pin = "AD25, AC25, AB25, AA24, AB26, R26, R24, P21" *)
	output reg [7:0] hdmi_r_out = 0;
	(* chip_pin = "P26, N25, P23, P22, R25, R23, T26, T24" *)
	output reg [7:0] hdmi_g_out = 0;
	(* chip_pin = "T23, U24, V25, V24, W26, W25, AA26, V23" *)
	output reg [7:0] hdmi_b_out = 0;
	(* chip_pin = "Y25" *)
	output hdmi_clk_out;
	(* chip_pin = "Y26" *)
	output reg hdmi_de_out = 0;
	(* chip_pin = "U26" *)
	output reg hdmi_hs_out = 0;
	(* chip_pin = "U25" *)
	output reg hdmi_vs_out = 0;
	(* chip_pin = "T12" *)
	input hdmi_int_in;
	wire hdmi_empty;
	reg [10:0] hdmi_x = 0;
	assign hdmi_clk_out = hdmi_x[0];
	reg [9:0] hdmi_y = 0;
	wire [WD-1:0] hdmi_q;
	reg [1:0] hdmi_en = 0;
	reg [31:0] hdmi_pixel;
	wire [WD:0] hdmipal_d;
	wire hdmipal_retry = 0;
	(* ramstyle = "no_rw_check, MLAB" *) reg [23:0] hdmi_palette [0:15];
	always @(posedge clk) begin
		if (hdmipal_d[6] || hdmi_x == 100*16-1) begin
			hdmi_hs_out <= 0; // HSYNC
			hdmi_x <= 0;
			if (hdmipal_d[6] || hdmi_y == 524) begin
				hdmi_vs_out <= 0; // VSYNC
				hdmi_y <= 0;
			end
			else begin
				if (hdmi_y == 1) hdmi_vs_out <= 1;
				hdmi_y <= hdmi_y + 10'd1;
			end
		end
		else begin
			if (hdmi_x == 12*16-1) hdmi_hs_out <= 1;
			hdmi_x <= hdmi_x + 11'd1;
		end
		case (hdmi_x)
			18*16-3: hdmi_en[0] <= 1;
			98*16-3: hdmi_en[0] <= 0;
		endcase
		if (hdmipal_d[6] || hdmi_y == 35+480) hdmi_en[1] <= 0;
		else if (hdmi_y == 35) hdmi_en[1] <= 1;
		if (hdmipal_d[7]) hdmi_palette[hdmipal_d[3:0]] <= hdmipal_d[31:8];
		casez (hdmi_x[3:0])
			4'b???1: begin
				hdmi_pixel <= {hdmi_pixel[27:0], 4'd0};
				{hdmi_r_out, hdmi_g_out, hdmi_b_out} <= hdmi_palette[hdmi_pixel[31:28]];
				hdmi_de_out <= &hdmi_en;
			end
			4'b1110: if (&hdmi_en) hdmi_pixel <= hdmi_q;
		endcase
	end
	wire [WD:0] hdmi_d;
	wire hdmi_retry = vram_full | vram_busy;
	relm_fifo #(
		.WAD(8),
		.WD(WD)
	) fifo_hdmi(
		.clk(clk),
		.clear_in(hdmipal_d[6]),
		.re_in(hdmi_x[3:0] == 4'b1110 && &hdmi_en),
		.we_in((!vram_busy && hdmi_d[WD]) | vram_send[WD]),
		.d_in(hdmi_d[0+:WD] | vram_send[0+:WD]),
		.empty_out(hdmi_empty),
		.full_out(vram_full),
		.q_out(hdmi_q)
	);

	(* chip_pin = "B7" *)
	output hdmi_scl_out;
	(* chip_pin = "G11" *)
	inout hdmi_sda_inout;
	reg i2c_scl = 1;
	assign hdmi_scl_out = i2c_scl ? 1'bz : 1'b0;
	reg i2c_sda = 1;
	assign hdmi_sda_inout = i2c_sda ? 1'bz : 1'b0;
	reg [1:0] i2c_sda_reg = 3;
	wire [WD:0] i2c_d;
	wire [WD:0] i2c_q = {{WD-8{1'b0}}, i2c_sda_reg[1], 8'd0};
	always @(posedge clk) begin
		i2c_sda_reg <= {i2c_sda_reg[0], hdmi_sda_inout};
		if (i2c_d[WD]) begin
			i2c_sda <= i2c_d[WD-1];
			i2c_scl <= i2c_d[0];
		end
	end

	(* chip_pin = "P8" *)
	input usb_int_in;
	(* chip_pin = "R8" *)
	output reg usb_ss_out = 1;
	(* chip_pin = "R9" *)
	output reg usb_mosi_out = 0;
	(* chip_pin = "R10" *)
	input usb_miso_in;
	(* chip_pin = "F26" *)
	output usb_sck_out;
	reg usb_sck = 1;
	assign usb_sck_out = usb_sck;
	reg [1:0] usb_int = 0;
	wire [WD:0] usb_d;
	wire [WD:0] usb_q = {1'b0, usb_d[31:16], usb_d[31], 7'd0, usb_d[7:1], usb_d[0] ? usb_int[1] : usb_miso_in};
	always @(posedge clk) begin
		usb_int <= {usb_int[0], usb_int_in};
		usb_sck <= usb_d[WD] ? usb_d[13] : 1'b1;
		if (usb_d[WD]) begin
			usb_ss_out <= usb_d[14];
			usb_mosi_out <= usb_d[23];
		end
	end

	(* chip_pin = "D6" *)
	output aud_xck_out;
	reg aud_pll_rst = 1;
	wire aud_pll_locked;
	reg [1:0] aud_pll_ready = 0;
	always @(posedge clk) aud_pll_ready <= {aud_pll_ready[0], aud_pll_locked & ~aud_pll_rst};
	altera_pll #(
		.fractional_vco_multiplier("true"),
		.reference_clock_frequency("50.0 MHz"),
		.operation_mode("direct"),
		.number_of_clocks(1),
		.output_clock_frequency0("18.432000 MHz"),
		.phase_shift0("0 ps"),
		.duty_cycle0(50),
		.output_clock_frequency1("0 MHz"),
		.phase_shift1("0 ps"),
		.duty_cycle1(50),
		.output_clock_frequency2("0 MHz"),
		.phase_shift2("0 ps"),
		.duty_cycle2(50),
		.output_clock_frequency3("0 MHz"),
		.phase_shift3("0 ps"),
		.duty_cycle3(50),
		.output_clock_frequency4("0 MHz"),
		.phase_shift4("0 ps"),
		.duty_cycle4(50),
		.output_clock_frequency5("0 MHz"),
		.phase_shift5("0 ps"),
		.duty_cycle5(50),
		.output_clock_frequency6("0 MHz"),
		.phase_shift6("0 ps"),
		.duty_cycle6(50),
		.output_clock_frequency7("0 MHz"),
		.phase_shift7("0 ps"),
		.duty_cycle7(50),
		.output_clock_frequency8("0 MHz"),
		.phase_shift8("0 ps"),
		.duty_cycle8(50),
		.output_clock_frequency9("0 MHz"),
		.phase_shift9("0 ps"),
		.duty_cycle9(50),
		.output_clock_frequency10("0 MHz"),
		.phase_shift10("0 ps"),
		.duty_cycle10(50),
		.output_clock_frequency11("0 MHz"),
		.phase_shift11("0 ps"),
		.duty_cycle11(50),
		.output_clock_frequency12("0 MHz"),
		.phase_shift12("0 ps"),
		.duty_cycle12(50),
		.output_clock_frequency13("0 MHz"),
		.phase_shift13("0 ps"),
		.duty_cycle13(50),
		.output_clock_frequency14("0 MHz"),
		.phase_shift14("0 ps"),
		.duty_cycle14(50),
		.output_clock_frequency15("0 MHz"),
		.phase_shift15("0 ps"),
		.duty_cycle15(50),
		.output_clock_frequency16("0 MHz"),
		.phase_shift16("0 ps"),
		.duty_cycle16(50),
		.output_clock_frequency17("0 MHz"),
		.phase_shift17("0 ps"),
		.duty_cycle17(50),
		.pll_type("General"),
		.pll_subtype("General")
	) audio_pll (
		.rst(aud_pll_rst),
		.outclk({aud_xck_out}),
		.locked(aud_pll_locked),
		.fboutclk(),
		.fbclk(1'b0),
		.refclk(clk)
	);

	(* chip_pin = "E6" *)
	input aud_bclk;
	(* chip_pin = "G10" *)
	input aud_daclrck_in;
	(* chip_pin = "H10" *)
	output reg aud_dacdat_out = 0;
	wire aud_dac_rdempty;
	reg aud_dac_clk = 0;
	wire [WD:0] aud_push_d;
	always @(posedge clk) if (aud_push_d[WD]) aud_pll_rst <= 0;
	wire aud_dac_wrfull;
	wire aud_push_retry = aud_dac_wrfull | !aud_pll_ready[1];
	always @(posedge aud_bclk) aud_dac_clk <= aud_daclrck_in;
	wire [31:0] aud_dac_q;
	reg [15:0] aud_dac_dl = 0;
	reg [15:0] aud_dac_dr = 0;
	always @(negedge aud_bclk) begin
		if (aud_dac_clk) begin
			aud_dac_dl <= aud_dac_q[31:16];
			aud_dacdat_out <= aud_dac_dr[15];
			aud_dac_dr <= {aud_dac_dr[14:0], 1'bx};
		end
		else begin
			aud_dac_dr <= aud_dac_q[15:0];
			aud_dacdat_out <= aud_dac_dl[15];
			aud_dac_dl <= {aud_dac_dl[14:0], 1'bx};
		end
	end
	dcfifo #(
		.lpm_numwords(256),
		.lpm_showahead("OFF"),
		.lpm_type("dcfifo"),
		.lpm_width(32),
		.lpm_widthu(8),
		.overflow_checking("ON"),
		.rdsync_delaypipe(5),
		.underflow_checking("ON"),
		.use_eab("ON"),
		.write_aclr_synch("ON"),
		.wrsync_delaypipe(5)
	) audio_dac (
		.wrclk(clk),
		.rdreq(!aud_dac_rdempty),
		.aclr(1'b0),
		.rdclk(aud_dac_clk),
		.wrreq(!aud_push_retry && aud_push_d[WD]),
		.data(aud_push_d[0+:WD]),
		.rdempty(aud_dac_rdempty),
		.wrfull(aud_dac_wrfull),
		.q(aud_dac_q)
	);
	(* chip_pin = "C7" *)
	input aud_adclrck_in;
	(* chip_pin = "D7" *)
	input aud_adcdat_in;
	wire aud_adc_rdempty;
	wire aud_adc_wrfull;
	wire [WD-1:0] aud_adc_q;
	wire [WD:0] aud_pop_d;
	wire [WD:0] aud_pop_q = {aud_adc_rdempty, aud_adc_q};
	reg [17:0] aud_adc_dl = 1;
	reg [17:0] aud_adc_dr = 18'h20000;
	wire aud_adc_wrreq = aud_adclrck_in & aud_adc_dl[17] & aud_adc_dr[17];
	always @(posedge aud_bclk) begin
		if (aud_adclrck_in) begin
			if ({aud_adc_dl[17], aud_adc_dr[17]} == 2'b10) begin
				aud_adc_dr <= {aud_adc_dr[16:0], aud_adcdat_in};
			end
			else begin
				aud_adc_dl <= 1;
				aud_adc_dr <= 1;
			end
		end
		else begin
			if ({aud_adc_dl[17], aud_adc_dr[17]} == 2'b00) begin
				aud_adc_dl <= {aud_adc_dl[16:0], aud_adcdat_in};
			end
		end
	end
	dcfifo #(
		.lpm_numwords(256),
		.lpm_showahead("OFF"),
		.lpm_type("dcfifo"),
		.lpm_width(32),
		.lpm_widthu(8),
		.overflow_checking("ON"),
		.rdsync_delaypipe(5),
		.underflow_checking("ON"),
		.use_eab("ON"),
		.write_aclr_synch("ON"),
		.wrsync_delaypipe(5)
	) audio_adc (
		.wrclk(aud_bclk),
		.rdreq(!aud_adc_rdempty && aud_pop_d[WD]),
		.aclr(1'b0),
		.rdclk(clk),
		.wrreq(!aud_adc_wrfull && aud_adc_wrreq),
		.data({aud_adc_dl[15:0], aud_adc_dr[15:0]}),
		.rdempty(aud_adc_rdempty),
		.wrfull(aud_adc_wrfull),
		.q(aud_adc_q)
	);

	parameter NFIFO = 6;

	wire [(WD+1)*NFIFO-1:0] pushf_d, popf_d, popf_q;
	wire [NFIFO-1:0] pushf_retry;
	generate
		genvar i;
		for (i = 0; i < NFIFO; i = i + 1) begin : fifo
			relm_fifo_io #(
				.WAD(11),
				.WD(WD)
			) fifo_io(
				.clk(clk),
				.push_d(pushf_d[(WD+1)*i+:WD+1]),
				.push_retry(pushf_retry[i]),
				.pop_d(popf_d[(WD+1)*i+:WD+1]),
				.pop_q(popf_q[(WD+1)*i+:WD+1])
			);
		end
	endgenerate

	parameter WID = 3;
	parameter WAD = 14;
	parameter WAD2 = 12;
	parameter WOP = 5;

	parameter NPUSH = 6 + NFIFO;
	parameter NPOP = 7 + NFIFO;

	wire [NPUSH*(WD+1)-1:0] push_d;
	assign {hex_d, led_d, hdmipal_d, hdmi_d, vram_d, aud_push_d, pushf_d} = push_d;
	wire [NPUSH-1:0] push_retry = {hex_retry, led_retry, hdmipal_retry, hdmi_retry, vram_retry, aud_push_retry, pushf_retry};
	wire [NPOP*(WD+1)-1:0] pop_d;
	assign {usb_d, uart_d, key_d, timer_d, i2c_d, sram_d, aud_pop_d, popf_d} = pop_d;
	wire [NPOP*(WD+1)-1:0] pop_q = {usb_q, uart_q, key_q, timer_q, i2c_q, sram_q, aud_pop_q, popf_q};

`include "coverage.txt"
	generate
		if (!USE_POP_JTAG && !USE_PUSH_PUTOP) begin : no_loader
			relm #(
				.WID(WID),
				.WAD(WAD),
				.WAD2(WAD2),
				.NPUSH(NPUSH),
				.NPOP(NPOP),
				.WSHIFT(5),
				.WD(WD),
				.WOP(WOP),
				.WC(WC),
				.CODE("code00"),
				.DATA("data00"),
				.EXT(".txt")
			) relm(
				.clk(clk),
				.push_out(push_d),
				.push_in(push_retry),
				.pop_out(pop_d),
				.pop_in(pop_q),
				.op_we_in(0),
				.op_wa_in(0),
				.op_d_in(0)
			);
		end
		else begin : use_loader
			wire [WD:0] putop_d;
			wire [WD:0] jtag_d;
			wire [23:0] jtag_ir;
			reg jtag_ready = 0;

			relm #(
				.WID(WID),
				.WAD(WAD),
				.WAD2(WAD2),
				.NPUSH(NPUSH),
				.MPUSH(USE_PUSH_PUTOP),
				.NPOP(NPOP),
				.MPOP(USE_POP_JTAG),
				.WSHIFT(5),
				.WD(WD),
				.WOP(WOP),
				.WC(WC),
				.CODE("code00"),
				.DATA("data00"),
				.EXT(".txt")
			) relm(
				.clk(clk),
				.push_out({putop_d, push_d}),
				.push_in({1'b0, push_retry}),
				.pop_out({jtag_d, pop_d}),
				.pop_in({~jtag_ready, {WD-24{1'b0}}, jtag_ir, pop_q}),
				.op_we_in(putop_d[23]),
				.op_wa_in(putop_d[0+:WAD+WID]),
				.op_d_in(putop_d[22-:WOP])
			);

			wire jtag_tck, jtag_uir;
			reg [2:0] jtag_we = 0;
			always @(posedge clk) begin
				jtag_we <= {jtag_we[1:0], jtag_uir};
				if (jtag_we[2:1] == 2'b10) jtag_ready <= 1;
				else if (jtag_d[WD]) jtag_ready <= 0;
			end
			sld_virtual_jtag #(
				.sld_instance_index(1),
				.sld_ir_width(24)
			) jtag(
				.tck(jtag_tck),
				.tdi(),
				.ir_in(jtag_ir),
				.tdo(1'b0),
				.ir_out(24'd0),
				.virtual_state_cdr(),
				.virtual_state_sdr(),
				.virtual_state_e1dr(),
				.virtual_state_pdr(),
				.virtual_state_e2dr(),
				.virtual_state_udr(),
				.virtual_state_cir(),
				.virtual_state_uir(jtag_uir),
				.tms(),
				.jtag_state_tlr(),
				.jtag_state_rti(),
				.jtag_state_sdrs(),
				.jtag_state_cdr(),
				.jtag_state_sdr(),
				.jtag_state_e1dr(),
				.jtag_state_pdr(),
				.jtag_state_e2dr(),
				.jtag_state_udr(),
				.jtag_state_sirs(),
				.jtag_state_cir(),
				.jtag_state_sir(),
				.jtag_state_e1ir(),
				.jtag_state_pir(),
				.jtag_state_e2ir(),
				.jtag_state_uir()
			);
		end
	endgenerate
endmodule
