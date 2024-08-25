module c5g(clk, key_in, sw_in, ledr_out, ledg_out, hex0_out, hex1_out, hex3_out, hdmi_r_out, hdmi_g_out, hdmi_b_out, hdmi_clk_out, hdmi_de_out, hdmi_hs_out, hdmi_vs_out, hdmi_int_in, hdmi_scl_out, hdmi_sda_out, hex2_inout, cam_xclk_out, cam_d_in, cam_reset_out, cam_pwdn_out, cam_href_in, sram_a_out, sram_d_inout, sram_ce_n_out, sram_oe_n_out, sram_we_n_out, sram_be_n_out);
	(* chip_pin = "R20" *)
	input clk;
	(* useioff = 1, chip_pin = "AB24, Y16, Y15, P12, P11" *)
	input [4:0] key_in;
	(* useioff = 1, chip_pin = "AE19, Y11, AC10, V10, AB10, W11, AC8, AD13, AE10, AC9" *)
	input [9:0] sw_in;
	(* useioff = 1, chip_pin = "J10, H7, K8, K10, J7, J8, G7, G6, F6, F7" *)
	output reg [9:0] ledr_out = 0;
	(* useioff = 1, chip_pin = "H9, H8, B6, A5, E9, D8, K6, L7" *)
	output reg [7:0] ledg_out = 0;
	(* useioff = 1, chip_pin = "Y18, Y19, Y20, W18, V17, V18, V19" *)
	output reg [6:0] hex0_out = 127;
	(* useioff = 1, chip_pin = "AF24, AC19, AE25, AE26, AB19, AD26, AA18" *)
	output reg [6:0] hex1_out = 127;
	reg [6:0] hex2_out = 127;
	(* useioff = 1, chip_pin = "AC22, AC23, AC24, AA22, AA23, Y23, Y24" *)
	output reg [6:0] hex3_out = 127;
	(* useioff = 1, chip_pin = "AD25, AC25, AB25, AA24, AB26, R26, R24, P21" *)
	output reg [7:0] hdmi_r_out = 0;
	(* useioff = 1, chip_pin = "P26, N25, P23, P22, R25, R23, T26, T24" *)
	output reg [7:0] hdmi_g_out = 0;
	(* useioff = 1, chip_pin = "T23, U24, V25, V24, W26, W25, AA26, V23" *)
	output reg [7:0] hdmi_b_out = 0;
	(* useioff = 1, chip_pin = "Y25" *)
	output hdmi_clk_out;
	(* useioff = 1, chip_pin = "Y26" *)
	output reg hdmi_de_out = 0;
	(* useioff = 1, chip_pin = "U26" *)
	output reg hdmi_hs_out = 0;
	(* useioff = 1, chip_pin = "U25" *)
	output reg hdmi_vs_out = 0;
	(* useioff = 1, chip_pin = "T12" *)
	input hdmi_int_in;
	(* useioff = 1, chip_pin = "B7" *)
	output reg hdmi_scl_out = 1;
	(* useioff = 1, chip_pin = "G11" *)
	output reg hdmi_sda_out = 1;
	(* useioff = 1, chip_pin = "W20, W21, V20, V22, U20, AD6, AD7" *)
	inout [6:0] hex2_inout;
	reg cam_active = 1;
	(* useioff = 1, chip_pin = "AA6" *)
	output reg cam_xclk_out = 0;
	(* useioff = 1, chip_pin = "G26, Y8, F26, Y9, R9, R10, P8, R8" *)
	input [7:0] cam_d_in;
	(* useioff = 1, chip_pin = "U19" *)
	output cam_reset_out = 1'bz;
	(* useioff = 1, chip_pin = "U22" *)
	output cam_pwdn_out = 1'bz;
	(* useioff = 1, chip_pin = "AA7" *)
	input cam_href_in;
	(* useioff = 1, chip_pin = "M24, N24, J26, J25, F22, E21, F21, G20, E23, D22, J21, J20, C25, D25, H20, H19, B26, B25" *)
	output [17:0] sram_a_out;
	(* useioff = 1, chip_pin = "K21, L22, G22, F23, J23, H22, H24, H23, L24, L23, G24, F24, K23, K24, E25, E24" *)
	inout [15:0] sram_d_inout;
	(* useioff = 1, chip_pin = "N23" *)
	output sram_ce_n_out = 0;
	(* useioff = 1, chip_pin = "M22" *)
	output reg sram_oe_n_out = 1;
	(* useioff = 1, chip_pin = "G25" *)
	output sram_we_n_out;
	(* useioff = 1, chip_pin = "M25, H25" *)
	output [1:0] sram_be_n_out = 0;
	reg [32:0] p_io$0;
	reg [32:0] d_io$0;
	wire [32:0] q_io$0;
	reg [4:0] key$0 = 0;
	reg [9:0] sw$0 = 0;
	always @(posedge clk) begin
		if (p_io$0[0]) ledg_out <= d_io$0[0+:8];
		if (p_io$0[1]) ledr_out <= d_io$0[0+:10];
		if (p_io$0[2]) hex0_out <= ~d_io$0[0+:7];
		if (p_io$0[3]) hex1_out <= ~d_io$0[0+:7];
		if (p_io$0[4]) hex2_out <= ~d_io$0[0+:7];
		if (p_io$0[5]) hex3_out <= ~d_io$0[0+:7];
		key$0 <= key_in;
		sw$0 <= sw_in;
	end
	assign q_io$0 = {18'd0, ~key$0[4], sw$0, ~key$0[3:0]};
	reg [32:0] p_io$1;
	reg [32:0] d_io$1;
	wire [32:0] q_io$1;
	wire jtag_tck$0;
	wire jtag_cir$0;
	wire jtag_uir$0;
	wire jtag_sdr$0;
	wire [31:0] jtag_d$0;
	reg [31:0] jtag_ir$0 = 0;
	reg [31:0] ir$0 = 0;
	always @(posedge jtag_tck$0) begin
		if (jtag_cir$0) jtag_ir$0 <= ir$0;
		else if (jtag_sdr$0) jtag_ir$0 <= {1'd0, jtag_ir$0[31:1]};
	end
	sld_virtual_jtag #(
		.sld_instance_index(1),
		.sld_ir_width(32)
	) sld_virtual_jtag$0(
		.tck(jtag_tck$0),
		.tdi(),
		.ir_in(jtag_d$0),
		.tdo(jtag_ir$0[0]),
		.ir_out(0),
		.virtual_state_cdr(),
		.virtual_state_sdr(),
		.virtual_state_e1dr(),
		.virtual_state_pdr(),
		.virtual_state_e2dr(),
		.virtual_state_udr(),
		.virtual_state_cir(jtag_cir$0),
		.virtual_state_uir(jtag_uir$0),
		.tms(),
		.jtag_state_tlr(),
		.jtag_state_rti(),
		.jtag_state_sdrs(),
		.jtag_state_cdr(),
		.jtag_state_sdr(jtag_sdr$0),
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
	reg [2:0] we$0 = 0;
	always @(posedge clk) begin
		if (p_io$1[32]) ir$0 <= p_io$1[0+:32];
		we$0 <= {we$0[1:0], jtag_uir$0};
	end
	reg empty$0 = 1;
	wire _fifo__re$0 = ~empty$0 & p_io$1[32];
	reg [5:0] _fifo__ra$0 = 0;
	wire [5:0] _fifo__ra_next$0 = _fifo__ra$0 + {5'd0, _fifo__re$0};
	reg _fifo__full$0 = 0;
	wire full$0 = _fifo__full$0 & ~p_io$1[32];
	wire _fifo__we$0 = ~full$0 & (we$0[2:1] == 2'b10);
	reg [5:0] _fifo__wa$0 = 0;
	wire [5:0] _fifo__wa_next$0 = _fifo__wa$0 + {5'd0, _fifo__we$0};
	(* ramstyle = "MLAB" *)
	reg [31:0] _fifo__mem$0 [0:31];
	wire [31:0] _fifo__d$0 = jtag_d$0;
	reg [31:0] q$0 = 0;
	always @(posedge clk) begin
		if (_fifo__we$0) _fifo__mem$0[_fifo__wa$0[4:0]] <= _fifo__d$0;
		q$0 <= _fifo__mem$0[_fifo__ra_next$0[4:0]];
		if (_fifo__ra_next$0[4:0] != _fifo__wa_next$0[4:0]) begin
			empty$0 <= _fifo__we$0 & (_fifo__ra_next$0[4:0] == _fifo__wa$0[4:0]);
			_fifo__full$0 <= 0;
			end
		else if (_fifo__ra_next$0[5] == _fifo__wa_next$0[5]) begin
			empty$0 <= 1;
			_fifo__full$0 <= 0;
			end
		else begin
			empty$0 <= 0;
			_fifo__full$0 <= 1;
		end
		_fifo__ra$0 <= _fifo__ra_next$0;
		_fifo__wa$0 <= _fifo__wa_next$0;
	end
	assign q_io$1 = {empty$0, q$0};
	reg [32:0] p_io$2;
	reg [32:0] d_io$2;
	wire [32:0] q_io$2;
	reg [10:0] vga_count$0 = 0;
	assign hdmi_clk_out = vga_count$0[0];
	wire vga_re$0 = vga_count$0 == 11'd1;
	reg [31:0] vga_rgb$0 = 0;
	reg empty$1 = 1;
	wire _fifo__re$1 = ~empty$1 & vga_re$0;
	reg [8:0] _fifo__ra$1 = 0;
	wire [8:0] _fifo__ra_next$1 = _fifo__ra$1 + {8'd0, _fifo__re$1};
	reg _fifo__full$1 = 0;
	wire full$1 = _fifo__full$1 & ~vga_re$0;
	wire _fifo__we$1 = ~full$1 & p_io$2[32];
	reg [8:0] _fifo__wa$1 = 0;
	wire [8:0] _fifo__wa_next$1 = _fifo__wa$1 + {8'd0, _fifo__we$1};
	(* ramstyle = "M10K" *)
	reg [39:0] _fifo__mem$1 [0:255];
	wire [39:0] _fifo__d$1 = {d_io$2[9:2], p_io$2[0+:32]};
	reg [39:0] q$1 = 0;
	always @(posedge clk) begin
		if (_fifo__we$1) _fifo__mem$1[_fifo__wa$1[7:0]] <= _fifo__d$1;
		q$1 <= _fifo__mem$1[_fifo__ra_next$1[7:0]];
		if (_fifo__ra_next$1[7:0] != _fifo__wa_next$1[7:0]) begin
			empty$1 <= _fifo__we$1 & (_fifo__ra_next$1[7:0] == _fifo__wa$1[7:0]);
			_fifo__full$1 <= 0;
			end
		else if (_fifo__ra_next$1[8] == _fifo__wa_next$1[8]) begin
			empty$1 <= 1;
			_fifo__full$1 <= 0;
			end
		else begin
			empty$1 <= 0;
			_fifo__full$1 <= 1;
		end
		_fifo__ra$1 <= _fifo__ra_next$1;
		_fifo__wa$1 <= _fifo__wa_next$1;
	end
	always @(posedge clk) begin
		if (vga_re$0) begin
			hdmi_de_out = q$1[32];
			hdmi_hs_out = q$1[32] | ~q$1[0];
			hdmi_vs_out = q$1[32] | ~q$1[1];
			vga_rgb$0 = {q$1[2+:30], q$1[1:0] & {2{q$1[32]}}};
			vga_count$0 = {q$1[39-:8], 3'd0};
			end
		else begin
			if (vga_count$0[0]) begin
				vga_rgb$0 = vga_rgb$0 << 8;
			end
			vga_count$0 = vga_count$0 - 11'd1;
		end
		case (vga_rgb$0[31:29])
			3'd0: begin
				hdmi_r_out = 8'd0;
				end
			3'd1: begin
				hdmi_r_out = 8'd99;
				end
			3'd2: begin
				hdmi_r_out = 8'd116;
				end
			3'd3: begin
				hdmi_r_out = 8'd136;
				end
			3'd4: begin
				hdmi_r_out = 8'd159;
				end
			3'd5: begin
				hdmi_r_out = 8'd186;
				end
			3'd6: begin
				hdmi_r_out = 8'd218;
				end
			default begin
				hdmi_r_out = 8'd255;
			end
		endcase
		case (vga_rgb$0[28:26])
			3'd0: begin
				hdmi_g_out = 8'd0;
				end
			3'd1: begin
				hdmi_g_out = 8'd99;
				end
			3'd2: begin
				hdmi_g_out = 8'd116;
				end
			3'd3: begin
				hdmi_g_out = 8'd136;
				end
			3'd4: begin
				hdmi_g_out = 8'd159;
				end
			3'd5: begin
				hdmi_g_out = 8'd186;
				end
			3'd6: begin
				hdmi_g_out = 8'd218;
				end
			default begin
				hdmi_g_out = 8'd255;
			end
		endcase
		case (vga_rgb$0[25:24])
			2'd0: begin
				hdmi_b_out = 8'd0;
				end
			2'd1: begin
				hdmi_b_out = 8'd136;
				end
			2'd2: begin
				hdmi_b_out = 8'd186;
				end
			default begin
				hdmi_b_out = 8'd255;
			end
		endcase
	end
	assign q_io$2 = {full$1, 32'd4};
	reg [32:0] p_io$3;
	reg [32:0] d_io$3;
	wire [32:0] q_io$3;
	reg [6:0] mix_out$0 = 7'bzzz11zz;
	assign hex2_inout = mix_out$0;
	always @(posedge clk) begin
		if (p_io$3[32]) begin
			hdmi_scl_out <= p_io$3[0];
			hdmi_sda_out <= p_io$3[1] ? 1'bz : p_io$3[31] | d_io$3[31];
		end
		if (cam_active) begin
			mix_out$0[6:4] <= 3'bzzz;
			mix_out$0[1:0] <= 2'bzz;
			if (p_io$3[32]) begin
				mix_out$0[2] <= p_io$3[0];
				mix_out$0[3] <= p_io$3[1] ? 1'bz : p_io$3[31] | d_io$3[31];
				end
			end
		else begin
			mix_out$0 <= hex2_out;
		end
	end
	assign q_io$3 = 33'd3;
	reg [32:0] p_io$4;
	reg [32:0] d_io$4;
	wire [32:0] q_io$4;
	reg [32:0] cam_q$0 = 0;
	reg [32:0] cam_q_io$0 = 0;
	assign q_io$4 = cam_q_io$0;
	always @(posedge clk) begin
		cam_xclk_out <= ~cam_xclk_out;
		cam_q_io$0 <= cam_q$0;
		if (p_io$4[32]) begin
			cam_active <= p_io$4[0];
		end
	end
	reg [24:0] cam_d$0 = 0;
	always @(posedge hex2_inout[1]) begin
		if (cam_href_in) begin
			if (cam_d$0[24]) begin
				cam_q$0 <= {1'd0, cam_d$0[23:0], cam_d_in};
				cam_d$0 <= 25'd1;
				end
			else begin
				cam_d$0 <= {cam_d$0[16:0], cam_d_in};
				end
			end
		else begin
			cam_q$0[32] <= 1'd1;
			cam_q$0[31] <= hex2_inout[0];
		end
	end
	reg [32:0] p_io$5;
	reg [32:0] d_io$5;
	wire [32:0] q_io$5;
	reg sram_we$0 = 0;
	assign sram_we_n_out = ~(sram_we$0 & clk);
	reg [17:0] sram_wa$0 = 0;
	assign sram_a_out = sram_we$0 ? sram_wa$0 : d_io$5[17:0];
	reg [15:0] sram_d$0 = 0;
	assign sram_d_inout = ~(sram_we$0 & clk) ? 16'hzzzz : sram_d$0;
	always @(posedge clk) begin
		sram_oe_n_out <= p_io$5[0];
		sram_we$0 <= p_io$5[0];
		sram_wa$0 <= {p_io$5[15:1] + d_io$5[31:21], d_io$5[20:18]};
		sram_d$0 <= p_io$5[31:16];
	end
	assign q_io$5 = {sram_we$0, sram_d_inout, 16'd0};
	reg [32:0] p_io$6;
	reg [32:0] d_io$6;
	wire [32:0] q_io$6;
	reg empty$2 = 1;
	wire _fifo__re$2 = ~empty$2 & p_io$6[0];
	reg [10:0] _fifo__ra$2 = 0;
	wire [10:0] _fifo__ra_next$2 = _fifo__ra$2 + {10'd0, _fifo__re$2};
	reg _fifo__full$2 = 0;
	wire full$2 = _fifo__full$2 & ~p_io$6[0];
	wire _fifo__we$2 = ~full$2 & p_io$6[1];
	reg [10:0] _fifo__wa$2 = 0;
	wire [10:0] _fifo__wa_next$2 = _fifo__wa$2 + {10'd0, _fifo__we$2};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$2 [0:1023];
	wire [31:0] _fifo__d$2 = d_io$6[0+:32];
	reg [31:0] q$2 = 0;
	always @(posedge clk) begin
		if (_fifo__we$2) _fifo__mem$2[_fifo__wa$2[9:0]] <= _fifo__d$2;
		q$2 <= _fifo__mem$2[_fifo__ra_next$2[9:0]];
		if (_fifo__ra_next$2[9:0] != _fifo__wa_next$2[9:0]) begin
			empty$2 <= _fifo__we$2 & (_fifo__ra_next$2[9:0] == _fifo__wa$2[9:0]);
			_fifo__full$2 <= 0;
			end
		else if (_fifo__ra_next$2[10] == _fifo__wa_next$2[10]) begin
			empty$2 <= 1;
			_fifo__full$2 <= 0;
			end
		else begin
			empty$2 <= 0;
			_fifo__full$2 <= 1;
		end
		_fifo__ra$2 <= _fifo__ra_next$2;
		_fifo__wa$2 <= _fifo__wa_next$2;
	end
	assign q_io$6[32-:2] = (full$2 & p_io$6[1]) ? 2'd3 : empty$2 ? 2'd2 : {1'd0, q$2[31]};
	assign q_io$6[30:0] = q$2[30:0];
	reg [32:0] p_io$7;
	reg [32:0] d_io$7;
	wire [32:0] q_io$7;
	reg empty$3 = 1;
	wire _fifo__re$3 = ~empty$3 & p_io$7[0];
	reg [10:0] _fifo__ra$3 = 0;
	wire [10:0] _fifo__ra_next$3 = _fifo__ra$3 + {10'd0, _fifo__re$3};
	reg _fifo__full$3 = 0;
	wire full$3 = _fifo__full$3 & ~p_io$7[0];
	wire _fifo__we$3 = ~full$3 & p_io$7[1];
	reg [10:0] _fifo__wa$3 = 0;
	wire [10:0] _fifo__wa_next$3 = _fifo__wa$3 + {10'd0, _fifo__we$3};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$3 [0:1023];
	wire [31:0] _fifo__d$3 = d_io$7[0+:32];
	reg [31:0] q$3 = 0;
	always @(posedge clk) begin
		if (_fifo__we$3) _fifo__mem$3[_fifo__wa$3[9:0]] <= _fifo__d$3;
		q$3 <= _fifo__mem$3[_fifo__ra_next$3[9:0]];
		if (_fifo__ra_next$3[9:0] != _fifo__wa_next$3[9:0]) begin
			empty$3 <= _fifo__we$3 & (_fifo__ra_next$3[9:0] == _fifo__wa$3[9:0]);
			_fifo__full$3 <= 0;
			end
		else if (_fifo__ra_next$3[10] == _fifo__wa_next$3[10]) begin
			empty$3 <= 1;
			_fifo__full$3 <= 0;
			end
		else begin
			empty$3 <= 0;
			_fifo__full$3 <= 1;
		end
		_fifo__ra$3 <= _fifo__ra_next$3;
		_fifo__wa$3 <= _fifo__wa_next$3;
	end
	assign q_io$7[32-:2] = (full$3 & p_io$7[1]) ? 2'd3 : empty$3 ? 2'd2 : {1'd0, q$3[31]};
	assign q_io$7[30:0] = q$3[30:0];
	reg [32:0] p_io$8;
	reg [32:0] d_io$8;
	wire [32:0] q_io$8;
	reg empty$4 = 1;
	wire _fifo__re$4 = ~empty$4 & p_io$8[0];
	reg [10:0] _fifo__ra$4 = 0;
	wire [10:0] _fifo__ra_next$4 = _fifo__ra$4 + {10'd0, _fifo__re$4};
	reg _fifo__full$4 = 0;
	wire full$4 = _fifo__full$4 & ~p_io$8[0];
	wire _fifo__we$4 = ~full$4 & p_io$8[1];
	reg [10:0] _fifo__wa$4 = 0;
	wire [10:0] _fifo__wa_next$4 = _fifo__wa$4 + {10'd0, _fifo__we$4};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$4 [0:1023];
	wire [31:0] _fifo__d$4 = d_io$8[0+:32];
	reg [31:0] q$4 = 0;
	always @(posedge clk) begin
		if (_fifo__we$4) _fifo__mem$4[_fifo__wa$4[9:0]] <= _fifo__d$4;
		q$4 <= _fifo__mem$4[_fifo__ra_next$4[9:0]];
		if (_fifo__ra_next$4[9:0] != _fifo__wa_next$4[9:0]) begin
			empty$4 <= _fifo__we$4 & (_fifo__ra_next$4[9:0] == _fifo__wa$4[9:0]);
			_fifo__full$4 <= 0;
			end
		else if (_fifo__ra_next$4[10] == _fifo__wa_next$4[10]) begin
			empty$4 <= 1;
			_fifo__full$4 <= 0;
			end
		else begin
			empty$4 <= 0;
			_fifo__full$4 <= 1;
		end
		_fifo__ra$4 <= _fifo__ra_next$4;
		_fifo__wa$4 <= _fifo__wa_next$4;
	end
	assign q_io$8[32-:2] = (full$4 & p_io$8[1]) ? 2'd3 : empty$4 ? 2'd2 : {1'd0, q$4[31]};
	assign q_io$8[30:0] = q$4[30:0];
	reg [32:0] p_io$9;
	reg [32:0] d_io$9;
	wire [32:0] q_io$9;
	reg empty$5 = 1;
	wire _fifo__re$5 = ~empty$5 & p_io$9[0];
	reg [10:0] _fifo__ra$5 = 0;
	wire [10:0] _fifo__ra_next$5 = _fifo__ra$5 + {10'd0, _fifo__re$5};
	reg _fifo__full$5 = 0;
	wire full$5 = _fifo__full$5 & ~p_io$9[0];
	wire _fifo__we$5 = ~full$5 & p_io$9[1];
	reg [10:0] _fifo__wa$5 = 0;
	wire [10:0] _fifo__wa_next$5 = _fifo__wa$5 + {10'd0, _fifo__we$5};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$5 [0:1023];
	wire [31:0] _fifo__d$5 = d_io$9[0+:32];
	reg [31:0] q$5 = 0;
	always @(posedge clk) begin
		if (_fifo__we$5) _fifo__mem$5[_fifo__wa$5[9:0]] <= _fifo__d$5;
		q$5 <= _fifo__mem$5[_fifo__ra_next$5[9:0]];
		if (_fifo__ra_next$5[9:0] != _fifo__wa_next$5[9:0]) begin
			empty$5 <= _fifo__we$5 & (_fifo__ra_next$5[9:0] == _fifo__wa$5[9:0]);
			_fifo__full$5 <= 0;
			end
		else if (_fifo__ra_next$5[10] == _fifo__wa_next$5[10]) begin
			empty$5 <= 1;
			_fifo__full$5 <= 0;
			end
		else begin
			empty$5 <= 0;
			_fifo__full$5 <= 1;
		end
		_fifo__ra$5 <= _fifo__ra_next$5;
		_fifo__wa$5 <= _fifo__wa_next$5;
	end
	assign q_io$9[32-:2] = (full$5 & p_io$9[1]) ? 2'd3 : empty$5 ? 2'd2 : {1'd0, q$5[31]};
	assign q_io$9[30:0] = q$5[30:0];
	reg [32:0] p_io$10;
	reg [32:0] d_io$10;
	wire [32:0] q_io$10;
	reg empty$6 = 1;
	wire _fifo__re$6 = ~empty$6 & p_io$10[0];
	reg [10:0] _fifo__ra$6 = 0;
	wire [10:0] _fifo__ra_next$6 = _fifo__ra$6 + {10'd0, _fifo__re$6};
	reg _fifo__full$6 = 0;
	wire full$6 = _fifo__full$6 & ~p_io$10[0];
	wire _fifo__we$6 = ~full$6 & p_io$10[1];
	reg [10:0] _fifo__wa$6 = 0;
	wire [10:0] _fifo__wa_next$6 = _fifo__wa$6 + {10'd0, _fifo__we$6};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$6 [0:1023];
	wire [31:0] _fifo__d$6 = d_io$10[0+:32];
	reg [31:0] q$6 = 0;
	always @(posedge clk) begin
		if (_fifo__we$6) _fifo__mem$6[_fifo__wa$6[9:0]] <= _fifo__d$6;
		q$6 <= _fifo__mem$6[_fifo__ra_next$6[9:0]];
		if (_fifo__ra_next$6[9:0] != _fifo__wa_next$6[9:0]) begin
			empty$6 <= _fifo__we$6 & (_fifo__ra_next$6[9:0] == _fifo__wa$6[9:0]);
			_fifo__full$6 <= 0;
			end
		else if (_fifo__ra_next$6[10] == _fifo__wa_next$6[10]) begin
			empty$6 <= 1;
			_fifo__full$6 <= 0;
			end
		else begin
			empty$6 <= 0;
			_fifo__full$6 <= 1;
		end
		_fifo__ra$6 <= _fifo__ra_next$6;
		_fifo__wa$6 <= _fifo__wa_next$6;
	end
	assign q_io$10[32-:2] = (full$6 & p_io$10[1]) ? 2'd3 : empty$6 ? 2'd2 : {1'd0, q$6[31]};
	assign q_io$10[30:0] = q$6[30:0];
	reg [32:0] p_io$11;
	reg [32:0] d_io$11;
	wire [32:0] q_io$11;
	reg empty$7 = 1;
	wire _fifo__re$7 = ~empty$7 & p_io$11[0];
	reg [10:0] _fifo__ra$7 = 0;
	wire [10:0] _fifo__ra_next$7 = _fifo__ra$7 + {10'd0, _fifo__re$7};
	reg _fifo__full$7 = 0;
	wire full$7 = _fifo__full$7 & ~p_io$11[0];
	wire _fifo__we$7 = ~full$7 & p_io$11[1];
	reg [10:0] _fifo__wa$7 = 0;
	wire [10:0] _fifo__wa_next$7 = _fifo__wa$7 + {10'd0, _fifo__we$7};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$7 [0:1023];
	wire [31:0] _fifo__d$7 = d_io$11[0+:32];
	reg [31:0] q$7 = 0;
	always @(posedge clk) begin
		if (_fifo__we$7) _fifo__mem$7[_fifo__wa$7[9:0]] <= _fifo__d$7;
		q$7 <= _fifo__mem$7[_fifo__ra_next$7[9:0]];
		if (_fifo__ra_next$7[9:0] != _fifo__wa_next$7[9:0]) begin
			empty$7 <= _fifo__we$7 & (_fifo__ra_next$7[9:0] == _fifo__wa$7[9:0]);
			_fifo__full$7 <= 0;
			end
		else if (_fifo__ra_next$7[10] == _fifo__wa_next$7[10]) begin
			empty$7 <= 1;
			_fifo__full$7 <= 0;
			end
		else begin
			empty$7 <= 0;
			_fifo__full$7 <= 1;
		end
		_fifo__ra$7 <= _fifo__ra_next$7;
		_fifo__wa$7 <= _fifo__wa_next$7;
	end
	assign q_io$11[32-:2] = (full$7 & p_io$11[1]) ? 2'd3 : empty$7 ? 2'd2 : {1'd0, q$7[31]};
	assign q_io$11[30:0] = q$7[30:0];
	reg [32:0] p_io$12;
	reg [32:0] d_io$12;
	wire [32:0] q_io$12;
	reg empty$8 = 1;
	wire _fifo__re$8 = ~empty$8 & p_io$12[0];
	reg [10:0] _fifo__ra$8 = 0;
	wire [10:0] _fifo__ra_next$8 = _fifo__ra$8 + {10'd0, _fifo__re$8};
	reg _fifo__full$8 = 0;
	wire full$8 = _fifo__full$8 & ~p_io$12[0];
	wire _fifo__we$8 = ~full$8 & p_io$12[1];
	reg [10:0] _fifo__wa$8 = 0;
	wire [10:0] _fifo__wa_next$8 = _fifo__wa$8 + {10'd0, _fifo__we$8};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$8 [0:1023];
	wire [31:0] _fifo__d$8 = d_io$12[0+:32];
	reg [31:0] q$8 = 0;
	always @(posedge clk) begin
		if (_fifo__we$8) _fifo__mem$8[_fifo__wa$8[9:0]] <= _fifo__d$8;
		q$8 <= _fifo__mem$8[_fifo__ra_next$8[9:0]];
		if (_fifo__ra_next$8[9:0] != _fifo__wa_next$8[9:0]) begin
			empty$8 <= _fifo__we$8 & (_fifo__ra_next$8[9:0] == _fifo__wa$8[9:0]);
			_fifo__full$8 <= 0;
			end
		else if (_fifo__ra_next$8[10] == _fifo__wa_next$8[10]) begin
			empty$8 <= 1;
			_fifo__full$8 <= 0;
			end
		else begin
			empty$8 <= 0;
			_fifo__full$8 <= 1;
		end
		_fifo__ra$8 <= _fifo__ra_next$8;
		_fifo__wa$8 <= _fifo__wa_next$8;
	end
	assign q_io$12[32-:2] = (full$8 & p_io$12[1]) ? 2'd3 : empty$8 ? 2'd2 : {1'd0, q$8[31]};
	assign q_io$12[30:0] = q$8[30:0];
	reg [32:0] p_io$13;
	reg [32:0] d_io$13;
	wire [32:0] q_io$13;
	reg empty$9 = 1;
	wire _fifo__re$9 = ~empty$9 & p_io$13[0];
	reg [10:0] _fifo__ra$9 = 0;
	wire [10:0] _fifo__ra_next$9 = _fifo__ra$9 + {10'd0, _fifo__re$9};
	reg _fifo__full$9 = 0;
	wire full$9 = _fifo__full$9 & ~p_io$13[0];
	wire _fifo__we$9 = ~full$9 & p_io$13[1];
	reg [10:0] _fifo__wa$9 = 0;
	wire [10:0] _fifo__wa_next$9 = _fifo__wa$9 + {10'd0, _fifo__we$9};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$9 [0:1023];
	wire [31:0] _fifo__d$9 = d_io$13[0+:32];
	reg [31:0] q$9 = 0;
	always @(posedge clk) begin
		if (_fifo__we$9) _fifo__mem$9[_fifo__wa$9[9:0]] <= _fifo__d$9;
		q$9 <= _fifo__mem$9[_fifo__ra_next$9[9:0]];
		if (_fifo__ra_next$9[9:0] != _fifo__wa_next$9[9:0]) begin
			empty$9 <= _fifo__we$9 & (_fifo__ra_next$9[9:0] == _fifo__wa$9[9:0]);
			_fifo__full$9 <= 0;
			end
		else if (_fifo__ra_next$9[10] == _fifo__wa_next$9[10]) begin
			empty$9 <= 1;
			_fifo__full$9 <= 0;
			end
		else begin
			empty$9 <= 0;
			_fifo__full$9 <= 1;
		end
		_fifo__ra$9 <= _fifo__ra_next$9;
		_fifo__wa$9 <= _fifo__wa_next$9;
	end
	assign q_io$13[32-:2] = (full$9 & p_io$13[1]) ? 2'd3 : empty$9 ? 2'd2 : {1'd0, q$9[31]};
	assign q_io$13[30:0] = q$9[30:0];
	reg [32:0] p_io$14;
	reg [32:0] d_io$14;
	wire [32:0] q_io$14;
	reg empty$10 = 1;
	wire _fifo__re$10 = ~empty$10 & p_io$14[0];
	reg [10:0] _fifo__ra$10 = 0;
	wire [10:0] _fifo__ra_next$10 = _fifo__ra$10 + {10'd0, _fifo__re$10};
	reg _fifo__full$10 = 0;
	wire full$10 = _fifo__full$10 & ~p_io$14[0];
	wire _fifo__we$10 = ~full$10 & p_io$14[1];
	reg [10:0] _fifo__wa$10 = 0;
	wire [10:0] _fifo__wa_next$10 = _fifo__wa$10 + {10'd0, _fifo__we$10};
	(* ramstyle = "M10K" *)
	reg [31:0] _fifo__mem$10 [0:1023];
	wire [31:0] _fifo__d$10 = d_io$14[0+:32];
	reg [31:0] q$10 = 0;
	always @(posedge clk) begin
		if (_fifo__we$10) _fifo__mem$10[_fifo__wa$10[9:0]] <= _fifo__d$10;
		q$10 <= _fifo__mem$10[_fifo__ra_next$10[9:0]];
		if (_fifo__ra_next$10[9:0] != _fifo__wa_next$10[9:0]) begin
			empty$10 <= _fifo__we$10 & (_fifo__ra_next$10[9:0] == _fifo__wa$10[9:0]);
			_fifo__full$10 <= 0;
			end
		else if (_fifo__ra_next$10[10] == _fifo__wa_next$10[10]) begin
			empty$10 <= 1;
			_fifo__full$10 <= 0;
			end
		else begin
			empty$10 <= 0;
			_fifo__full$10 <= 1;
		end
		_fifo__ra$10 <= _fifo__ra_next$10;
		_fifo__wa$10 <= _fifo__wa_next$10;
	end
	assign q_io$14[32-:2] = (full$10 & p_io$14[1]) ? 2'd3 : empty$10 ? 2'd2 : {1'd0, q$10[31]};
	assign q_io$14[30:0] = q$10[30:0];
	// relm_pe
	localparam [3:0] LOCK = 4'b0010; // 0010xxxx lock
	localparam [2:0] IO = 3'b111; // 111xxxxx io
	localparam [7:0] HALT = 8'b00110110; // 00110110 halt
	localparam [1:0] PUT = 2'b01; // 01xxxxxx put
	wire [32:0] acc_in$0;
	reg [32:0] acc$0 = 0;
	reg [32:0] acc_out$0;
	wire [16:0] pc_in$0;
	reg [16:0] pc$0 = 0;
	reg [16:0] pc_out$0;
	wire [7:0] op$0;
	wire [31:0] y$0;
	wire op_lock$0 = LOCK == op$0[7-:4];
	reg [3:0] lock_timer$0 = 0;
	always @(posedge clk) begin
		acc$0 <= acc_in$0;
		pc$0 <= pc_in$0;
		if (lock_timer$0) lock_timer$0 <= lock_timer$0 - 4'd1;
		else if (op_lock$0) lock_timer$0 <= y$0[0+:4];
	end
	wire retry_lock$0 = |lock_timer$0 & op_lock$0;
	wire [32:0] ax$0 = {op$0[2], {32{op$0[2]}} ^ acc$0[0+:32]};
	wire [32:0] ay$0 = {op$0[1], {32{op$0[1]}} ^ y$0};
	wire [4:0] ye$0 = op$0[0] ? y$0[0+:5] : -y$0[0+:5];
	wire [31:0] ys$0 = {{16{ye$0[4]}}, {16{~ye$0[4]}}} & {2{{{8{ye$0[3]}}, {8{~ye$0[3]}}} & {2{{{4{ye$0[2]}}, {4{~ye$0[2]}}} & {2{{{2{ye$0[1]}}, {2{~ye$0[1]}}} & {2{{ye$0[0], ~ye$0[0]}}}}}}}}};
	wire signed [32:0] mx$0 = {op$0[3] & acc$0[31], acc$0[0+:32]};
	wire signed [32:0] my$0 = op$0[2] ? {1'd0, ys$0} : {op$0[3] & y$0[31], y$0};
	wire signed [65:0] xy$0 = mx$0 * my$0;
	wire op_io$0 = IO == op$0[7-:3];
	wire [15:0] op_en$0 = {{8{op$0[3]}}, {8{~op$0[3]}}} & {2{{{4{op$0[2]}}, {4{~op$0[2]}}} & {2{{{2{op$0[1]}}, {2{~op$0[1]}}} & {2{{op$0[0] & op_io$0, ~op$0[0] & op_io$0}}}}}}};
	reg [32:0] acc_io$0;
	reg retry_io$0;
	wire retry_put$0;
	wire [2:0] opc$0 = acc$0[32] ? op$0[5:3] : op$0[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$0 = acc$0[31] ? opc$0[2] : !acc$0[30:0] ? opc$0[1] : opc$0[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$0;
	wire [31:0] wb_in_d$0;
	wire [7:0] wb_in_op$0;
	wire wb_in_we$0;
	reg [39:0] q$11;
	wire [12:0] _dpmem__wa$0 = wb_in_ad$0;
	wire _dpmem__we$0 = wb_in_we$0;
	wire [39:0] _dpmem__d$0 = {wb_in_d$0, wb_in_op$0};
	wire [12:0] _dpmem__ra$0 = pc_in$0[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$0 [0:6399];
	initial $readmemh("mem00.txt", _dpmem__mem$0);
	always @(posedge clk) begin
		if (_dpmem__we$0) _dpmem__mem$0[_dpmem__wa$0] <= _dpmem__d$0;
		q$11 <= _dpmem__mem$0[_dpmem__ra$0];
	end
	reg [31:0] fwd_y$0 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$0 = HALT;
	reg fwd_en$0 = 1;
	always @(posedge clk) begin
		fwd_y$0 = wb_in_d$0;
		fwd_op$0 = wb_in_op$0;
		fwd_en$0 = wb_in_we$0 & (wb_in_ad$0 == pc_in$0[16-:13]);
		if (pc_in$0[0+:4] != 4'd0) begin
			fwd_op$0 = HALT;
			fwd_en$0 = 1;
		end
	end
	assign y$0 = fwd_en$0 ? fwd_y$0 : q$11[39-:32];
	assign op$0 = fwd_en$0 ? fwd_op$0 : q$11[0+:8];
	wire op_put$0 = PUT == op$0[7-:2];
	wire [15:0] y_en$0 = {{8{y$0[3]}}, {8{~y$0[3]}}} & {2{{{4{y$0[2]}}, {4{~y$0[2]}}} & {2{{{2{y$0[1]}}, {2{~y$0[1]}}} & {2{{y$0[0] & op_put$0, ~y$0[0] & op_put$0}}}}}}};
	wire [12:0] wb_in_ad$1;
	wire [31:0] wb_in_d$1;
	wire [7:0] wb_in_op$1;
	wire wb_in_we$1;
	reg [12:0] wb_ad$0 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$0 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$0 = 8'bxxxxxxxx;
	reg wb_we$0 = 0;
	always @(posedge clk) begin
		wb_ad$0 = wb_in_ad$1;
		wb_d$0 = wb_in_d$1;
		wb_op$0 = wb_in_op$1;
		wb_we$0 = wb_in_we$1;
	end
	wire [12:0] wb_in_ad$2;
	wire [31:0] wb_in_d$2;
	wire [7:0] wb_in_op$2;
	wire wb_in_we$2;
	reg [12:0] wb_ad$1 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$1 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$1 = 8'bxxxxxxxx;
	reg wb_we$1 = 0;
	always @(posedge clk) begin
		wb_ad$1 = wb_in_ad$2;
		wb_d$1 = wb_in_d$2;
		wb_op$1 = wb_in_op$2;
		wb_we$1 = wb_in_we$2;
	end
	wire [12:0] wb_in_ad$3;
	wire [31:0] wb_in_d$3;
	wire [7:0] wb_in_op$3;
	wire wb_in_we$3;
	reg [12:0] wb_ad$2 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$2 = 8'bxxxxxxxx;
	reg wb_we$2 = 0;
	always @(posedge clk) begin
		wb_ad$2 = wb_in_ad$3;
		wb_d$2 = wb_in_d$3;
		wb_op$2 = wb_in_op$3;
		wb_we$2 = wb_in_we$3;
	end
	wire [12:0] wb_in_ad$4;
	wire [31:0] wb_in_d$4;
	wire [7:0] wb_in_op$4;
	wire wb_in_we$4;
	reg [12:0] wb_ad$3 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$3 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$3 = 8'bxxxxxxxx;
	reg wb_we$3 = 0;
	always @(posedge clk) begin
		wb_ad$3 = wb_in_ad$4;
		wb_d$3 = wb_in_d$4;
		wb_op$3 = wb_in_op$4;
		wb_we$3 = wb_in_we$4;
	end
	wire [12:0] wb_in_ad$5;
	wire [31:0] wb_in_d$5;
	wire [7:0] wb_in_op$5;
	wire wb_in_we$5;
	reg [12:0] wb_ad$4 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$4 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$4 = 8'bxxxxxxxx;
	reg wb_we$4 = 0;
	always @(posedge clk) begin
		wb_ad$4 = wb_in_ad$5;
		wb_d$4 = wb_in_d$5;
		wb_op$4 = wb_in_op$5;
		wb_we$4 = wb_in_we$5;
	end
	wire [12:0] wb_in_ad$6;
	wire [31:0] wb_in_d$6;
	wire [7:0] wb_in_op$6;
	wire wb_in_we$6;
	reg [12:0] wb_ad$5 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$5 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$5 = 8'bxxxxxxxx;
	reg wb_we$5 = 0;
	always @(posedge clk) begin
		wb_ad$5 = wb_in_ad$6;
		wb_d$5 = wb_in_d$6;
		wb_op$5 = wb_in_op$6;
		wb_we$5 = wb_in_we$6;
	end
	wire [12:0] wb_in_ad$7;
	wire [31:0] wb_in_d$7;
	wire [7:0] wb_in_op$7;
	wire wb_in_we$7;
	reg [12:0] wb_ad$6 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$6 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$6 = 8'bxxxxxxxx;
	reg wb_we$6 = 0;
	always @(posedge clk) begin
		wb_ad$6 = wb_in_ad$7;
		wb_d$6 = wb_in_d$7;
		wb_op$6 = wb_in_op$7;
		wb_we$6 = wb_in_we$7;
	end
	wire [12:0] wb_in_ad$8;
	wire [31:0] wb_in_d$8;
	wire [7:0] wb_in_op$8;
	wire wb_in_we$8;
	reg [12:0] wb_ad$7 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$7 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$7 = 8'bxxxxxxxx;
	reg wb_we$7 = 0;
	always @(posedge clk) begin
		wb_ad$7 = wb_in_ad$8;
		wb_d$7 = wb_in_d$8;
		wb_op$7 = wb_in_op$8;
		wb_we$7 = wb_in_we$8;
	end
	wire [12:0] wb_in_ad$9;
	wire [31:0] wb_in_d$9;
	wire [7:0] wb_in_op$9;
	wire wb_in_we$9;
	reg [12:0] wb_ad$8 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$8 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$8 = 8'bxxxxxxxx;
	reg wb_we$8 = 0;
	always @(posedge clk) begin
		wb_ad$8 = wb_in_ad$9;
		wb_d$8 = wb_in_d$9;
		wb_op$8 = wb_in_op$9;
		wb_we$8 = wb_in_we$9;
	end
	wire [12:0] wb_in_ad$10;
	wire [31:0] wb_in_d$10;
	wire [7:0] wb_in_op$10;
	wire wb_in_we$10;
	reg [12:0] wb_ad$9 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$9 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$9 = 8'bxxxxxxxx;
	reg wb_we$9 = 0;
	always @(posedge clk) begin
		wb_ad$9 = wb_in_ad$10;
		wb_d$9 = wb_in_d$10;
		wb_op$9 = wb_in_op$10;
		wb_we$9 = wb_in_we$10;
	end
	wire [12:0] wb_in_ad$11;
	wire [31:0] wb_in_d$11;
	wire [7:0] wb_in_op$11;
	wire wb_in_we$11;
	reg [12:0] wb_ad$10 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$10 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$10 = 8'bxxxxxxxx;
	reg wb_we$10 = 0;
	always @(posedge clk) begin
		wb_ad$10 = wb_in_ad$11;
		wb_d$10 = wb_in_d$11;
		wb_op$10 = wb_in_op$11;
		wb_we$10 = wb_in_we$11;
	end
	wire [12:0] wb_in_ad$12;
	wire [31:0] wb_in_d$12;
	wire [7:0] wb_in_op$12;
	wire wb_in_we$12;
	reg [12:0] wb_ad$11 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$11 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$11 = 8'bxxxxxxxx;
	reg wb_we$11 = 0;
	always @(posedge clk) begin
		wb_ad$11 = wb_in_ad$12;
		wb_d$11 = wb_in_d$12;
		wb_op$11 = wb_in_op$12;
		wb_we$11 = wb_in_we$12;
	end
	wire [12:0] wb_in_ad$13;
	wire [31:0] wb_in_d$13;
	wire [7:0] wb_in_op$13;
	wire wb_in_we$13;
	reg [12:0] wb_ad$12 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$12 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$12 = 8'bxxxxxxxx;
	reg wb_we$12 = 0;
	always @(posedge clk) begin
		wb_ad$12 = wb_in_ad$13;
		wb_d$12 = wb_in_d$13;
		wb_op$12 = wb_in_op$13;
		wb_we$12 = wb_in_we$13;
	end
	wire [12:0] wb_in_ad$14;
	wire [31:0] wb_in_d$14;
	wire [7:0] wb_in_op$14;
	wire wb_in_we$14;
	reg [12:0] wb_ad$13 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$13 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$13 = 8'bxxxxxxxx;
	reg wb_we$13 = 0;
	always @(posedge clk) begin
		wb_ad$13 = wb_in_ad$14;
		wb_d$13 = wb_in_d$14;
		wb_op$13 = wb_in_op$14;
		wb_we$13 = wb_in_we$14;
	end
	wire [12:0] wb_in_ad$15;
	wire [31:0] wb_in_d$15;
	wire [7:0] wb_in_op$15;
	wire wb_in_we$15;
	reg [12:0] wb_ad$14 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$14 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$14 = 8'bxxxxxxxx;
	reg wb_we$14 = 0;
	always @(posedge clk) begin
		wb_ad$14 = wb_in_ad$15;
		wb_d$14 = wb_in_d$15;
		wb_op$14 = wb_in_op$15;
		wb_we$14 = wb_in_we$15;
	end
	assign retry_put$0 = (y_en$0[1] & wb_we$0) | (y_en$0[2] & wb_we$1) | (y_en$0[3] & wb_we$2) | (y_en$0[4] & wb_we$3) | (y_en$0[5] & wb_we$4) | (y_en$0[6] & wb_we$5) | (y_en$0[7] & wb_we$6) | (y_en$0[8] & wb_we$7) | (y_en$0[9] & wb_we$8) | (y_en$0[10] & wb_we$9) | (y_en$0[11] & wb_we$10) | (y_en$0[12] & wb_we$11) | (y_en$0[13] & wb_we$12) | (y_en$0[14] & wb_we$13) | (y_en$0[15] & wb_we$14);
	wire [32:0] acc_in$1;
	reg [32:0] acc$1 = 0;
	reg [32:0] acc_out$1;
	wire [16:0] pc_in$1;
	reg [16:0] pc$1 = 1;
	reg [16:0] pc_out$1;
	wire [7:0] op$1;
	wire [31:0] y$1;
	wire op_lock$1 = LOCK == op$1[7-:4];
	reg [3:0] lock_timer$1 = 0;
	always @(posedge clk) begin
		acc$1 <= acc_in$1;
		pc$1 <= pc_in$1;
		if (lock_timer$1) lock_timer$1 <= lock_timer$1 - 4'd1;
		else if (op_lock$1) lock_timer$1 <= y$1[0+:4];
	end
	wire retry_lock$1 = |lock_timer$1 & op_lock$1;
	wire [32:0] ax$1 = {op$1[2], {32{op$1[2]}} ^ acc$1[0+:32]};
	wire [32:0] ay$1 = {op$1[1], {32{op$1[1]}} ^ y$1};
	wire [4:0] ye$1 = op$1[0] ? y$1[0+:5] : -y$1[0+:5];
	wire [31:0] ys$1 = {{16{ye$1[4]}}, {16{~ye$1[4]}}} & {2{{{8{ye$1[3]}}, {8{~ye$1[3]}}} & {2{{{4{ye$1[2]}}, {4{~ye$1[2]}}} & {2{{{2{ye$1[1]}}, {2{~ye$1[1]}}} & {2{{ye$1[0], ~ye$1[0]}}}}}}}}};
	wire signed [32:0] mx$1 = {op$1[3] & acc$1[31], acc$1[0+:32]};
	wire signed [32:0] my$1 = op$1[2] ? {1'd0, ys$1} : {op$1[3] & y$1[31], y$1};
	wire signed [65:0] xy$1 = mx$1 * my$1;
	wire op_io$1 = IO == op$1[7-:3];
	wire [15:0] op_en$1 = {{8{op$1[3]}}, {8{~op$1[3]}}} & {2{{{4{op$1[2]}}, {4{~op$1[2]}}} & {2{{{2{op$1[1]}}, {2{~op$1[1]}}} & {2{{op$1[0] & op_io$1, ~op$1[0] & op_io$1}}}}}}};
	reg [32:0] acc_io$1;
	reg retry_io$1;
	wire retry_put$1;
	wire [2:0] opc$1 = acc$1[32] ? op$1[5:3] : op$1[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$1 = acc$1[31] ? opc$1[2] : !acc$1[30:0] ? opc$1[1] : opc$1[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$16;
	wire [31:0] wb_in_d$16;
	wire [7:0] wb_in_op$16;
	wire wb_in_we$16;
	reg [39:0] q$12;
	wire [12:0] _dpmem__wa$1 = wb_in_ad$16;
	wire _dpmem__we$1 = wb_in_we$16;
	wire [39:0] _dpmem__d$1 = {wb_in_d$16, wb_in_op$16};
	wire [12:0] _dpmem__ra$1 = pc_in$1[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$1 [0:6399];
	initial $readmemh("mem01.txt", _dpmem__mem$1);
	always @(posedge clk) begin
		if (_dpmem__we$1) _dpmem__mem$1[_dpmem__wa$1] <= _dpmem__d$1;
		q$12 <= _dpmem__mem$1[_dpmem__ra$1];
	end
	reg [31:0] fwd_y$1 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$1 = HALT;
	reg fwd_en$1 = 1;
	always @(posedge clk) begin
		fwd_y$1 = wb_in_d$16;
		fwd_op$1 = wb_in_op$16;
		fwd_en$1 = wb_in_we$16 & (wb_in_ad$16 == pc_in$1[16-:13]);
		if (pc_in$1[0+:4] != 4'd1) begin
			fwd_op$1 = HALT;
			fwd_en$1 = 1;
		end
	end
	assign y$1 = fwd_en$1 ? fwd_y$1 : q$12[39-:32];
	assign op$1 = fwd_en$1 ? fwd_op$1 : q$12[0+:8];
	wire op_put$1 = PUT == op$1[7-:2];
	wire [15:0] y_en$1 = {{8{y$1[3]}}, {8{~y$1[3]}}} & {2{{{4{y$1[2]}}, {4{~y$1[2]}}} & {2{{{2{y$1[1]}}, {2{~y$1[1]}}} & {2{{y$1[0] & op_put$1, ~y$1[0] & op_put$1}}}}}}};
	wire [12:0] wb_in_ad$17;
	wire [31:0] wb_in_d$17;
	wire [7:0] wb_in_op$17;
	wire wb_in_we$17;
	reg [12:0] wb_ad$15 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$15 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$15 = 8'bxxxxxxxx;
	reg wb_we$15 = 0;
	always @(posedge clk) begin
		wb_ad$15 = wb_in_ad$17;
		wb_d$15 = wb_in_d$17;
		wb_op$15 = wb_in_op$17;
		wb_we$15 = wb_in_we$17;
	end
	wire [12:0] wb_in_ad$18;
	wire [31:0] wb_in_d$18;
	wire [7:0] wb_in_op$18;
	wire wb_in_we$18;
	reg [12:0] wb_ad$16 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$16 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$16 = 8'bxxxxxxxx;
	reg wb_we$16 = 0;
	always @(posedge clk) begin
		wb_ad$16 = wb_in_ad$18;
		wb_d$16 = wb_in_d$18;
		wb_op$16 = wb_in_op$18;
		wb_we$16 = wb_in_we$18;
	end
	wire [12:0] wb_in_ad$19;
	wire [31:0] wb_in_d$19;
	wire [7:0] wb_in_op$19;
	wire wb_in_we$19;
	reg [12:0] wb_ad$17 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$17 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$17 = 8'bxxxxxxxx;
	reg wb_we$17 = 0;
	always @(posedge clk) begin
		wb_ad$17 = wb_in_ad$19;
		wb_d$17 = wb_in_d$19;
		wb_op$17 = wb_in_op$19;
		wb_we$17 = wb_in_we$19;
	end
	wire [12:0] wb_in_ad$20;
	wire [31:0] wb_in_d$20;
	wire [7:0] wb_in_op$20;
	wire wb_in_we$20;
	reg [12:0] wb_ad$18 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$18 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$18 = 8'bxxxxxxxx;
	reg wb_we$18 = 0;
	always @(posedge clk) begin
		wb_ad$18 = wb_in_ad$20;
		wb_d$18 = wb_in_d$20;
		wb_op$18 = wb_in_op$20;
		wb_we$18 = wb_in_we$20;
	end
	wire [12:0] wb_in_ad$21;
	wire [31:0] wb_in_d$21;
	wire [7:0] wb_in_op$21;
	wire wb_in_we$21;
	reg [12:0] wb_ad$19 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$19 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$19 = 8'bxxxxxxxx;
	reg wb_we$19 = 0;
	always @(posedge clk) begin
		wb_ad$19 = wb_in_ad$21;
		wb_d$19 = wb_in_d$21;
		wb_op$19 = wb_in_op$21;
		wb_we$19 = wb_in_we$21;
	end
	wire [12:0] wb_in_ad$22;
	wire [31:0] wb_in_d$22;
	wire [7:0] wb_in_op$22;
	wire wb_in_we$22;
	reg [12:0] wb_ad$20 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$20 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$20 = 8'bxxxxxxxx;
	reg wb_we$20 = 0;
	always @(posedge clk) begin
		wb_ad$20 = wb_in_ad$22;
		wb_d$20 = wb_in_d$22;
		wb_op$20 = wb_in_op$22;
		wb_we$20 = wb_in_we$22;
	end
	wire [12:0] wb_in_ad$23;
	wire [31:0] wb_in_d$23;
	wire [7:0] wb_in_op$23;
	wire wb_in_we$23;
	reg [12:0] wb_ad$21 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$21 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$21 = 8'bxxxxxxxx;
	reg wb_we$21 = 0;
	always @(posedge clk) begin
		wb_ad$21 = wb_in_ad$23;
		wb_d$21 = wb_in_d$23;
		wb_op$21 = wb_in_op$23;
		wb_we$21 = wb_in_we$23;
	end
	wire [12:0] wb_in_ad$24;
	wire [31:0] wb_in_d$24;
	wire [7:0] wb_in_op$24;
	wire wb_in_we$24;
	reg [12:0] wb_ad$22 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$22 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$22 = 8'bxxxxxxxx;
	reg wb_we$22 = 0;
	always @(posedge clk) begin
		wb_ad$22 = wb_in_ad$24;
		wb_d$22 = wb_in_d$24;
		wb_op$22 = wb_in_op$24;
		wb_we$22 = wb_in_we$24;
	end
	wire [12:0] wb_in_ad$25;
	wire [31:0] wb_in_d$25;
	wire [7:0] wb_in_op$25;
	wire wb_in_we$25;
	reg [12:0] wb_ad$23 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$23 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$23 = 8'bxxxxxxxx;
	reg wb_we$23 = 0;
	always @(posedge clk) begin
		wb_ad$23 = wb_in_ad$25;
		wb_d$23 = wb_in_d$25;
		wb_op$23 = wb_in_op$25;
		wb_we$23 = wb_in_we$25;
	end
	wire [12:0] wb_in_ad$26;
	wire [31:0] wb_in_d$26;
	wire [7:0] wb_in_op$26;
	wire wb_in_we$26;
	reg [12:0] wb_ad$24 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$24 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$24 = 8'bxxxxxxxx;
	reg wb_we$24 = 0;
	always @(posedge clk) begin
		wb_ad$24 = wb_in_ad$26;
		wb_d$24 = wb_in_d$26;
		wb_op$24 = wb_in_op$26;
		wb_we$24 = wb_in_we$26;
	end
	wire [12:0] wb_in_ad$27;
	wire [31:0] wb_in_d$27;
	wire [7:0] wb_in_op$27;
	wire wb_in_we$27;
	reg [12:0] wb_ad$25 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$25 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$25 = 8'bxxxxxxxx;
	reg wb_we$25 = 0;
	always @(posedge clk) begin
		wb_ad$25 = wb_in_ad$27;
		wb_d$25 = wb_in_d$27;
		wb_op$25 = wb_in_op$27;
		wb_we$25 = wb_in_we$27;
	end
	wire [12:0] wb_in_ad$28;
	wire [31:0] wb_in_d$28;
	wire [7:0] wb_in_op$28;
	wire wb_in_we$28;
	reg [12:0] wb_ad$26 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$26 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$26 = 8'bxxxxxxxx;
	reg wb_we$26 = 0;
	always @(posedge clk) begin
		wb_ad$26 = wb_in_ad$28;
		wb_d$26 = wb_in_d$28;
		wb_op$26 = wb_in_op$28;
		wb_we$26 = wb_in_we$28;
	end
	wire [12:0] wb_in_ad$29;
	wire [31:0] wb_in_d$29;
	wire [7:0] wb_in_op$29;
	wire wb_in_we$29;
	reg [12:0] wb_ad$27 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$27 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$27 = 8'bxxxxxxxx;
	reg wb_we$27 = 0;
	always @(posedge clk) begin
		wb_ad$27 = wb_in_ad$29;
		wb_d$27 = wb_in_d$29;
		wb_op$27 = wb_in_op$29;
		wb_we$27 = wb_in_we$29;
	end
	wire [12:0] wb_in_ad$30;
	wire [31:0] wb_in_d$30;
	wire [7:0] wb_in_op$30;
	wire wb_in_we$30;
	reg [12:0] wb_ad$28 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$28 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$28 = 8'bxxxxxxxx;
	reg wb_we$28 = 0;
	always @(posedge clk) begin
		wb_ad$28 = wb_in_ad$30;
		wb_d$28 = wb_in_d$30;
		wb_op$28 = wb_in_op$30;
		wb_we$28 = wb_in_we$30;
	end
	wire [12:0] wb_in_ad$31;
	wire [31:0] wb_in_d$31;
	wire [7:0] wb_in_op$31;
	wire wb_in_we$31;
	reg [12:0] wb_ad$29 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$29 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$29 = 8'bxxxxxxxx;
	reg wb_we$29 = 0;
	always @(posedge clk) begin
		wb_ad$29 = wb_in_ad$31;
		wb_d$29 = wb_in_d$31;
		wb_op$29 = wb_in_op$31;
		wb_we$29 = wb_in_we$31;
	end
	assign retry_put$1 = (y_en$1[0] & wb_we$15) | (y_en$1[2] & wb_we$16) | (y_en$1[3] & wb_we$17) | (y_en$1[4] & wb_we$18) | (y_en$1[5] & wb_we$19) | (y_en$1[6] & wb_we$20) | (y_en$1[7] & wb_we$21) | (y_en$1[8] & wb_we$22) | (y_en$1[9] & wb_we$23) | (y_en$1[10] & wb_we$24) | (y_en$1[11] & wb_we$25) | (y_en$1[12] & wb_we$26) | (y_en$1[13] & wb_we$27) | (y_en$1[14] & wb_we$28) | (y_en$1[15] & wb_we$29);
	wire [32:0] acc_in$2;
	reg [32:0] acc$2 = 0;
	reg [32:0] acc_out$2;
	wire [16:0] pc_in$2;
	reg [16:0] pc$2 = 2;
	reg [16:0] pc_out$2;
	wire [7:0] op$2;
	wire [31:0] y$2;
	wire op_lock$2 = LOCK == op$2[7-:4];
	reg [3:0] lock_timer$2 = 0;
	always @(posedge clk) begin
		acc$2 <= acc_in$2;
		pc$2 <= pc_in$2;
		if (lock_timer$2) lock_timer$2 <= lock_timer$2 - 4'd1;
		else if (op_lock$2) lock_timer$2 <= y$2[0+:4];
	end
	wire retry_lock$2 = |lock_timer$2 & op_lock$2;
	wire [32:0] ax$2 = {op$2[2], {32{op$2[2]}} ^ acc$2[0+:32]};
	wire [32:0] ay$2 = {op$2[1], {32{op$2[1]}} ^ y$2};
	wire [4:0] ye$2 = op$2[0] ? y$2[0+:5] : -y$2[0+:5];
	wire [31:0] ys$2 = {{16{ye$2[4]}}, {16{~ye$2[4]}}} & {2{{{8{ye$2[3]}}, {8{~ye$2[3]}}} & {2{{{4{ye$2[2]}}, {4{~ye$2[2]}}} & {2{{{2{ye$2[1]}}, {2{~ye$2[1]}}} & {2{{ye$2[0], ~ye$2[0]}}}}}}}}};
	wire signed [32:0] mx$2 = {op$2[3] & acc$2[31], acc$2[0+:32]};
	wire signed [32:0] my$2 = op$2[2] ? {1'd0, ys$2} : {op$2[3] & y$2[31], y$2};
	wire signed [65:0] xy$2 = mx$2 * my$2;
	wire op_io$2 = IO == op$2[7-:3];
	wire [15:0] op_en$2 = {{8{op$2[3]}}, {8{~op$2[3]}}} & {2{{{4{op$2[2]}}, {4{~op$2[2]}}} & {2{{{2{op$2[1]}}, {2{~op$2[1]}}} & {2{{op$2[0] & op_io$2, ~op$2[0] & op_io$2}}}}}}};
	reg [32:0] acc_io$2;
	reg retry_io$2;
	wire retry_put$2;
	wire [2:0] opc$2 = acc$2[32] ? op$2[5:3] : op$2[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$2 = acc$2[31] ? opc$2[2] : !acc$2[30:0] ? opc$2[1] : opc$2[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$32;
	wire [31:0] wb_in_d$32;
	wire [7:0] wb_in_op$32;
	wire wb_in_we$32;
	reg [39:0] q$13;
	wire [12:0] _dpmem__wa$2 = wb_in_ad$32;
	wire _dpmem__we$2 = wb_in_we$32;
	wire [39:0] _dpmem__d$2 = {wb_in_d$32, wb_in_op$32};
	wire [12:0] _dpmem__ra$2 = pc_in$2[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$2 [0:6399];
	initial $readmemh("mem02.txt", _dpmem__mem$2);
	always @(posedge clk) begin
		if (_dpmem__we$2) _dpmem__mem$2[_dpmem__wa$2] <= _dpmem__d$2;
		q$13 <= _dpmem__mem$2[_dpmem__ra$2];
	end
	reg [31:0] fwd_y$2 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$2 = HALT;
	reg fwd_en$2 = 1;
	always @(posedge clk) begin
		fwd_y$2 = wb_in_d$32;
		fwd_op$2 = wb_in_op$32;
		fwd_en$2 = wb_in_we$32 & (wb_in_ad$32 == pc_in$2[16-:13]);
		if (pc_in$2[0+:4] != 4'd2) begin
			fwd_op$2 = HALT;
			fwd_en$2 = 1;
		end
	end
	assign y$2 = fwd_en$2 ? fwd_y$2 : q$13[39-:32];
	assign op$2 = fwd_en$2 ? fwd_op$2 : q$13[0+:8];
	wire op_put$2 = PUT == op$2[7-:2];
	wire [15:0] y_en$2 = {{8{y$2[3]}}, {8{~y$2[3]}}} & {2{{{4{y$2[2]}}, {4{~y$2[2]}}} & {2{{{2{y$2[1]}}, {2{~y$2[1]}}} & {2{{y$2[0] & op_put$2, ~y$2[0] & op_put$2}}}}}}};
	wire [12:0] wb_in_ad$33;
	wire [31:0] wb_in_d$33;
	wire [7:0] wb_in_op$33;
	wire wb_in_we$33;
	reg [12:0] wb_ad$30 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$30 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$30 = 8'bxxxxxxxx;
	reg wb_we$30 = 0;
	always @(posedge clk) begin
		wb_ad$30 = wb_in_ad$33;
		wb_d$30 = wb_in_d$33;
		wb_op$30 = wb_in_op$33;
		wb_we$30 = wb_in_we$33;
	end
	wire [12:0] wb_in_ad$34;
	wire [31:0] wb_in_d$34;
	wire [7:0] wb_in_op$34;
	wire wb_in_we$34;
	reg [12:0] wb_ad$31 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$31 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$31 = 8'bxxxxxxxx;
	reg wb_we$31 = 0;
	always @(posedge clk) begin
		wb_ad$31 = wb_in_ad$34;
		wb_d$31 = wb_in_d$34;
		wb_op$31 = wb_in_op$34;
		wb_we$31 = wb_in_we$34;
	end
	wire [12:0] wb_in_ad$35;
	wire [31:0] wb_in_d$35;
	wire [7:0] wb_in_op$35;
	wire wb_in_we$35;
	reg [12:0] wb_ad$32 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$32 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$32 = 8'bxxxxxxxx;
	reg wb_we$32 = 0;
	always @(posedge clk) begin
		wb_ad$32 = wb_in_ad$35;
		wb_d$32 = wb_in_d$35;
		wb_op$32 = wb_in_op$35;
		wb_we$32 = wb_in_we$35;
	end
	wire [12:0] wb_in_ad$36;
	wire [31:0] wb_in_d$36;
	wire [7:0] wb_in_op$36;
	wire wb_in_we$36;
	reg [12:0] wb_ad$33 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$33 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$33 = 8'bxxxxxxxx;
	reg wb_we$33 = 0;
	always @(posedge clk) begin
		wb_ad$33 = wb_in_ad$36;
		wb_d$33 = wb_in_d$36;
		wb_op$33 = wb_in_op$36;
		wb_we$33 = wb_in_we$36;
	end
	wire [12:0] wb_in_ad$37;
	wire [31:0] wb_in_d$37;
	wire [7:0] wb_in_op$37;
	wire wb_in_we$37;
	reg [12:0] wb_ad$34 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$34 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$34 = 8'bxxxxxxxx;
	reg wb_we$34 = 0;
	always @(posedge clk) begin
		wb_ad$34 = wb_in_ad$37;
		wb_d$34 = wb_in_d$37;
		wb_op$34 = wb_in_op$37;
		wb_we$34 = wb_in_we$37;
	end
	wire [12:0] wb_in_ad$38;
	wire [31:0] wb_in_d$38;
	wire [7:0] wb_in_op$38;
	wire wb_in_we$38;
	reg [12:0] wb_ad$35 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$35 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$35 = 8'bxxxxxxxx;
	reg wb_we$35 = 0;
	always @(posedge clk) begin
		wb_ad$35 = wb_in_ad$38;
		wb_d$35 = wb_in_d$38;
		wb_op$35 = wb_in_op$38;
		wb_we$35 = wb_in_we$38;
	end
	wire [12:0] wb_in_ad$39;
	wire [31:0] wb_in_d$39;
	wire [7:0] wb_in_op$39;
	wire wb_in_we$39;
	reg [12:0] wb_ad$36 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$36 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$36 = 8'bxxxxxxxx;
	reg wb_we$36 = 0;
	always @(posedge clk) begin
		wb_ad$36 = wb_in_ad$39;
		wb_d$36 = wb_in_d$39;
		wb_op$36 = wb_in_op$39;
		wb_we$36 = wb_in_we$39;
	end
	wire [12:0] wb_in_ad$40;
	wire [31:0] wb_in_d$40;
	wire [7:0] wb_in_op$40;
	wire wb_in_we$40;
	reg [12:0] wb_ad$37 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$37 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$37 = 8'bxxxxxxxx;
	reg wb_we$37 = 0;
	always @(posedge clk) begin
		wb_ad$37 = wb_in_ad$40;
		wb_d$37 = wb_in_d$40;
		wb_op$37 = wb_in_op$40;
		wb_we$37 = wb_in_we$40;
	end
	wire [12:0] wb_in_ad$41;
	wire [31:0] wb_in_d$41;
	wire [7:0] wb_in_op$41;
	wire wb_in_we$41;
	reg [12:0] wb_ad$38 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$38 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$38 = 8'bxxxxxxxx;
	reg wb_we$38 = 0;
	always @(posedge clk) begin
		wb_ad$38 = wb_in_ad$41;
		wb_d$38 = wb_in_d$41;
		wb_op$38 = wb_in_op$41;
		wb_we$38 = wb_in_we$41;
	end
	wire [12:0] wb_in_ad$42;
	wire [31:0] wb_in_d$42;
	wire [7:0] wb_in_op$42;
	wire wb_in_we$42;
	reg [12:0] wb_ad$39 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$39 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$39 = 8'bxxxxxxxx;
	reg wb_we$39 = 0;
	always @(posedge clk) begin
		wb_ad$39 = wb_in_ad$42;
		wb_d$39 = wb_in_d$42;
		wb_op$39 = wb_in_op$42;
		wb_we$39 = wb_in_we$42;
	end
	wire [12:0] wb_in_ad$43;
	wire [31:0] wb_in_d$43;
	wire [7:0] wb_in_op$43;
	wire wb_in_we$43;
	reg [12:0] wb_ad$40 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$40 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$40 = 8'bxxxxxxxx;
	reg wb_we$40 = 0;
	always @(posedge clk) begin
		wb_ad$40 = wb_in_ad$43;
		wb_d$40 = wb_in_d$43;
		wb_op$40 = wb_in_op$43;
		wb_we$40 = wb_in_we$43;
	end
	wire [12:0] wb_in_ad$44;
	wire [31:0] wb_in_d$44;
	wire [7:0] wb_in_op$44;
	wire wb_in_we$44;
	reg [12:0] wb_ad$41 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$41 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$41 = 8'bxxxxxxxx;
	reg wb_we$41 = 0;
	always @(posedge clk) begin
		wb_ad$41 = wb_in_ad$44;
		wb_d$41 = wb_in_d$44;
		wb_op$41 = wb_in_op$44;
		wb_we$41 = wb_in_we$44;
	end
	wire [12:0] wb_in_ad$45;
	wire [31:0] wb_in_d$45;
	wire [7:0] wb_in_op$45;
	wire wb_in_we$45;
	reg [12:0] wb_ad$42 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$42 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$42 = 8'bxxxxxxxx;
	reg wb_we$42 = 0;
	always @(posedge clk) begin
		wb_ad$42 = wb_in_ad$45;
		wb_d$42 = wb_in_d$45;
		wb_op$42 = wb_in_op$45;
		wb_we$42 = wb_in_we$45;
	end
	wire [12:0] wb_in_ad$46;
	wire [31:0] wb_in_d$46;
	wire [7:0] wb_in_op$46;
	wire wb_in_we$46;
	reg [12:0] wb_ad$43 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$43 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$43 = 8'bxxxxxxxx;
	reg wb_we$43 = 0;
	always @(posedge clk) begin
		wb_ad$43 = wb_in_ad$46;
		wb_d$43 = wb_in_d$46;
		wb_op$43 = wb_in_op$46;
		wb_we$43 = wb_in_we$46;
	end
	wire [12:0] wb_in_ad$47;
	wire [31:0] wb_in_d$47;
	wire [7:0] wb_in_op$47;
	wire wb_in_we$47;
	reg [12:0] wb_ad$44 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$44 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$44 = 8'bxxxxxxxx;
	reg wb_we$44 = 0;
	always @(posedge clk) begin
		wb_ad$44 = wb_in_ad$47;
		wb_d$44 = wb_in_d$47;
		wb_op$44 = wb_in_op$47;
		wb_we$44 = wb_in_we$47;
	end
	assign retry_put$2 = (y_en$2[0] & wb_we$30) | (y_en$2[1] & wb_we$31) | (y_en$2[3] & wb_we$32) | (y_en$2[4] & wb_we$33) | (y_en$2[5] & wb_we$34) | (y_en$2[6] & wb_we$35) | (y_en$2[7] & wb_we$36) | (y_en$2[8] & wb_we$37) | (y_en$2[9] & wb_we$38) | (y_en$2[10] & wb_we$39) | (y_en$2[11] & wb_we$40) | (y_en$2[12] & wb_we$41) | (y_en$2[13] & wb_we$42) | (y_en$2[14] & wb_we$43) | (y_en$2[15] & wb_we$44);
	wire [32:0] acc_in$3;
	reg [32:0] acc$3 = 0;
	reg [32:0] acc_out$3;
	wire [16:0] pc_in$3;
	reg [16:0] pc$3 = 3;
	reg [16:0] pc_out$3;
	wire [7:0] op$3;
	wire [31:0] y$3;
	wire op_lock$3 = LOCK == op$3[7-:4];
	reg [3:0] lock_timer$3 = 0;
	always @(posedge clk) begin
		acc$3 <= acc_in$3;
		pc$3 <= pc_in$3;
		if (lock_timer$3) lock_timer$3 <= lock_timer$3 - 4'd1;
		else if (op_lock$3) lock_timer$3 <= y$3[0+:4];
	end
	wire retry_lock$3 = |lock_timer$3 & op_lock$3;
	wire [32:0] ax$3 = {op$3[2], {32{op$3[2]}} ^ acc$3[0+:32]};
	wire [32:0] ay$3 = {op$3[1], {32{op$3[1]}} ^ y$3};
	wire [4:0] ye$3 = op$3[0] ? y$3[0+:5] : -y$3[0+:5];
	wire [31:0] ys$3 = {{16{ye$3[4]}}, {16{~ye$3[4]}}} & {2{{{8{ye$3[3]}}, {8{~ye$3[3]}}} & {2{{{4{ye$3[2]}}, {4{~ye$3[2]}}} & {2{{{2{ye$3[1]}}, {2{~ye$3[1]}}} & {2{{ye$3[0], ~ye$3[0]}}}}}}}}};
	wire signed [32:0] mx$3 = {op$3[3] & acc$3[31], acc$3[0+:32]};
	wire signed [32:0] my$3 = op$3[2] ? {1'd0, ys$3} : {op$3[3] & y$3[31], y$3};
	wire signed [65:0] xy$3 = mx$3 * my$3;
	wire op_io$3 = IO == op$3[7-:3];
	wire [15:0] op_en$3 = {{8{op$3[3]}}, {8{~op$3[3]}}} & {2{{{4{op$3[2]}}, {4{~op$3[2]}}} & {2{{{2{op$3[1]}}, {2{~op$3[1]}}} & {2{{op$3[0] & op_io$3, ~op$3[0] & op_io$3}}}}}}};
	reg [32:0] acc_io$3;
	reg retry_io$3;
	wire retry_put$3;
	wire [2:0] opc$3 = acc$3[32] ? op$3[5:3] : op$3[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$3 = acc$3[31] ? opc$3[2] : !acc$3[30:0] ? opc$3[1] : opc$3[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$48;
	wire [31:0] wb_in_d$48;
	wire [7:0] wb_in_op$48;
	wire wb_in_we$48;
	reg [39:0] q$14;
	wire [12:0] _dpmem__wa$3 = wb_in_ad$48;
	wire _dpmem__we$3 = wb_in_we$48;
	wire [39:0] _dpmem__d$3 = {wb_in_d$48, wb_in_op$48};
	wire [12:0] _dpmem__ra$3 = pc_in$3[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$3 [0:6399];
	initial $readmemh("mem03.txt", _dpmem__mem$3);
	always @(posedge clk) begin
		if (_dpmem__we$3) _dpmem__mem$3[_dpmem__wa$3] <= _dpmem__d$3;
		q$14 <= _dpmem__mem$3[_dpmem__ra$3];
	end
	reg [31:0] fwd_y$3 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$3 = HALT;
	reg fwd_en$3 = 1;
	always @(posedge clk) begin
		fwd_y$3 = wb_in_d$48;
		fwd_op$3 = wb_in_op$48;
		fwd_en$3 = wb_in_we$48 & (wb_in_ad$48 == pc_in$3[16-:13]);
		if (pc_in$3[0+:4] != 4'd3) begin
			fwd_op$3 = HALT;
			fwd_en$3 = 1;
		end
	end
	assign y$3 = fwd_en$3 ? fwd_y$3 : q$14[39-:32];
	assign op$3 = fwd_en$3 ? fwd_op$3 : q$14[0+:8];
	wire op_put$3 = PUT == op$3[7-:2];
	wire [15:0] y_en$3 = {{8{y$3[3]}}, {8{~y$3[3]}}} & {2{{{4{y$3[2]}}, {4{~y$3[2]}}} & {2{{{2{y$3[1]}}, {2{~y$3[1]}}} & {2{{y$3[0] & op_put$3, ~y$3[0] & op_put$3}}}}}}};
	wire [12:0] wb_in_ad$49;
	wire [31:0] wb_in_d$49;
	wire [7:0] wb_in_op$49;
	wire wb_in_we$49;
	reg [12:0] wb_ad$45 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$45 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$45 = 8'bxxxxxxxx;
	reg wb_we$45 = 0;
	always @(posedge clk) begin
		wb_ad$45 = wb_in_ad$49;
		wb_d$45 = wb_in_d$49;
		wb_op$45 = wb_in_op$49;
		wb_we$45 = wb_in_we$49;
	end
	wire [12:0] wb_in_ad$50;
	wire [31:0] wb_in_d$50;
	wire [7:0] wb_in_op$50;
	wire wb_in_we$50;
	reg [12:0] wb_ad$46 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$46 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$46 = 8'bxxxxxxxx;
	reg wb_we$46 = 0;
	always @(posedge clk) begin
		wb_ad$46 = wb_in_ad$50;
		wb_d$46 = wb_in_d$50;
		wb_op$46 = wb_in_op$50;
		wb_we$46 = wb_in_we$50;
	end
	wire [12:0] wb_in_ad$51;
	wire [31:0] wb_in_d$51;
	wire [7:0] wb_in_op$51;
	wire wb_in_we$51;
	reg [12:0] wb_ad$47 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$47 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$47 = 8'bxxxxxxxx;
	reg wb_we$47 = 0;
	always @(posedge clk) begin
		wb_ad$47 = wb_in_ad$51;
		wb_d$47 = wb_in_d$51;
		wb_op$47 = wb_in_op$51;
		wb_we$47 = wb_in_we$51;
	end
	wire [12:0] wb_in_ad$52;
	wire [31:0] wb_in_d$52;
	wire [7:0] wb_in_op$52;
	wire wb_in_we$52;
	reg [12:0] wb_ad$48 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$48 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$48 = 8'bxxxxxxxx;
	reg wb_we$48 = 0;
	always @(posedge clk) begin
		wb_ad$48 = wb_in_ad$52;
		wb_d$48 = wb_in_d$52;
		wb_op$48 = wb_in_op$52;
		wb_we$48 = wb_in_we$52;
	end
	wire [12:0] wb_in_ad$53;
	wire [31:0] wb_in_d$53;
	wire [7:0] wb_in_op$53;
	wire wb_in_we$53;
	reg [12:0] wb_ad$49 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$49 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$49 = 8'bxxxxxxxx;
	reg wb_we$49 = 0;
	always @(posedge clk) begin
		wb_ad$49 = wb_in_ad$53;
		wb_d$49 = wb_in_d$53;
		wb_op$49 = wb_in_op$53;
		wb_we$49 = wb_in_we$53;
	end
	wire [12:0] wb_in_ad$54;
	wire [31:0] wb_in_d$54;
	wire [7:0] wb_in_op$54;
	wire wb_in_we$54;
	reg [12:0] wb_ad$50 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$50 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$50 = 8'bxxxxxxxx;
	reg wb_we$50 = 0;
	always @(posedge clk) begin
		wb_ad$50 = wb_in_ad$54;
		wb_d$50 = wb_in_d$54;
		wb_op$50 = wb_in_op$54;
		wb_we$50 = wb_in_we$54;
	end
	wire [12:0] wb_in_ad$55;
	wire [31:0] wb_in_d$55;
	wire [7:0] wb_in_op$55;
	wire wb_in_we$55;
	reg [12:0] wb_ad$51 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$51 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$51 = 8'bxxxxxxxx;
	reg wb_we$51 = 0;
	always @(posedge clk) begin
		wb_ad$51 = wb_in_ad$55;
		wb_d$51 = wb_in_d$55;
		wb_op$51 = wb_in_op$55;
		wb_we$51 = wb_in_we$55;
	end
	wire [12:0] wb_in_ad$56;
	wire [31:0] wb_in_d$56;
	wire [7:0] wb_in_op$56;
	wire wb_in_we$56;
	reg [12:0] wb_ad$52 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$52 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$52 = 8'bxxxxxxxx;
	reg wb_we$52 = 0;
	always @(posedge clk) begin
		wb_ad$52 = wb_in_ad$56;
		wb_d$52 = wb_in_d$56;
		wb_op$52 = wb_in_op$56;
		wb_we$52 = wb_in_we$56;
	end
	wire [12:0] wb_in_ad$57;
	wire [31:0] wb_in_d$57;
	wire [7:0] wb_in_op$57;
	wire wb_in_we$57;
	reg [12:0] wb_ad$53 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$53 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$53 = 8'bxxxxxxxx;
	reg wb_we$53 = 0;
	always @(posedge clk) begin
		wb_ad$53 = wb_in_ad$57;
		wb_d$53 = wb_in_d$57;
		wb_op$53 = wb_in_op$57;
		wb_we$53 = wb_in_we$57;
	end
	wire [12:0] wb_in_ad$58;
	wire [31:0] wb_in_d$58;
	wire [7:0] wb_in_op$58;
	wire wb_in_we$58;
	reg [12:0] wb_ad$54 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$54 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$54 = 8'bxxxxxxxx;
	reg wb_we$54 = 0;
	always @(posedge clk) begin
		wb_ad$54 = wb_in_ad$58;
		wb_d$54 = wb_in_d$58;
		wb_op$54 = wb_in_op$58;
		wb_we$54 = wb_in_we$58;
	end
	wire [12:0] wb_in_ad$59;
	wire [31:0] wb_in_d$59;
	wire [7:0] wb_in_op$59;
	wire wb_in_we$59;
	reg [12:0] wb_ad$55 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$55 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$55 = 8'bxxxxxxxx;
	reg wb_we$55 = 0;
	always @(posedge clk) begin
		wb_ad$55 = wb_in_ad$59;
		wb_d$55 = wb_in_d$59;
		wb_op$55 = wb_in_op$59;
		wb_we$55 = wb_in_we$59;
	end
	wire [12:0] wb_in_ad$60;
	wire [31:0] wb_in_d$60;
	wire [7:0] wb_in_op$60;
	wire wb_in_we$60;
	reg [12:0] wb_ad$56 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$56 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$56 = 8'bxxxxxxxx;
	reg wb_we$56 = 0;
	always @(posedge clk) begin
		wb_ad$56 = wb_in_ad$60;
		wb_d$56 = wb_in_d$60;
		wb_op$56 = wb_in_op$60;
		wb_we$56 = wb_in_we$60;
	end
	wire [12:0] wb_in_ad$61;
	wire [31:0] wb_in_d$61;
	wire [7:0] wb_in_op$61;
	wire wb_in_we$61;
	reg [12:0] wb_ad$57 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$57 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$57 = 8'bxxxxxxxx;
	reg wb_we$57 = 0;
	always @(posedge clk) begin
		wb_ad$57 = wb_in_ad$61;
		wb_d$57 = wb_in_d$61;
		wb_op$57 = wb_in_op$61;
		wb_we$57 = wb_in_we$61;
	end
	wire [12:0] wb_in_ad$62;
	wire [31:0] wb_in_d$62;
	wire [7:0] wb_in_op$62;
	wire wb_in_we$62;
	reg [12:0] wb_ad$58 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$58 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$58 = 8'bxxxxxxxx;
	reg wb_we$58 = 0;
	always @(posedge clk) begin
		wb_ad$58 = wb_in_ad$62;
		wb_d$58 = wb_in_d$62;
		wb_op$58 = wb_in_op$62;
		wb_we$58 = wb_in_we$62;
	end
	wire [12:0] wb_in_ad$63;
	wire [31:0] wb_in_d$63;
	wire [7:0] wb_in_op$63;
	wire wb_in_we$63;
	reg [12:0] wb_ad$59 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$59 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$59 = 8'bxxxxxxxx;
	reg wb_we$59 = 0;
	always @(posedge clk) begin
		wb_ad$59 = wb_in_ad$63;
		wb_d$59 = wb_in_d$63;
		wb_op$59 = wb_in_op$63;
		wb_we$59 = wb_in_we$63;
	end
	assign retry_put$3 = (y_en$3[0] & wb_we$45) | (y_en$3[1] & wb_we$46) | (y_en$3[2] & wb_we$47) | (y_en$3[4] & wb_we$48) | (y_en$3[5] & wb_we$49) | (y_en$3[6] & wb_we$50) | (y_en$3[7] & wb_we$51) | (y_en$3[8] & wb_we$52) | (y_en$3[9] & wb_we$53) | (y_en$3[10] & wb_we$54) | (y_en$3[11] & wb_we$55) | (y_en$3[12] & wb_we$56) | (y_en$3[13] & wb_we$57) | (y_en$3[14] & wb_we$58) | (y_en$3[15] & wb_we$59);
	wire [32:0] acc_in$4;
	reg [32:0] acc$4 = 0;
	reg [32:0] acc_out$4;
	wire [16:0] pc_in$4;
	reg [16:0] pc$4 = 4;
	reg [16:0] pc_out$4;
	wire [7:0] op$4;
	wire [31:0] y$4;
	wire op_lock$4 = LOCK == op$4[7-:4];
	reg [3:0] lock_timer$4 = 0;
	always @(posedge clk) begin
		acc$4 <= acc_in$4;
		pc$4 <= pc_in$4;
		if (lock_timer$4) lock_timer$4 <= lock_timer$4 - 4'd1;
		else if (op_lock$4) lock_timer$4 <= y$4[0+:4];
	end
	wire retry_lock$4 = |lock_timer$4 & op_lock$4;
	wire [32:0] ax$4 = {op$4[2], {32{op$4[2]}} ^ acc$4[0+:32]};
	wire [32:0] ay$4 = {op$4[1], {32{op$4[1]}} ^ y$4};
	wire [4:0] ye$4 = op$4[0] ? y$4[0+:5] : -y$4[0+:5];
	wire [31:0] ys$4 = {{16{ye$4[4]}}, {16{~ye$4[4]}}} & {2{{{8{ye$4[3]}}, {8{~ye$4[3]}}} & {2{{{4{ye$4[2]}}, {4{~ye$4[2]}}} & {2{{{2{ye$4[1]}}, {2{~ye$4[1]}}} & {2{{ye$4[0], ~ye$4[0]}}}}}}}}};
	wire signed [32:0] mx$4 = {op$4[3] & acc$4[31], acc$4[0+:32]};
	wire signed [32:0] my$4 = op$4[2] ? {1'd0, ys$4} : {op$4[3] & y$4[31], y$4};
	wire signed [65:0] xy$4 = mx$4 * my$4;
	wire op_io$4 = IO == op$4[7-:3];
	wire [15:0] op_en$4 = {{8{op$4[3]}}, {8{~op$4[3]}}} & {2{{{4{op$4[2]}}, {4{~op$4[2]}}} & {2{{{2{op$4[1]}}, {2{~op$4[1]}}} & {2{{op$4[0] & op_io$4, ~op$4[0] & op_io$4}}}}}}};
	reg [32:0] acc_io$4;
	reg retry_io$4;
	wire retry_put$4;
	wire [2:0] opc$4 = acc$4[32] ? op$4[5:3] : op$4[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$4 = acc$4[31] ? opc$4[2] : !acc$4[30:0] ? opc$4[1] : opc$4[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$64;
	wire [31:0] wb_in_d$64;
	wire [7:0] wb_in_op$64;
	wire wb_in_we$64;
	reg [39:0] q$15;
	wire [12:0] _dpmem__wa$4 = wb_in_ad$64;
	wire _dpmem__we$4 = wb_in_we$64;
	wire [39:0] _dpmem__d$4 = {wb_in_d$64, wb_in_op$64};
	wire [12:0] _dpmem__ra$4 = pc_in$4[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$4 [0:6399];
	initial $readmemh("mem04.txt", _dpmem__mem$4);
	always @(posedge clk) begin
		if (_dpmem__we$4) _dpmem__mem$4[_dpmem__wa$4] <= _dpmem__d$4;
		q$15 <= _dpmem__mem$4[_dpmem__ra$4];
	end
	reg [31:0] fwd_y$4 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$4 = HALT;
	reg fwd_en$4 = 1;
	always @(posedge clk) begin
		fwd_y$4 = wb_in_d$64;
		fwd_op$4 = wb_in_op$64;
		fwd_en$4 = wb_in_we$64 & (wb_in_ad$64 == pc_in$4[16-:13]);
		if (pc_in$4[0+:4] != 4'd4) begin
			fwd_op$4 = HALT;
			fwd_en$4 = 1;
		end
	end
	assign y$4 = fwd_en$4 ? fwd_y$4 : q$15[39-:32];
	assign op$4 = fwd_en$4 ? fwd_op$4 : q$15[0+:8];
	wire op_put$4 = PUT == op$4[7-:2];
	wire [15:0] y_en$4 = {{8{y$4[3]}}, {8{~y$4[3]}}} & {2{{{4{y$4[2]}}, {4{~y$4[2]}}} & {2{{{2{y$4[1]}}, {2{~y$4[1]}}} & {2{{y$4[0] & op_put$4, ~y$4[0] & op_put$4}}}}}}};
	wire [12:0] wb_in_ad$65;
	wire [31:0] wb_in_d$65;
	wire [7:0] wb_in_op$65;
	wire wb_in_we$65;
	reg [12:0] wb_ad$60 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$60 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$60 = 8'bxxxxxxxx;
	reg wb_we$60 = 0;
	always @(posedge clk) begin
		wb_ad$60 = wb_in_ad$65;
		wb_d$60 = wb_in_d$65;
		wb_op$60 = wb_in_op$65;
		wb_we$60 = wb_in_we$65;
	end
	wire [12:0] wb_in_ad$66;
	wire [31:0] wb_in_d$66;
	wire [7:0] wb_in_op$66;
	wire wb_in_we$66;
	reg [12:0] wb_ad$61 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$61 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$61 = 8'bxxxxxxxx;
	reg wb_we$61 = 0;
	always @(posedge clk) begin
		wb_ad$61 = wb_in_ad$66;
		wb_d$61 = wb_in_d$66;
		wb_op$61 = wb_in_op$66;
		wb_we$61 = wb_in_we$66;
	end
	wire [12:0] wb_in_ad$67;
	wire [31:0] wb_in_d$67;
	wire [7:0] wb_in_op$67;
	wire wb_in_we$67;
	reg [12:0] wb_ad$62 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$62 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$62 = 8'bxxxxxxxx;
	reg wb_we$62 = 0;
	always @(posedge clk) begin
		wb_ad$62 = wb_in_ad$67;
		wb_d$62 = wb_in_d$67;
		wb_op$62 = wb_in_op$67;
		wb_we$62 = wb_in_we$67;
	end
	wire [12:0] wb_in_ad$68;
	wire [31:0] wb_in_d$68;
	wire [7:0] wb_in_op$68;
	wire wb_in_we$68;
	reg [12:0] wb_ad$63 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$63 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$63 = 8'bxxxxxxxx;
	reg wb_we$63 = 0;
	always @(posedge clk) begin
		wb_ad$63 = wb_in_ad$68;
		wb_d$63 = wb_in_d$68;
		wb_op$63 = wb_in_op$68;
		wb_we$63 = wb_in_we$68;
	end
	wire [12:0] wb_in_ad$69;
	wire [31:0] wb_in_d$69;
	wire [7:0] wb_in_op$69;
	wire wb_in_we$69;
	reg [12:0] wb_ad$64 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$64 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$64 = 8'bxxxxxxxx;
	reg wb_we$64 = 0;
	always @(posedge clk) begin
		wb_ad$64 = wb_in_ad$69;
		wb_d$64 = wb_in_d$69;
		wb_op$64 = wb_in_op$69;
		wb_we$64 = wb_in_we$69;
	end
	wire [12:0] wb_in_ad$70;
	wire [31:0] wb_in_d$70;
	wire [7:0] wb_in_op$70;
	wire wb_in_we$70;
	reg [12:0] wb_ad$65 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$65 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$65 = 8'bxxxxxxxx;
	reg wb_we$65 = 0;
	always @(posedge clk) begin
		wb_ad$65 = wb_in_ad$70;
		wb_d$65 = wb_in_d$70;
		wb_op$65 = wb_in_op$70;
		wb_we$65 = wb_in_we$70;
	end
	wire [12:0] wb_in_ad$71;
	wire [31:0] wb_in_d$71;
	wire [7:0] wb_in_op$71;
	wire wb_in_we$71;
	reg [12:0] wb_ad$66 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$66 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$66 = 8'bxxxxxxxx;
	reg wb_we$66 = 0;
	always @(posedge clk) begin
		wb_ad$66 = wb_in_ad$71;
		wb_d$66 = wb_in_d$71;
		wb_op$66 = wb_in_op$71;
		wb_we$66 = wb_in_we$71;
	end
	wire [12:0] wb_in_ad$72;
	wire [31:0] wb_in_d$72;
	wire [7:0] wb_in_op$72;
	wire wb_in_we$72;
	reg [12:0] wb_ad$67 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$67 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$67 = 8'bxxxxxxxx;
	reg wb_we$67 = 0;
	always @(posedge clk) begin
		wb_ad$67 = wb_in_ad$72;
		wb_d$67 = wb_in_d$72;
		wb_op$67 = wb_in_op$72;
		wb_we$67 = wb_in_we$72;
	end
	wire [12:0] wb_in_ad$73;
	wire [31:0] wb_in_d$73;
	wire [7:0] wb_in_op$73;
	wire wb_in_we$73;
	reg [12:0] wb_ad$68 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$68 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$68 = 8'bxxxxxxxx;
	reg wb_we$68 = 0;
	always @(posedge clk) begin
		wb_ad$68 = wb_in_ad$73;
		wb_d$68 = wb_in_d$73;
		wb_op$68 = wb_in_op$73;
		wb_we$68 = wb_in_we$73;
	end
	wire [12:0] wb_in_ad$74;
	wire [31:0] wb_in_d$74;
	wire [7:0] wb_in_op$74;
	wire wb_in_we$74;
	reg [12:0] wb_ad$69 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$69 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$69 = 8'bxxxxxxxx;
	reg wb_we$69 = 0;
	always @(posedge clk) begin
		wb_ad$69 = wb_in_ad$74;
		wb_d$69 = wb_in_d$74;
		wb_op$69 = wb_in_op$74;
		wb_we$69 = wb_in_we$74;
	end
	wire [12:0] wb_in_ad$75;
	wire [31:0] wb_in_d$75;
	wire [7:0] wb_in_op$75;
	wire wb_in_we$75;
	reg [12:0] wb_ad$70 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$70 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$70 = 8'bxxxxxxxx;
	reg wb_we$70 = 0;
	always @(posedge clk) begin
		wb_ad$70 = wb_in_ad$75;
		wb_d$70 = wb_in_d$75;
		wb_op$70 = wb_in_op$75;
		wb_we$70 = wb_in_we$75;
	end
	wire [12:0] wb_in_ad$76;
	wire [31:0] wb_in_d$76;
	wire [7:0] wb_in_op$76;
	wire wb_in_we$76;
	reg [12:0] wb_ad$71 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$71 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$71 = 8'bxxxxxxxx;
	reg wb_we$71 = 0;
	always @(posedge clk) begin
		wb_ad$71 = wb_in_ad$76;
		wb_d$71 = wb_in_d$76;
		wb_op$71 = wb_in_op$76;
		wb_we$71 = wb_in_we$76;
	end
	wire [12:0] wb_in_ad$77;
	wire [31:0] wb_in_d$77;
	wire [7:0] wb_in_op$77;
	wire wb_in_we$77;
	reg [12:0] wb_ad$72 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$72 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$72 = 8'bxxxxxxxx;
	reg wb_we$72 = 0;
	always @(posedge clk) begin
		wb_ad$72 = wb_in_ad$77;
		wb_d$72 = wb_in_d$77;
		wb_op$72 = wb_in_op$77;
		wb_we$72 = wb_in_we$77;
	end
	wire [12:0] wb_in_ad$78;
	wire [31:0] wb_in_d$78;
	wire [7:0] wb_in_op$78;
	wire wb_in_we$78;
	reg [12:0] wb_ad$73 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$73 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$73 = 8'bxxxxxxxx;
	reg wb_we$73 = 0;
	always @(posedge clk) begin
		wb_ad$73 = wb_in_ad$78;
		wb_d$73 = wb_in_d$78;
		wb_op$73 = wb_in_op$78;
		wb_we$73 = wb_in_we$78;
	end
	wire [12:0] wb_in_ad$79;
	wire [31:0] wb_in_d$79;
	wire [7:0] wb_in_op$79;
	wire wb_in_we$79;
	reg [12:0] wb_ad$74 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$74 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$74 = 8'bxxxxxxxx;
	reg wb_we$74 = 0;
	always @(posedge clk) begin
		wb_ad$74 = wb_in_ad$79;
		wb_d$74 = wb_in_d$79;
		wb_op$74 = wb_in_op$79;
		wb_we$74 = wb_in_we$79;
	end
	assign retry_put$4 = (y_en$4[0] & wb_we$60) | (y_en$4[1] & wb_we$61) | (y_en$4[2] & wb_we$62) | (y_en$4[3] & wb_we$63) | (y_en$4[5] & wb_we$64) | (y_en$4[6] & wb_we$65) | (y_en$4[7] & wb_we$66) | (y_en$4[8] & wb_we$67) | (y_en$4[9] & wb_we$68) | (y_en$4[10] & wb_we$69) | (y_en$4[11] & wb_we$70) | (y_en$4[12] & wb_we$71) | (y_en$4[13] & wb_we$72) | (y_en$4[14] & wb_we$73) | (y_en$4[15] & wb_we$74);
	wire [32:0] acc_in$5;
	reg [32:0] acc$5 = 0;
	reg [32:0] acc_out$5;
	wire [16:0] pc_in$5;
	reg [16:0] pc$5 = 5;
	reg [16:0] pc_out$5;
	wire [7:0] op$5;
	wire [31:0] y$5;
	wire op_lock$5 = LOCK == op$5[7-:4];
	reg [3:0] lock_timer$5 = 0;
	always @(posedge clk) begin
		acc$5 <= acc_in$5;
		pc$5 <= pc_in$5;
		if (lock_timer$5) lock_timer$5 <= lock_timer$5 - 4'd1;
		else if (op_lock$5) lock_timer$5 <= y$5[0+:4];
	end
	wire retry_lock$5 = |lock_timer$5 & op_lock$5;
	wire [32:0] ax$5 = {op$5[2], {32{op$5[2]}} ^ acc$5[0+:32]};
	wire [32:0] ay$5 = {op$5[1], {32{op$5[1]}} ^ y$5};
	wire [4:0] ye$5 = op$5[0] ? y$5[0+:5] : -y$5[0+:5];
	wire [31:0] ys$5 = {{16{ye$5[4]}}, {16{~ye$5[4]}}} & {2{{{8{ye$5[3]}}, {8{~ye$5[3]}}} & {2{{{4{ye$5[2]}}, {4{~ye$5[2]}}} & {2{{{2{ye$5[1]}}, {2{~ye$5[1]}}} & {2{{ye$5[0], ~ye$5[0]}}}}}}}}};
	wire signed [32:0] mx$5 = {op$5[3] & acc$5[31], acc$5[0+:32]};
	wire signed [32:0] my$5 = op$5[2] ? {1'd0, ys$5} : {op$5[3] & y$5[31], y$5};
	wire signed [65:0] xy$5 = mx$5 * my$5;
	wire op_io$5 = IO == op$5[7-:3];
	wire [15:0] op_en$5 = {{8{op$5[3]}}, {8{~op$5[3]}}} & {2{{{4{op$5[2]}}, {4{~op$5[2]}}} & {2{{{2{op$5[1]}}, {2{~op$5[1]}}} & {2{{op$5[0] & op_io$5, ~op$5[0] & op_io$5}}}}}}};
	reg [32:0] acc_io$5;
	reg retry_io$5;
	wire retry_put$5;
	wire [2:0] opc$5 = acc$5[32] ? op$5[5:3] : op$5[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$5 = acc$5[31] ? opc$5[2] : !acc$5[30:0] ? opc$5[1] : opc$5[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$80;
	wire [31:0] wb_in_d$80;
	wire [7:0] wb_in_op$80;
	wire wb_in_we$80;
	reg [39:0] q$16;
	wire [12:0] _dpmem__wa$5 = wb_in_ad$80;
	wire _dpmem__we$5 = wb_in_we$80;
	wire [39:0] _dpmem__d$5 = {wb_in_d$80, wb_in_op$80};
	wire [12:0] _dpmem__ra$5 = pc_in$5[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$5 [0:6399];
	initial $readmemh("mem05.txt", _dpmem__mem$5);
	always @(posedge clk) begin
		if (_dpmem__we$5) _dpmem__mem$5[_dpmem__wa$5] <= _dpmem__d$5;
		q$16 <= _dpmem__mem$5[_dpmem__ra$5];
	end
	reg [31:0] fwd_y$5 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$5 = HALT;
	reg fwd_en$5 = 1;
	always @(posedge clk) begin
		fwd_y$5 = wb_in_d$80;
		fwd_op$5 = wb_in_op$80;
		fwd_en$5 = wb_in_we$80 & (wb_in_ad$80 == pc_in$5[16-:13]);
		if (pc_in$5[0+:4] != 4'd5) begin
			fwd_op$5 = HALT;
			fwd_en$5 = 1;
		end
	end
	assign y$5 = fwd_en$5 ? fwd_y$5 : q$16[39-:32];
	assign op$5 = fwd_en$5 ? fwd_op$5 : q$16[0+:8];
	wire op_put$5 = PUT == op$5[7-:2];
	wire [15:0] y_en$5 = {{8{y$5[3]}}, {8{~y$5[3]}}} & {2{{{4{y$5[2]}}, {4{~y$5[2]}}} & {2{{{2{y$5[1]}}, {2{~y$5[1]}}} & {2{{y$5[0] & op_put$5, ~y$5[0] & op_put$5}}}}}}};
	wire [12:0] wb_in_ad$81;
	wire [31:0] wb_in_d$81;
	wire [7:0] wb_in_op$81;
	wire wb_in_we$81;
	reg [12:0] wb_ad$75 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$75 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$75 = 8'bxxxxxxxx;
	reg wb_we$75 = 0;
	always @(posedge clk) begin
		wb_ad$75 = wb_in_ad$81;
		wb_d$75 = wb_in_d$81;
		wb_op$75 = wb_in_op$81;
		wb_we$75 = wb_in_we$81;
	end
	wire [12:0] wb_in_ad$82;
	wire [31:0] wb_in_d$82;
	wire [7:0] wb_in_op$82;
	wire wb_in_we$82;
	reg [12:0] wb_ad$76 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$76 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$76 = 8'bxxxxxxxx;
	reg wb_we$76 = 0;
	always @(posedge clk) begin
		wb_ad$76 = wb_in_ad$82;
		wb_d$76 = wb_in_d$82;
		wb_op$76 = wb_in_op$82;
		wb_we$76 = wb_in_we$82;
	end
	wire [12:0] wb_in_ad$83;
	wire [31:0] wb_in_d$83;
	wire [7:0] wb_in_op$83;
	wire wb_in_we$83;
	reg [12:0] wb_ad$77 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$77 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$77 = 8'bxxxxxxxx;
	reg wb_we$77 = 0;
	always @(posedge clk) begin
		wb_ad$77 = wb_in_ad$83;
		wb_d$77 = wb_in_d$83;
		wb_op$77 = wb_in_op$83;
		wb_we$77 = wb_in_we$83;
	end
	wire [12:0] wb_in_ad$84;
	wire [31:0] wb_in_d$84;
	wire [7:0] wb_in_op$84;
	wire wb_in_we$84;
	reg [12:0] wb_ad$78 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$78 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$78 = 8'bxxxxxxxx;
	reg wb_we$78 = 0;
	always @(posedge clk) begin
		wb_ad$78 = wb_in_ad$84;
		wb_d$78 = wb_in_d$84;
		wb_op$78 = wb_in_op$84;
		wb_we$78 = wb_in_we$84;
	end
	wire [12:0] wb_in_ad$85;
	wire [31:0] wb_in_d$85;
	wire [7:0] wb_in_op$85;
	wire wb_in_we$85;
	reg [12:0] wb_ad$79 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$79 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$79 = 8'bxxxxxxxx;
	reg wb_we$79 = 0;
	always @(posedge clk) begin
		wb_ad$79 = wb_in_ad$85;
		wb_d$79 = wb_in_d$85;
		wb_op$79 = wb_in_op$85;
		wb_we$79 = wb_in_we$85;
	end
	wire [12:0] wb_in_ad$86;
	wire [31:0] wb_in_d$86;
	wire [7:0] wb_in_op$86;
	wire wb_in_we$86;
	reg [12:0] wb_ad$80 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$80 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$80 = 8'bxxxxxxxx;
	reg wb_we$80 = 0;
	always @(posedge clk) begin
		wb_ad$80 = wb_in_ad$86;
		wb_d$80 = wb_in_d$86;
		wb_op$80 = wb_in_op$86;
		wb_we$80 = wb_in_we$86;
	end
	wire [12:0] wb_in_ad$87;
	wire [31:0] wb_in_d$87;
	wire [7:0] wb_in_op$87;
	wire wb_in_we$87;
	reg [12:0] wb_ad$81 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$81 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$81 = 8'bxxxxxxxx;
	reg wb_we$81 = 0;
	always @(posedge clk) begin
		wb_ad$81 = wb_in_ad$87;
		wb_d$81 = wb_in_d$87;
		wb_op$81 = wb_in_op$87;
		wb_we$81 = wb_in_we$87;
	end
	wire [12:0] wb_in_ad$88;
	wire [31:0] wb_in_d$88;
	wire [7:0] wb_in_op$88;
	wire wb_in_we$88;
	reg [12:0] wb_ad$82 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$82 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$82 = 8'bxxxxxxxx;
	reg wb_we$82 = 0;
	always @(posedge clk) begin
		wb_ad$82 = wb_in_ad$88;
		wb_d$82 = wb_in_d$88;
		wb_op$82 = wb_in_op$88;
		wb_we$82 = wb_in_we$88;
	end
	wire [12:0] wb_in_ad$89;
	wire [31:0] wb_in_d$89;
	wire [7:0] wb_in_op$89;
	wire wb_in_we$89;
	reg [12:0] wb_ad$83 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$83 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$83 = 8'bxxxxxxxx;
	reg wb_we$83 = 0;
	always @(posedge clk) begin
		wb_ad$83 = wb_in_ad$89;
		wb_d$83 = wb_in_d$89;
		wb_op$83 = wb_in_op$89;
		wb_we$83 = wb_in_we$89;
	end
	wire [12:0] wb_in_ad$90;
	wire [31:0] wb_in_d$90;
	wire [7:0] wb_in_op$90;
	wire wb_in_we$90;
	reg [12:0] wb_ad$84 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$84 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$84 = 8'bxxxxxxxx;
	reg wb_we$84 = 0;
	always @(posedge clk) begin
		wb_ad$84 = wb_in_ad$90;
		wb_d$84 = wb_in_d$90;
		wb_op$84 = wb_in_op$90;
		wb_we$84 = wb_in_we$90;
	end
	wire [12:0] wb_in_ad$91;
	wire [31:0] wb_in_d$91;
	wire [7:0] wb_in_op$91;
	wire wb_in_we$91;
	reg [12:0] wb_ad$85 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$85 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$85 = 8'bxxxxxxxx;
	reg wb_we$85 = 0;
	always @(posedge clk) begin
		wb_ad$85 = wb_in_ad$91;
		wb_d$85 = wb_in_d$91;
		wb_op$85 = wb_in_op$91;
		wb_we$85 = wb_in_we$91;
	end
	wire [12:0] wb_in_ad$92;
	wire [31:0] wb_in_d$92;
	wire [7:0] wb_in_op$92;
	wire wb_in_we$92;
	reg [12:0] wb_ad$86 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$86 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$86 = 8'bxxxxxxxx;
	reg wb_we$86 = 0;
	always @(posedge clk) begin
		wb_ad$86 = wb_in_ad$92;
		wb_d$86 = wb_in_d$92;
		wb_op$86 = wb_in_op$92;
		wb_we$86 = wb_in_we$92;
	end
	wire [12:0] wb_in_ad$93;
	wire [31:0] wb_in_d$93;
	wire [7:0] wb_in_op$93;
	wire wb_in_we$93;
	reg [12:0] wb_ad$87 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$87 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$87 = 8'bxxxxxxxx;
	reg wb_we$87 = 0;
	always @(posedge clk) begin
		wb_ad$87 = wb_in_ad$93;
		wb_d$87 = wb_in_d$93;
		wb_op$87 = wb_in_op$93;
		wb_we$87 = wb_in_we$93;
	end
	wire [12:0] wb_in_ad$94;
	wire [31:0] wb_in_d$94;
	wire [7:0] wb_in_op$94;
	wire wb_in_we$94;
	reg [12:0] wb_ad$88 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$88 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$88 = 8'bxxxxxxxx;
	reg wb_we$88 = 0;
	always @(posedge clk) begin
		wb_ad$88 = wb_in_ad$94;
		wb_d$88 = wb_in_d$94;
		wb_op$88 = wb_in_op$94;
		wb_we$88 = wb_in_we$94;
	end
	wire [12:0] wb_in_ad$95;
	wire [31:0] wb_in_d$95;
	wire [7:0] wb_in_op$95;
	wire wb_in_we$95;
	reg [12:0] wb_ad$89 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$89 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$89 = 8'bxxxxxxxx;
	reg wb_we$89 = 0;
	always @(posedge clk) begin
		wb_ad$89 = wb_in_ad$95;
		wb_d$89 = wb_in_d$95;
		wb_op$89 = wb_in_op$95;
		wb_we$89 = wb_in_we$95;
	end
	assign retry_put$5 = (y_en$5[0] & wb_we$75) | (y_en$5[1] & wb_we$76) | (y_en$5[2] & wb_we$77) | (y_en$5[3] & wb_we$78) | (y_en$5[4] & wb_we$79) | (y_en$5[6] & wb_we$80) | (y_en$5[7] & wb_we$81) | (y_en$5[8] & wb_we$82) | (y_en$5[9] & wb_we$83) | (y_en$5[10] & wb_we$84) | (y_en$5[11] & wb_we$85) | (y_en$5[12] & wb_we$86) | (y_en$5[13] & wb_we$87) | (y_en$5[14] & wb_we$88) | (y_en$5[15] & wb_we$89);
	wire [32:0] acc_in$6;
	reg [32:0] acc$6 = 0;
	reg [32:0] acc_out$6;
	wire [16:0] pc_in$6;
	reg [16:0] pc$6 = 6;
	reg [16:0] pc_out$6;
	wire [7:0] op$6;
	wire [31:0] y$6;
	wire op_lock$6 = LOCK == op$6[7-:4];
	reg [3:0] lock_timer$6 = 0;
	always @(posedge clk) begin
		acc$6 <= acc_in$6;
		pc$6 <= pc_in$6;
		if (lock_timer$6) lock_timer$6 <= lock_timer$6 - 4'd1;
		else if (op_lock$6) lock_timer$6 <= y$6[0+:4];
	end
	wire retry_lock$6 = |lock_timer$6 & op_lock$6;
	wire [32:0] ax$6 = {op$6[2], {32{op$6[2]}} ^ acc$6[0+:32]};
	wire [32:0] ay$6 = {op$6[1], {32{op$6[1]}} ^ y$6};
	wire [4:0] ye$6 = op$6[0] ? y$6[0+:5] : -y$6[0+:5];
	wire [31:0] ys$6 = {{16{ye$6[4]}}, {16{~ye$6[4]}}} & {2{{{8{ye$6[3]}}, {8{~ye$6[3]}}} & {2{{{4{ye$6[2]}}, {4{~ye$6[2]}}} & {2{{{2{ye$6[1]}}, {2{~ye$6[1]}}} & {2{{ye$6[0], ~ye$6[0]}}}}}}}}};
	wire signed [32:0] mx$6 = {op$6[3] & acc$6[31], acc$6[0+:32]};
	wire signed [32:0] my$6 = op$6[2] ? {1'd0, ys$6} : {op$6[3] & y$6[31], y$6};
	wire signed [65:0] xy$6 = mx$6 * my$6;
	wire op_io$6 = IO == op$6[7-:3];
	wire [15:0] op_en$6 = {{8{op$6[3]}}, {8{~op$6[3]}}} & {2{{{4{op$6[2]}}, {4{~op$6[2]}}} & {2{{{2{op$6[1]}}, {2{~op$6[1]}}} & {2{{op$6[0] & op_io$6, ~op$6[0] & op_io$6}}}}}}};
	reg [32:0] acc_io$6;
	reg retry_io$6;
	wire retry_put$6;
	wire [2:0] opc$6 = acc$6[32] ? op$6[5:3] : op$6[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$6 = acc$6[31] ? opc$6[2] : !acc$6[30:0] ? opc$6[1] : opc$6[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$96;
	wire [31:0] wb_in_d$96;
	wire [7:0] wb_in_op$96;
	wire wb_in_we$96;
	reg [39:0] q$17;
	wire [12:0] _dpmem__wa$6 = wb_in_ad$96;
	wire _dpmem__we$6 = wb_in_we$96;
	wire [39:0] _dpmem__d$6 = {wb_in_d$96, wb_in_op$96};
	wire [12:0] _dpmem__ra$6 = pc_in$6[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$6 [0:6399];
	initial $readmemh("mem06.txt", _dpmem__mem$6);
	always @(posedge clk) begin
		if (_dpmem__we$6) _dpmem__mem$6[_dpmem__wa$6] <= _dpmem__d$6;
		q$17 <= _dpmem__mem$6[_dpmem__ra$6];
	end
	reg [31:0] fwd_y$6 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$6 = HALT;
	reg fwd_en$6 = 1;
	always @(posedge clk) begin
		fwd_y$6 = wb_in_d$96;
		fwd_op$6 = wb_in_op$96;
		fwd_en$6 = wb_in_we$96 & (wb_in_ad$96 == pc_in$6[16-:13]);
		if (pc_in$6[0+:4] != 4'd6) begin
			fwd_op$6 = HALT;
			fwd_en$6 = 1;
		end
	end
	assign y$6 = fwd_en$6 ? fwd_y$6 : q$17[39-:32];
	assign op$6 = fwd_en$6 ? fwd_op$6 : q$17[0+:8];
	wire op_put$6 = PUT == op$6[7-:2];
	wire [15:0] y_en$6 = {{8{y$6[3]}}, {8{~y$6[3]}}} & {2{{{4{y$6[2]}}, {4{~y$6[2]}}} & {2{{{2{y$6[1]}}, {2{~y$6[1]}}} & {2{{y$6[0] & op_put$6, ~y$6[0] & op_put$6}}}}}}};
	wire [12:0] wb_in_ad$97;
	wire [31:0] wb_in_d$97;
	wire [7:0] wb_in_op$97;
	wire wb_in_we$97;
	reg [12:0] wb_ad$90 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$90 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$90 = 8'bxxxxxxxx;
	reg wb_we$90 = 0;
	always @(posedge clk) begin
		wb_ad$90 = wb_in_ad$97;
		wb_d$90 = wb_in_d$97;
		wb_op$90 = wb_in_op$97;
		wb_we$90 = wb_in_we$97;
	end
	wire [12:0] wb_in_ad$98;
	wire [31:0] wb_in_d$98;
	wire [7:0] wb_in_op$98;
	wire wb_in_we$98;
	reg [12:0] wb_ad$91 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$91 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$91 = 8'bxxxxxxxx;
	reg wb_we$91 = 0;
	always @(posedge clk) begin
		wb_ad$91 = wb_in_ad$98;
		wb_d$91 = wb_in_d$98;
		wb_op$91 = wb_in_op$98;
		wb_we$91 = wb_in_we$98;
	end
	wire [12:0] wb_in_ad$99;
	wire [31:0] wb_in_d$99;
	wire [7:0] wb_in_op$99;
	wire wb_in_we$99;
	reg [12:0] wb_ad$92 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$92 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$92 = 8'bxxxxxxxx;
	reg wb_we$92 = 0;
	always @(posedge clk) begin
		wb_ad$92 = wb_in_ad$99;
		wb_d$92 = wb_in_d$99;
		wb_op$92 = wb_in_op$99;
		wb_we$92 = wb_in_we$99;
	end
	wire [12:0] wb_in_ad$100;
	wire [31:0] wb_in_d$100;
	wire [7:0] wb_in_op$100;
	wire wb_in_we$100;
	reg [12:0] wb_ad$93 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$93 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$93 = 8'bxxxxxxxx;
	reg wb_we$93 = 0;
	always @(posedge clk) begin
		wb_ad$93 = wb_in_ad$100;
		wb_d$93 = wb_in_d$100;
		wb_op$93 = wb_in_op$100;
		wb_we$93 = wb_in_we$100;
	end
	wire [12:0] wb_in_ad$101;
	wire [31:0] wb_in_d$101;
	wire [7:0] wb_in_op$101;
	wire wb_in_we$101;
	reg [12:0] wb_ad$94 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$94 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$94 = 8'bxxxxxxxx;
	reg wb_we$94 = 0;
	always @(posedge clk) begin
		wb_ad$94 = wb_in_ad$101;
		wb_d$94 = wb_in_d$101;
		wb_op$94 = wb_in_op$101;
		wb_we$94 = wb_in_we$101;
	end
	wire [12:0] wb_in_ad$102;
	wire [31:0] wb_in_d$102;
	wire [7:0] wb_in_op$102;
	wire wb_in_we$102;
	reg [12:0] wb_ad$95 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$95 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$95 = 8'bxxxxxxxx;
	reg wb_we$95 = 0;
	always @(posedge clk) begin
		wb_ad$95 = wb_in_ad$102;
		wb_d$95 = wb_in_d$102;
		wb_op$95 = wb_in_op$102;
		wb_we$95 = wb_in_we$102;
	end
	wire [12:0] wb_in_ad$103;
	wire [31:0] wb_in_d$103;
	wire [7:0] wb_in_op$103;
	wire wb_in_we$103;
	reg [12:0] wb_ad$96 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$96 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$96 = 8'bxxxxxxxx;
	reg wb_we$96 = 0;
	always @(posedge clk) begin
		wb_ad$96 = wb_in_ad$103;
		wb_d$96 = wb_in_d$103;
		wb_op$96 = wb_in_op$103;
		wb_we$96 = wb_in_we$103;
	end
	wire [12:0] wb_in_ad$104;
	wire [31:0] wb_in_d$104;
	wire [7:0] wb_in_op$104;
	wire wb_in_we$104;
	reg [12:0] wb_ad$97 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$97 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$97 = 8'bxxxxxxxx;
	reg wb_we$97 = 0;
	always @(posedge clk) begin
		wb_ad$97 = wb_in_ad$104;
		wb_d$97 = wb_in_d$104;
		wb_op$97 = wb_in_op$104;
		wb_we$97 = wb_in_we$104;
	end
	wire [12:0] wb_in_ad$105;
	wire [31:0] wb_in_d$105;
	wire [7:0] wb_in_op$105;
	wire wb_in_we$105;
	reg [12:0] wb_ad$98 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$98 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$98 = 8'bxxxxxxxx;
	reg wb_we$98 = 0;
	always @(posedge clk) begin
		wb_ad$98 = wb_in_ad$105;
		wb_d$98 = wb_in_d$105;
		wb_op$98 = wb_in_op$105;
		wb_we$98 = wb_in_we$105;
	end
	wire [12:0] wb_in_ad$106;
	wire [31:0] wb_in_d$106;
	wire [7:0] wb_in_op$106;
	wire wb_in_we$106;
	reg [12:0] wb_ad$99 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$99 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$99 = 8'bxxxxxxxx;
	reg wb_we$99 = 0;
	always @(posedge clk) begin
		wb_ad$99 = wb_in_ad$106;
		wb_d$99 = wb_in_d$106;
		wb_op$99 = wb_in_op$106;
		wb_we$99 = wb_in_we$106;
	end
	wire [12:0] wb_in_ad$107;
	wire [31:0] wb_in_d$107;
	wire [7:0] wb_in_op$107;
	wire wb_in_we$107;
	reg [12:0] wb_ad$100 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$100 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$100 = 8'bxxxxxxxx;
	reg wb_we$100 = 0;
	always @(posedge clk) begin
		wb_ad$100 = wb_in_ad$107;
		wb_d$100 = wb_in_d$107;
		wb_op$100 = wb_in_op$107;
		wb_we$100 = wb_in_we$107;
	end
	wire [12:0] wb_in_ad$108;
	wire [31:0] wb_in_d$108;
	wire [7:0] wb_in_op$108;
	wire wb_in_we$108;
	reg [12:0] wb_ad$101 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$101 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$101 = 8'bxxxxxxxx;
	reg wb_we$101 = 0;
	always @(posedge clk) begin
		wb_ad$101 = wb_in_ad$108;
		wb_d$101 = wb_in_d$108;
		wb_op$101 = wb_in_op$108;
		wb_we$101 = wb_in_we$108;
	end
	wire [12:0] wb_in_ad$109;
	wire [31:0] wb_in_d$109;
	wire [7:0] wb_in_op$109;
	wire wb_in_we$109;
	reg [12:0] wb_ad$102 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$102 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$102 = 8'bxxxxxxxx;
	reg wb_we$102 = 0;
	always @(posedge clk) begin
		wb_ad$102 = wb_in_ad$109;
		wb_d$102 = wb_in_d$109;
		wb_op$102 = wb_in_op$109;
		wb_we$102 = wb_in_we$109;
	end
	wire [12:0] wb_in_ad$110;
	wire [31:0] wb_in_d$110;
	wire [7:0] wb_in_op$110;
	wire wb_in_we$110;
	reg [12:0] wb_ad$103 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$103 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$103 = 8'bxxxxxxxx;
	reg wb_we$103 = 0;
	always @(posedge clk) begin
		wb_ad$103 = wb_in_ad$110;
		wb_d$103 = wb_in_d$110;
		wb_op$103 = wb_in_op$110;
		wb_we$103 = wb_in_we$110;
	end
	wire [12:0] wb_in_ad$111;
	wire [31:0] wb_in_d$111;
	wire [7:0] wb_in_op$111;
	wire wb_in_we$111;
	reg [12:0] wb_ad$104 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$104 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$104 = 8'bxxxxxxxx;
	reg wb_we$104 = 0;
	always @(posedge clk) begin
		wb_ad$104 = wb_in_ad$111;
		wb_d$104 = wb_in_d$111;
		wb_op$104 = wb_in_op$111;
		wb_we$104 = wb_in_we$111;
	end
	assign retry_put$6 = (y_en$6[0] & wb_we$90) | (y_en$6[1] & wb_we$91) | (y_en$6[2] & wb_we$92) | (y_en$6[3] & wb_we$93) | (y_en$6[4] & wb_we$94) | (y_en$6[5] & wb_we$95) | (y_en$6[7] & wb_we$96) | (y_en$6[8] & wb_we$97) | (y_en$6[9] & wb_we$98) | (y_en$6[10] & wb_we$99) | (y_en$6[11] & wb_we$100) | (y_en$6[12] & wb_we$101) | (y_en$6[13] & wb_we$102) | (y_en$6[14] & wb_we$103) | (y_en$6[15] & wb_we$104);
	wire [32:0] acc_in$7;
	reg [32:0] acc$7 = 0;
	reg [32:0] acc_out$7;
	wire [16:0] pc_in$7;
	reg [16:0] pc$7 = 7;
	reg [16:0] pc_out$7;
	wire [7:0] op$7;
	wire [31:0] y$7;
	wire op_lock$7 = LOCK == op$7[7-:4];
	reg [3:0] lock_timer$7 = 0;
	always @(posedge clk) begin
		acc$7 <= acc_in$7;
		pc$7 <= pc_in$7;
		if (lock_timer$7) lock_timer$7 <= lock_timer$7 - 4'd1;
		else if (op_lock$7) lock_timer$7 <= y$7[0+:4];
	end
	wire retry_lock$7 = |lock_timer$7 & op_lock$7;
	wire [32:0] ax$7 = {op$7[2], {32{op$7[2]}} ^ acc$7[0+:32]};
	wire [32:0] ay$7 = {op$7[1], {32{op$7[1]}} ^ y$7};
	wire [4:0] ye$7 = op$7[0] ? y$7[0+:5] : -y$7[0+:5];
	wire [31:0] ys$7 = {{16{ye$7[4]}}, {16{~ye$7[4]}}} & {2{{{8{ye$7[3]}}, {8{~ye$7[3]}}} & {2{{{4{ye$7[2]}}, {4{~ye$7[2]}}} & {2{{{2{ye$7[1]}}, {2{~ye$7[1]}}} & {2{{ye$7[0], ~ye$7[0]}}}}}}}}};
	wire signed [32:0] mx$7 = {op$7[3] & acc$7[31], acc$7[0+:32]};
	wire signed [32:0] my$7 = op$7[2] ? {1'd0, ys$7} : {op$7[3] & y$7[31], y$7};
	wire signed [65:0] xy$7 = mx$7 * my$7;
	wire op_io$7 = IO == op$7[7-:3];
	wire [15:0] op_en$7 = {{8{op$7[3]}}, {8{~op$7[3]}}} & {2{{{4{op$7[2]}}, {4{~op$7[2]}}} & {2{{{2{op$7[1]}}, {2{~op$7[1]}}} & {2{{op$7[0] & op_io$7, ~op$7[0] & op_io$7}}}}}}};
	reg [32:0] acc_io$7;
	reg retry_io$7;
	wire retry_put$7;
	wire [2:0] opc$7 = acc$7[32] ? op$7[5:3] : op$7[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$7 = acc$7[31] ? opc$7[2] : !acc$7[30:0] ? opc$7[1] : opc$7[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$112;
	wire [31:0] wb_in_d$112;
	wire [7:0] wb_in_op$112;
	wire wb_in_we$112;
	reg [39:0] q$18;
	wire [12:0] _dpmem__wa$7 = wb_in_ad$112;
	wire _dpmem__we$7 = wb_in_we$112;
	wire [39:0] _dpmem__d$7 = {wb_in_d$112, wb_in_op$112};
	wire [12:0] _dpmem__ra$7 = pc_in$7[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$7 [0:6399];
	initial $readmemh("mem07.txt", _dpmem__mem$7);
	always @(posedge clk) begin
		if (_dpmem__we$7) _dpmem__mem$7[_dpmem__wa$7] <= _dpmem__d$7;
		q$18 <= _dpmem__mem$7[_dpmem__ra$7];
	end
	reg [31:0] fwd_y$7 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$7 = HALT;
	reg fwd_en$7 = 1;
	always @(posedge clk) begin
		fwd_y$7 = wb_in_d$112;
		fwd_op$7 = wb_in_op$112;
		fwd_en$7 = wb_in_we$112 & (wb_in_ad$112 == pc_in$7[16-:13]);
		if (pc_in$7[0+:4] != 4'd7) begin
			fwd_op$7 = HALT;
			fwd_en$7 = 1;
		end
	end
	assign y$7 = fwd_en$7 ? fwd_y$7 : q$18[39-:32];
	assign op$7 = fwd_en$7 ? fwd_op$7 : q$18[0+:8];
	wire op_put$7 = PUT == op$7[7-:2];
	wire [15:0] y_en$7 = {{8{y$7[3]}}, {8{~y$7[3]}}} & {2{{{4{y$7[2]}}, {4{~y$7[2]}}} & {2{{{2{y$7[1]}}, {2{~y$7[1]}}} & {2{{y$7[0] & op_put$7, ~y$7[0] & op_put$7}}}}}}};
	wire [12:0] wb_in_ad$113;
	wire [31:0] wb_in_d$113;
	wire [7:0] wb_in_op$113;
	wire wb_in_we$113;
	reg [12:0] wb_ad$105 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$105 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$105 = 8'bxxxxxxxx;
	reg wb_we$105 = 0;
	always @(posedge clk) begin
		wb_ad$105 = wb_in_ad$113;
		wb_d$105 = wb_in_d$113;
		wb_op$105 = wb_in_op$113;
		wb_we$105 = wb_in_we$113;
	end
	wire [12:0] wb_in_ad$114;
	wire [31:0] wb_in_d$114;
	wire [7:0] wb_in_op$114;
	wire wb_in_we$114;
	reg [12:0] wb_ad$106 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$106 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$106 = 8'bxxxxxxxx;
	reg wb_we$106 = 0;
	always @(posedge clk) begin
		wb_ad$106 = wb_in_ad$114;
		wb_d$106 = wb_in_d$114;
		wb_op$106 = wb_in_op$114;
		wb_we$106 = wb_in_we$114;
	end
	wire [12:0] wb_in_ad$115;
	wire [31:0] wb_in_d$115;
	wire [7:0] wb_in_op$115;
	wire wb_in_we$115;
	reg [12:0] wb_ad$107 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$107 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$107 = 8'bxxxxxxxx;
	reg wb_we$107 = 0;
	always @(posedge clk) begin
		wb_ad$107 = wb_in_ad$115;
		wb_d$107 = wb_in_d$115;
		wb_op$107 = wb_in_op$115;
		wb_we$107 = wb_in_we$115;
	end
	wire [12:0] wb_in_ad$116;
	wire [31:0] wb_in_d$116;
	wire [7:0] wb_in_op$116;
	wire wb_in_we$116;
	reg [12:0] wb_ad$108 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$108 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$108 = 8'bxxxxxxxx;
	reg wb_we$108 = 0;
	always @(posedge clk) begin
		wb_ad$108 = wb_in_ad$116;
		wb_d$108 = wb_in_d$116;
		wb_op$108 = wb_in_op$116;
		wb_we$108 = wb_in_we$116;
	end
	wire [12:0] wb_in_ad$117;
	wire [31:0] wb_in_d$117;
	wire [7:0] wb_in_op$117;
	wire wb_in_we$117;
	reg [12:0] wb_ad$109 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$109 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$109 = 8'bxxxxxxxx;
	reg wb_we$109 = 0;
	always @(posedge clk) begin
		wb_ad$109 = wb_in_ad$117;
		wb_d$109 = wb_in_d$117;
		wb_op$109 = wb_in_op$117;
		wb_we$109 = wb_in_we$117;
	end
	wire [12:0] wb_in_ad$118;
	wire [31:0] wb_in_d$118;
	wire [7:0] wb_in_op$118;
	wire wb_in_we$118;
	reg [12:0] wb_ad$110 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$110 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$110 = 8'bxxxxxxxx;
	reg wb_we$110 = 0;
	always @(posedge clk) begin
		wb_ad$110 = wb_in_ad$118;
		wb_d$110 = wb_in_d$118;
		wb_op$110 = wb_in_op$118;
		wb_we$110 = wb_in_we$118;
	end
	wire [12:0] wb_in_ad$119;
	wire [31:0] wb_in_d$119;
	wire [7:0] wb_in_op$119;
	wire wb_in_we$119;
	reg [12:0] wb_ad$111 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$111 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$111 = 8'bxxxxxxxx;
	reg wb_we$111 = 0;
	always @(posedge clk) begin
		wb_ad$111 = wb_in_ad$119;
		wb_d$111 = wb_in_d$119;
		wb_op$111 = wb_in_op$119;
		wb_we$111 = wb_in_we$119;
	end
	wire [12:0] wb_in_ad$120;
	wire [31:0] wb_in_d$120;
	wire [7:0] wb_in_op$120;
	wire wb_in_we$120;
	reg [12:0] wb_ad$112 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$112 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$112 = 8'bxxxxxxxx;
	reg wb_we$112 = 0;
	always @(posedge clk) begin
		wb_ad$112 = wb_in_ad$120;
		wb_d$112 = wb_in_d$120;
		wb_op$112 = wb_in_op$120;
		wb_we$112 = wb_in_we$120;
	end
	wire [12:0] wb_in_ad$121;
	wire [31:0] wb_in_d$121;
	wire [7:0] wb_in_op$121;
	wire wb_in_we$121;
	reg [12:0] wb_ad$113 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$113 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$113 = 8'bxxxxxxxx;
	reg wb_we$113 = 0;
	always @(posedge clk) begin
		wb_ad$113 = wb_in_ad$121;
		wb_d$113 = wb_in_d$121;
		wb_op$113 = wb_in_op$121;
		wb_we$113 = wb_in_we$121;
	end
	wire [12:0] wb_in_ad$122;
	wire [31:0] wb_in_d$122;
	wire [7:0] wb_in_op$122;
	wire wb_in_we$122;
	reg [12:0] wb_ad$114 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$114 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$114 = 8'bxxxxxxxx;
	reg wb_we$114 = 0;
	always @(posedge clk) begin
		wb_ad$114 = wb_in_ad$122;
		wb_d$114 = wb_in_d$122;
		wb_op$114 = wb_in_op$122;
		wb_we$114 = wb_in_we$122;
	end
	wire [12:0] wb_in_ad$123;
	wire [31:0] wb_in_d$123;
	wire [7:0] wb_in_op$123;
	wire wb_in_we$123;
	reg [12:0] wb_ad$115 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$115 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$115 = 8'bxxxxxxxx;
	reg wb_we$115 = 0;
	always @(posedge clk) begin
		wb_ad$115 = wb_in_ad$123;
		wb_d$115 = wb_in_d$123;
		wb_op$115 = wb_in_op$123;
		wb_we$115 = wb_in_we$123;
	end
	wire [12:0] wb_in_ad$124;
	wire [31:0] wb_in_d$124;
	wire [7:0] wb_in_op$124;
	wire wb_in_we$124;
	reg [12:0] wb_ad$116 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$116 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$116 = 8'bxxxxxxxx;
	reg wb_we$116 = 0;
	always @(posedge clk) begin
		wb_ad$116 = wb_in_ad$124;
		wb_d$116 = wb_in_d$124;
		wb_op$116 = wb_in_op$124;
		wb_we$116 = wb_in_we$124;
	end
	wire [12:0] wb_in_ad$125;
	wire [31:0] wb_in_d$125;
	wire [7:0] wb_in_op$125;
	wire wb_in_we$125;
	reg [12:0] wb_ad$117 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$117 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$117 = 8'bxxxxxxxx;
	reg wb_we$117 = 0;
	always @(posedge clk) begin
		wb_ad$117 = wb_in_ad$125;
		wb_d$117 = wb_in_d$125;
		wb_op$117 = wb_in_op$125;
		wb_we$117 = wb_in_we$125;
	end
	wire [12:0] wb_in_ad$126;
	wire [31:0] wb_in_d$126;
	wire [7:0] wb_in_op$126;
	wire wb_in_we$126;
	reg [12:0] wb_ad$118 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$118 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$118 = 8'bxxxxxxxx;
	reg wb_we$118 = 0;
	always @(posedge clk) begin
		wb_ad$118 = wb_in_ad$126;
		wb_d$118 = wb_in_d$126;
		wb_op$118 = wb_in_op$126;
		wb_we$118 = wb_in_we$126;
	end
	wire [12:0] wb_in_ad$127;
	wire [31:0] wb_in_d$127;
	wire [7:0] wb_in_op$127;
	wire wb_in_we$127;
	reg [12:0] wb_ad$119 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$119 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$119 = 8'bxxxxxxxx;
	reg wb_we$119 = 0;
	always @(posedge clk) begin
		wb_ad$119 = wb_in_ad$127;
		wb_d$119 = wb_in_d$127;
		wb_op$119 = wb_in_op$127;
		wb_we$119 = wb_in_we$127;
	end
	assign retry_put$7 = (y_en$7[0] & wb_we$105) | (y_en$7[1] & wb_we$106) | (y_en$7[2] & wb_we$107) | (y_en$7[3] & wb_we$108) | (y_en$7[4] & wb_we$109) | (y_en$7[5] & wb_we$110) | (y_en$7[6] & wb_we$111) | (y_en$7[8] & wb_we$112) | (y_en$7[9] & wb_we$113) | (y_en$7[10] & wb_we$114) | (y_en$7[11] & wb_we$115) | (y_en$7[12] & wb_we$116) | (y_en$7[13] & wb_we$117) | (y_en$7[14] & wb_we$118) | (y_en$7[15] & wb_we$119);
	wire [32:0] acc_in$8;
	reg [32:0] acc$8 = 0;
	reg [32:0] acc_out$8;
	wire [16:0] pc_in$8;
	reg [16:0] pc$8 = 8;
	reg [16:0] pc_out$8;
	wire [7:0] op$8;
	wire [31:0] y$8;
	wire op_lock$8 = LOCK == op$8[7-:4];
	reg [3:0] lock_timer$8 = 0;
	always @(posedge clk) begin
		acc$8 <= acc_in$8;
		pc$8 <= pc_in$8;
		if (lock_timer$8) lock_timer$8 <= lock_timer$8 - 4'd1;
		else if (op_lock$8) lock_timer$8 <= y$8[0+:4];
	end
	wire retry_lock$8 = |lock_timer$8 & op_lock$8;
	wire [32:0] ax$8 = {op$8[2], {32{op$8[2]}} ^ acc$8[0+:32]};
	wire [32:0] ay$8 = {op$8[1], {32{op$8[1]}} ^ y$8};
	wire [4:0] ye$8 = op$8[0] ? y$8[0+:5] : -y$8[0+:5];
	wire [31:0] ys$8 = {{16{ye$8[4]}}, {16{~ye$8[4]}}} & {2{{{8{ye$8[3]}}, {8{~ye$8[3]}}} & {2{{{4{ye$8[2]}}, {4{~ye$8[2]}}} & {2{{{2{ye$8[1]}}, {2{~ye$8[1]}}} & {2{{ye$8[0], ~ye$8[0]}}}}}}}}};
	wire signed [32:0] mx$8 = {op$8[3] & acc$8[31], acc$8[0+:32]};
	wire signed [32:0] my$8 = op$8[2] ? {1'd0, ys$8} : {op$8[3] & y$8[31], y$8};
	wire signed [65:0] xy$8 = mx$8 * my$8;
	wire op_io$8 = IO == op$8[7-:3];
	wire [15:0] op_en$8 = {{8{op$8[3]}}, {8{~op$8[3]}}} & {2{{{4{op$8[2]}}, {4{~op$8[2]}}} & {2{{{2{op$8[1]}}, {2{~op$8[1]}}} & {2{{op$8[0] & op_io$8, ~op$8[0] & op_io$8}}}}}}};
	reg [32:0] acc_io$8;
	reg retry_io$8;
	wire retry_put$8;
	wire [2:0] opc$8 = acc$8[32] ? op$8[5:3] : op$8[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$8 = acc$8[31] ? opc$8[2] : !acc$8[30:0] ? opc$8[1] : opc$8[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$128;
	wire [31:0] wb_in_d$128;
	wire [7:0] wb_in_op$128;
	wire wb_in_we$128;
	reg [39:0] q$19;
	wire [12:0] _dpmem__wa$8 = wb_in_ad$128;
	wire _dpmem__we$8 = wb_in_we$128;
	wire [39:0] _dpmem__d$8 = {wb_in_d$128, wb_in_op$128};
	wire [12:0] _dpmem__ra$8 = pc_in$8[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$8 [0:6399];
	initial $readmemh("mem08.txt", _dpmem__mem$8);
	always @(posedge clk) begin
		if (_dpmem__we$8) _dpmem__mem$8[_dpmem__wa$8] <= _dpmem__d$8;
		q$19 <= _dpmem__mem$8[_dpmem__ra$8];
	end
	reg [31:0] fwd_y$8 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$8 = HALT;
	reg fwd_en$8 = 1;
	always @(posedge clk) begin
		fwd_y$8 = wb_in_d$128;
		fwd_op$8 = wb_in_op$128;
		fwd_en$8 = wb_in_we$128 & (wb_in_ad$128 == pc_in$8[16-:13]);
		if (pc_in$8[0+:4] != 4'd8) begin
			fwd_op$8 = HALT;
			fwd_en$8 = 1;
		end
	end
	assign y$8 = fwd_en$8 ? fwd_y$8 : q$19[39-:32];
	assign op$8 = fwd_en$8 ? fwd_op$8 : q$19[0+:8];
	wire op_put$8 = PUT == op$8[7-:2];
	wire [15:0] y_en$8 = {{8{y$8[3]}}, {8{~y$8[3]}}} & {2{{{4{y$8[2]}}, {4{~y$8[2]}}} & {2{{{2{y$8[1]}}, {2{~y$8[1]}}} & {2{{y$8[0] & op_put$8, ~y$8[0] & op_put$8}}}}}}};
	wire [12:0] wb_in_ad$129;
	wire [31:0] wb_in_d$129;
	wire [7:0] wb_in_op$129;
	wire wb_in_we$129;
	reg [12:0] wb_ad$120 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$120 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$120 = 8'bxxxxxxxx;
	reg wb_we$120 = 0;
	always @(posedge clk) begin
		wb_ad$120 = wb_in_ad$129;
		wb_d$120 = wb_in_d$129;
		wb_op$120 = wb_in_op$129;
		wb_we$120 = wb_in_we$129;
	end
	wire [12:0] wb_in_ad$130;
	wire [31:0] wb_in_d$130;
	wire [7:0] wb_in_op$130;
	wire wb_in_we$130;
	reg [12:0] wb_ad$121 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$121 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$121 = 8'bxxxxxxxx;
	reg wb_we$121 = 0;
	always @(posedge clk) begin
		wb_ad$121 = wb_in_ad$130;
		wb_d$121 = wb_in_d$130;
		wb_op$121 = wb_in_op$130;
		wb_we$121 = wb_in_we$130;
	end
	wire [12:0] wb_in_ad$131;
	wire [31:0] wb_in_d$131;
	wire [7:0] wb_in_op$131;
	wire wb_in_we$131;
	reg [12:0] wb_ad$122 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$122 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$122 = 8'bxxxxxxxx;
	reg wb_we$122 = 0;
	always @(posedge clk) begin
		wb_ad$122 = wb_in_ad$131;
		wb_d$122 = wb_in_d$131;
		wb_op$122 = wb_in_op$131;
		wb_we$122 = wb_in_we$131;
	end
	wire [12:0] wb_in_ad$132;
	wire [31:0] wb_in_d$132;
	wire [7:0] wb_in_op$132;
	wire wb_in_we$132;
	reg [12:0] wb_ad$123 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$123 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$123 = 8'bxxxxxxxx;
	reg wb_we$123 = 0;
	always @(posedge clk) begin
		wb_ad$123 = wb_in_ad$132;
		wb_d$123 = wb_in_d$132;
		wb_op$123 = wb_in_op$132;
		wb_we$123 = wb_in_we$132;
	end
	wire [12:0] wb_in_ad$133;
	wire [31:0] wb_in_d$133;
	wire [7:0] wb_in_op$133;
	wire wb_in_we$133;
	reg [12:0] wb_ad$124 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$124 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$124 = 8'bxxxxxxxx;
	reg wb_we$124 = 0;
	always @(posedge clk) begin
		wb_ad$124 = wb_in_ad$133;
		wb_d$124 = wb_in_d$133;
		wb_op$124 = wb_in_op$133;
		wb_we$124 = wb_in_we$133;
	end
	wire [12:0] wb_in_ad$134;
	wire [31:0] wb_in_d$134;
	wire [7:0] wb_in_op$134;
	wire wb_in_we$134;
	reg [12:0] wb_ad$125 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$125 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$125 = 8'bxxxxxxxx;
	reg wb_we$125 = 0;
	always @(posedge clk) begin
		wb_ad$125 = wb_in_ad$134;
		wb_d$125 = wb_in_d$134;
		wb_op$125 = wb_in_op$134;
		wb_we$125 = wb_in_we$134;
	end
	wire [12:0] wb_in_ad$135;
	wire [31:0] wb_in_d$135;
	wire [7:0] wb_in_op$135;
	wire wb_in_we$135;
	reg [12:0] wb_ad$126 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$126 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$126 = 8'bxxxxxxxx;
	reg wb_we$126 = 0;
	always @(posedge clk) begin
		wb_ad$126 = wb_in_ad$135;
		wb_d$126 = wb_in_d$135;
		wb_op$126 = wb_in_op$135;
		wb_we$126 = wb_in_we$135;
	end
	wire [12:0] wb_in_ad$136;
	wire [31:0] wb_in_d$136;
	wire [7:0] wb_in_op$136;
	wire wb_in_we$136;
	reg [12:0] wb_ad$127 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$127 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$127 = 8'bxxxxxxxx;
	reg wb_we$127 = 0;
	always @(posedge clk) begin
		wb_ad$127 = wb_in_ad$136;
		wb_d$127 = wb_in_d$136;
		wb_op$127 = wb_in_op$136;
		wb_we$127 = wb_in_we$136;
	end
	wire [12:0] wb_in_ad$137;
	wire [31:0] wb_in_d$137;
	wire [7:0] wb_in_op$137;
	wire wb_in_we$137;
	reg [12:0] wb_ad$128 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$128 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$128 = 8'bxxxxxxxx;
	reg wb_we$128 = 0;
	always @(posedge clk) begin
		wb_ad$128 = wb_in_ad$137;
		wb_d$128 = wb_in_d$137;
		wb_op$128 = wb_in_op$137;
		wb_we$128 = wb_in_we$137;
	end
	wire [12:0] wb_in_ad$138;
	wire [31:0] wb_in_d$138;
	wire [7:0] wb_in_op$138;
	wire wb_in_we$138;
	reg [12:0] wb_ad$129 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$129 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$129 = 8'bxxxxxxxx;
	reg wb_we$129 = 0;
	always @(posedge clk) begin
		wb_ad$129 = wb_in_ad$138;
		wb_d$129 = wb_in_d$138;
		wb_op$129 = wb_in_op$138;
		wb_we$129 = wb_in_we$138;
	end
	wire [12:0] wb_in_ad$139;
	wire [31:0] wb_in_d$139;
	wire [7:0] wb_in_op$139;
	wire wb_in_we$139;
	reg [12:0] wb_ad$130 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$130 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$130 = 8'bxxxxxxxx;
	reg wb_we$130 = 0;
	always @(posedge clk) begin
		wb_ad$130 = wb_in_ad$139;
		wb_d$130 = wb_in_d$139;
		wb_op$130 = wb_in_op$139;
		wb_we$130 = wb_in_we$139;
	end
	wire [12:0] wb_in_ad$140;
	wire [31:0] wb_in_d$140;
	wire [7:0] wb_in_op$140;
	wire wb_in_we$140;
	reg [12:0] wb_ad$131 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$131 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$131 = 8'bxxxxxxxx;
	reg wb_we$131 = 0;
	always @(posedge clk) begin
		wb_ad$131 = wb_in_ad$140;
		wb_d$131 = wb_in_d$140;
		wb_op$131 = wb_in_op$140;
		wb_we$131 = wb_in_we$140;
	end
	wire [12:0] wb_in_ad$141;
	wire [31:0] wb_in_d$141;
	wire [7:0] wb_in_op$141;
	wire wb_in_we$141;
	reg [12:0] wb_ad$132 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$132 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$132 = 8'bxxxxxxxx;
	reg wb_we$132 = 0;
	always @(posedge clk) begin
		wb_ad$132 = wb_in_ad$141;
		wb_d$132 = wb_in_d$141;
		wb_op$132 = wb_in_op$141;
		wb_we$132 = wb_in_we$141;
	end
	wire [12:0] wb_in_ad$142;
	wire [31:0] wb_in_d$142;
	wire [7:0] wb_in_op$142;
	wire wb_in_we$142;
	reg [12:0] wb_ad$133 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$133 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$133 = 8'bxxxxxxxx;
	reg wb_we$133 = 0;
	always @(posedge clk) begin
		wb_ad$133 = wb_in_ad$142;
		wb_d$133 = wb_in_d$142;
		wb_op$133 = wb_in_op$142;
		wb_we$133 = wb_in_we$142;
	end
	wire [12:0] wb_in_ad$143;
	wire [31:0] wb_in_d$143;
	wire [7:0] wb_in_op$143;
	wire wb_in_we$143;
	reg [12:0] wb_ad$134 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$134 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$134 = 8'bxxxxxxxx;
	reg wb_we$134 = 0;
	always @(posedge clk) begin
		wb_ad$134 = wb_in_ad$143;
		wb_d$134 = wb_in_d$143;
		wb_op$134 = wb_in_op$143;
		wb_we$134 = wb_in_we$143;
	end
	assign retry_put$8 = (y_en$8[0] & wb_we$120) | (y_en$8[1] & wb_we$121) | (y_en$8[2] & wb_we$122) | (y_en$8[3] & wb_we$123) | (y_en$8[4] & wb_we$124) | (y_en$8[5] & wb_we$125) | (y_en$8[6] & wb_we$126) | (y_en$8[7] & wb_we$127) | (y_en$8[9] & wb_we$128) | (y_en$8[10] & wb_we$129) | (y_en$8[11] & wb_we$130) | (y_en$8[12] & wb_we$131) | (y_en$8[13] & wb_we$132) | (y_en$8[14] & wb_we$133) | (y_en$8[15] & wb_we$134);
	wire [32:0] acc_in$9;
	reg [32:0] acc$9 = 0;
	reg [32:0] acc_out$9;
	wire [16:0] pc_in$9;
	reg [16:0] pc$9 = 9;
	reg [16:0] pc_out$9;
	wire [7:0] op$9;
	wire [31:0] y$9;
	wire op_lock$9 = LOCK == op$9[7-:4];
	reg [3:0] lock_timer$9 = 0;
	always @(posedge clk) begin
		acc$9 <= acc_in$9;
		pc$9 <= pc_in$9;
		if (lock_timer$9) lock_timer$9 <= lock_timer$9 - 4'd1;
		else if (op_lock$9) lock_timer$9 <= y$9[0+:4];
	end
	wire retry_lock$9 = |lock_timer$9 & op_lock$9;
	wire [32:0] ax$9 = {op$9[2], {32{op$9[2]}} ^ acc$9[0+:32]};
	wire [32:0] ay$9 = {op$9[1], {32{op$9[1]}} ^ y$9};
	wire [4:0] ye$9 = op$9[0] ? y$9[0+:5] : -y$9[0+:5];
	wire [31:0] ys$9 = {{16{ye$9[4]}}, {16{~ye$9[4]}}} & {2{{{8{ye$9[3]}}, {8{~ye$9[3]}}} & {2{{{4{ye$9[2]}}, {4{~ye$9[2]}}} & {2{{{2{ye$9[1]}}, {2{~ye$9[1]}}} & {2{{ye$9[0], ~ye$9[0]}}}}}}}}};
	wire signed [32:0] mx$9 = {op$9[3] & acc$9[31], acc$9[0+:32]};
	wire signed [32:0] my$9 = op$9[2] ? {1'd0, ys$9} : {op$9[3] & y$9[31], y$9};
	wire signed [65:0] xy$9 = mx$9 * my$9;
	wire op_io$9 = IO == op$9[7-:3];
	wire [15:0] op_en$9 = {{8{op$9[3]}}, {8{~op$9[3]}}} & {2{{{4{op$9[2]}}, {4{~op$9[2]}}} & {2{{{2{op$9[1]}}, {2{~op$9[1]}}} & {2{{op$9[0] & op_io$9, ~op$9[0] & op_io$9}}}}}}};
	reg [32:0] acc_io$9;
	reg retry_io$9;
	wire retry_put$9;
	wire [2:0] opc$9 = acc$9[32] ? op$9[5:3] : op$9[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$9 = acc$9[31] ? opc$9[2] : !acc$9[30:0] ? opc$9[1] : opc$9[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$144;
	wire [31:0] wb_in_d$144;
	wire [7:0] wb_in_op$144;
	wire wb_in_we$144;
	reg [39:0] q$20;
	wire [12:0] _dpmem__wa$9 = wb_in_ad$144;
	wire _dpmem__we$9 = wb_in_we$144;
	wire [39:0] _dpmem__d$9 = {wb_in_d$144, wb_in_op$144};
	wire [12:0] _dpmem__ra$9 = pc_in$9[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$9 [0:6399];
	initial $readmemh("mem09.txt", _dpmem__mem$9);
	always @(posedge clk) begin
		if (_dpmem__we$9) _dpmem__mem$9[_dpmem__wa$9] <= _dpmem__d$9;
		q$20 <= _dpmem__mem$9[_dpmem__ra$9];
	end
	reg [31:0] fwd_y$9 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$9 = HALT;
	reg fwd_en$9 = 1;
	always @(posedge clk) begin
		fwd_y$9 = wb_in_d$144;
		fwd_op$9 = wb_in_op$144;
		fwd_en$9 = wb_in_we$144 & (wb_in_ad$144 == pc_in$9[16-:13]);
		if (pc_in$9[0+:4] != 4'd9) begin
			fwd_op$9 = HALT;
			fwd_en$9 = 1;
		end
	end
	assign y$9 = fwd_en$9 ? fwd_y$9 : q$20[39-:32];
	assign op$9 = fwd_en$9 ? fwd_op$9 : q$20[0+:8];
	wire op_put$9 = PUT == op$9[7-:2];
	wire [15:0] y_en$9 = {{8{y$9[3]}}, {8{~y$9[3]}}} & {2{{{4{y$9[2]}}, {4{~y$9[2]}}} & {2{{{2{y$9[1]}}, {2{~y$9[1]}}} & {2{{y$9[0] & op_put$9, ~y$9[0] & op_put$9}}}}}}};
	wire [12:0] wb_in_ad$145;
	wire [31:0] wb_in_d$145;
	wire [7:0] wb_in_op$145;
	wire wb_in_we$145;
	reg [12:0] wb_ad$135 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$135 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$135 = 8'bxxxxxxxx;
	reg wb_we$135 = 0;
	always @(posedge clk) begin
		wb_ad$135 = wb_in_ad$145;
		wb_d$135 = wb_in_d$145;
		wb_op$135 = wb_in_op$145;
		wb_we$135 = wb_in_we$145;
	end
	wire [12:0] wb_in_ad$146;
	wire [31:0] wb_in_d$146;
	wire [7:0] wb_in_op$146;
	wire wb_in_we$146;
	reg [12:0] wb_ad$136 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$136 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$136 = 8'bxxxxxxxx;
	reg wb_we$136 = 0;
	always @(posedge clk) begin
		wb_ad$136 = wb_in_ad$146;
		wb_d$136 = wb_in_d$146;
		wb_op$136 = wb_in_op$146;
		wb_we$136 = wb_in_we$146;
	end
	wire [12:0] wb_in_ad$147;
	wire [31:0] wb_in_d$147;
	wire [7:0] wb_in_op$147;
	wire wb_in_we$147;
	reg [12:0] wb_ad$137 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$137 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$137 = 8'bxxxxxxxx;
	reg wb_we$137 = 0;
	always @(posedge clk) begin
		wb_ad$137 = wb_in_ad$147;
		wb_d$137 = wb_in_d$147;
		wb_op$137 = wb_in_op$147;
		wb_we$137 = wb_in_we$147;
	end
	wire [12:0] wb_in_ad$148;
	wire [31:0] wb_in_d$148;
	wire [7:0] wb_in_op$148;
	wire wb_in_we$148;
	reg [12:0] wb_ad$138 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$138 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$138 = 8'bxxxxxxxx;
	reg wb_we$138 = 0;
	always @(posedge clk) begin
		wb_ad$138 = wb_in_ad$148;
		wb_d$138 = wb_in_d$148;
		wb_op$138 = wb_in_op$148;
		wb_we$138 = wb_in_we$148;
	end
	wire [12:0] wb_in_ad$149;
	wire [31:0] wb_in_d$149;
	wire [7:0] wb_in_op$149;
	wire wb_in_we$149;
	reg [12:0] wb_ad$139 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$139 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$139 = 8'bxxxxxxxx;
	reg wb_we$139 = 0;
	always @(posedge clk) begin
		wb_ad$139 = wb_in_ad$149;
		wb_d$139 = wb_in_d$149;
		wb_op$139 = wb_in_op$149;
		wb_we$139 = wb_in_we$149;
	end
	wire [12:0] wb_in_ad$150;
	wire [31:0] wb_in_d$150;
	wire [7:0] wb_in_op$150;
	wire wb_in_we$150;
	reg [12:0] wb_ad$140 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$140 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$140 = 8'bxxxxxxxx;
	reg wb_we$140 = 0;
	always @(posedge clk) begin
		wb_ad$140 = wb_in_ad$150;
		wb_d$140 = wb_in_d$150;
		wb_op$140 = wb_in_op$150;
		wb_we$140 = wb_in_we$150;
	end
	wire [12:0] wb_in_ad$151;
	wire [31:0] wb_in_d$151;
	wire [7:0] wb_in_op$151;
	wire wb_in_we$151;
	reg [12:0] wb_ad$141 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$141 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$141 = 8'bxxxxxxxx;
	reg wb_we$141 = 0;
	always @(posedge clk) begin
		wb_ad$141 = wb_in_ad$151;
		wb_d$141 = wb_in_d$151;
		wb_op$141 = wb_in_op$151;
		wb_we$141 = wb_in_we$151;
	end
	wire [12:0] wb_in_ad$152;
	wire [31:0] wb_in_d$152;
	wire [7:0] wb_in_op$152;
	wire wb_in_we$152;
	reg [12:0] wb_ad$142 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$142 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$142 = 8'bxxxxxxxx;
	reg wb_we$142 = 0;
	always @(posedge clk) begin
		wb_ad$142 = wb_in_ad$152;
		wb_d$142 = wb_in_d$152;
		wb_op$142 = wb_in_op$152;
		wb_we$142 = wb_in_we$152;
	end
	wire [12:0] wb_in_ad$153;
	wire [31:0] wb_in_d$153;
	wire [7:0] wb_in_op$153;
	wire wb_in_we$153;
	reg [12:0] wb_ad$143 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$143 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$143 = 8'bxxxxxxxx;
	reg wb_we$143 = 0;
	always @(posedge clk) begin
		wb_ad$143 = wb_in_ad$153;
		wb_d$143 = wb_in_d$153;
		wb_op$143 = wb_in_op$153;
		wb_we$143 = wb_in_we$153;
	end
	wire [12:0] wb_in_ad$154;
	wire [31:0] wb_in_d$154;
	wire [7:0] wb_in_op$154;
	wire wb_in_we$154;
	reg [12:0] wb_ad$144 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$144 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$144 = 8'bxxxxxxxx;
	reg wb_we$144 = 0;
	always @(posedge clk) begin
		wb_ad$144 = wb_in_ad$154;
		wb_d$144 = wb_in_d$154;
		wb_op$144 = wb_in_op$154;
		wb_we$144 = wb_in_we$154;
	end
	wire [12:0] wb_in_ad$155;
	wire [31:0] wb_in_d$155;
	wire [7:0] wb_in_op$155;
	wire wb_in_we$155;
	reg [12:0] wb_ad$145 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$145 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$145 = 8'bxxxxxxxx;
	reg wb_we$145 = 0;
	always @(posedge clk) begin
		wb_ad$145 = wb_in_ad$155;
		wb_d$145 = wb_in_d$155;
		wb_op$145 = wb_in_op$155;
		wb_we$145 = wb_in_we$155;
	end
	wire [12:0] wb_in_ad$156;
	wire [31:0] wb_in_d$156;
	wire [7:0] wb_in_op$156;
	wire wb_in_we$156;
	reg [12:0] wb_ad$146 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$146 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$146 = 8'bxxxxxxxx;
	reg wb_we$146 = 0;
	always @(posedge clk) begin
		wb_ad$146 = wb_in_ad$156;
		wb_d$146 = wb_in_d$156;
		wb_op$146 = wb_in_op$156;
		wb_we$146 = wb_in_we$156;
	end
	wire [12:0] wb_in_ad$157;
	wire [31:0] wb_in_d$157;
	wire [7:0] wb_in_op$157;
	wire wb_in_we$157;
	reg [12:0] wb_ad$147 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$147 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$147 = 8'bxxxxxxxx;
	reg wb_we$147 = 0;
	always @(posedge clk) begin
		wb_ad$147 = wb_in_ad$157;
		wb_d$147 = wb_in_d$157;
		wb_op$147 = wb_in_op$157;
		wb_we$147 = wb_in_we$157;
	end
	wire [12:0] wb_in_ad$158;
	wire [31:0] wb_in_d$158;
	wire [7:0] wb_in_op$158;
	wire wb_in_we$158;
	reg [12:0] wb_ad$148 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$148 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$148 = 8'bxxxxxxxx;
	reg wb_we$148 = 0;
	always @(posedge clk) begin
		wb_ad$148 = wb_in_ad$158;
		wb_d$148 = wb_in_d$158;
		wb_op$148 = wb_in_op$158;
		wb_we$148 = wb_in_we$158;
	end
	wire [12:0] wb_in_ad$159;
	wire [31:0] wb_in_d$159;
	wire [7:0] wb_in_op$159;
	wire wb_in_we$159;
	reg [12:0] wb_ad$149 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$149 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$149 = 8'bxxxxxxxx;
	reg wb_we$149 = 0;
	always @(posedge clk) begin
		wb_ad$149 = wb_in_ad$159;
		wb_d$149 = wb_in_d$159;
		wb_op$149 = wb_in_op$159;
		wb_we$149 = wb_in_we$159;
	end
	assign retry_put$9 = (y_en$9[0] & wb_we$135) | (y_en$9[1] & wb_we$136) | (y_en$9[2] & wb_we$137) | (y_en$9[3] & wb_we$138) | (y_en$9[4] & wb_we$139) | (y_en$9[5] & wb_we$140) | (y_en$9[6] & wb_we$141) | (y_en$9[7] & wb_we$142) | (y_en$9[8] & wb_we$143) | (y_en$9[10] & wb_we$144) | (y_en$9[11] & wb_we$145) | (y_en$9[12] & wb_we$146) | (y_en$9[13] & wb_we$147) | (y_en$9[14] & wb_we$148) | (y_en$9[15] & wb_we$149);
	wire [32:0] acc_in$10;
	reg [32:0] acc$10 = 0;
	reg [32:0] acc_out$10;
	wire [16:0] pc_in$10;
	reg [16:0] pc$10 = 10;
	reg [16:0] pc_out$10;
	wire [7:0] op$10;
	wire [31:0] y$10;
	wire op_lock$10 = LOCK == op$10[7-:4];
	reg [3:0] lock_timer$10 = 0;
	always @(posedge clk) begin
		acc$10 <= acc_in$10;
		pc$10 <= pc_in$10;
		if (lock_timer$10) lock_timer$10 <= lock_timer$10 - 4'd1;
		else if (op_lock$10) lock_timer$10 <= y$10[0+:4];
	end
	wire retry_lock$10 = |lock_timer$10 & op_lock$10;
	wire [32:0] ax$10 = {op$10[2], {32{op$10[2]}} ^ acc$10[0+:32]};
	wire [32:0] ay$10 = {op$10[1], {32{op$10[1]}} ^ y$10};
	wire [4:0] ye$10 = op$10[0] ? y$10[0+:5] : -y$10[0+:5];
	wire [31:0] ys$10 = {{16{ye$10[4]}}, {16{~ye$10[4]}}} & {2{{{8{ye$10[3]}}, {8{~ye$10[3]}}} & {2{{{4{ye$10[2]}}, {4{~ye$10[2]}}} & {2{{{2{ye$10[1]}}, {2{~ye$10[1]}}} & {2{{ye$10[0], ~ye$10[0]}}}}}}}}};
	wire signed [32:0] mx$10 = {op$10[3] & acc$10[31], acc$10[0+:32]};
	wire signed [32:0] my$10 = op$10[2] ? {1'd0, ys$10} : {op$10[3] & y$10[31], y$10};
	wire signed [65:0] xy$10 = mx$10 * my$10;
	wire op_io$10 = IO == op$10[7-:3];
	wire [15:0] op_en$10 = {{8{op$10[3]}}, {8{~op$10[3]}}} & {2{{{4{op$10[2]}}, {4{~op$10[2]}}} & {2{{{2{op$10[1]}}, {2{~op$10[1]}}} & {2{{op$10[0] & op_io$10, ~op$10[0] & op_io$10}}}}}}};
	reg [32:0] acc_io$10;
	reg retry_io$10;
	wire retry_put$10;
	wire [2:0] opc$10 = acc$10[32] ? op$10[5:3] : op$10[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$10 = acc$10[31] ? opc$10[2] : !acc$10[30:0] ? opc$10[1] : opc$10[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$160;
	wire [31:0] wb_in_d$160;
	wire [7:0] wb_in_op$160;
	wire wb_in_we$160;
	reg [39:0] q$21;
	wire [12:0] _dpmem__wa$10 = wb_in_ad$160;
	wire _dpmem__we$10 = wb_in_we$160;
	wire [39:0] _dpmem__d$10 = {wb_in_d$160, wb_in_op$160};
	wire [12:0] _dpmem__ra$10 = pc_in$10[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$10 [0:6399];
	initial $readmemh("mem10.txt", _dpmem__mem$10);
	always @(posedge clk) begin
		if (_dpmem__we$10) _dpmem__mem$10[_dpmem__wa$10] <= _dpmem__d$10;
		q$21 <= _dpmem__mem$10[_dpmem__ra$10];
	end
	reg [31:0] fwd_y$10 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$10 = HALT;
	reg fwd_en$10 = 1;
	always @(posedge clk) begin
		fwd_y$10 = wb_in_d$160;
		fwd_op$10 = wb_in_op$160;
		fwd_en$10 = wb_in_we$160 & (wb_in_ad$160 == pc_in$10[16-:13]);
		if (pc_in$10[0+:4] != 4'd10) begin
			fwd_op$10 = HALT;
			fwd_en$10 = 1;
		end
	end
	assign y$10 = fwd_en$10 ? fwd_y$10 : q$21[39-:32];
	assign op$10 = fwd_en$10 ? fwd_op$10 : q$21[0+:8];
	wire op_put$10 = PUT == op$10[7-:2];
	wire [15:0] y_en$10 = {{8{y$10[3]}}, {8{~y$10[3]}}} & {2{{{4{y$10[2]}}, {4{~y$10[2]}}} & {2{{{2{y$10[1]}}, {2{~y$10[1]}}} & {2{{y$10[0] & op_put$10, ~y$10[0] & op_put$10}}}}}}};
	wire [12:0] wb_in_ad$161;
	wire [31:0] wb_in_d$161;
	wire [7:0] wb_in_op$161;
	wire wb_in_we$161;
	reg [12:0] wb_ad$150 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$150 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$150 = 8'bxxxxxxxx;
	reg wb_we$150 = 0;
	always @(posedge clk) begin
		wb_ad$150 = wb_in_ad$161;
		wb_d$150 = wb_in_d$161;
		wb_op$150 = wb_in_op$161;
		wb_we$150 = wb_in_we$161;
	end
	wire [12:0] wb_in_ad$162;
	wire [31:0] wb_in_d$162;
	wire [7:0] wb_in_op$162;
	wire wb_in_we$162;
	reg [12:0] wb_ad$151 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$151 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$151 = 8'bxxxxxxxx;
	reg wb_we$151 = 0;
	always @(posedge clk) begin
		wb_ad$151 = wb_in_ad$162;
		wb_d$151 = wb_in_d$162;
		wb_op$151 = wb_in_op$162;
		wb_we$151 = wb_in_we$162;
	end
	wire [12:0] wb_in_ad$163;
	wire [31:0] wb_in_d$163;
	wire [7:0] wb_in_op$163;
	wire wb_in_we$163;
	reg [12:0] wb_ad$152 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$152 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$152 = 8'bxxxxxxxx;
	reg wb_we$152 = 0;
	always @(posedge clk) begin
		wb_ad$152 = wb_in_ad$163;
		wb_d$152 = wb_in_d$163;
		wb_op$152 = wb_in_op$163;
		wb_we$152 = wb_in_we$163;
	end
	wire [12:0] wb_in_ad$164;
	wire [31:0] wb_in_d$164;
	wire [7:0] wb_in_op$164;
	wire wb_in_we$164;
	reg [12:0] wb_ad$153 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$153 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$153 = 8'bxxxxxxxx;
	reg wb_we$153 = 0;
	always @(posedge clk) begin
		wb_ad$153 = wb_in_ad$164;
		wb_d$153 = wb_in_d$164;
		wb_op$153 = wb_in_op$164;
		wb_we$153 = wb_in_we$164;
	end
	wire [12:0] wb_in_ad$165;
	wire [31:0] wb_in_d$165;
	wire [7:0] wb_in_op$165;
	wire wb_in_we$165;
	reg [12:0] wb_ad$154 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$154 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$154 = 8'bxxxxxxxx;
	reg wb_we$154 = 0;
	always @(posedge clk) begin
		wb_ad$154 = wb_in_ad$165;
		wb_d$154 = wb_in_d$165;
		wb_op$154 = wb_in_op$165;
		wb_we$154 = wb_in_we$165;
	end
	wire [12:0] wb_in_ad$166;
	wire [31:0] wb_in_d$166;
	wire [7:0] wb_in_op$166;
	wire wb_in_we$166;
	reg [12:0] wb_ad$155 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$155 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$155 = 8'bxxxxxxxx;
	reg wb_we$155 = 0;
	always @(posedge clk) begin
		wb_ad$155 = wb_in_ad$166;
		wb_d$155 = wb_in_d$166;
		wb_op$155 = wb_in_op$166;
		wb_we$155 = wb_in_we$166;
	end
	wire [12:0] wb_in_ad$167;
	wire [31:0] wb_in_d$167;
	wire [7:0] wb_in_op$167;
	wire wb_in_we$167;
	reg [12:0] wb_ad$156 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$156 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$156 = 8'bxxxxxxxx;
	reg wb_we$156 = 0;
	always @(posedge clk) begin
		wb_ad$156 = wb_in_ad$167;
		wb_d$156 = wb_in_d$167;
		wb_op$156 = wb_in_op$167;
		wb_we$156 = wb_in_we$167;
	end
	wire [12:0] wb_in_ad$168;
	wire [31:0] wb_in_d$168;
	wire [7:0] wb_in_op$168;
	wire wb_in_we$168;
	reg [12:0] wb_ad$157 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$157 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$157 = 8'bxxxxxxxx;
	reg wb_we$157 = 0;
	always @(posedge clk) begin
		wb_ad$157 = wb_in_ad$168;
		wb_d$157 = wb_in_d$168;
		wb_op$157 = wb_in_op$168;
		wb_we$157 = wb_in_we$168;
	end
	wire [12:0] wb_in_ad$169;
	wire [31:0] wb_in_d$169;
	wire [7:0] wb_in_op$169;
	wire wb_in_we$169;
	reg [12:0] wb_ad$158 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$158 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$158 = 8'bxxxxxxxx;
	reg wb_we$158 = 0;
	always @(posedge clk) begin
		wb_ad$158 = wb_in_ad$169;
		wb_d$158 = wb_in_d$169;
		wb_op$158 = wb_in_op$169;
		wb_we$158 = wb_in_we$169;
	end
	wire [12:0] wb_in_ad$170;
	wire [31:0] wb_in_d$170;
	wire [7:0] wb_in_op$170;
	wire wb_in_we$170;
	reg [12:0] wb_ad$159 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$159 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$159 = 8'bxxxxxxxx;
	reg wb_we$159 = 0;
	always @(posedge clk) begin
		wb_ad$159 = wb_in_ad$170;
		wb_d$159 = wb_in_d$170;
		wb_op$159 = wb_in_op$170;
		wb_we$159 = wb_in_we$170;
	end
	wire [12:0] wb_in_ad$171;
	wire [31:0] wb_in_d$171;
	wire [7:0] wb_in_op$171;
	wire wb_in_we$171;
	reg [12:0] wb_ad$160 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$160 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$160 = 8'bxxxxxxxx;
	reg wb_we$160 = 0;
	always @(posedge clk) begin
		wb_ad$160 = wb_in_ad$171;
		wb_d$160 = wb_in_d$171;
		wb_op$160 = wb_in_op$171;
		wb_we$160 = wb_in_we$171;
	end
	wire [12:0] wb_in_ad$172;
	wire [31:0] wb_in_d$172;
	wire [7:0] wb_in_op$172;
	wire wb_in_we$172;
	reg [12:0] wb_ad$161 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$161 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$161 = 8'bxxxxxxxx;
	reg wb_we$161 = 0;
	always @(posedge clk) begin
		wb_ad$161 = wb_in_ad$172;
		wb_d$161 = wb_in_d$172;
		wb_op$161 = wb_in_op$172;
		wb_we$161 = wb_in_we$172;
	end
	wire [12:0] wb_in_ad$173;
	wire [31:0] wb_in_d$173;
	wire [7:0] wb_in_op$173;
	wire wb_in_we$173;
	reg [12:0] wb_ad$162 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$162 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$162 = 8'bxxxxxxxx;
	reg wb_we$162 = 0;
	always @(posedge clk) begin
		wb_ad$162 = wb_in_ad$173;
		wb_d$162 = wb_in_d$173;
		wb_op$162 = wb_in_op$173;
		wb_we$162 = wb_in_we$173;
	end
	wire [12:0] wb_in_ad$174;
	wire [31:0] wb_in_d$174;
	wire [7:0] wb_in_op$174;
	wire wb_in_we$174;
	reg [12:0] wb_ad$163 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$163 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$163 = 8'bxxxxxxxx;
	reg wb_we$163 = 0;
	always @(posedge clk) begin
		wb_ad$163 = wb_in_ad$174;
		wb_d$163 = wb_in_d$174;
		wb_op$163 = wb_in_op$174;
		wb_we$163 = wb_in_we$174;
	end
	wire [12:0] wb_in_ad$175;
	wire [31:0] wb_in_d$175;
	wire [7:0] wb_in_op$175;
	wire wb_in_we$175;
	reg [12:0] wb_ad$164 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$164 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$164 = 8'bxxxxxxxx;
	reg wb_we$164 = 0;
	always @(posedge clk) begin
		wb_ad$164 = wb_in_ad$175;
		wb_d$164 = wb_in_d$175;
		wb_op$164 = wb_in_op$175;
		wb_we$164 = wb_in_we$175;
	end
	assign retry_put$10 = (y_en$10[0] & wb_we$150) | (y_en$10[1] & wb_we$151) | (y_en$10[2] & wb_we$152) | (y_en$10[3] & wb_we$153) | (y_en$10[4] & wb_we$154) | (y_en$10[5] & wb_we$155) | (y_en$10[6] & wb_we$156) | (y_en$10[7] & wb_we$157) | (y_en$10[8] & wb_we$158) | (y_en$10[9] & wb_we$159) | (y_en$10[11] & wb_we$160) | (y_en$10[12] & wb_we$161) | (y_en$10[13] & wb_we$162) | (y_en$10[14] & wb_we$163) | (y_en$10[15] & wb_we$164);
	wire [32:0] acc_in$11;
	reg [32:0] acc$11 = 0;
	reg [32:0] acc_out$11;
	wire [16:0] pc_in$11;
	reg [16:0] pc$11 = 11;
	reg [16:0] pc_out$11;
	wire [7:0] op$11;
	wire [31:0] y$11;
	wire op_lock$11 = LOCK == op$11[7-:4];
	reg [3:0] lock_timer$11 = 0;
	always @(posedge clk) begin
		acc$11 <= acc_in$11;
		pc$11 <= pc_in$11;
		if (lock_timer$11) lock_timer$11 <= lock_timer$11 - 4'd1;
		else if (op_lock$11) lock_timer$11 <= y$11[0+:4];
	end
	wire retry_lock$11 = |lock_timer$11 & op_lock$11;
	wire [32:0] ax$11 = {op$11[2], {32{op$11[2]}} ^ acc$11[0+:32]};
	wire [32:0] ay$11 = {op$11[1], {32{op$11[1]}} ^ y$11};
	wire [4:0] ye$11 = op$11[0] ? y$11[0+:5] : -y$11[0+:5];
	wire [31:0] ys$11 = {{16{ye$11[4]}}, {16{~ye$11[4]}}} & {2{{{8{ye$11[3]}}, {8{~ye$11[3]}}} & {2{{{4{ye$11[2]}}, {4{~ye$11[2]}}} & {2{{{2{ye$11[1]}}, {2{~ye$11[1]}}} & {2{{ye$11[0], ~ye$11[0]}}}}}}}}};
	wire signed [32:0] mx$11 = {op$11[3] & acc$11[31], acc$11[0+:32]};
	wire signed [32:0] my$11 = op$11[2] ? {1'd0, ys$11} : {op$11[3] & y$11[31], y$11};
	wire signed [65:0] xy$11 = mx$11 * my$11;
	wire op_io$11 = IO == op$11[7-:3];
	wire [15:0] op_en$11 = {{8{op$11[3]}}, {8{~op$11[3]}}} & {2{{{4{op$11[2]}}, {4{~op$11[2]}}} & {2{{{2{op$11[1]}}, {2{~op$11[1]}}} & {2{{op$11[0] & op_io$11, ~op$11[0] & op_io$11}}}}}}};
	reg [32:0] acc_io$11;
	reg retry_io$11;
	wire retry_put$11;
	wire [2:0] opc$11 = acc$11[32] ? op$11[5:3] : op$11[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$11 = acc$11[31] ? opc$11[2] : !acc$11[30:0] ? opc$11[1] : opc$11[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$176;
	wire [31:0] wb_in_d$176;
	wire [7:0] wb_in_op$176;
	wire wb_in_we$176;
	reg [39:0] q$22;
	wire [12:0] _dpmem__wa$11 = wb_in_ad$176;
	wire _dpmem__we$11 = wb_in_we$176;
	wire [39:0] _dpmem__d$11 = {wb_in_d$176, wb_in_op$176};
	wire [12:0] _dpmem__ra$11 = pc_in$11[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$11 [0:6399];
	initial $readmemh("mem11.txt", _dpmem__mem$11);
	always @(posedge clk) begin
		if (_dpmem__we$11) _dpmem__mem$11[_dpmem__wa$11] <= _dpmem__d$11;
		q$22 <= _dpmem__mem$11[_dpmem__ra$11];
	end
	reg [31:0] fwd_y$11 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$11 = HALT;
	reg fwd_en$11 = 1;
	always @(posedge clk) begin
		fwd_y$11 = wb_in_d$176;
		fwd_op$11 = wb_in_op$176;
		fwd_en$11 = wb_in_we$176 & (wb_in_ad$176 == pc_in$11[16-:13]);
		if (pc_in$11[0+:4] != 4'd11) begin
			fwd_op$11 = HALT;
			fwd_en$11 = 1;
		end
	end
	assign y$11 = fwd_en$11 ? fwd_y$11 : q$22[39-:32];
	assign op$11 = fwd_en$11 ? fwd_op$11 : q$22[0+:8];
	wire op_put$11 = PUT == op$11[7-:2];
	wire [15:0] y_en$11 = {{8{y$11[3]}}, {8{~y$11[3]}}} & {2{{{4{y$11[2]}}, {4{~y$11[2]}}} & {2{{{2{y$11[1]}}, {2{~y$11[1]}}} & {2{{y$11[0] & op_put$11, ~y$11[0] & op_put$11}}}}}}};
	wire [12:0] wb_in_ad$177;
	wire [31:0] wb_in_d$177;
	wire [7:0] wb_in_op$177;
	wire wb_in_we$177;
	reg [12:0] wb_ad$165 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$165 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$165 = 8'bxxxxxxxx;
	reg wb_we$165 = 0;
	always @(posedge clk) begin
		wb_ad$165 = wb_in_ad$177;
		wb_d$165 = wb_in_d$177;
		wb_op$165 = wb_in_op$177;
		wb_we$165 = wb_in_we$177;
	end
	wire [12:0] wb_in_ad$178;
	wire [31:0] wb_in_d$178;
	wire [7:0] wb_in_op$178;
	wire wb_in_we$178;
	reg [12:0] wb_ad$166 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$166 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$166 = 8'bxxxxxxxx;
	reg wb_we$166 = 0;
	always @(posedge clk) begin
		wb_ad$166 = wb_in_ad$178;
		wb_d$166 = wb_in_d$178;
		wb_op$166 = wb_in_op$178;
		wb_we$166 = wb_in_we$178;
	end
	wire [12:0] wb_in_ad$179;
	wire [31:0] wb_in_d$179;
	wire [7:0] wb_in_op$179;
	wire wb_in_we$179;
	reg [12:0] wb_ad$167 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$167 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$167 = 8'bxxxxxxxx;
	reg wb_we$167 = 0;
	always @(posedge clk) begin
		wb_ad$167 = wb_in_ad$179;
		wb_d$167 = wb_in_d$179;
		wb_op$167 = wb_in_op$179;
		wb_we$167 = wb_in_we$179;
	end
	wire [12:0] wb_in_ad$180;
	wire [31:0] wb_in_d$180;
	wire [7:0] wb_in_op$180;
	wire wb_in_we$180;
	reg [12:0] wb_ad$168 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$168 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$168 = 8'bxxxxxxxx;
	reg wb_we$168 = 0;
	always @(posedge clk) begin
		wb_ad$168 = wb_in_ad$180;
		wb_d$168 = wb_in_d$180;
		wb_op$168 = wb_in_op$180;
		wb_we$168 = wb_in_we$180;
	end
	wire [12:0] wb_in_ad$181;
	wire [31:0] wb_in_d$181;
	wire [7:0] wb_in_op$181;
	wire wb_in_we$181;
	reg [12:0] wb_ad$169 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$169 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$169 = 8'bxxxxxxxx;
	reg wb_we$169 = 0;
	always @(posedge clk) begin
		wb_ad$169 = wb_in_ad$181;
		wb_d$169 = wb_in_d$181;
		wb_op$169 = wb_in_op$181;
		wb_we$169 = wb_in_we$181;
	end
	wire [12:0] wb_in_ad$182;
	wire [31:0] wb_in_d$182;
	wire [7:0] wb_in_op$182;
	wire wb_in_we$182;
	reg [12:0] wb_ad$170 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$170 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$170 = 8'bxxxxxxxx;
	reg wb_we$170 = 0;
	always @(posedge clk) begin
		wb_ad$170 = wb_in_ad$182;
		wb_d$170 = wb_in_d$182;
		wb_op$170 = wb_in_op$182;
		wb_we$170 = wb_in_we$182;
	end
	wire [12:0] wb_in_ad$183;
	wire [31:0] wb_in_d$183;
	wire [7:0] wb_in_op$183;
	wire wb_in_we$183;
	reg [12:0] wb_ad$171 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$171 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$171 = 8'bxxxxxxxx;
	reg wb_we$171 = 0;
	always @(posedge clk) begin
		wb_ad$171 = wb_in_ad$183;
		wb_d$171 = wb_in_d$183;
		wb_op$171 = wb_in_op$183;
		wb_we$171 = wb_in_we$183;
	end
	wire [12:0] wb_in_ad$184;
	wire [31:0] wb_in_d$184;
	wire [7:0] wb_in_op$184;
	wire wb_in_we$184;
	reg [12:0] wb_ad$172 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$172 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$172 = 8'bxxxxxxxx;
	reg wb_we$172 = 0;
	always @(posedge clk) begin
		wb_ad$172 = wb_in_ad$184;
		wb_d$172 = wb_in_d$184;
		wb_op$172 = wb_in_op$184;
		wb_we$172 = wb_in_we$184;
	end
	wire [12:0] wb_in_ad$185;
	wire [31:0] wb_in_d$185;
	wire [7:0] wb_in_op$185;
	wire wb_in_we$185;
	reg [12:0] wb_ad$173 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$173 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$173 = 8'bxxxxxxxx;
	reg wb_we$173 = 0;
	always @(posedge clk) begin
		wb_ad$173 = wb_in_ad$185;
		wb_d$173 = wb_in_d$185;
		wb_op$173 = wb_in_op$185;
		wb_we$173 = wb_in_we$185;
	end
	wire [12:0] wb_in_ad$186;
	wire [31:0] wb_in_d$186;
	wire [7:0] wb_in_op$186;
	wire wb_in_we$186;
	reg [12:0] wb_ad$174 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$174 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$174 = 8'bxxxxxxxx;
	reg wb_we$174 = 0;
	always @(posedge clk) begin
		wb_ad$174 = wb_in_ad$186;
		wb_d$174 = wb_in_d$186;
		wb_op$174 = wb_in_op$186;
		wb_we$174 = wb_in_we$186;
	end
	wire [12:0] wb_in_ad$187;
	wire [31:0] wb_in_d$187;
	wire [7:0] wb_in_op$187;
	wire wb_in_we$187;
	reg [12:0] wb_ad$175 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$175 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$175 = 8'bxxxxxxxx;
	reg wb_we$175 = 0;
	always @(posedge clk) begin
		wb_ad$175 = wb_in_ad$187;
		wb_d$175 = wb_in_d$187;
		wb_op$175 = wb_in_op$187;
		wb_we$175 = wb_in_we$187;
	end
	wire [12:0] wb_in_ad$188;
	wire [31:0] wb_in_d$188;
	wire [7:0] wb_in_op$188;
	wire wb_in_we$188;
	reg [12:0] wb_ad$176 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$176 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$176 = 8'bxxxxxxxx;
	reg wb_we$176 = 0;
	always @(posedge clk) begin
		wb_ad$176 = wb_in_ad$188;
		wb_d$176 = wb_in_d$188;
		wb_op$176 = wb_in_op$188;
		wb_we$176 = wb_in_we$188;
	end
	wire [12:0] wb_in_ad$189;
	wire [31:0] wb_in_d$189;
	wire [7:0] wb_in_op$189;
	wire wb_in_we$189;
	reg [12:0] wb_ad$177 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$177 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$177 = 8'bxxxxxxxx;
	reg wb_we$177 = 0;
	always @(posedge clk) begin
		wb_ad$177 = wb_in_ad$189;
		wb_d$177 = wb_in_d$189;
		wb_op$177 = wb_in_op$189;
		wb_we$177 = wb_in_we$189;
	end
	wire [12:0] wb_in_ad$190;
	wire [31:0] wb_in_d$190;
	wire [7:0] wb_in_op$190;
	wire wb_in_we$190;
	reg [12:0] wb_ad$178 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$178 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$178 = 8'bxxxxxxxx;
	reg wb_we$178 = 0;
	always @(posedge clk) begin
		wb_ad$178 = wb_in_ad$190;
		wb_d$178 = wb_in_d$190;
		wb_op$178 = wb_in_op$190;
		wb_we$178 = wb_in_we$190;
	end
	wire [12:0] wb_in_ad$191;
	wire [31:0] wb_in_d$191;
	wire [7:0] wb_in_op$191;
	wire wb_in_we$191;
	reg [12:0] wb_ad$179 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$179 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$179 = 8'bxxxxxxxx;
	reg wb_we$179 = 0;
	always @(posedge clk) begin
		wb_ad$179 = wb_in_ad$191;
		wb_d$179 = wb_in_d$191;
		wb_op$179 = wb_in_op$191;
		wb_we$179 = wb_in_we$191;
	end
	assign retry_put$11 = (y_en$11[0] & wb_we$165) | (y_en$11[1] & wb_we$166) | (y_en$11[2] & wb_we$167) | (y_en$11[3] & wb_we$168) | (y_en$11[4] & wb_we$169) | (y_en$11[5] & wb_we$170) | (y_en$11[6] & wb_we$171) | (y_en$11[7] & wb_we$172) | (y_en$11[8] & wb_we$173) | (y_en$11[9] & wb_we$174) | (y_en$11[10] & wb_we$175) | (y_en$11[12] & wb_we$176) | (y_en$11[13] & wb_we$177) | (y_en$11[14] & wb_we$178) | (y_en$11[15] & wb_we$179);
	wire [32:0] acc_in$12;
	reg [32:0] acc$12 = 0;
	reg [32:0] acc_out$12;
	wire [16:0] pc_in$12;
	reg [16:0] pc$12 = 12;
	reg [16:0] pc_out$12;
	wire [7:0] op$12;
	wire [31:0] y$12;
	wire op_lock$12 = LOCK == op$12[7-:4];
	reg [3:0] lock_timer$12 = 0;
	always @(posedge clk) begin
		acc$12 <= acc_in$12;
		pc$12 <= pc_in$12;
		if (lock_timer$12) lock_timer$12 <= lock_timer$12 - 4'd1;
		else if (op_lock$12) lock_timer$12 <= y$12[0+:4];
	end
	wire retry_lock$12 = |lock_timer$12 & op_lock$12;
	wire [32:0] ax$12 = {op$12[2], {32{op$12[2]}} ^ acc$12[0+:32]};
	wire [32:0] ay$12 = {op$12[1], {32{op$12[1]}} ^ y$12};
	wire [4:0] ye$12 = op$12[0] ? y$12[0+:5] : -y$12[0+:5];
	wire [31:0] ys$12 = {{16{ye$12[4]}}, {16{~ye$12[4]}}} & {2{{{8{ye$12[3]}}, {8{~ye$12[3]}}} & {2{{{4{ye$12[2]}}, {4{~ye$12[2]}}} & {2{{{2{ye$12[1]}}, {2{~ye$12[1]}}} & {2{{ye$12[0], ~ye$12[0]}}}}}}}}};
	wire signed [32:0] mx$12 = {op$12[3] & acc$12[31], acc$12[0+:32]};
	wire signed [32:0] my$12 = op$12[2] ? {1'd0, ys$12} : {op$12[3] & y$12[31], y$12};
	wire signed [65:0] xy$12 = mx$12 * my$12;
	wire op_io$12 = IO == op$12[7-:3];
	wire [15:0] op_en$12 = {{8{op$12[3]}}, {8{~op$12[3]}}} & {2{{{4{op$12[2]}}, {4{~op$12[2]}}} & {2{{{2{op$12[1]}}, {2{~op$12[1]}}} & {2{{op$12[0] & op_io$12, ~op$12[0] & op_io$12}}}}}}};
	reg [32:0] acc_io$12;
	reg retry_io$12;
	wire retry_put$12;
	wire [2:0] opc$12 = acc$12[32] ? op$12[5:3] : op$12[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$12 = acc$12[31] ? opc$12[2] : !acc$12[30:0] ? opc$12[1] : opc$12[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$192;
	wire [31:0] wb_in_d$192;
	wire [7:0] wb_in_op$192;
	wire wb_in_we$192;
	reg [39:0] q$23;
	wire [12:0] _dpmem__wa$12 = wb_in_ad$192;
	wire _dpmem__we$12 = wb_in_we$192;
	wire [39:0] _dpmem__d$12 = {wb_in_d$192, wb_in_op$192};
	wire [12:0] _dpmem__ra$12 = pc_in$12[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$12 [0:6399];
	initial $readmemh("mem12.txt", _dpmem__mem$12);
	always @(posedge clk) begin
		if (_dpmem__we$12) _dpmem__mem$12[_dpmem__wa$12] <= _dpmem__d$12;
		q$23 <= _dpmem__mem$12[_dpmem__ra$12];
	end
	reg [31:0] fwd_y$12 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$12 = HALT;
	reg fwd_en$12 = 1;
	always @(posedge clk) begin
		fwd_y$12 = wb_in_d$192;
		fwd_op$12 = wb_in_op$192;
		fwd_en$12 = wb_in_we$192 & (wb_in_ad$192 == pc_in$12[16-:13]);
		if (pc_in$12[0+:4] != 4'd12) begin
			fwd_op$12 = HALT;
			fwd_en$12 = 1;
		end
	end
	assign y$12 = fwd_en$12 ? fwd_y$12 : q$23[39-:32];
	assign op$12 = fwd_en$12 ? fwd_op$12 : q$23[0+:8];
	wire op_put$12 = PUT == op$12[7-:2];
	wire [15:0] y_en$12 = {{8{y$12[3]}}, {8{~y$12[3]}}} & {2{{{4{y$12[2]}}, {4{~y$12[2]}}} & {2{{{2{y$12[1]}}, {2{~y$12[1]}}} & {2{{y$12[0] & op_put$12, ~y$12[0] & op_put$12}}}}}}};
	wire [12:0] wb_in_ad$193;
	wire [31:0] wb_in_d$193;
	wire [7:0] wb_in_op$193;
	wire wb_in_we$193;
	reg [12:0] wb_ad$180 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$180 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$180 = 8'bxxxxxxxx;
	reg wb_we$180 = 0;
	always @(posedge clk) begin
		wb_ad$180 = wb_in_ad$193;
		wb_d$180 = wb_in_d$193;
		wb_op$180 = wb_in_op$193;
		wb_we$180 = wb_in_we$193;
	end
	wire [12:0] wb_in_ad$194;
	wire [31:0] wb_in_d$194;
	wire [7:0] wb_in_op$194;
	wire wb_in_we$194;
	reg [12:0] wb_ad$181 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$181 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$181 = 8'bxxxxxxxx;
	reg wb_we$181 = 0;
	always @(posedge clk) begin
		wb_ad$181 = wb_in_ad$194;
		wb_d$181 = wb_in_d$194;
		wb_op$181 = wb_in_op$194;
		wb_we$181 = wb_in_we$194;
	end
	wire [12:0] wb_in_ad$195;
	wire [31:0] wb_in_d$195;
	wire [7:0] wb_in_op$195;
	wire wb_in_we$195;
	reg [12:0] wb_ad$182 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$182 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$182 = 8'bxxxxxxxx;
	reg wb_we$182 = 0;
	always @(posedge clk) begin
		wb_ad$182 = wb_in_ad$195;
		wb_d$182 = wb_in_d$195;
		wb_op$182 = wb_in_op$195;
		wb_we$182 = wb_in_we$195;
	end
	wire [12:0] wb_in_ad$196;
	wire [31:0] wb_in_d$196;
	wire [7:0] wb_in_op$196;
	wire wb_in_we$196;
	reg [12:0] wb_ad$183 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$183 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$183 = 8'bxxxxxxxx;
	reg wb_we$183 = 0;
	always @(posedge clk) begin
		wb_ad$183 = wb_in_ad$196;
		wb_d$183 = wb_in_d$196;
		wb_op$183 = wb_in_op$196;
		wb_we$183 = wb_in_we$196;
	end
	wire [12:0] wb_in_ad$197;
	wire [31:0] wb_in_d$197;
	wire [7:0] wb_in_op$197;
	wire wb_in_we$197;
	reg [12:0] wb_ad$184 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$184 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$184 = 8'bxxxxxxxx;
	reg wb_we$184 = 0;
	always @(posedge clk) begin
		wb_ad$184 = wb_in_ad$197;
		wb_d$184 = wb_in_d$197;
		wb_op$184 = wb_in_op$197;
		wb_we$184 = wb_in_we$197;
	end
	wire [12:0] wb_in_ad$198;
	wire [31:0] wb_in_d$198;
	wire [7:0] wb_in_op$198;
	wire wb_in_we$198;
	reg [12:0] wb_ad$185 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$185 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$185 = 8'bxxxxxxxx;
	reg wb_we$185 = 0;
	always @(posedge clk) begin
		wb_ad$185 = wb_in_ad$198;
		wb_d$185 = wb_in_d$198;
		wb_op$185 = wb_in_op$198;
		wb_we$185 = wb_in_we$198;
	end
	wire [12:0] wb_in_ad$199;
	wire [31:0] wb_in_d$199;
	wire [7:0] wb_in_op$199;
	wire wb_in_we$199;
	reg [12:0] wb_ad$186 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$186 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$186 = 8'bxxxxxxxx;
	reg wb_we$186 = 0;
	always @(posedge clk) begin
		wb_ad$186 = wb_in_ad$199;
		wb_d$186 = wb_in_d$199;
		wb_op$186 = wb_in_op$199;
		wb_we$186 = wb_in_we$199;
	end
	wire [12:0] wb_in_ad$200;
	wire [31:0] wb_in_d$200;
	wire [7:0] wb_in_op$200;
	wire wb_in_we$200;
	reg [12:0] wb_ad$187 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$187 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$187 = 8'bxxxxxxxx;
	reg wb_we$187 = 0;
	always @(posedge clk) begin
		wb_ad$187 = wb_in_ad$200;
		wb_d$187 = wb_in_d$200;
		wb_op$187 = wb_in_op$200;
		wb_we$187 = wb_in_we$200;
	end
	wire [12:0] wb_in_ad$201;
	wire [31:0] wb_in_d$201;
	wire [7:0] wb_in_op$201;
	wire wb_in_we$201;
	reg [12:0] wb_ad$188 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$188 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$188 = 8'bxxxxxxxx;
	reg wb_we$188 = 0;
	always @(posedge clk) begin
		wb_ad$188 = wb_in_ad$201;
		wb_d$188 = wb_in_d$201;
		wb_op$188 = wb_in_op$201;
		wb_we$188 = wb_in_we$201;
	end
	wire [12:0] wb_in_ad$202;
	wire [31:0] wb_in_d$202;
	wire [7:0] wb_in_op$202;
	wire wb_in_we$202;
	reg [12:0] wb_ad$189 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$189 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$189 = 8'bxxxxxxxx;
	reg wb_we$189 = 0;
	always @(posedge clk) begin
		wb_ad$189 = wb_in_ad$202;
		wb_d$189 = wb_in_d$202;
		wb_op$189 = wb_in_op$202;
		wb_we$189 = wb_in_we$202;
	end
	wire [12:0] wb_in_ad$203;
	wire [31:0] wb_in_d$203;
	wire [7:0] wb_in_op$203;
	wire wb_in_we$203;
	reg [12:0] wb_ad$190 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$190 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$190 = 8'bxxxxxxxx;
	reg wb_we$190 = 0;
	always @(posedge clk) begin
		wb_ad$190 = wb_in_ad$203;
		wb_d$190 = wb_in_d$203;
		wb_op$190 = wb_in_op$203;
		wb_we$190 = wb_in_we$203;
	end
	wire [12:0] wb_in_ad$204;
	wire [31:0] wb_in_d$204;
	wire [7:0] wb_in_op$204;
	wire wb_in_we$204;
	reg [12:0] wb_ad$191 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$191 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$191 = 8'bxxxxxxxx;
	reg wb_we$191 = 0;
	always @(posedge clk) begin
		wb_ad$191 = wb_in_ad$204;
		wb_d$191 = wb_in_d$204;
		wb_op$191 = wb_in_op$204;
		wb_we$191 = wb_in_we$204;
	end
	wire [12:0] wb_in_ad$205;
	wire [31:0] wb_in_d$205;
	wire [7:0] wb_in_op$205;
	wire wb_in_we$205;
	reg [12:0] wb_ad$192 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$192 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$192 = 8'bxxxxxxxx;
	reg wb_we$192 = 0;
	always @(posedge clk) begin
		wb_ad$192 = wb_in_ad$205;
		wb_d$192 = wb_in_d$205;
		wb_op$192 = wb_in_op$205;
		wb_we$192 = wb_in_we$205;
	end
	wire [12:0] wb_in_ad$206;
	wire [31:0] wb_in_d$206;
	wire [7:0] wb_in_op$206;
	wire wb_in_we$206;
	reg [12:0] wb_ad$193 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$193 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$193 = 8'bxxxxxxxx;
	reg wb_we$193 = 0;
	always @(posedge clk) begin
		wb_ad$193 = wb_in_ad$206;
		wb_d$193 = wb_in_d$206;
		wb_op$193 = wb_in_op$206;
		wb_we$193 = wb_in_we$206;
	end
	wire [12:0] wb_in_ad$207;
	wire [31:0] wb_in_d$207;
	wire [7:0] wb_in_op$207;
	wire wb_in_we$207;
	reg [12:0] wb_ad$194 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$194 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$194 = 8'bxxxxxxxx;
	reg wb_we$194 = 0;
	always @(posedge clk) begin
		wb_ad$194 = wb_in_ad$207;
		wb_d$194 = wb_in_d$207;
		wb_op$194 = wb_in_op$207;
		wb_we$194 = wb_in_we$207;
	end
	assign retry_put$12 = (y_en$12[0] & wb_we$180) | (y_en$12[1] & wb_we$181) | (y_en$12[2] & wb_we$182) | (y_en$12[3] & wb_we$183) | (y_en$12[4] & wb_we$184) | (y_en$12[5] & wb_we$185) | (y_en$12[6] & wb_we$186) | (y_en$12[7] & wb_we$187) | (y_en$12[8] & wb_we$188) | (y_en$12[9] & wb_we$189) | (y_en$12[10] & wb_we$190) | (y_en$12[11] & wb_we$191) | (y_en$12[13] & wb_we$192) | (y_en$12[14] & wb_we$193) | (y_en$12[15] & wb_we$194);
	wire [32:0] acc_in$13;
	reg [32:0] acc$13 = 0;
	reg [32:0] acc_out$13;
	wire [16:0] pc_in$13;
	reg [16:0] pc$13 = 13;
	reg [16:0] pc_out$13;
	wire [7:0] op$13;
	wire [31:0] y$13;
	wire op_lock$13 = LOCK == op$13[7-:4];
	reg [3:0] lock_timer$13 = 0;
	always @(posedge clk) begin
		acc$13 <= acc_in$13;
		pc$13 <= pc_in$13;
		if (lock_timer$13) lock_timer$13 <= lock_timer$13 - 4'd1;
		else if (op_lock$13) lock_timer$13 <= y$13[0+:4];
	end
	wire retry_lock$13 = |lock_timer$13 & op_lock$13;
	wire [32:0] ax$13 = {op$13[2], {32{op$13[2]}} ^ acc$13[0+:32]};
	wire [32:0] ay$13 = {op$13[1], {32{op$13[1]}} ^ y$13};
	wire [4:0] ye$13 = op$13[0] ? y$13[0+:5] : -y$13[0+:5];
	wire [31:0] ys$13 = {{16{ye$13[4]}}, {16{~ye$13[4]}}} & {2{{{8{ye$13[3]}}, {8{~ye$13[3]}}} & {2{{{4{ye$13[2]}}, {4{~ye$13[2]}}} & {2{{{2{ye$13[1]}}, {2{~ye$13[1]}}} & {2{{ye$13[0], ~ye$13[0]}}}}}}}}};
	wire signed [32:0] mx$13 = {op$13[3] & acc$13[31], acc$13[0+:32]};
	wire signed [32:0] my$13 = op$13[2] ? {1'd0, ys$13} : {op$13[3] & y$13[31], y$13};
	wire signed [65:0] xy$13 = mx$13 * my$13;
	wire op_io$13 = IO == op$13[7-:3];
	wire [15:0] op_en$13 = {{8{op$13[3]}}, {8{~op$13[3]}}} & {2{{{4{op$13[2]}}, {4{~op$13[2]}}} & {2{{{2{op$13[1]}}, {2{~op$13[1]}}} & {2{{op$13[0] & op_io$13, ~op$13[0] & op_io$13}}}}}}};
	reg [32:0] acc_io$13;
	reg retry_io$13;
	wire retry_put$13;
	wire [2:0] opc$13 = acc$13[32] ? op$13[5:3] : op$13[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$13 = acc$13[31] ? opc$13[2] : !acc$13[30:0] ? opc$13[1] : opc$13[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$208;
	wire [31:0] wb_in_d$208;
	wire [7:0] wb_in_op$208;
	wire wb_in_we$208;
	reg [39:0] q$24;
	wire [12:0] _dpmem__wa$13 = wb_in_ad$208;
	wire _dpmem__we$13 = wb_in_we$208;
	wire [39:0] _dpmem__d$13 = {wb_in_d$208, wb_in_op$208};
	wire [12:0] _dpmem__ra$13 = pc_in$13[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$13 [0:6399];
	initial $readmemh("mem13.txt", _dpmem__mem$13);
	always @(posedge clk) begin
		if (_dpmem__we$13) _dpmem__mem$13[_dpmem__wa$13] <= _dpmem__d$13;
		q$24 <= _dpmem__mem$13[_dpmem__ra$13];
	end
	reg [31:0] fwd_y$13 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$13 = HALT;
	reg fwd_en$13 = 1;
	always @(posedge clk) begin
		fwd_y$13 = wb_in_d$208;
		fwd_op$13 = wb_in_op$208;
		fwd_en$13 = wb_in_we$208 & (wb_in_ad$208 == pc_in$13[16-:13]);
		if (pc_in$13[0+:4] != 4'd13) begin
			fwd_op$13 = HALT;
			fwd_en$13 = 1;
		end
	end
	assign y$13 = fwd_en$13 ? fwd_y$13 : q$24[39-:32];
	assign op$13 = fwd_en$13 ? fwd_op$13 : q$24[0+:8];
	wire op_put$13 = PUT == op$13[7-:2];
	wire [15:0] y_en$13 = {{8{y$13[3]}}, {8{~y$13[3]}}} & {2{{{4{y$13[2]}}, {4{~y$13[2]}}} & {2{{{2{y$13[1]}}, {2{~y$13[1]}}} & {2{{y$13[0] & op_put$13, ~y$13[0] & op_put$13}}}}}}};
	wire [12:0] wb_in_ad$209;
	wire [31:0] wb_in_d$209;
	wire [7:0] wb_in_op$209;
	wire wb_in_we$209;
	reg [12:0] wb_ad$195 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$195 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$195 = 8'bxxxxxxxx;
	reg wb_we$195 = 0;
	always @(posedge clk) begin
		wb_ad$195 = wb_in_ad$209;
		wb_d$195 = wb_in_d$209;
		wb_op$195 = wb_in_op$209;
		wb_we$195 = wb_in_we$209;
	end
	wire [12:0] wb_in_ad$210;
	wire [31:0] wb_in_d$210;
	wire [7:0] wb_in_op$210;
	wire wb_in_we$210;
	reg [12:0] wb_ad$196 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$196 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$196 = 8'bxxxxxxxx;
	reg wb_we$196 = 0;
	always @(posedge clk) begin
		wb_ad$196 = wb_in_ad$210;
		wb_d$196 = wb_in_d$210;
		wb_op$196 = wb_in_op$210;
		wb_we$196 = wb_in_we$210;
	end
	wire [12:0] wb_in_ad$211;
	wire [31:0] wb_in_d$211;
	wire [7:0] wb_in_op$211;
	wire wb_in_we$211;
	reg [12:0] wb_ad$197 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$197 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$197 = 8'bxxxxxxxx;
	reg wb_we$197 = 0;
	always @(posedge clk) begin
		wb_ad$197 = wb_in_ad$211;
		wb_d$197 = wb_in_d$211;
		wb_op$197 = wb_in_op$211;
		wb_we$197 = wb_in_we$211;
	end
	wire [12:0] wb_in_ad$212;
	wire [31:0] wb_in_d$212;
	wire [7:0] wb_in_op$212;
	wire wb_in_we$212;
	reg [12:0] wb_ad$198 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$198 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$198 = 8'bxxxxxxxx;
	reg wb_we$198 = 0;
	always @(posedge clk) begin
		wb_ad$198 = wb_in_ad$212;
		wb_d$198 = wb_in_d$212;
		wb_op$198 = wb_in_op$212;
		wb_we$198 = wb_in_we$212;
	end
	wire [12:0] wb_in_ad$213;
	wire [31:0] wb_in_d$213;
	wire [7:0] wb_in_op$213;
	wire wb_in_we$213;
	reg [12:0] wb_ad$199 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$199 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$199 = 8'bxxxxxxxx;
	reg wb_we$199 = 0;
	always @(posedge clk) begin
		wb_ad$199 = wb_in_ad$213;
		wb_d$199 = wb_in_d$213;
		wb_op$199 = wb_in_op$213;
		wb_we$199 = wb_in_we$213;
	end
	wire [12:0] wb_in_ad$214;
	wire [31:0] wb_in_d$214;
	wire [7:0] wb_in_op$214;
	wire wb_in_we$214;
	reg [12:0] wb_ad$200 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$200 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$200 = 8'bxxxxxxxx;
	reg wb_we$200 = 0;
	always @(posedge clk) begin
		wb_ad$200 = wb_in_ad$214;
		wb_d$200 = wb_in_d$214;
		wb_op$200 = wb_in_op$214;
		wb_we$200 = wb_in_we$214;
	end
	wire [12:0] wb_in_ad$215;
	wire [31:0] wb_in_d$215;
	wire [7:0] wb_in_op$215;
	wire wb_in_we$215;
	reg [12:0] wb_ad$201 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$201 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$201 = 8'bxxxxxxxx;
	reg wb_we$201 = 0;
	always @(posedge clk) begin
		wb_ad$201 = wb_in_ad$215;
		wb_d$201 = wb_in_d$215;
		wb_op$201 = wb_in_op$215;
		wb_we$201 = wb_in_we$215;
	end
	wire [12:0] wb_in_ad$216;
	wire [31:0] wb_in_d$216;
	wire [7:0] wb_in_op$216;
	wire wb_in_we$216;
	reg [12:0] wb_ad$202 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$202 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$202 = 8'bxxxxxxxx;
	reg wb_we$202 = 0;
	always @(posedge clk) begin
		wb_ad$202 = wb_in_ad$216;
		wb_d$202 = wb_in_d$216;
		wb_op$202 = wb_in_op$216;
		wb_we$202 = wb_in_we$216;
	end
	wire [12:0] wb_in_ad$217;
	wire [31:0] wb_in_d$217;
	wire [7:0] wb_in_op$217;
	wire wb_in_we$217;
	reg [12:0] wb_ad$203 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$203 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$203 = 8'bxxxxxxxx;
	reg wb_we$203 = 0;
	always @(posedge clk) begin
		wb_ad$203 = wb_in_ad$217;
		wb_d$203 = wb_in_d$217;
		wb_op$203 = wb_in_op$217;
		wb_we$203 = wb_in_we$217;
	end
	wire [12:0] wb_in_ad$218;
	wire [31:0] wb_in_d$218;
	wire [7:0] wb_in_op$218;
	wire wb_in_we$218;
	reg [12:0] wb_ad$204 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$204 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$204 = 8'bxxxxxxxx;
	reg wb_we$204 = 0;
	always @(posedge clk) begin
		wb_ad$204 = wb_in_ad$218;
		wb_d$204 = wb_in_d$218;
		wb_op$204 = wb_in_op$218;
		wb_we$204 = wb_in_we$218;
	end
	wire [12:0] wb_in_ad$219;
	wire [31:0] wb_in_d$219;
	wire [7:0] wb_in_op$219;
	wire wb_in_we$219;
	reg [12:0] wb_ad$205 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$205 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$205 = 8'bxxxxxxxx;
	reg wb_we$205 = 0;
	always @(posedge clk) begin
		wb_ad$205 = wb_in_ad$219;
		wb_d$205 = wb_in_d$219;
		wb_op$205 = wb_in_op$219;
		wb_we$205 = wb_in_we$219;
	end
	wire [12:0] wb_in_ad$220;
	wire [31:0] wb_in_d$220;
	wire [7:0] wb_in_op$220;
	wire wb_in_we$220;
	reg [12:0] wb_ad$206 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$206 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$206 = 8'bxxxxxxxx;
	reg wb_we$206 = 0;
	always @(posedge clk) begin
		wb_ad$206 = wb_in_ad$220;
		wb_d$206 = wb_in_d$220;
		wb_op$206 = wb_in_op$220;
		wb_we$206 = wb_in_we$220;
	end
	wire [12:0] wb_in_ad$221;
	wire [31:0] wb_in_d$221;
	wire [7:0] wb_in_op$221;
	wire wb_in_we$221;
	reg [12:0] wb_ad$207 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$207 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$207 = 8'bxxxxxxxx;
	reg wb_we$207 = 0;
	always @(posedge clk) begin
		wb_ad$207 = wb_in_ad$221;
		wb_d$207 = wb_in_d$221;
		wb_op$207 = wb_in_op$221;
		wb_we$207 = wb_in_we$221;
	end
	wire [12:0] wb_in_ad$222;
	wire [31:0] wb_in_d$222;
	wire [7:0] wb_in_op$222;
	wire wb_in_we$222;
	reg [12:0] wb_ad$208 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$208 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$208 = 8'bxxxxxxxx;
	reg wb_we$208 = 0;
	always @(posedge clk) begin
		wb_ad$208 = wb_in_ad$222;
		wb_d$208 = wb_in_d$222;
		wb_op$208 = wb_in_op$222;
		wb_we$208 = wb_in_we$222;
	end
	wire [12:0] wb_in_ad$223;
	wire [31:0] wb_in_d$223;
	wire [7:0] wb_in_op$223;
	wire wb_in_we$223;
	reg [12:0] wb_ad$209 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$209 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$209 = 8'bxxxxxxxx;
	reg wb_we$209 = 0;
	always @(posedge clk) begin
		wb_ad$209 = wb_in_ad$223;
		wb_d$209 = wb_in_d$223;
		wb_op$209 = wb_in_op$223;
		wb_we$209 = wb_in_we$223;
	end
	assign retry_put$13 = (y_en$13[0] & wb_we$195) | (y_en$13[1] & wb_we$196) | (y_en$13[2] & wb_we$197) | (y_en$13[3] & wb_we$198) | (y_en$13[4] & wb_we$199) | (y_en$13[5] & wb_we$200) | (y_en$13[6] & wb_we$201) | (y_en$13[7] & wb_we$202) | (y_en$13[8] & wb_we$203) | (y_en$13[9] & wb_we$204) | (y_en$13[10] & wb_we$205) | (y_en$13[11] & wb_we$206) | (y_en$13[12] & wb_we$207) | (y_en$13[14] & wb_we$208) | (y_en$13[15] & wb_we$209);
	wire [32:0] acc_in$14;
	reg [32:0] acc$14 = 0;
	reg [32:0] acc_out$14;
	wire [16:0] pc_in$14;
	reg [16:0] pc$14 = 14;
	reg [16:0] pc_out$14;
	wire [7:0] op$14;
	wire [31:0] y$14;
	wire op_lock$14 = LOCK == op$14[7-:4];
	reg [3:0] lock_timer$14 = 0;
	always @(posedge clk) begin
		acc$14 <= acc_in$14;
		pc$14 <= pc_in$14;
		if (lock_timer$14) lock_timer$14 <= lock_timer$14 - 4'd1;
		else if (op_lock$14) lock_timer$14 <= y$14[0+:4];
	end
	wire retry_lock$14 = |lock_timer$14 & op_lock$14;
	wire [32:0] ax$14 = {op$14[2], {32{op$14[2]}} ^ acc$14[0+:32]};
	wire [32:0] ay$14 = {op$14[1], {32{op$14[1]}} ^ y$14};
	wire [4:0] ye$14 = op$14[0] ? y$14[0+:5] : -y$14[0+:5];
	wire [31:0] ys$14 = {{16{ye$14[4]}}, {16{~ye$14[4]}}} & {2{{{8{ye$14[3]}}, {8{~ye$14[3]}}} & {2{{{4{ye$14[2]}}, {4{~ye$14[2]}}} & {2{{{2{ye$14[1]}}, {2{~ye$14[1]}}} & {2{{ye$14[0], ~ye$14[0]}}}}}}}}};
	wire signed [32:0] mx$14 = {op$14[3] & acc$14[31], acc$14[0+:32]};
	wire signed [32:0] my$14 = op$14[2] ? {1'd0, ys$14} : {op$14[3] & y$14[31], y$14};
	wire signed [65:0] xy$14 = mx$14 * my$14;
	wire op_io$14 = IO == op$14[7-:3];
	wire [15:0] op_en$14 = {{8{op$14[3]}}, {8{~op$14[3]}}} & {2{{{4{op$14[2]}}, {4{~op$14[2]}}} & {2{{{2{op$14[1]}}, {2{~op$14[1]}}} & {2{{op$14[0] & op_io$14, ~op$14[0] & op_io$14}}}}}}};
	reg [32:0] acc_io$14;
	reg retry_io$14;
	wire retry_put$14;
	wire [2:0] opc$14 = acc$14[32] ? op$14[5:3] : op$14[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$14 = acc$14[31] ? opc$14[2] : !acc$14[30:0] ? opc$14[1] : opc$14[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$224;
	wire [31:0] wb_in_d$224;
	wire [7:0] wb_in_op$224;
	wire wb_in_we$224;
	reg [39:0] q$25;
	wire [12:0] _dpmem__wa$14 = wb_in_ad$224;
	wire _dpmem__we$14 = wb_in_we$224;
	wire [39:0] _dpmem__d$14 = {wb_in_d$224, wb_in_op$224};
	wire [12:0] _dpmem__ra$14 = pc_in$14[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$14 [0:6399];
	initial $readmemh("mem14.txt", _dpmem__mem$14);
	always @(posedge clk) begin
		if (_dpmem__we$14) _dpmem__mem$14[_dpmem__wa$14] <= _dpmem__d$14;
		q$25 <= _dpmem__mem$14[_dpmem__ra$14];
	end
	reg [31:0] fwd_y$14 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$14 = HALT;
	reg fwd_en$14 = 1;
	always @(posedge clk) begin
		fwd_y$14 = wb_in_d$224;
		fwd_op$14 = wb_in_op$224;
		fwd_en$14 = wb_in_we$224 & (wb_in_ad$224 == pc_in$14[16-:13]);
		if (pc_in$14[0+:4] != 4'd14) begin
			fwd_op$14 = HALT;
			fwd_en$14 = 1;
		end
	end
	assign y$14 = fwd_en$14 ? fwd_y$14 : q$25[39-:32];
	assign op$14 = fwd_en$14 ? fwd_op$14 : q$25[0+:8];
	wire op_put$14 = PUT == op$14[7-:2];
	wire [15:0] y_en$14 = {{8{y$14[3]}}, {8{~y$14[3]}}} & {2{{{4{y$14[2]}}, {4{~y$14[2]}}} & {2{{{2{y$14[1]}}, {2{~y$14[1]}}} & {2{{y$14[0] & op_put$14, ~y$14[0] & op_put$14}}}}}}};
	wire [12:0] wb_in_ad$225;
	wire [31:0] wb_in_d$225;
	wire [7:0] wb_in_op$225;
	wire wb_in_we$225;
	reg [12:0] wb_ad$210 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$210 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$210 = 8'bxxxxxxxx;
	reg wb_we$210 = 0;
	always @(posedge clk) begin
		wb_ad$210 = wb_in_ad$225;
		wb_d$210 = wb_in_d$225;
		wb_op$210 = wb_in_op$225;
		wb_we$210 = wb_in_we$225;
	end
	wire [12:0] wb_in_ad$226;
	wire [31:0] wb_in_d$226;
	wire [7:0] wb_in_op$226;
	wire wb_in_we$226;
	reg [12:0] wb_ad$211 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$211 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$211 = 8'bxxxxxxxx;
	reg wb_we$211 = 0;
	always @(posedge clk) begin
		wb_ad$211 = wb_in_ad$226;
		wb_d$211 = wb_in_d$226;
		wb_op$211 = wb_in_op$226;
		wb_we$211 = wb_in_we$226;
	end
	wire [12:0] wb_in_ad$227;
	wire [31:0] wb_in_d$227;
	wire [7:0] wb_in_op$227;
	wire wb_in_we$227;
	reg [12:0] wb_ad$212 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$212 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$212 = 8'bxxxxxxxx;
	reg wb_we$212 = 0;
	always @(posedge clk) begin
		wb_ad$212 = wb_in_ad$227;
		wb_d$212 = wb_in_d$227;
		wb_op$212 = wb_in_op$227;
		wb_we$212 = wb_in_we$227;
	end
	wire [12:0] wb_in_ad$228;
	wire [31:0] wb_in_d$228;
	wire [7:0] wb_in_op$228;
	wire wb_in_we$228;
	reg [12:0] wb_ad$213 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$213 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$213 = 8'bxxxxxxxx;
	reg wb_we$213 = 0;
	always @(posedge clk) begin
		wb_ad$213 = wb_in_ad$228;
		wb_d$213 = wb_in_d$228;
		wb_op$213 = wb_in_op$228;
		wb_we$213 = wb_in_we$228;
	end
	wire [12:0] wb_in_ad$229;
	wire [31:0] wb_in_d$229;
	wire [7:0] wb_in_op$229;
	wire wb_in_we$229;
	reg [12:0] wb_ad$214 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$214 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$214 = 8'bxxxxxxxx;
	reg wb_we$214 = 0;
	always @(posedge clk) begin
		wb_ad$214 = wb_in_ad$229;
		wb_d$214 = wb_in_d$229;
		wb_op$214 = wb_in_op$229;
		wb_we$214 = wb_in_we$229;
	end
	wire [12:0] wb_in_ad$230;
	wire [31:0] wb_in_d$230;
	wire [7:0] wb_in_op$230;
	wire wb_in_we$230;
	reg [12:0] wb_ad$215 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$215 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$215 = 8'bxxxxxxxx;
	reg wb_we$215 = 0;
	always @(posedge clk) begin
		wb_ad$215 = wb_in_ad$230;
		wb_d$215 = wb_in_d$230;
		wb_op$215 = wb_in_op$230;
		wb_we$215 = wb_in_we$230;
	end
	wire [12:0] wb_in_ad$231;
	wire [31:0] wb_in_d$231;
	wire [7:0] wb_in_op$231;
	wire wb_in_we$231;
	reg [12:0] wb_ad$216 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$216 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$216 = 8'bxxxxxxxx;
	reg wb_we$216 = 0;
	always @(posedge clk) begin
		wb_ad$216 = wb_in_ad$231;
		wb_d$216 = wb_in_d$231;
		wb_op$216 = wb_in_op$231;
		wb_we$216 = wb_in_we$231;
	end
	wire [12:0] wb_in_ad$232;
	wire [31:0] wb_in_d$232;
	wire [7:0] wb_in_op$232;
	wire wb_in_we$232;
	reg [12:0] wb_ad$217 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$217 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$217 = 8'bxxxxxxxx;
	reg wb_we$217 = 0;
	always @(posedge clk) begin
		wb_ad$217 = wb_in_ad$232;
		wb_d$217 = wb_in_d$232;
		wb_op$217 = wb_in_op$232;
		wb_we$217 = wb_in_we$232;
	end
	wire [12:0] wb_in_ad$233;
	wire [31:0] wb_in_d$233;
	wire [7:0] wb_in_op$233;
	wire wb_in_we$233;
	reg [12:0] wb_ad$218 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$218 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$218 = 8'bxxxxxxxx;
	reg wb_we$218 = 0;
	always @(posedge clk) begin
		wb_ad$218 = wb_in_ad$233;
		wb_d$218 = wb_in_d$233;
		wb_op$218 = wb_in_op$233;
		wb_we$218 = wb_in_we$233;
	end
	wire [12:0] wb_in_ad$234;
	wire [31:0] wb_in_d$234;
	wire [7:0] wb_in_op$234;
	wire wb_in_we$234;
	reg [12:0] wb_ad$219 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$219 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$219 = 8'bxxxxxxxx;
	reg wb_we$219 = 0;
	always @(posedge clk) begin
		wb_ad$219 = wb_in_ad$234;
		wb_d$219 = wb_in_d$234;
		wb_op$219 = wb_in_op$234;
		wb_we$219 = wb_in_we$234;
	end
	wire [12:0] wb_in_ad$235;
	wire [31:0] wb_in_d$235;
	wire [7:0] wb_in_op$235;
	wire wb_in_we$235;
	reg [12:0] wb_ad$220 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$220 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$220 = 8'bxxxxxxxx;
	reg wb_we$220 = 0;
	always @(posedge clk) begin
		wb_ad$220 = wb_in_ad$235;
		wb_d$220 = wb_in_d$235;
		wb_op$220 = wb_in_op$235;
		wb_we$220 = wb_in_we$235;
	end
	wire [12:0] wb_in_ad$236;
	wire [31:0] wb_in_d$236;
	wire [7:0] wb_in_op$236;
	wire wb_in_we$236;
	reg [12:0] wb_ad$221 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$221 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$221 = 8'bxxxxxxxx;
	reg wb_we$221 = 0;
	always @(posedge clk) begin
		wb_ad$221 = wb_in_ad$236;
		wb_d$221 = wb_in_d$236;
		wb_op$221 = wb_in_op$236;
		wb_we$221 = wb_in_we$236;
	end
	wire [12:0] wb_in_ad$237;
	wire [31:0] wb_in_d$237;
	wire [7:0] wb_in_op$237;
	wire wb_in_we$237;
	reg [12:0] wb_ad$222 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$222 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$222 = 8'bxxxxxxxx;
	reg wb_we$222 = 0;
	always @(posedge clk) begin
		wb_ad$222 = wb_in_ad$237;
		wb_d$222 = wb_in_d$237;
		wb_op$222 = wb_in_op$237;
		wb_we$222 = wb_in_we$237;
	end
	wire [12:0] wb_in_ad$238;
	wire [31:0] wb_in_d$238;
	wire [7:0] wb_in_op$238;
	wire wb_in_we$238;
	reg [12:0] wb_ad$223 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$223 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$223 = 8'bxxxxxxxx;
	reg wb_we$223 = 0;
	always @(posedge clk) begin
		wb_ad$223 = wb_in_ad$238;
		wb_d$223 = wb_in_d$238;
		wb_op$223 = wb_in_op$238;
		wb_we$223 = wb_in_we$238;
	end
	wire [12:0] wb_in_ad$239;
	wire [31:0] wb_in_d$239;
	wire [7:0] wb_in_op$239;
	wire wb_in_we$239;
	reg [12:0] wb_ad$224 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$224 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$224 = 8'bxxxxxxxx;
	reg wb_we$224 = 0;
	always @(posedge clk) begin
		wb_ad$224 = wb_in_ad$239;
		wb_d$224 = wb_in_d$239;
		wb_op$224 = wb_in_op$239;
		wb_we$224 = wb_in_we$239;
	end
	assign retry_put$14 = (y_en$14[0] & wb_we$210) | (y_en$14[1] & wb_we$211) | (y_en$14[2] & wb_we$212) | (y_en$14[3] & wb_we$213) | (y_en$14[4] & wb_we$214) | (y_en$14[5] & wb_we$215) | (y_en$14[6] & wb_we$216) | (y_en$14[7] & wb_we$217) | (y_en$14[8] & wb_we$218) | (y_en$14[9] & wb_we$219) | (y_en$14[10] & wb_we$220) | (y_en$14[11] & wb_we$221) | (y_en$14[12] & wb_we$222) | (y_en$14[13] & wb_we$223) | (y_en$14[15] & wb_we$224);
	wire [32:0] acc_in$15;
	reg [32:0] acc$15 = 0;
	reg [32:0] acc_out$15;
	wire [16:0] pc_in$15;
	reg [16:0] pc$15 = 15;
	reg [16:0] pc_out$15;
	wire [7:0] op$15;
	wire [31:0] y$15;
	wire op_lock$15 = LOCK == op$15[7-:4];
	reg [3:0] lock_timer$15 = 0;
	always @(posedge clk) begin
		acc$15 <= acc_in$15;
		pc$15 <= pc_in$15;
		if (lock_timer$15) lock_timer$15 <= lock_timer$15 - 4'd1;
		else if (op_lock$15) lock_timer$15 <= y$15[0+:4];
	end
	wire retry_lock$15 = |lock_timer$15 & op_lock$15;
	wire [32:0] ax$15 = {op$15[2], {32{op$15[2]}} ^ acc$15[0+:32]};
	wire [32:0] ay$15 = {op$15[1], {32{op$15[1]}} ^ y$15};
	wire [4:0] ye$15 = op$15[0] ? y$15[0+:5] : -y$15[0+:5];
	wire [31:0] ys$15 = {{16{ye$15[4]}}, {16{~ye$15[4]}}} & {2{{{8{ye$15[3]}}, {8{~ye$15[3]}}} & {2{{{4{ye$15[2]}}, {4{~ye$15[2]}}} & {2{{{2{ye$15[1]}}, {2{~ye$15[1]}}} & {2{{ye$15[0], ~ye$15[0]}}}}}}}}};
	wire signed [32:0] mx$15 = {op$15[3] & acc$15[31], acc$15[0+:32]};
	wire signed [32:0] my$15 = op$15[2] ? {1'd0, ys$15} : {op$15[3] & y$15[31], y$15};
	wire signed [65:0] xy$15 = mx$15 * my$15;
	wire op_io$15 = IO == op$15[7-:3];
	wire [15:0] op_en$15 = {{8{op$15[3]}}, {8{~op$15[3]}}} & {2{{{4{op$15[2]}}, {4{~op$15[2]}}} & {2{{{2{op$15[1]}}, {2{~op$15[1]}}} & {2{{op$15[0] & op_io$15, ~op$15[0] & op_io$15}}}}}}};
	reg [32:0] acc_io$15;
	reg retry_io$15;
	wire retry_put$15;
	wire [2:0] opc$15 = acc$15[32] ? op$15[5:3] : op$15[2:0]; // 10cccnnn jump  c: carry  n: !carry
	wire cond$15 = acc$15[31] ? opc$15[2] : !acc$15[30:0] ? opc$15[1] : opc$15[0]; // 10mzpmzp jump  m: acc<0 z: acc=0 p: acc>0
	wire [12:0] wb_in_ad$240;
	wire [31:0] wb_in_d$240;
	wire [7:0] wb_in_op$240;
	wire wb_in_we$240;
	reg [39:0] q$26;
	wire [12:0] _dpmem__wa$15 = wb_in_ad$240;
	wire _dpmem__we$15 = wb_in_we$240;
	wire [39:0] _dpmem__d$15 = {wb_in_d$240, wb_in_op$240};
	wire [12:0] _dpmem__ra$15 = pc_in$15[4+:13];
	(* ramstyle = "M10K", max_depth = 2048 *)
	reg [39:0] _dpmem__mem$15 [0:6399];
	initial $readmemh("mem15.txt", _dpmem__mem$15);
	always @(posedge clk) begin
		if (_dpmem__we$15) _dpmem__mem$15[_dpmem__wa$15] <= _dpmem__d$15;
		q$26 <= _dpmem__mem$15[_dpmem__ra$15];
	end
	reg [31:0] fwd_y$15 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] fwd_op$15 = HALT;
	reg fwd_en$15 = 1;
	always @(posedge clk) begin
		fwd_y$15 = wb_in_d$240;
		fwd_op$15 = wb_in_op$240;
		fwd_en$15 = wb_in_we$240 & (wb_in_ad$240 == pc_in$15[16-:13]);
		if (pc_in$15[0+:4] != 4'd15) begin
			fwd_op$15 = HALT;
			fwd_en$15 = 1;
		end
	end
	assign y$15 = fwd_en$15 ? fwd_y$15 : q$26[39-:32];
	assign op$15 = fwd_en$15 ? fwd_op$15 : q$26[0+:8];
	wire op_put$15 = PUT == op$15[7-:2];
	wire [15:0] y_en$15 = {{8{y$15[3]}}, {8{~y$15[3]}}} & {2{{{4{y$15[2]}}, {4{~y$15[2]}}} & {2{{{2{y$15[1]}}, {2{~y$15[1]}}} & {2{{y$15[0] & op_put$15, ~y$15[0] & op_put$15}}}}}}};
	wire [12:0] wb_in_ad$241;
	wire [31:0] wb_in_d$241;
	wire [7:0] wb_in_op$241;
	wire wb_in_we$241;
	reg [12:0] wb_ad$225 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$225 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$225 = 8'bxxxxxxxx;
	reg wb_we$225 = 0;
	always @(posedge clk) begin
		wb_ad$225 = wb_in_ad$241;
		wb_d$225 = wb_in_d$241;
		wb_op$225 = wb_in_op$241;
		wb_we$225 = wb_in_we$241;
	end
	wire [12:0] wb_in_ad$242;
	wire [31:0] wb_in_d$242;
	wire [7:0] wb_in_op$242;
	wire wb_in_we$242;
	reg [12:0] wb_ad$226 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$226 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$226 = 8'bxxxxxxxx;
	reg wb_we$226 = 0;
	always @(posedge clk) begin
		wb_ad$226 = wb_in_ad$242;
		wb_d$226 = wb_in_d$242;
		wb_op$226 = wb_in_op$242;
		wb_we$226 = wb_in_we$242;
	end
	wire [12:0] wb_in_ad$243;
	wire [31:0] wb_in_d$243;
	wire [7:0] wb_in_op$243;
	wire wb_in_we$243;
	reg [12:0] wb_ad$227 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$227 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$227 = 8'bxxxxxxxx;
	reg wb_we$227 = 0;
	always @(posedge clk) begin
		wb_ad$227 = wb_in_ad$243;
		wb_d$227 = wb_in_d$243;
		wb_op$227 = wb_in_op$243;
		wb_we$227 = wb_in_we$243;
	end
	wire [12:0] wb_in_ad$244;
	wire [31:0] wb_in_d$244;
	wire [7:0] wb_in_op$244;
	wire wb_in_we$244;
	reg [12:0] wb_ad$228 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$228 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$228 = 8'bxxxxxxxx;
	reg wb_we$228 = 0;
	always @(posedge clk) begin
		wb_ad$228 = wb_in_ad$244;
		wb_d$228 = wb_in_d$244;
		wb_op$228 = wb_in_op$244;
		wb_we$228 = wb_in_we$244;
	end
	wire [12:0] wb_in_ad$245;
	wire [31:0] wb_in_d$245;
	wire [7:0] wb_in_op$245;
	wire wb_in_we$245;
	reg [12:0] wb_ad$229 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$229 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$229 = 8'bxxxxxxxx;
	reg wb_we$229 = 0;
	always @(posedge clk) begin
		wb_ad$229 = wb_in_ad$245;
		wb_d$229 = wb_in_d$245;
		wb_op$229 = wb_in_op$245;
		wb_we$229 = wb_in_we$245;
	end
	wire [12:0] wb_in_ad$246;
	wire [31:0] wb_in_d$246;
	wire [7:0] wb_in_op$246;
	wire wb_in_we$246;
	reg [12:0] wb_ad$230 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$230 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$230 = 8'bxxxxxxxx;
	reg wb_we$230 = 0;
	always @(posedge clk) begin
		wb_ad$230 = wb_in_ad$246;
		wb_d$230 = wb_in_d$246;
		wb_op$230 = wb_in_op$246;
		wb_we$230 = wb_in_we$246;
	end
	wire [12:0] wb_in_ad$247;
	wire [31:0] wb_in_d$247;
	wire [7:0] wb_in_op$247;
	wire wb_in_we$247;
	reg [12:0] wb_ad$231 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$231 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$231 = 8'bxxxxxxxx;
	reg wb_we$231 = 0;
	always @(posedge clk) begin
		wb_ad$231 = wb_in_ad$247;
		wb_d$231 = wb_in_d$247;
		wb_op$231 = wb_in_op$247;
		wb_we$231 = wb_in_we$247;
	end
	wire [12:0] wb_in_ad$248;
	wire [31:0] wb_in_d$248;
	wire [7:0] wb_in_op$248;
	wire wb_in_we$248;
	reg [12:0] wb_ad$232 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$232 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$232 = 8'bxxxxxxxx;
	reg wb_we$232 = 0;
	always @(posedge clk) begin
		wb_ad$232 = wb_in_ad$248;
		wb_d$232 = wb_in_d$248;
		wb_op$232 = wb_in_op$248;
		wb_we$232 = wb_in_we$248;
	end
	wire [12:0] wb_in_ad$249;
	wire [31:0] wb_in_d$249;
	wire [7:0] wb_in_op$249;
	wire wb_in_we$249;
	reg [12:0] wb_ad$233 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$233 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$233 = 8'bxxxxxxxx;
	reg wb_we$233 = 0;
	always @(posedge clk) begin
		wb_ad$233 = wb_in_ad$249;
		wb_d$233 = wb_in_d$249;
		wb_op$233 = wb_in_op$249;
		wb_we$233 = wb_in_we$249;
	end
	wire [12:0] wb_in_ad$250;
	wire [31:0] wb_in_d$250;
	wire [7:0] wb_in_op$250;
	wire wb_in_we$250;
	reg [12:0] wb_ad$234 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$234 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$234 = 8'bxxxxxxxx;
	reg wb_we$234 = 0;
	always @(posedge clk) begin
		wb_ad$234 = wb_in_ad$250;
		wb_d$234 = wb_in_d$250;
		wb_op$234 = wb_in_op$250;
		wb_we$234 = wb_in_we$250;
	end
	wire [12:0] wb_in_ad$251;
	wire [31:0] wb_in_d$251;
	wire [7:0] wb_in_op$251;
	wire wb_in_we$251;
	reg [12:0] wb_ad$235 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$235 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$235 = 8'bxxxxxxxx;
	reg wb_we$235 = 0;
	always @(posedge clk) begin
		wb_ad$235 = wb_in_ad$251;
		wb_d$235 = wb_in_d$251;
		wb_op$235 = wb_in_op$251;
		wb_we$235 = wb_in_we$251;
	end
	wire [12:0] wb_in_ad$252;
	wire [31:0] wb_in_d$252;
	wire [7:0] wb_in_op$252;
	wire wb_in_we$252;
	reg [12:0] wb_ad$236 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$236 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$236 = 8'bxxxxxxxx;
	reg wb_we$236 = 0;
	always @(posedge clk) begin
		wb_ad$236 = wb_in_ad$252;
		wb_d$236 = wb_in_d$252;
		wb_op$236 = wb_in_op$252;
		wb_we$236 = wb_in_we$252;
	end
	wire [12:0] wb_in_ad$253;
	wire [31:0] wb_in_d$253;
	wire [7:0] wb_in_op$253;
	wire wb_in_we$253;
	reg [12:0] wb_ad$237 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$237 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$237 = 8'bxxxxxxxx;
	reg wb_we$237 = 0;
	always @(posedge clk) begin
		wb_ad$237 = wb_in_ad$253;
		wb_d$237 = wb_in_d$253;
		wb_op$237 = wb_in_op$253;
		wb_we$237 = wb_in_we$253;
	end
	wire [12:0] wb_in_ad$254;
	wire [31:0] wb_in_d$254;
	wire [7:0] wb_in_op$254;
	wire wb_in_we$254;
	reg [12:0] wb_ad$238 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$238 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$238 = 8'bxxxxxxxx;
	reg wb_we$238 = 0;
	always @(posedge clk) begin
		wb_ad$238 = wb_in_ad$254;
		wb_d$238 = wb_in_d$254;
		wb_op$238 = wb_in_op$254;
		wb_we$238 = wb_in_we$254;
	end
	wire [12:0] wb_in_ad$255;
	wire [31:0] wb_in_d$255;
	wire [7:0] wb_in_op$255;
	wire wb_in_we$255;
	reg [12:0] wb_ad$239 = 13'bxxxxxxxxxxxxx;
	reg [31:0] wb_d$239 = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	reg [7:0] wb_op$239 = 8'bxxxxxxxx;
	reg wb_we$239 = 0;
	always @(posedge clk) begin
		wb_ad$239 = wb_in_ad$255;
		wb_d$239 = wb_in_d$255;
		wb_op$239 = wb_in_op$255;
		wb_we$239 = wb_in_we$255;
	end
	assign retry_put$15 = (y_en$15[0] & wb_we$225) | (y_en$15[1] & wb_we$226) | (y_en$15[2] & wb_we$227) | (y_en$15[3] & wb_we$228) | (y_en$15[4] & wb_we$229) | (y_en$15[5] & wb_we$230) | (y_en$15[6] & wb_we$231) | (y_en$15[7] & wb_we$232) | (y_en$15[8] & wb_we$233) | (y_en$15[9] & wb_we$234) | (y_en$15[10] & wb_we$235) | (y_en$15[11] & wb_we$236) | (y_en$15[12] & wb_we$237) | (y_en$15[13] & wb_we$238) | (y_en$15[14] & wb_we$239);
	assign wb_in_ad$17 = y$0[4+:13];
	assign wb_in_d$17 = acc$0[0+:32];
	assign wb_in_op$17 = y$0[31-:8];
	assign wb_in_we$17 = y_en$0[0];
	assign wb_in_ad$16 = wb_we$0 ? wb_ad$0 : y$0[4+:13];
	assign wb_in_d$16 = wb_we$0 ? wb_d$0 : acc$0[0+:32];
	assign wb_in_op$16 = wb_we$0 ? wb_op$0 : y$0[31-:8];
	assign wb_in_we$16 = wb_we$0 | y_en$0[1];
	assign wb_in_ad$18 = wb_we$1 ? wb_ad$1 : y$0[4+:13];
	assign wb_in_d$18 = wb_we$1 ? wb_d$1 : acc$0[0+:32];
	assign wb_in_op$18 = wb_we$1 ? wb_op$1 : y$0[31-:8];
	assign wb_in_we$18 = wb_we$1 | y_en$0[2];
	assign wb_in_ad$19 = wb_we$2 ? wb_ad$2 : y$0[4+:13];
	assign wb_in_d$19 = wb_we$2 ? wb_d$2 : acc$0[0+:32];
	assign wb_in_op$19 = wb_we$2 ? wb_op$2 : y$0[31-:8];
	assign wb_in_we$19 = wb_we$2 | y_en$0[3];
	assign wb_in_ad$20 = wb_we$3 ? wb_ad$3 : y$0[4+:13];
	assign wb_in_d$20 = wb_we$3 ? wb_d$3 : acc$0[0+:32];
	assign wb_in_op$20 = wb_we$3 ? wb_op$3 : y$0[31-:8];
	assign wb_in_we$20 = wb_we$3 | y_en$0[4];
	assign wb_in_ad$21 = wb_we$4 ? wb_ad$4 : y$0[4+:13];
	assign wb_in_d$21 = wb_we$4 ? wb_d$4 : acc$0[0+:32];
	assign wb_in_op$21 = wb_we$4 ? wb_op$4 : y$0[31-:8];
	assign wb_in_we$21 = wb_we$4 | y_en$0[5];
	assign wb_in_ad$22 = wb_we$5 ? wb_ad$5 : y$0[4+:13];
	assign wb_in_d$22 = wb_we$5 ? wb_d$5 : acc$0[0+:32];
	assign wb_in_op$22 = wb_we$5 ? wb_op$5 : y$0[31-:8];
	assign wb_in_we$22 = wb_we$5 | y_en$0[6];
	assign wb_in_ad$23 = wb_we$6 ? wb_ad$6 : y$0[4+:13];
	assign wb_in_d$23 = wb_we$6 ? wb_d$6 : acc$0[0+:32];
	assign wb_in_op$23 = wb_we$6 ? wb_op$6 : y$0[31-:8];
	assign wb_in_we$23 = wb_we$6 | y_en$0[7];
	assign wb_in_ad$24 = wb_we$7 ? wb_ad$7 : y$0[4+:13];
	assign wb_in_d$24 = wb_we$7 ? wb_d$7 : acc$0[0+:32];
	assign wb_in_op$24 = wb_we$7 ? wb_op$7 : y$0[31-:8];
	assign wb_in_we$24 = wb_we$7 | y_en$0[8];
	assign wb_in_ad$25 = wb_we$8 ? wb_ad$8 : y$0[4+:13];
	assign wb_in_d$25 = wb_we$8 ? wb_d$8 : acc$0[0+:32];
	assign wb_in_op$25 = wb_we$8 ? wb_op$8 : y$0[31-:8];
	assign wb_in_we$25 = wb_we$8 | y_en$0[9];
	assign wb_in_ad$26 = wb_we$9 ? wb_ad$9 : y$0[4+:13];
	assign wb_in_d$26 = wb_we$9 ? wb_d$9 : acc$0[0+:32];
	assign wb_in_op$26 = wb_we$9 ? wb_op$9 : y$0[31-:8];
	assign wb_in_we$26 = wb_we$9 | y_en$0[10];
	assign wb_in_ad$27 = wb_we$10 ? wb_ad$10 : y$0[4+:13];
	assign wb_in_d$27 = wb_we$10 ? wb_d$10 : acc$0[0+:32];
	assign wb_in_op$27 = wb_we$10 ? wb_op$10 : y$0[31-:8];
	assign wb_in_we$27 = wb_we$10 | y_en$0[11];
	assign wb_in_ad$28 = wb_we$11 ? wb_ad$11 : y$0[4+:13];
	assign wb_in_d$28 = wb_we$11 ? wb_d$11 : acc$0[0+:32];
	assign wb_in_op$28 = wb_we$11 ? wb_op$11 : y$0[31-:8];
	assign wb_in_we$28 = wb_we$11 | y_en$0[12];
	assign wb_in_ad$29 = wb_we$12 ? wb_ad$12 : y$0[4+:13];
	assign wb_in_d$29 = wb_we$12 ? wb_d$12 : acc$0[0+:32];
	assign wb_in_op$29 = wb_we$12 ? wb_op$12 : y$0[31-:8];
	assign wb_in_we$29 = wb_we$12 | y_en$0[13];
	assign wb_in_ad$30 = wb_we$13 ? wb_ad$13 : y$0[4+:13];
	assign wb_in_d$30 = wb_we$13 ? wb_d$13 : acc$0[0+:32];
	assign wb_in_op$30 = wb_we$13 ? wb_op$13 : y$0[31-:8];
	assign wb_in_we$30 = wb_we$13 | y_en$0[14];
	assign wb_in_ad$31 = wb_we$14 ? wb_ad$14 : y$0[4+:13];
	assign wb_in_d$31 = wb_we$14 ? wb_d$14 : acc$0[0+:32];
	assign wb_in_op$31 = wb_we$14 ? wb_op$14 : y$0[31-:8];
	assign wb_in_we$31 = wb_we$14 | y_en$0[15];
	assign acc_in$1 = acc_out$0;
	assign pc_in$1 = pc_out$0;
	assign wb_in_ad$33 = wb_we$15 ? wb_ad$15 : y$1[4+:13];
	assign wb_in_d$33 = wb_we$15 ? wb_d$15 : acc$1[0+:32];
	assign wb_in_op$33 = wb_we$15 ? wb_op$15 : y$1[31-:8];
	assign wb_in_we$33 = wb_we$15 | y_en$1[0];
	assign wb_in_ad$34 = y$1[4+:13];
	assign wb_in_d$34 = acc$1[0+:32];
	assign wb_in_op$34 = y$1[31-:8];
	assign wb_in_we$34 = y_en$1[1];
	assign wb_in_ad$32 = wb_we$16 ? wb_ad$16 : y$1[4+:13];
	assign wb_in_d$32 = wb_we$16 ? wb_d$16 : acc$1[0+:32];
	assign wb_in_op$32 = wb_we$16 ? wb_op$16 : y$1[31-:8];
	assign wb_in_we$32 = wb_we$16 | y_en$1[2];
	assign wb_in_ad$35 = wb_we$17 ? wb_ad$17 : y$1[4+:13];
	assign wb_in_d$35 = wb_we$17 ? wb_d$17 : acc$1[0+:32];
	assign wb_in_op$35 = wb_we$17 ? wb_op$17 : y$1[31-:8];
	assign wb_in_we$35 = wb_we$17 | y_en$1[3];
	assign wb_in_ad$36 = wb_we$18 ? wb_ad$18 : y$1[4+:13];
	assign wb_in_d$36 = wb_we$18 ? wb_d$18 : acc$1[0+:32];
	assign wb_in_op$36 = wb_we$18 ? wb_op$18 : y$1[31-:8];
	assign wb_in_we$36 = wb_we$18 | y_en$1[4];
	assign wb_in_ad$37 = wb_we$19 ? wb_ad$19 : y$1[4+:13];
	assign wb_in_d$37 = wb_we$19 ? wb_d$19 : acc$1[0+:32];
	assign wb_in_op$37 = wb_we$19 ? wb_op$19 : y$1[31-:8];
	assign wb_in_we$37 = wb_we$19 | y_en$1[5];
	assign wb_in_ad$38 = wb_we$20 ? wb_ad$20 : y$1[4+:13];
	assign wb_in_d$38 = wb_we$20 ? wb_d$20 : acc$1[0+:32];
	assign wb_in_op$38 = wb_we$20 ? wb_op$20 : y$1[31-:8];
	assign wb_in_we$38 = wb_we$20 | y_en$1[6];
	assign wb_in_ad$39 = wb_we$21 ? wb_ad$21 : y$1[4+:13];
	assign wb_in_d$39 = wb_we$21 ? wb_d$21 : acc$1[0+:32];
	assign wb_in_op$39 = wb_we$21 ? wb_op$21 : y$1[31-:8];
	assign wb_in_we$39 = wb_we$21 | y_en$1[7];
	assign wb_in_ad$40 = wb_we$22 ? wb_ad$22 : y$1[4+:13];
	assign wb_in_d$40 = wb_we$22 ? wb_d$22 : acc$1[0+:32];
	assign wb_in_op$40 = wb_we$22 ? wb_op$22 : y$1[31-:8];
	assign wb_in_we$40 = wb_we$22 | y_en$1[8];
	assign wb_in_ad$41 = wb_we$23 ? wb_ad$23 : y$1[4+:13];
	assign wb_in_d$41 = wb_we$23 ? wb_d$23 : acc$1[0+:32];
	assign wb_in_op$41 = wb_we$23 ? wb_op$23 : y$1[31-:8];
	assign wb_in_we$41 = wb_we$23 | y_en$1[9];
	assign wb_in_ad$42 = wb_we$24 ? wb_ad$24 : y$1[4+:13];
	assign wb_in_d$42 = wb_we$24 ? wb_d$24 : acc$1[0+:32];
	assign wb_in_op$42 = wb_we$24 ? wb_op$24 : y$1[31-:8];
	assign wb_in_we$42 = wb_we$24 | y_en$1[10];
	assign wb_in_ad$43 = wb_we$25 ? wb_ad$25 : y$1[4+:13];
	assign wb_in_d$43 = wb_we$25 ? wb_d$25 : acc$1[0+:32];
	assign wb_in_op$43 = wb_we$25 ? wb_op$25 : y$1[31-:8];
	assign wb_in_we$43 = wb_we$25 | y_en$1[11];
	assign wb_in_ad$44 = wb_we$26 ? wb_ad$26 : y$1[4+:13];
	assign wb_in_d$44 = wb_we$26 ? wb_d$26 : acc$1[0+:32];
	assign wb_in_op$44 = wb_we$26 ? wb_op$26 : y$1[31-:8];
	assign wb_in_we$44 = wb_we$26 | y_en$1[12];
	assign wb_in_ad$45 = wb_we$27 ? wb_ad$27 : y$1[4+:13];
	assign wb_in_d$45 = wb_we$27 ? wb_d$27 : acc$1[0+:32];
	assign wb_in_op$45 = wb_we$27 ? wb_op$27 : y$1[31-:8];
	assign wb_in_we$45 = wb_we$27 | y_en$1[13];
	assign wb_in_ad$46 = wb_we$28 ? wb_ad$28 : y$1[4+:13];
	assign wb_in_d$46 = wb_we$28 ? wb_d$28 : acc$1[0+:32];
	assign wb_in_op$46 = wb_we$28 ? wb_op$28 : y$1[31-:8];
	assign wb_in_we$46 = wb_we$28 | y_en$1[14];
	assign wb_in_ad$47 = wb_we$29 ? wb_ad$29 : y$1[4+:13];
	assign wb_in_d$47 = wb_we$29 ? wb_d$29 : acc$1[0+:32];
	assign wb_in_op$47 = wb_we$29 ? wb_op$29 : y$1[31-:8];
	assign wb_in_we$47 = wb_we$29 | y_en$1[15];
	assign acc_in$2 = acc_out$1;
	assign pc_in$2 = pc_out$1;
	assign wb_in_ad$49 = wb_we$30 ? wb_ad$30 : y$2[4+:13];
	assign wb_in_d$49 = wb_we$30 ? wb_d$30 : acc$2[0+:32];
	assign wb_in_op$49 = wb_we$30 ? wb_op$30 : y$2[31-:8];
	assign wb_in_we$49 = wb_we$30 | y_en$2[0];
	assign wb_in_ad$50 = wb_we$31 ? wb_ad$31 : y$2[4+:13];
	assign wb_in_d$50 = wb_we$31 ? wb_d$31 : acc$2[0+:32];
	assign wb_in_op$50 = wb_we$31 ? wb_op$31 : y$2[31-:8];
	assign wb_in_we$50 = wb_we$31 | y_en$2[1];
	assign wb_in_ad$51 = y$2[4+:13];
	assign wb_in_d$51 = acc$2[0+:32];
	assign wb_in_op$51 = y$2[31-:8];
	assign wb_in_we$51 = y_en$2[2];
	assign wb_in_ad$48 = wb_we$32 ? wb_ad$32 : y$2[4+:13];
	assign wb_in_d$48 = wb_we$32 ? wb_d$32 : acc$2[0+:32];
	assign wb_in_op$48 = wb_we$32 ? wb_op$32 : y$2[31-:8];
	assign wb_in_we$48 = wb_we$32 | y_en$2[3];
	assign wb_in_ad$52 = wb_we$33 ? wb_ad$33 : y$2[4+:13];
	assign wb_in_d$52 = wb_we$33 ? wb_d$33 : acc$2[0+:32];
	assign wb_in_op$52 = wb_we$33 ? wb_op$33 : y$2[31-:8];
	assign wb_in_we$52 = wb_we$33 | y_en$2[4];
	assign wb_in_ad$53 = wb_we$34 ? wb_ad$34 : y$2[4+:13];
	assign wb_in_d$53 = wb_we$34 ? wb_d$34 : acc$2[0+:32];
	assign wb_in_op$53 = wb_we$34 ? wb_op$34 : y$2[31-:8];
	assign wb_in_we$53 = wb_we$34 | y_en$2[5];
	assign wb_in_ad$54 = wb_we$35 ? wb_ad$35 : y$2[4+:13];
	assign wb_in_d$54 = wb_we$35 ? wb_d$35 : acc$2[0+:32];
	assign wb_in_op$54 = wb_we$35 ? wb_op$35 : y$2[31-:8];
	assign wb_in_we$54 = wb_we$35 | y_en$2[6];
	assign wb_in_ad$55 = wb_we$36 ? wb_ad$36 : y$2[4+:13];
	assign wb_in_d$55 = wb_we$36 ? wb_d$36 : acc$2[0+:32];
	assign wb_in_op$55 = wb_we$36 ? wb_op$36 : y$2[31-:8];
	assign wb_in_we$55 = wb_we$36 | y_en$2[7];
	assign wb_in_ad$56 = wb_we$37 ? wb_ad$37 : y$2[4+:13];
	assign wb_in_d$56 = wb_we$37 ? wb_d$37 : acc$2[0+:32];
	assign wb_in_op$56 = wb_we$37 ? wb_op$37 : y$2[31-:8];
	assign wb_in_we$56 = wb_we$37 | y_en$2[8];
	assign wb_in_ad$57 = wb_we$38 ? wb_ad$38 : y$2[4+:13];
	assign wb_in_d$57 = wb_we$38 ? wb_d$38 : acc$2[0+:32];
	assign wb_in_op$57 = wb_we$38 ? wb_op$38 : y$2[31-:8];
	assign wb_in_we$57 = wb_we$38 | y_en$2[9];
	assign wb_in_ad$58 = wb_we$39 ? wb_ad$39 : y$2[4+:13];
	assign wb_in_d$58 = wb_we$39 ? wb_d$39 : acc$2[0+:32];
	assign wb_in_op$58 = wb_we$39 ? wb_op$39 : y$2[31-:8];
	assign wb_in_we$58 = wb_we$39 | y_en$2[10];
	assign wb_in_ad$59 = wb_we$40 ? wb_ad$40 : y$2[4+:13];
	assign wb_in_d$59 = wb_we$40 ? wb_d$40 : acc$2[0+:32];
	assign wb_in_op$59 = wb_we$40 ? wb_op$40 : y$2[31-:8];
	assign wb_in_we$59 = wb_we$40 | y_en$2[11];
	assign wb_in_ad$60 = wb_we$41 ? wb_ad$41 : y$2[4+:13];
	assign wb_in_d$60 = wb_we$41 ? wb_d$41 : acc$2[0+:32];
	assign wb_in_op$60 = wb_we$41 ? wb_op$41 : y$2[31-:8];
	assign wb_in_we$60 = wb_we$41 | y_en$2[12];
	assign wb_in_ad$61 = wb_we$42 ? wb_ad$42 : y$2[4+:13];
	assign wb_in_d$61 = wb_we$42 ? wb_d$42 : acc$2[0+:32];
	assign wb_in_op$61 = wb_we$42 ? wb_op$42 : y$2[31-:8];
	assign wb_in_we$61 = wb_we$42 | y_en$2[13];
	assign wb_in_ad$62 = wb_we$43 ? wb_ad$43 : y$2[4+:13];
	assign wb_in_d$62 = wb_we$43 ? wb_d$43 : acc$2[0+:32];
	assign wb_in_op$62 = wb_we$43 ? wb_op$43 : y$2[31-:8];
	assign wb_in_we$62 = wb_we$43 | y_en$2[14];
	assign wb_in_ad$63 = wb_we$44 ? wb_ad$44 : y$2[4+:13];
	assign wb_in_d$63 = wb_we$44 ? wb_d$44 : acc$2[0+:32];
	assign wb_in_op$63 = wb_we$44 ? wb_op$44 : y$2[31-:8];
	assign wb_in_we$63 = wb_we$44 | y_en$2[15];
	assign acc_in$3 = acc_out$2;
	assign pc_in$3 = pc_out$2;
	assign wb_in_ad$65 = wb_we$45 ? wb_ad$45 : y$3[4+:13];
	assign wb_in_d$65 = wb_we$45 ? wb_d$45 : acc$3[0+:32];
	assign wb_in_op$65 = wb_we$45 ? wb_op$45 : y$3[31-:8];
	assign wb_in_we$65 = wb_we$45 | y_en$3[0];
	assign wb_in_ad$66 = wb_we$46 ? wb_ad$46 : y$3[4+:13];
	assign wb_in_d$66 = wb_we$46 ? wb_d$46 : acc$3[0+:32];
	assign wb_in_op$66 = wb_we$46 ? wb_op$46 : y$3[31-:8];
	assign wb_in_we$66 = wb_we$46 | y_en$3[1];
	assign wb_in_ad$67 = wb_we$47 ? wb_ad$47 : y$3[4+:13];
	assign wb_in_d$67 = wb_we$47 ? wb_d$47 : acc$3[0+:32];
	assign wb_in_op$67 = wb_we$47 ? wb_op$47 : y$3[31-:8];
	assign wb_in_we$67 = wb_we$47 | y_en$3[2];
	assign wb_in_ad$68 = y$3[4+:13];
	assign wb_in_d$68 = acc$3[0+:32];
	assign wb_in_op$68 = y$3[31-:8];
	assign wb_in_we$68 = y_en$3[3];
	assign wb_in_ad$64 = wb_we$48 ? wb_ad$48 : y$3[4+:13];
	assign wb_in_d$64 = wb_we$48 ? wb_d$48 : acc$3[0+:32];
	assign wb_in_op$64 = wb_we$48 ? wb_op$48 : y$3[31-:8];
	assign wb_in_we$64 = wb_we$48 | y_en$3[4];
	assign wb_in_ad$69 = wb_we$49 ? wb_ad$49 : y$3[4+:13];
	assign wb_in_d$69 = wb_we$49 ? wb_d$49 : acc$3[0+:32];
	assign wb_in_op$69 = wb_we$49 ? wb_op$49 : y$3[31-:8];
	assign wb_in_we$69 = wb_we$49 | y_en$3[5];
	assign wb_in_ad$70 = wb_we$50 ? wb_ad$50 : y$3[4+:13];
	assign wb_in_d$70 = wb_we$50 ? wb_d$50 : acc$3[0+:32];
	assign wb_in_op$70 = wb_we$50 ? wb_op$50 : y$3[31-:8];
	assign wb_in_we$70 = wb_we$50 | y_en$3[6];
	assign wb_in_ad$71 = wb_we$51 ? wb_ad$51 : y$3[4+:13];
	assign wb_in_d$71 = wb_we$51 ? wb_d$51 : acc$3[0+:32];
	assign wb_in_op$71 = wb_we$51 ? wb_op$51 : y$3[31-:8];
	assign wb_in_we$71 = wb_we$51 | y_en$3[7];
	assign wb_in_ad$72 = wb_we$52 ? wb_ad$52 : y$3[4+:13];
	assign wb_in_d$72 = wb_we$52 ? wb_d$52 : acc$3[0+:32];
	assign wb_in_op$72 = wb_we$52 ? wb_op$52 : y$3[31-:8];
	assign wb_in_we$72 = wb_we$52 | y_en$3[8];
	assign wb_in_ad$73 = wb_we$53 ? wb_ad$53 : y$3[4+:13];
	assign wb_in_d$73 = wb_we$53 ? wb_d$53 : acc$3[0+:32];
	assign wb_in_op$73 = wb_we$53 ? wb_op$53 : y$3[31-:8];
	assign wb_in_we$73 = wb_we$53 | y_en$3[9];
	assign wb_in_ad$74 = wb_we$54 ? wb_ad$54 : y$3[4+:13];
	assign wb_in_d$74 = wb_we$54 ? wb_d$54 : acc$3[0+:32];
	assign wb_in_op$74 = wb_we$54 ? wb_op$54 : y$3[31-:8];
	assign wb_in_we$74 = wb_we$54 | y_en$3[10];
	assign wb_in_ad$75 = wb_we$55 ? wb_ad$55 : y$3[4+:13];
	assign wb_in_d$75 = wb_we$55 ? wb_d$55 : acc$3[0+:32];
	assign wb_in_op$75 = wb_we$55 ? wb_op$55 : y$3[31-:8];
	assign wb_in_we$75 = wb_we$55 | y_en$3[11];
	assign wb_in_ad$76 = wb_we$56 ? wb_ad$56 : y$3[4+:13];
	assign wb_in_d$76 = wb_we$56 ? wb_d$56 : acc$3[0+:32];
	assign wb_in_op$76 = wb_we$56 ? wb_op$56 : y$3[31-:8];
	assign wb_in_we$76 = wb_we$56 | y_en$3[12];
	assign wb_in_ad$77 = wb_we$57 ? wb_ad$57 : y$3[4+:13];
	assign wb_in_d$77 = wb_we$57 ? wb_d$57 : acc$3[0+:32];
	assign wb_in_op$77 = wb_we$57 ? wb_op$57 : y$3[31-:8];
	assign wb_in_we$77 = wb_we$57 | y_en$3[13];
	assign wb_in_ad$78 = wb_we$58 ? wb_ad$58 : y$3[4+:13];
	assign wb_in_d$78 = wb_we$58 ? wb_d$58 : acc$3[0+:32];
	assign wb_in_op$78 = wb_we$58 ? wb_op$58 : y$3[31-:8];
	assign wb_in_we$78 = wb_we$58 | y_en$3[14];
	assign wb_in_ad$79 = wb_we$59 ? wb_ad$59 : y$3[4+:13];
	assign wb_in_d$79 = wb_we$59 ? wb_d$59 : acc$3[0+:32];
	assign wb_in_op$79 = wb_we$59 ? wb_op$59 : y$3[31-:8];
	assign wb_in_we$79 = wb_we$59 | y_en$3[15];
	assign acc_in$4 = acc_out$3;
	assign pc_in$4 = pc_out$3;
	assign wb_in_ad$81 = wb_we$60 ? wb_ad$60 : y$4[4+:13];
	assign wb_in_d$81 = wb_we$60 ? wb_d$60 : acc$4[0+:32];
	assign wb_in_op$81 = wb_we$60 ? wb_op$60 : y$4[31-:8];
	assign wb_in_we$81 = wb_we$60 | y_en$4[0];
	assign wb_in_ad$82 = wb_we$61 ? wb_ad$61 : y$4[4+:13];
	assign wb_in_d$82 = wb_we$61 ? wb_d$61 : acc$4[0+:32];
	assign wb_in_op$82 = wb_we$61 ? wb_op$61 : y$4[31-:8];
	assign wb_in_we$82 = wb_we$61 | y_en$4[1];
	assign wb_in_ad$83 = wb_we$62 ? wb_ad$62 : y$4[4+:13];
	assign wb_in_d$83 = wb_we$62 ? wb_d$62 : acc$4[0+:32];
	assign wb_in_op$83 = wb_we$62 ? wb_op$62 : y$4[31-:8];
	assign wb_in_we$83 = wb_we$62 | y_en$4[2];
	assign wb_in_ad$84 = wb_we$63 ? wb_ad$63 : y$4[4+:13];
	assign wb_in_d$84 = wb_we$63 ? wb_d$63 : acc$4[0+:32];
	assign wb_in_op$84 = wb_we$63 ? wb_op$63 : y$4[31-:8];
	assign wb_in_we$84 = wb_we$63 | y_en$4[3];
	assign wb_in_ad$85 = y$4[4+:13];
	assign wb_in_d$85 = acc$4[0+:32];
	assign wb_in_op$85 = y$4[31-:8];
	assign wb_in_we$85 = y_en$4[4];
	assign wb_in_ad$80 = wb_we$64 ? wb_ad$64 : y$4[4+:13];
	assign wb_in_d$80 = wb_we$64 ? wb_d$64 : acc$4[0+:32];
	assign wb_in_op$80 = wb_we$64 ? wb_op$64 : y$4[31-:8];
	assign wb_in_we$80 = wb_we$64 | y_en$4[5];
	assign wb_in_ad$86 = wb_we$65 ? wb_ad$65 : y$4[4+:13];
	assign wb_in_d$86 = wb_we$65 ? wb_d$65 : acc$4[0+:32];
	assign wb_in_op$86 = wb_we$65 ? wb_op$65 : y$4[31-:8];
	assign wb_in_we$86 = wb_we$65 | y_en$4[6];
	assign wb_in_ad$87 = wb_we$66 ? wb_ad$66 : y$4[4+:13];
	assign wb_in_d$87 = wb_we$66 ? wb_d$66 : acc$4[0+:32];
	assign wb_in_op$87 = wb_we$66 ? wb_op$66 : y$4[31-:8];
	assign wb_in_we$87 = wb_we$66 | y_en$4[7];
	assign wb_in_ad$88 = wb_we$67 ? wb_ad$67 : y$4[4+:13];
	assign wb_in_d$88 = wb_we$67 ? wb_d$67 : acc$4[0+:32];
	assign wb_in_op$88 = wb_we$67 ? wb_op$67 : y$4[31-:8];
	assign wb_in_we$88 = wb_we$67 | y_en$4[8];
	assign wb_in_ad$89 = wb_we$68 ? wb_ad$68 : y$4[4+:13];
	assign wb_in_d$89 = wb_we$68 ? wb_d$68 : acc$4[0+:32];
	assign wb_in_op$89 = wb_we$68 ? wb_op$68 : y$4[31-:8];
	assign wb_in_we$89 = wb_we$68 | y_en$4[9];
	assign wb_in_ad$90 = wb_we$69 ? wb_ad$69 : y$4[4+:13];
	assign wb_in_d$90 = wb_we$69 ? wb_d$69 : acc$4[0+:32];
	assign wb_in_op$90 = wb_we$69 ? wb_op$69 : y$4[31-:8];
	assign wb_in_we$90 = wb_we$69 | y_en$4[10];
	assign wb_in_ad$91 = wb_we$70 ? wb_ad$70 : y$4[4+:13];
	assign wb_in_d$91 = wb_we$70 ? wb_d$70 : acc$4[0+:32];
	assign wb_in_op$91 = wb_we$70 ? wb_op$70 : y$4[31-:8];
	assign wb_in_we$91 = wb_we$70 | y_en$4[11];
	assign wb_in_ad$92 = wb_we$71 ? wb_ad$71 : y$4[4+:13];
	assign wb_in_d$92 = wb_we$71 ? wb_d$71 : acc$4[0+:32];
	assign wb_in_op$92 = wb_we$71 ? wb_op$71 : y$4[31-:8];
	assign wb_in_we$92 = wb_we$71 | y_en$4[12];
	assign wb_in_ad$93 = wb_we$72 ? wb_ad$72 : y$4[4+:13];
	assign wb_in_d$93 = wb_we$72 ? wb_d$72 : acc$4[0+:32];
	assign wb_in_op$93 = wb_we$72 ? wb_op$72 : y$4[31-:8];
	assign wb_in_we$93 = wb_we$72 | y_en$4[13];
	assign wb_in_ad$94 = wb_we$73 ? wb_ad$73 : y$4[4+:13];
	assign wb_in_d$94 = wb_we$73 ? wb_d$73 : acc$4[0+:32];
	assign wb_in_op$94 = wb_we$73 ? wb_op$73 : y$4[31-:8];
	assign wb_in_we$94 = wb_we$73 | y_en$4[14];
	assign wb_in_ad$95 = wb_we$74 ? wb_ad$74 : y$4[4+:13];
	assign wb_in_d$95 = wb_we$74 ? wb_d$74 : acc$4[0+:32];
	assign wb_in_op$95 = wb_we$74 ? wb_op$74 : y$4[31-:8];
	assign wb_in_we$95 = wb_we$74 | y_en$4[15];
	assign acc_in$5 = acc_out$4;
	assign pc_in$5 = pc_out$4;
	assign wb_in_ad$97 = wb_we$75 ? wb_ad$75 : y$5[4+:13];
	assign wb_in_d$97 = wb_we$75 ? wb_d$75 : acc$5[0+:32];
	assign wb_in_op$97 = wb_we$75 ? wb_op$75 : y$5[31-:8];
	assign wb_in_we$97 = wb_we$75 | y_en$5[0];
	assign wb_in_ad$98 = wb_we$76 ? wb_ad$76 : y$5[4+:13];
	assign wb_in_d$98 = wb_we$76 ? wb_d$76 : acc$5[0+:32];
	assign wb_in_op$98 = wb_we$76 ? wb_op$76 : y$5[31-:8];
	assign wb_in_we$98 = wb_we$76 | y_en$5[1];
	assign wb_in_ad$99 = wb_we$77 ? wb_ad$77 : y$5[4+:13];
	assign wb_in_d$99 = wb_we$77 ? wb_d$77 : acc$5[0+:32];
	assign wb_in_op$99 = wb_we$77 ? wb_op$77 : y$5[31-:8];
	assign wb_in_we$99 = wb_we$77 | y_en$5[2];
	assign wb_in_ad$100 = wb_we$78 ? wb_ad$78 : y$5[4+:13];
	assign wb_in_d$100 = wb_we$78 ? wb_d$78 : acc$5[0+:32];
	assign wb_in_op$100 = wb_we$78 ? wb_op$78 : y$5[31-:8];
	assign wb_in_we$100 = wb_we$78 | y_en$5[3];
	assign wb_in_ad$101 = wb_we$79 ? wb_ad$79 : y$5[4+:13];
	assign wb_in_d$101 = wb_we$79 ? wb_d$79 : acc$5[0+:32];
	assign wb_in_op$101 = wb_we$79 ? wb_op$79 : y$5[31-:8];
	assign wb_in_we$101 = wb_we$79 | y_en$5[4];
	assign wb_in_ad$102 = y$5[4+:13];
	assign wb_in_d$102 = acc$5[0+:32];
	assign wb_in_op$102 = y$5[31-:8];
	assign wb_in_we$102 = y_en$5[5];
	assign wb_in_ad$96 = wb_we$80 ? wb_ad$80 : y$5[4+:13];
	assign wb_in_d$96 = wb_we$80 ? wb_d$80 : acc$5[0+:32];
	assign wb_in_op$96 = wb_we$80 ? wb_op$80 : y$5[31-:8];
	assign wb_in_we$96 = wb_we$80 | y_en$5[6];
	assign wb_in_ad$103 = wb_we$81 ? wb_ad$81 : y$5[4+:13];
	assign wb_in_d$103 = wb_we$81 ? wb_d$81 : acc$5[0+:32];
	assign wb_in_op$103 = wb_we$81 ? wb_op$81 : y$5[31-:8];
	assign wb_in_we$103 = wb_we$81 | y_en$5[7];
	assign wb_in_ad$104 = wb_we$82 ? wb_ad$82 : y$5[4+:13];
	assign wb_in_d$104 = wb_we$82 ? wb_d$82 : acc$5[0+:32];
	assign wb_in_op$104 = wb_we$82 ? wb_op$82 : y$5[31-:8];
	assign wb_in_we$104 = wb_we$82 | y_en$5[8];
	assign wb_in_ad$105 = wb_we$83 ? wb_ad$83 : y$5[4+:13];
	assign wb_in_d$105 = wb_we$83 ? wb_d$83 : acc$5[0+:32];
	assign wb_in_op$105 = wb_we$83 ? wb_op$83 : y$5[31-:8];
	assign wb_in_we$105 = wb_we$83 | y_en$5[9];
	assign wb_in_ad$106 = wb_we$84 ? wb_ad$84 : y$5[4+:13];
	assign wb_in_d$106 = wb_we$84 ? wb_d$84 : acc$5[0+:32];
	assign wb_in_op$106 = wb_we$84 ? wb_op$84 : y$5[31-:8];
	assign wb_in_we$106 = wb_we$84 | y_en$5[10];
	assign wb_in_ad$107 = wb_we$85 ? wb_ad$85 : y$5[4+:13];
	assign wb_in_d$107 = wb_we$85 ? wb_d$85 : acc$5[0+:32];
	assign wb_in_op$107 = wb_we$85 ? wb_op$85 : y$5[31-:8];
	assign wb_in_we$107 = wb_we$85 | y_en$5[11];
	assign wb_in_ad$108 = wb_we$86 ? wb_ad$86 : y$5[4+:13];
	assign wb_in_d$108 = wb_we$86 ? wb_d$86 : acc$5[0+:32];
	assign wb_in_op$108 = wb_we$86 ? wb_op$86 : y$5[31-:8];
	assign wb_in_we$108 = wb_we$86 | y_en$5[12];
	assign wb_in_ad$109 = wb_we$87 ? wb_ad$87 : y$5[4+:13];
	assign wb_in_d$109 = wb_we$87 ? wb_d$87 : acc$5[0+:32];
	assign wb_in_op$109 = wb_we$87 ? wb_op$87 : y$5[31-:8];
	assign wb_in_we$109 = wb_we$87 | y_en$5[13];
	assign wb_in_ad$110 = wb_we$88 ? wb_ad$88 : y$5[4+:13];
	assign wb_in_d$110 = wb_we$88 ? wb_d$88 : acc$5[0+:32];
	assign wb_in_op$110 = wb_we$88 ? wb_op$88 : y$5[31-:8];
	assign wb_in_we$110 = wb_we$88 | y_en$5[14];
	assign wb_in_ad$111 = wb_we$89 ? wb_ad$89 : y$5[4+:13];
	assign wb_in_d$111 = wb_we$89 ? wb_d$89 : acc$5[0+:32];
	assign wb_in_op$111 = wb_we$89 ? wb_op$89 : y$5[31-:8];
	assign wb_in_we$111 = wb_we$89 | y_en$5[15];
	assign acc_in$6 = acc_out$5;
	assign pc_in$6 = pc_out$5;
	assign wb_in_ad$113 = wb_we$90 ? wb_ad$90 : y$6[4+:13];
	assign wb_in_d$113 = wb_we$90 ? wb_d$90 : acc$6[0+:32];
	assign wb_in_op$113 = wb_we$90 ? wb_op$90 : y$6[31-:8];
	assign wb_in_we$113 = wb_we$90 | y_en$6[0];
	assign wb_in_ad$114 = wb_we$91 ? wb_ad$91 : y$6[4+:13];
	assign wb_in_d$114 = wb_we$91 ? wb_d$91 : acc$6[0+:32];
	assign wb_in_op$114 = wb_we$91 ? wb_op$91 : y$6[31-:8];
	assign wb_in_we$114 = wb_we$91 | y_en$6[1];
	assign wb_in_ad$115 = wb_we$92 ? wb_ad$92 : y$6[4+:13];
	assign wb_in_d$115 = wb_we$92 ? wb_d$92 : acc$6[0+:32];
	assign wb_in_op$115 = wb_we$92 ? wb_op$92 : y$6[31-:8];
	assign wb_in_we$115 = wb_we$92 | y_en$6[2];
	assign wb_in_ad$116 = wb_we$93 ? wb_ad$93 : y$6[4+:13];
	assign wb_in_d$116 = wb_we$93 ? wb_d$93 : acc$6[0+:32];
	assign wb_in_op$116 = wb_we$93 ? wb_op$93 : y$6[31-:8];
	assign wb_in_we$116 = wb_we$93 | y_en$6[3];
	assign wb_in_ad$117 = wb_we$94 ? wb_ad$94 : y$6[4+:13];
	assign wb_in_d$117 = wb_we$94 ? wb_d$94 : acc$6[0+:32];
	assign wb_in_op$117 = wb_we$94 ? wb_op$94 : y$6[31-:8];
	assign wb_in_we$117 = wb_we$94 | y_en$6[4];
	assign wb_in_ad$118 = wb_we$95 ? wb_ad$95 : y$6[4+:13];
	assign wb_in_d$118 = wb_we$95 ? wb_d$95 : acc$6[0+:32];
	assign wb_in_op$118 = wb_we$95 ? wb_op$95 : y$6[31-:8];
	assign wb_in_we$118 = wb_we$95 | y_en$6[5];
	assign wb_in_ad$119 = y$6[4+:13];
	assign wb_in_d$119 = acc$6[0+:32];
	assign wb_in_op$119 = y$6[31-:8];
	assign wb_in_we$119 = y_en$6[6];
	assign wb_in_ad$112 = wb_we$96 ? wb_ad$96 : y$6[4+:13];
	assign wb_in_d$112 = wb_we$96 ? wb_d$96 : acc$6[0+:32];
	assign wb_in_op$112 = wb_we$96 ? wb_op$96 : y$6[31-:8];
	assign wb_in_we$112 = wb_we$96 | y_en$6[7];
	assign wb_in_ad$120 = wb_we$97 ? wb_ad$97 : y$6[4+:13];
	assign wb_in_d$120 = wb_we$97 ? wb_d$97 : acc$6[0+:32];
	assign wb_in_op$120 = wb_we$97 ? wb_op$97 : y$6[31-:8];
	assign wb_in_we$120 = wb_we$97 | y_en$6[8];
	assign wb_in_ad$121 = wb_we$98 ? wb_ad$98 : y$6[4+:13];
	assign wb_in_d$121 = wb_we$98 ? wb_d$98 : acc$6[0+:32];
	assign wb_in_op$121 = wb_we$98 ? wb_op$98 : y$6[31-:8];
	assign wb_in_we$121 = wb_we$98 | y_en$6[9];
	assign wb_in_ad$122 = wb_we$99 ? wb_ad$99 : y$6[4+:13];
	assign wb_in_d$122 = wb_we$99 ? wb_d$99 : acc$6[0+:32];
	assign wb_in_op$122 = wb_we$99 ? wb_op$99 : y$6[31-:8];
	assign wb_in_we$122 = wb_we$99 | y_en$6[10];
	assign wb_in_ad$123 = wb_we$100 ? wb_ad$100 : y$6[4+:13];
	assign wb_in_d$123 = wb_we$100 ? wb_d$100 : acc$6[0+:32];
	assign wb_in_op$123 = wb_we$100 ? wb_op$100 : y$6[31-:8];
	assign wb_in_we$123 = wb_we$100 | y_en$6[11];
	assign wb_in_ad$124 = wb_we$101 ? wb_ad$101 : y$6[4+:13];
	assign wb_in_d$124 = wb_we$101 ? wb_d$101 : acc$6[0+:32];
	assign wb_in_op$124 = wb_we$101 ? wb_op$101 : y$6[31-:8];
	assign wb_in_we$124 = wb_we$101 | y_en$6[12];
	assign wb_in_ad$125 = wb_we$102 ? wb_ad$102 : y$6[4+:13];
	assign wb_in_d$125 = wb_we$102 ? wb_d$102 : acc$6[0+:32];
	assign wb_in_op$125 = wb_we$102 ? wb_op$102 : y$6[31-:8];
	assign wb_in_we$125 = wb_we$102 | y_en$6[13];
	assign wb_in_ad$126 = wb_we$103 ? wb_ad$103 : y$6[4+:13];
	assign wb_in_d$126 = wb_we$103 ? wb_d$103 : acc$6[0+:32];
	assign wb_in_op$126 = wb_we$103 ? wb_op$103 : y$6[31-:8];
	assign wb_in_we$126 = wb_we$103 | y_en$6[14];
	assign wb_in_ad$127 = wb_we$104 ? wb_ad$104 : y$6[4+:13];
	assign wb_in_d$127 = wb_we$104 ? wb_d$104 : acc$6[0+:32];
	assign wb_in_op$127 = wb_we$104 ? wb_op$104 : y$6[31-:8];
	assign wb_in_we$127 = wb_we$104 | y_en$6[15];
	assign acc_in$7 = acc_out$6;
	assign pc_in$7 = pc_out$6;
	assign wb_in_ad$129 = wb_we$105 ? wb_ad$105 : y$7[4+:13];
	assign wb_in_d$129 = wb_we$105 ? wb_d$105 : acc$7[0+:32];
	assign wb_in_op$129 = wb_we$105 ? wb_op$105 : y$7[31-:8];
	assign wb_in_we$129 = wb_we$105 | y_en$7[0];
	assign wb_in_ad$130 = wb_we$106 ? wb_ad$106 : y$7[4+:13];
	assign wb_in_d$130 = wb_we$106 ? wb_d$106 : acc$7[0+:32];
	assign wb_in_op$130 = wb_we$106 ? wb_op$106 : y$7[31-:8];
	assign wb_in_we$130 = wb_we$106 | y_en$7[1];
	assign wb_in_ad$131 = wb_we$107 ? wb_ad$107 : y$7[4+:13];
	assign wb_in_d$131 = wb_we$107 ? wb_d$107 : acc$7[0+:32];
	assign wb_in_op$131 = wb_we$107 ? wb_op$107 : y$7[31-:8];
	assign wb_in_we$131 = wb_we$107 | y_en$7[2];
	assign wb_in_ad$132 = wb_we$108 ? wb_ad$108 : y$7[4+:13];
	assign wb_in_d$132 = wb_we$108 ? wb_d$108 : acc$7[0+:32];
	assign wb_in_op$132 = wb_we$108 ? wb_op$108 : y$7[31-:8];
	assign wb_in_we$132 = wb_we$108 | y_en$7[3];
	assign wb_in_ad$133 = wb_we$109 ? wb_ad$109 : y$7[4+:13];
	assign wb_in_d$133 = wb_we$109 ? wb_d$109 : acc$7[0+:32];
	assign wb_in_op$133 = wb_we$109 ? wb_op$109 : y$7[31-:8];
	assign wb_in_we$133 = wb_we$109 | y_en$7[4];
	assign wb_in_ad$134 = wb_we$110 ? wb_ad$110 : y$7[4+:13];
	assign wb_in_d$134 = wb_we$110 ? wb_d$110 : acc$7[0+:32];
	assign wb_in_op$134 = wb_we$110 ? wb_op$110 : y$7[31-:8];
	assign wb_in_we$134 = wb_we$110 | y_en$7[5];
	assign wb_in_ad$135 = wb_we$111 ? wb_ad$111 : y$7[4+:13];
	assign wb_in_d$135 = wb_we$111 ? wb_d$111 : acc$7[0+:32];
	assign wb_in_op$135 = wb_we$111 ? wb_op$111 : y$7[31-:8];
	assign wb_in_we$135 = wb_we$111 | y_en$7[6];
	assign wb_in_ad$136 = y$7[4+:13];
	assign wb_in_d$136 = acc$7[0+:32];
	assign wb_in_op$136 = y$7[31-:8];
	assign wb_in_we$136 = y_en$7[7];
	assign wb_in_ad$128 = wb_we$112 ? wb_ad$112 : y$7[4+:13];
	assign wb_in_d$128 = wb_we$112 ? wb_d$112 : acc$7[0+:32];
	assign wb_in_op$128 = wb_we$112 ? wb_op$112 : y$7[31-:8];
	assign wb_in_we$128 = wb_we$112 | y_en$7[8];
	assign wb_in_ad$137 = wb_we$113 ? wb_ad$113 : y$7[4+:13];
	assign wb_in_d$137 = wb_we$113 ? wb_d$113 : acc$7[0+:32];
	assign wb_in_op$137 = wb_we$113 ? wb_op$113 : y$7[31-:8];
	assign wb_in_we$137 = wb_we$113 | y_en$7[9];
	assign wb_in_ad$138 = wb_we$114 ? wb_ad$114 : y$7[4+:13];
	assign wb_in_d$138 = wb_we$114 ? wb_d$114 : acc$7[0+:32];
	assign wb_in_op$138 = wb_we$114 ? wb_op$114 : y$7[31-:8];
	assign wb_in_we$138 = wb_we$114 | y_en$7[10];
	assign wb_in_ad$139 = wb_we$115 ? wb_ad$115 : y$7[4+:13];
	assign wb_in_d$139 = wb_we$115 ? wb_d$115 : acc$7[0+:32];
	assign wb_in_op$139 = wb_we$115 ? wb_op$115 : y$7[31-:8];
	assign wb_in_we$139 = wb_we$115 | y_en$7[11];
	assign wb_in_ad$140 = wb_we$116 ? wb_ad$116 : y$7[4+:13];
	assign wb_in_d$140 = wb_we$116 ? wb_d$116 : acc$7[0+:32];
	assign wb_in_op$140 = wb_we$116 ? wb_op$116 : y$7[31-:8];
	assign wb_in_we$140 = wb_we$116 | y_en$7[12];
	assign wb_in_ad$141 = wb_we$117 ? wb_ad$117 : y$7[4+:13];
	assign wb_in_d$141 = wb_we$117 ? wb_d$117 : acc$7[0+:32];
	assign wb_in_op$141 = wb_we$117 ? wb_op$117 : y$7[31-:8];
	assign wb_in_we$141 = wb_we$117 | y_en$7[13];
	assign wb_in_ad$142 = wb_we$118 ? wb_ad$118 : y$7[4+:13];
	assign wb_in_d$142 = wb_we$118 ? wb_d$118 : acc$7[0+:32];
	assign wb_in_op$142 = wb_we$118 ? wb_op$118 : y$7[31-:8];
	assign wb_in_we$142 = wb_we$118 | y_en$7[14];
	assign wb_in_ad$143 = wb_we$119 ? wb_ad$119 : y$7[4+:13];
	assign wb_in_d$143 = wb_we$119 ? wb_d$119 : acc$7[0+:32];
	assign wb_in_op$143 = wb_we$119 ? wb_op$119 : y$7[31-:8];
	assign wb_in_we$143 = wb_we$119 | y_en$7[15];
	assign acc_in$8 = acc_out$7;
	assign pc_in$8 = pc_out$7;
	assign wb_in_ad$145 = wb_we$120 ? wb_ad$120 : y$8[4+:13];
	assign wb_in_d$145 = wb_we$120 ? wb_d$120 : acc$8[0+:32];
	assign wb_in_op$145 = wb_we$120 ? wb_op$120 : y$8[31-:8];
	assign wb_in_we$145 = wb_we$120 | y_en$8[0];
	assign wb_in_ad$146 = wb_we$121 ? wb_ad$121 : y$8[4+:13];
	assign wb_in_d$146 = wb_we$121 ? wb_d$121 : acc$8[0+:32];
	assign wb_in_op$146 = wb_we$121 ? wb_op$121 : y$8[31-:8];
	assign wb_in_we$146 = wb_we$121 | y_en$8[1];
	assign wb_in_ad$147 = wb_we$122 ? wb_ad$122 : y$8[4+:13];
	assign wb_in_d$147 = wb_we$122 ? wb_d$122 : acc$8[0+:32];
	assign wb_in_op$147 = wb_we$122 ? wb_op$122 : y$8[31-:8];
	assign wb_in_we$147 = wb_we$122 | y_en$8[2];
	assign wb_in_ad$148 = wb_we$123 ? wb_ad$123 : y$8[4+:13];
	assign wb_in_d$148 = wb_we$123 ? wb_d$123 : acc$8[0+:32];
	assign wb_in_op$148 = wb_we$123 ? wb_op$123 : y$8[31-:8];
	assign wb_in_we$148 = wb_we$123 | y_en$8[3];
	assign wb_in_ad$149 = wb_we$124 ? wb_ad$124 : y$8[4+:13];
	assign wb_in_d$149 = wb_we$124 ? wb_d$124 : acc$8[0+:32];
	assign wb_in_op$149 = wb_we$124 ? wb_op$124 : y$8[31-:8];
	assign wb_in_we$149 = wb_we$124 | y_en$8[4];
	assign wb_in_ad$150 = wb_we$125 ? wb_ad$125 : y$8[4+:13];
	assign wb_in_d$150 = wb_we$125 ? wb_d$125 : acc$8[0+:32];
	assign wb_in_op$150 = wb_we$125 ? wb_op$125 : y$8[31-:8];
	assign wb_in_we$150 = wb_we$125 | y_en$8[5];
	assign wb_in_ad$151 = wb_we$126 ? wb_ad$126 : y$8[4+:13];
	assign wb_in_d$151 = wb_we$126 ? wb_d$126 : acc$8[0+:32];
	assign wb_in_op$151 = wb_we$126 ? wb_op$126 : y$8[31-:8];
	assign wb_in_we$151 = wb_we$126 | y_en$8[6];
	assign wb_in_ad$152 = wb_we$127 ? wb_ad$127 : y$8[4+:13];
	assign wb_in_d$152 = wb_we$127 ? wb_d$127 : acc$8[0+:32];
	assign wb_in_op$152 = wb_we$127 ? wb_op$127 : y$8[31-:8];
	assign wb_in_we$152 = wb_we$127 | y_en$8[7];
	assign wb_in_ad$153 = y$8[4+:13];
	assign wb_in_d$153 = acc$8[0+:32];
	assign wb_in_op$153 = y$8[31-:8];
	assign wb_in_we$153 = y_en$8[8];
	assign wb_in_ad$144 = wb_we$128 ? wb_ad$128 : y$8[4+:13];
	assign wb_in_d$144 = wb_we$128 ? wb_d$128 : acc$8[0+:32];
	assign wb_in_op$144 = wb_we$128 ? wb_op$128 : y$8[31-:8];
	assign wb_in_we$144 = wb_we$128 | y_en$8[9];
	assign wb_in_ad$154 = wb_we$129 ? wb_ad$129 : y$8[4+:13];
	assign wb_in_d$154 = wb_we$129 ? wb_d$129 : acc$8[0+:32];
	assign wb_in_op$154 = wb_we$129 ? wb_op$129 : y$8[31-:8];
	assign wb_in_we$154 = wb_we$129 | y_en$8[10];
	assign wb_in_ad$155 = wb_we$130 ? wb_ad$130 : y$8[4+:13];
	assign wb_in_d$155 = wb_we$130 ? wb_d$130 : acc$8[0+:32];
	assign wb_in_op$155 = wb_we$130 ? wb_op$130 : y$8[31-:8];
	assign wb_in_we$155 = wb_we$130 | y_en$8[11];
	assign wb_in_ad$156 = wb_we$131 ? wb_ad$131 : y$8[4+:13];
	assign wb_in_d$156 = wb_we$131 ? wb_d$131 : acc$8[0+:32];
	assign wb_in_op$156 = wb_we$131 ? wb_op$131 : y$8[31-:8];
	assign wb_in_we$156 = wb_we$131 | y_en$8[12];
	assign wb_in_ad$157 = wb_we$132 ? wb_ad$132 : y$8[4+:13];
	assign wb_in_d$157 = wb_we$132 ? wb_d$132 : acc$8[0+:32];
	assign wb_in_op$157 = wb_we$132 ? wb_op$132 : y$8[31-:8];
	assign wb_in_we$157 = wb_we$132 | y_en$8[13];
	assign wb_in_ad$158 = wb_we$133 ? wb_ad$133 : y$8[4+:13];
	assign wb_in_d$158 = wb_we$133 ? wb_d$133 : acc$8[0+:32];
	assign wb_in_op$158 = wb_we$133 ? wb_op$133 : y$8[31-:8];
	assign wb_in_we$158 = wb_we$133 | y_en$8[14];
	assign wb_in_ad$159 = wb_we$134 ? wb_ad$134 : y$8[4+:13];
	assign wb_in_d$159 = wb_we$134 ? wb_d$134 : acc$8[0+:32];
	assign wb_in_op$159 = wb_we$134 ? wb_op$134 : y$8[31-:8];
	assign wb_in_we$159 = wb_we$134 | y_en$8[15];
	assign acc_in$9 = acc_out$8;
	assign pc_in$9 = pc_out$8;
	assign wb_in_ad$161 = wb_we$135 ? wb_ad$135 : y$9[4+:13];
	assign wb_in_d$161 = wb_we$135 ? wb_d$135 : acc$9[0+:32];
	assign wb_in_op$161 = wb_we$135 ? wb_op$135 : y$9[31-:8];
	assign wb_in_we$161 = wb_we$135 | y_en$9[0];
	assign wb_in_ad$162 = wb_we$136 ? wb_ad$136 : y$9[4+:13];
	assign wb_in_d$162 = wb_we$136 ? wb_d$136 : acc$9[0+:32];
	assign wb_in_op$162 = wb_we$136 ? wb_op$136 : y$9[31-:8];
	assign wb_in_we$162 = wb_we$136 | y_en$9[1];
	assign wb_in_ad$163 = wb_we$137 ? wb_ad$137 : y$9[4+:13];
	assign wb_in_d$163 = wb_we$137 ? wb_d$137 : acc$9[0+:32];
	assign wb_in_op$163 = wb_we$137 ? wb_op$137 : y$9[31-:8];
	assign wb_in_we$163 = wb_we$137 | y_en$9[2];
	assign wb_in_ad$164 = wb_we$138 ? wb_ad$138 : y$9[4+:13];
	assign wb_in_d$164 = wb_we$138 ? wb_d$138 : acc$9[0+:32];
	assign wb_in_op$164 = wb_we$138 ? wb_op$138 : y$9[31-:8];
	assign wb_in_we$164 = wb_we$138 | y_en$9[3];
	assign wb_in_ad$165 = wb_we$139 ? wb_ad$139 : y$9[4+:13];
	assign wb_in_d$165 = wb_we$139 ? wb_d$139 : acc$9[0+:32];
	assign wb_in_op$165 = wb_we$139 ? wb_op$139 : y$9[31-:8];
	assign wb_in_we$165 = wb_we$139 | y_en$9[4];
	assign wb_in_ad$166 = wb_we$140 ? wb_ad$140 : y$9[4+:13];
	assign wb_in_d$166 = wb_we$140 ? wb_d$140 : acc$9[0+:32];
	assign wb_in_op$166 = wb_we$140 ? wb_op$140 : y$9[31-:8];
	assign wb_in_we$166 = wb_we$140 | y_en$9[5];
	assign wb_in_ad$167 = wb_we$141 ? wb_ad$141 : y$9[4+:13];
	assign wb_in_d$167 = wb_we$141 ? wb_d$141 : acc$9[0+:32];
	assign wb_in_op$167 = wb_we$141 ? wb_op$141 : y$9[31-:8];
	assign wb_in_we$167 = wb_we$141 | y_en$9[6];
	assign wb_in_ad$168 = wb_we$142 ? wb_ad$142 : y$9[4+:13];
	assign wb_in_d$168 = wb_we$142 ? wb_d$142 : acc$9[0+:32];
	assign wb_in_op$168 = wb_we$142 ? wb_op$142 : y$9[31-:8];
	assign wb_in_we$168 = wb_we$142 | y_en$9[7];
	assign wb_in_ad$169 = wb_we$143 ? wb_ad$143 : y$9[4+:13];
	assign wb_in_d$169 = wb_we$143 ? wb_d$143 : acc$9[0+:32];
	assign wb_in_op$169 = wb_we$143 ? wb_op$143 : y$9[31-:8];
	assign wb_in_we$169 = wb_we$143 | y_en$9[8];
	assign wb_in_ad$170 = y$9[4+:13];
	assign wb_in_d$170 = acc$9[0+:32];
	assign wb_in_op$170 = y$9[31-:8];
	assign wb_in_we$170 = y_en$9[9];
	assign wb_in_ad$160 = wb_we$144 ? wb_ad$144 : y$9[4+:13];
	assign wb_in_d$160 = wb_we$144 ? wb_d$144 : acc$9[0+:32];
	assign wb_in_op$160 = wb_we$144 ? wb_op$144 : y$9[31-:8];
	assign wb_in_we$160 = wb_we$144 | y_en$9[10];
	assign wb_in_ad$171 = wb_we$145 ? wb_ad$145 : y$9[4+:13];
	assign wb_in_d$171 = wb_we$145 ? wb_d$145 : acc$9[0+:32];
	assign wb_in_op$171 = wb_we$145 ? wb_op$145 : y$9[31-:8];
	assign wb_in_we$171 = wb_we$145 | y_en$9[11];
	assign wb_in_ad$172 = wb_we$146 ? wb_ad$146 : y$9[4+:13];
	assign wb_in_d$172 = wb_we$146 ? wb_d$146 : acc$9[0+:32];
	assign wb_in_op$172 = wb_we$146 ? wb_op$146 : y$9[31-:8];
	assign wb_in_we$172 = wb_we$146 | y_en$9[12];
	assign wb_in_ad$173 = wb_we$147 ? wb_ad$147 : y$9[4+:13];
	assign wb_in_d$173 = wb_we$147 ? wb_d$147 : acc$9[0+:32];
	assign wb_in_op$173 = wb_we$147 ? wb_op$147 : y$9[31-:8];
	assign wb_in_we$173 = wb_we$147 | y_en$9[13];
	assign wb_in_ad$174 = wb_we$148 ? wb_ad$148 : y$9[4+:13];
	assign wb_in_d$174 = wb_we$148 ? wb_d$148 : acc$9[0+:32];
	assign wb_in_op$174 = wb_we$148 ? wb_op$148 : y$9[31-:8];
	assign wb_in_we$174 = wb_we$148 | y_en$9[14];
	assign wb_in_ad$175 = wb_we$149 ? wb_ad$149 : y$9[4+:13];
	assign wb_in_d$175 = wb_we$149 ? wb_d$149 : acc$9[0+:32];
	assign wb_in_op$175 = wb_we$149 ? wb_op$149 : y$9[31-:8];
	assign wb_in_we$175 = wb_we$149 | y_en$9[15];
	assign acc_in$10 = acc_out$9;
	assign pc_in$10 = pc_out$9;
	assign wb_in_ad$177 = wb_we$150 ? wb_ad$150 : y$10[4+:13];
	assign wb_in_d$177 = wb_we$150 ? wb_d$150 : acc$10[0+:32];
	assign wb_in_op$177 = wb_we$150 ? wb_op$150 : y$10[31-:8];
	assign wb_in_we$177 = wb_we$150 | y_en$10[0];
	assign wb_in_ad$178 = wb_we$151 ? wb_ad$151 : y$10[4+:13];
	assign wb_in_d$178 = wb_we$151 ? wb_d$151 : acc$10[0+:32];
	assign wb_in_op$178 = wb_we$151 ? wb_op$151 : y$10[31-:8];
	assign wb_in_we$178 = wb_we$151 | y_en$10[1];
	assign wb_in_ad$179 = wb_we$152 ? wb_ad$152 : y$10[4+:13];
	assign wb_in_d$179 = wb_we$152 ? wb_d$152 : acc$10[0+:32];
	assign wb_in_op$179 = wb_we$152 ? wb_op$152 : y$10[31-:8];
	assign wb_in_we$179 = wb_we$152 | y_en$10[2];
	assign wb_in_ad$180 = wb_we$153 ? wb_ad$153 : y$10[4+:13];
	assign wb_in_d$180 = wb_we$153 ? wb_d$153 : acc$10[0+:32];
	assign wb_in_op$180 = wb_we$153 ? wb_op$153 : y$10[31-:8];
	assign wb_in_we$180 = wb_we$153 | y_en$10[3];
	assign wb_in_ad$181 = wb_we$154 ? wb_ad$154 : y$10[4+:13];
	assign wb_in_d$181 = wb_we$154 ? wb_d$154 : acc$10[0+:32];
	assign wb_in_op$181 = wb_we$154 ? wb_op$154 : y$10[31-:8];
	assign wb_in_we$181 = wb_we$154 | y_en$10[4];
	assign wb_in_ad$182 = wb_we$155 ? wb_ad$155 : y$10[4+:13];
	assign wb_in_d$182 = wb_we$155 ? wb_d$155 : acc$10[0+:32];
	assign wb_in_op$182 = wb_we$155 ? wb_op$155 : y$10[31-:8];
	assign wb_in_we$182 = wb_we$155 | y_en$10[5];
	assign wb_in_ad$183 = wb_we$156 ? wb_ad$156 : y$10[4+:13];
	assign wb_in_d$183 = wb_we$156 ? wb_d$156 : acc$10[0+:32];
	assign wb_in_op$183 = wb_we$156 ? wb_op$156 : y$10[31-:8];
	assign wb_in_we$183 = wb_we$156 | y_en$10[6];
	assign wb_in_ad$184 = wb_we$157 ? wb_ad$157 : y$10[4+:13];
	assign wb_in_d$184 = wb_we$157 ? wb_d$157 : acc$10[0+:32];
	assign wb_in_op$184 = wb_we$157 ? wb_op$157 : y$10[31-:8];
	assign wb_in_we$184 = wb_we$157 | y_en$10[7];
	assign wb_in_ad$185 = wb_we$158 ? wb_ad$158 : y$10[4+:13];
	assign wb_in_d$185 = wb_we$158 ? wb_d$158 : acc$10[0+:32];
	assign wb_in_op$185 = wb_we$158 ? wb_op$158 : y$10[31-:8];
	assign wb_in_we$185 = wb_we$158 | y_en$10[8];
	assign wb_in_ad$186 = wb_we$159 ? wb_ad$159 : y$10[4+:13];
	assign wb_in_d$186 = wb_we$159 ? wb_d$159 : acc$10[0+:32];
	assign wb_in_op$186 = wb_we$159 ? wb_op$159 : y$10[31-:8];
	assign wb_in_we$186 = wb_we$159 | y_en$10[9];
	assign wb_in_ad$187 = y$10[4+:13];
	assign wb_in_d$187 = acc$10[0+:32];
	assign wb_in_op$187 = y$10[31-:8];
	assign wb_in_we$187 = y_en$10[10];
	assign wb_in_ad$176 = wb_we$160 ? wb_ad$160 : y$10[4+:13];
	assign wb_in_d$176 = wb_we$160 ? wb_d$160 : acc$10[0+:32];
	assign wb_in_op$176 = wb_we$160 ? wb_op$160 : y$10[31-:8];
	assign wb_in_we$176 = wb_we$160 | y_en$10[11];
	assign wb_in_ad$188 = wb_we$161 ? wb_ad$161 : y$10[4+:13];
	assign wb_in_d$188 = wb_we$161 ? wb_d$161 : acc$10[0+:32];
	assign wb_in_op$188 = wb_we$161 ? wb_op$161 : y$10[31-:8];
	assign wb_in_we$188 = wb_we$161 | y_en$10[12];
	assign wb_in_ad$189 = wb_we$162 ? wb_ad$162 : y$10[4+:13];
	assign wb_in_d$189 = wb_we$162 ? wb_d$162 : acc$10[0+:32];
	assign wb_in_op$189 = wb_we$162 ? wb_op$162 : y$10[31-:8];
	assign wb_in_we$189 = wb_we$162 | y_en$10[13];
	assign wb_in_ad$190 = wb_we$163 ? wb_ad$163 : y$10[4+:13];
	assign wb_in_d$190 = wb_we$163 ? wb_d$163 : acc$10[0+:32];
	assign wb_in_op$190 = wb_we$163 ? wb_op$163 : y$10[31-:8];
	assign wb_in_we$190 = wb_we$163 | y_en$10[14];
	assign wb_in_ad$191 = wb_we$164 ? wb_ad$164 : y$10[4+:13];
	assign wb_in_d$191 = wb_we$164 ? wb_d$164 : acc$10[0+:32];
	assign wb_in_op$191 = wb_we$164 ? wb_op$164 : y$10[31-:8];
	assign wb_in_we$191 = wb_we$164 | y_en$10[15];
	assign acc_in$11 = acc_out$10;
	assign pc_in$11 = pc_out$10;
	assign wb_in_ad$193 = wb_we$165 ? wb_ad$165 : y$11[4+:13];
	assign wb_in_d$193 = wb_we$165 ? wb_d$165 : acc$11[0+:32];
	assign wb_in_op$193 = wb_we$165 ? wb_op$165 : y$11[31-:8];
	assign wb_in_we$193 = wb_we$165 | y_en$11[0];
	assign wb_in_ad$194 = wb_we$166 ? wb_ad$166 : y$11[4+:13];
	assign wb_in_d$194 = wb_we$166 ? wb_d$166 : acc$11[0+:32];
	assign wb_in_op$194 = wb_we$166 ? wb_op$166 : y$11[31-:8];
	assign wb_in_we$194 = wb_we$166 | y_en$11[1];
	assign wb_in_ad$195 = wb_we$167 ? wb_ad$167 : y$11[4+:13];
	assign wb_in_d$195 = wb_we$167 ? wb_d$167 : acc$11[0+:32];
	assign wb_in_op$195 = wb_we$167 ? wb_op$167 : y$11[31-:8];
	assign wb_in_we$195 = wb_we$167 | y_en$11[2];
	assign wb_in_ad$196 = wb_we$168 ? wb_ad$168 : y$11[4+:13];
	assign wb_in_d$196 = wb_we$168 ? wb_d$168 : acc$11[0+:32];
	assign wb_in_op$196 = wb_we$168 ? wb_op$168 : y$11[31-:8];
	assign wb_in_we$196 = wb_we$168 | y_en$11[3];
	assign wb_in_ad$197 = wb_we$169 ? wb_ad$169 : y$11[4+:13];
	assign wb_in_d$197 = wb_we$169 ? wb_d$169 : acc$11[0+:32];
	assign wb_in_op$197 = wb_we$169 ? wb_op$169 : y$11[31-:8];
	assign wb_in_we$197 = wb_we$169 | y_en$11[4];
	assign wb_in_ad$198 = wb_we$170 ? wb_ad$170 : y$11[4+:13];
	assign wb_in_d$198 = wb_we$170 ? wb_d$170 : acc$11[0+:32];
	assign wb_in_op$198 = wb_we$170 ? wb_op$170 : y$11[31-:8];
	assign wb_in_we$198 = wb_we$170 | y_en$11[5];
	assign wb_in_ad$199 = wb_we$171 ? wb_ad$171 : y$11[4+:13];
	assign wb_in_d$199 = wb_we$171 ? wb_d$171 : acc$11[0+:32];
	assign wb_in_op$199 = wb_we$171 ? wb_op$171 : y$11[31-:8];
	assign wb_in_we$199 = wb_we$171 | y_en$11[6];
	assign wb_in_ad$200 = wb_we$172 ? wb_ad$172 : y$11[4+:13];
	assign wb_in_d$200 = wb_we$172 ? wb_d$172 : acc$11[0+:32];
	assign wb_in_op$200 = wb_we$172 ? wb_op$172 : y$11[31-:8];
	assign wb_in_we$200 = wb_we$172 | y_en$11[7];
	assign wb_in_ad$201 = wb_we$173 ? wb_ad$173 : y$11[4+:13];
	assign wb_in_d$201 = wb_we$173 ? wb_d$173 : acc$11[0+:32];
	assign wb_in_op$201 = wb_we$173 ? wb_op$173 : y$11[31-:8];
	assign wb_in_we$201 = wb_we$173 | y_en$11[8];
	assign wb_in_ad$202 = wb_we$174 ? wb_ad$174 : y$11[4+:13];
	assign wb_in_d$202 = wb_we$174 ? wb_d$174 : acc$11[0+:32];
	assign wb_in_op$202 = wb_we$174 ? wb_op$174 : y$11[31-:8];
	assign wb_in_we$202 = wb_we$174 | y_en$11[9];
	assign wb_in_ad$203 = wb_we$175 ? wb_ad$175 : y$11[4+:13];
	assign wb_in_d$203 = wb_we$175 ? wb_d$175 : acc$11[0+:32];
	assign wb_in_op$203 = wb_we$175 ? wb_op$175 : y$11[31-:8];
	assign wb_in_we$203 = wb_we$175 | y_en$11[10];
	assign wb_in_ad$204 = y$11[4+:13];
	assign wb_in_d$204 = acc$11[0+:32];
	assign wb_in_op$204 = y$11[31-:8];
	assign wb_in_we$204 = y_en$11[11];
	assign wb_in_ad$192 = wb_we$176 ? wb_ad$176 : y$11[4+:13];
	assign wb_in_d$192 = wb_we$176 ? wb_d$176 : acc$11[0+:32];
	assign wb_in_op$192 = wb_we$176 ? wb_op$176 : y$11[31-:8];
	assign wb_in_we$192 = wb_we$176 | y_en$11[12];
	assign wb_in_ad$205 = wb_we$177 ? wb_ad$177 : y$11[4+:13];
	assign wb_in_d$205 = wb_we$177 ? wb_d$177 : acc$11[0+:32];
	assign wb_in_op$205 = wb_we$177 ? wb_op$177 : y$11[31-:8];
	assign wb_in_we$205 = wb_we$177 | y_en$11[13];
	assign wb_in_ad$206 = wb_we$178 ? wb_ad$178 : y$11[4+:13];
	assign wb_in_d$206 = wb_we$178 ? wb_d$178 : acc$11[0+:32];
	assign wb_in_op$206 = wb_we$178 ? wb_op$178 : y$11[31-:8];
	assign wb_in_we$206 = wb_we$178 | y_en$11[14];
	assign wb_in_ad$207 = wb_we$179 ? wb_ad$179 : y$11[4+:13];
	assign wb_in_d$207 = wb_we$179 ? wb_d$179 : acc$11[0+:32];
	assign wb_in_op$207 = wb_we$179 ? wb_op$179 : y$11[31-:8];
	assign wb_in_we$207 = wb_we$179 | y_en$11[15];
	assign acc_in$12 = acc_out$11;
	assign pc_in$12 = pc_out$11;
	assign wb_in_ad$209 = wb_we$180 ? wb_ad$180 : y$12[4+:13];
	assign wb_in_d$209 = wb_we$180 ? wb_d$180 : acc$12[0+:32];
	assign wb_in_op$209 = wb_we$180 ? wb_op$180 : y$12[31-:8];
	assign wb_in_we$209 = wb_we$180 | y_en$12[0];
	assign wb_in_ad$210 = wb_we$181 ? wb_ad$181 : y$12[4+:13];
	assign wb_in_d$210 = wb_we$181 ? wb_d$181 : acc$12[0+:32];
	assign wb_in_op$210 = wb_we$181 ? wb_op$181 : y$12[31-:8];
	assign wb_in_we$210 = wb_we$181 | y_en$12[1];
	assign wb_in_ad$211 = wb_we$182 ? wb_ad$182 : y$12[4+:13];
	assign wb_in_d$211 = wb_we$182 ? wb_d$182 : acc$12[0+:32];
	assign wb_in_op$211 = wb_we$182 ? wb_op$182 : y$12[31-:8];
	assign wb_in_we$211 = wb_we$182 | y_en$12[2];
	assign wb_in_ad$212 = wb_we$183 ? wb_ad$183 : y$12[4+:13];
	assign wb_in_d$212 = wb_we$183 ? wb_d$183 : acc$12[0+:32];
	assign wb_in_op$212 = wb_we$183 ? wb_op$183 : y$12[31-:8];
	assign wb_in_we$212 = wb_we$183 | y_en$12[3];
	assign wb_in_ad$213 = wb_we$184 ? wb_ad$184 : y$12[4+:13];
	assign wb_in_d$213 = wb_we$184 ? wb_d$184 : acc$12[0+:32];
	assign wb_in_op$213 = wb_we$184 ? wb_op$184 : y$12[31-:8];
	assign wb_in_we$213 = wb_we$184 | y_en$12[4];
	assign wb_in_ad$214 = wb_we$185 ? wb_ad$185 : y$12[4+:13];
	assign wb_in_d$214 = wb_we$185 ? wb_d$185 : acc$12[0+:32];
	assign wb_in_op$214 = wb_we$185 ? wb_op$185 : y$12[31-:8];
	assign wb_in_we$214 = wb_we$185 | y_en$12[5];
	assign wb_in_ad$215 = wb_we$186 ? wb_ad$186 : y$12[4+:13];
	assign wb_in_d$215 = wb_we$186 ? wb_d$186 : acc$12[0+:32];
	assign wb_in_op$215 = wb_we$186 ? wb_op$186 : y$12[31-:8];
	assign wb_in_we$215 = wb_we$186 | y_en$12[6];
	assign wb_in_ad$216 = wb_we$187 ? wb_ad$187 : y$12[4+:13];
	assign wb_in_d$216 = wb_we$187 ? wb_d$187 : acc$12[0+:32];
	assign wb_in_op$216 = wb_we$187 ? wb_op$187 : y$12[31-:8];
	assign wb_in_we$216 = wb_we$187 | y_en$12[7];
	assign wb_in_ad$217 = wb_we$188 ? wb_ad$188 : y$12[4+:13];
	assign wb_in_d$217 = wb_we$188 ? wb_d$188 : acc$12[0+:32];
	assign wb_in_op$217 = wb_we$188 ? wb_op$188 : y$12[31-:8];
	assign wb_in_we$217 = wb_we$188 | y_en$12[8];
	assign wb_in_ad$218 = wb_we$189 ? wb_ad$189 : y$12[4+:13];
	assign wb_in_d$218 = wb_we$189 ? wb_d$189 : acc$12[0+:32];
	assign wb_in_op$218 = wb_we$189 ? wb_op$189 : y$12[31-:8];
	assign wb_in_we$218 = wb_we$189 | y_en$12[9];
	assign wb_in_ad$219 = wb_we$190 ? wb_ad$190 : y$12[4+:13];
	assign wb_in_d$219 = wb_we$190 ? wb_d$190 : acc$12[0+:32];
	assign wb_in_op$219 = wb_we$190 ? wb_op$190 : y$12[31-:8];
	assign wb_in_we$219 = wb_we$190 | y_en$12[10];
	assign wb_in_ad$220 = wb_we$191 ? wb_ad$191 : y$12[4+:13];
	assign wb_in_d$220 = wb_we$191 ? wb_d$191 : acc$12[0+:32];
	assign wb_in_op$220 = wb_we$191 ? wb_op$191 : y$12[31-:8];
	assign wb_in_we$220 = wb_we$191 | y_en$12[11];
	assign wb_in_ad$221 = y$12[4+:13];
	assign wb_in_d$221 = acc$12[0+:32];
	assign wb_in_op$221 = y$12[31-:8];
	assign wb_in_we$221 = y_en$12[12];
	assign wb_in_ad$208 = wb_we$192 ? wb_ad$192 : y$12[4+:13];
	assign wb_in_d$208 = wb_we$192 ? wb_d$192 : acc$12[0+:32];
	assign wb_in_op$208 = wb_we$192 ? wb_op$192 : y$12[31-:8];
	assign wb_in_we$208 = wb_we$192 | y_en$12[13];
	assign wb_in_ad$222 = wb_we$193 ? wb_ad$193 : y$12[4+:13];
	assign wb_in_d$222 = wb_we$193 ? wb_d$193 : acc$12[0+:32];
	assign wb_in_op$222 = wb_we$193 ? wb_op$193 : y$12[31-:8];
	assign wb_in_we$222 = wb_we$193 | y_en$12[14];
	assign wb_in_ad$223 = wb_we$194 ? wb_ad$194 : y$12[4+:13];
	assign wb_in_d$223 = wb_we$194 ? wb_d$194 : acc$12[0+:32];
	assign wb_in_op$223 = wb_we$194 ? wb_op$194 : y$12[31-:8];
	assign wb_in_we$223 = wb_we$194 | y_en$12[15];
	assign acc_in$13 = acc_out$12;
	assign pc_in$13 = pc_out$12;
	assign wb_in_ad$225 = wb_we$195 ? wb_ad$195 : y$13[4+:13];
	assign wb_in_d$225 = wb_we$195 ? wb_d$195 : acc$13[0+:32];
	assign wb_in_op$225 = wb_we$195 ? wb_op$195 : y$13[31-:8];
	assign wb_in_we$225 = wb_we$195 | y_en$13[0];
	assign wb_in_ad$226 = wb_we$196 ? wb_ad$196 : y$13[4+:13];
	assign wb_in_d$226 = wb_we$196 ? wb_d$196 : acc$13[0+:32];
	assign wb_in_op$226 = wb_we$196 ? wb_op$196 : y$13[31-:8];
	assign wb_in_we$226 = wb_we$196 | y_en$13[1];
	assign wb_in_ad$227 = wb_we$197 ? wb_ad$197 : y$13[4+:13];
	assign wb_in_d$227 = wb_we$197 ? wb_d$197 : acc$13[0+:32];
	assign wb_in_op$227 = wb_we$197 ? wb_op$197 : y$13[31-:8];
	assign wb_in_we$227 = wb_we$197 | y_en$13[2];
	assign wb_in_ad$228 = wb_we$198 ? wb_ad$198 : y$13[4+:13];
	assign wb_in_d$228 = wb_we$198 ? wb_d$198 : acc$13[0+:32];
	assign wb_in_op$228 = wb_we$198 ? wb_op$198 : y$13[31-:8];
	assign wb_in_we$228 = wb_we$198 | y_en$13[3];
	assign wb_in_ad$229 = wb_we$199 ? wb_ad$199 : y$13[4+:13];
	assign wb_in_d$229 = wb_we$199 ? wb_d$199 : acc$13[0+:32];
	assign wb_in_op$229 = wb_we$199 ? wb_op$199 : y$13[31-:8];
	assign wb_in_we$229 = wb_we$199 | y_en$13[4];
	assign wb_in_ad$230 = wb_we$200 ? wb_ad$200 : y$13[4+:13];
	assign wb_in_d$230 = wb_we$200 ? wb_d$200 : acc$13[0+:32];
	assign wb_in_op$230 = wb_we$200 ? wb_op$200 : y$13[31-:8];
	assign wb_in_we$230 = wb_we$200 | y_en$13[5];
	assign wb_in_ad$231 = wb_we$201 ? wb_ad$201 : y$13[4+:13];
	assign wb_in_d$231 = wb_we$201 ? wb_d$201 : acc$13[0+:32];
	assign wb_in_op$231 = wb_we$201 ? wb_op$201 : y$13[31-:8];
	assign wb_in_we$231 = wb_we$201 | y_en$13[6];
	assign wb_in_ad$232 = wb_we$202 ? wb_ad$202 : y$13[4+:13];
	assign wb_in_d$232 = wb_we$202 ? wb_d$202 : acc$13[0+:32];
	assign wb_in_op$232 = wb_we$202 ? wb_op$202 : y$13[31-:8];
	assign wb_in_we$232 = wb_we$202 | y_en$13[7];
	assign wb_in_ad$233 = wb_we$203 ? wb_ad$203 : y$13[4+:13];
	assign wb_in_d$233 = wb_we$203 ? wb_d$203 : acc$13[0+:32];
	assign wb_in_op$233 = wb_we$203 ? wb_op$203 : y$13[31-:8];
	assign wb_in_we$233 = wb_we$203 | y_en$13[8];
	assign wb_in_ad$234 = wb_we$204 ? wb_ad$204 : y$13[4+:13];
	assign wb_in_d$234 = wb_we$204 ? wb_d$204 : acc$13[0+:32];
	assign wb_in_op$234 = wb_we$204 ? wb_op$204 : y$13[31-:8];
	assign wb_in_we$234 = wb_we$204 | y_en$13[9];
	assign wb_in_ad$235 = wb_we$205 ? wb_ad$205 : y$13[4+:13];
	assign wb_in_d$235 = wb_we$205 ? wb_d$205 : acc$13[0+:32];
	assign wb_in_op$235 = wb_we$205 ? wb_op$205 : y$13[31-:8];
	assign wb_in_we$235 = wb_we$205 | y_en$13[10];
	assign wb_in_ad$236 = wb_we$206 ? wb_ad$206 : y$13[4+:13];
	assign wb_in_d$236 = wb_we$206 ? wb_d$206 : acc$13[0+:32];
	assign wb_in_op$236 = wb_we$206 ? wb_op$206 : y$13[31-:8];
	assign wb_in_we$236 = wb_we$206 | y_en$13[11];
	assign wb_in_ad$237 = wb_we$207 ? wb_ad$207 : y$13[4+:13];
	assign wb_in_d$237 = wb_we$207 ? wb_d$207 : acc$13[0+:32];
	assign wb_in_op$237 = wb_we$207 ? wb_op$207 : y$13[31-:8];
	assign wb_in_we$237 = wb_we$207 | y_en$13[12];
	assign wb_in_ad$238 = y$13[4+:13];
	assign wb_in_d$238 = acc$13[0+:32];
	assign wb_in_op$238 = y$13[31-:8];
	assign wb_in_we$238 = y_en$13[13];
	assign wb_in_ad$224 = wb_we$208 ? wb_ad$208 : y$13[4+:13];
	assign wb_in_d$224 = wb_we$208 ? wb_d$208 : acc$13[0+:32];
	assign wb_in_op$224 = wb_we$208 ? wb_op$208 : y$13[31-:8];
	assign wb_in_we$224 = wb_we$208 | y_en$13[14];
	assign wb_in_ad$239 = wb_we$209 ? wb_ad$209 : y$13[4+:13];
	assign wb_in_d$239 = wb_we$209 ? wb_d$209 : acc$13[0+:32];
	assign wb_in_op$239 = wb_we$209 ? wb_op$209 : y$13[31-:8];
	assign wb_in_we$239 = wb_we$209 | y_en$13[15];
	assign acc_in$14 = acc_out$13;
	assign pc_in$14 = pc_out$13;
	assign wb_in_ad$241 = wb_we$210 ? wb_ad$210 : y$14[4+:13];
	assign wb_in_d$241 = wb_we$210 ? wb_d$210 : acc$14[0+:32];
	assign wb_in_op$241 = wb_we$210 ? wb_op$210 : y$14[31-:8];
	assign wb_in_we$241 = wb_we$210 | y_en$14[0];
	assign wb_in_ad$242 = wb_we$211 ? wb_ad$211 : y$14[4+:13];
	assign wb_in_d$242 = wb_we$211 ? wb_d$211 : acc$14[0+:32];
	assign wb_in_op$242 = wb_we$211 ? wb_op$211 : y$14[31-:8];
	assign wb_in_we$242 = wb_we$211 | y_en$14[1];
	assign wb_in_ad$243 = wb_we$212 ? wb_ad$212 : y$14[4+:13];
	assign wb_in_d$243 = wb_we$212 ? wb_d$212 : acc$14[0+:32];
	assign wb_in_op$243 = wb_we$212 ? wb_op$212 : y$14[31-:8];
	assign wb_in_we$243 = wb_we$212 | y_en$14[2];
	assign wb_in_ad$244 = wb_we$213 ? wb_ad$213 : y$14[4+:13];
	assign wb_in_d$244 = wb_we$213 ? wb_d$213 : acc$14[0+:32];
	assign wb_in_op$244 = wb_we$213 ? wb_op$213 : y$14[31-:8];
	assign wb_in_we$244 = wb_we$213 | y_en$14[3];
	assign wb_in_ad$245 = wb_we$214 ? wb_ad$214 : y$14[4+:13];
	assign wb_in_d$245 = wb_we$214 ? wb_d$214 : acc$14[0+:32];
	assign wb_in_op$245 = wb_we$214 ? wb_op$214 : y$14[31-:8];
	assign wb_in_we$245 = wb_we$214 | y_en$14[4];
	assign wb_in_ad$246 = wb_we$215 ? wb_ad$215 : y$14[4+:13];
	assign wb_in_d$246 = wb_we$215 ? wb_d$215 : acc$14[0+:32];
	assign wb_in_op$246 = wb_we$215 ? wb_op$215 : y$14[31-:8];
	assign wb_in_we$246 = wb_we$215 | y_en$14[5];
	assign wb_in_ad$247 = wb_we$216 ? wb_ad$216 : y$14[4+:13];
	assign wb_in_d$247 = wb_we$216 ? wb_d$216 : acc$14[0+:32];
	assign wb_in_op$247 = wb_we$216 ? wb_op$216 : y$14[31-:8];
	assign wb_in_we$247 = wb_we$216 | y_en$14[6];
	assign wb_in_ad$248 = wb_we$217 ? wb_ad$217 : y$14[4+:13];
	assign wb_in_d$248 = wb_we$217 ? wb_d$217 : acc$14[0+:32];
	assign wb_in_op$248 = wb_we$217 ? wb_op$217 : y$14[31-:8];
	assign wb_in_we$248 = wb_we$217 | y_en$14[7];
	assign wb_in_ad$249 = wb_we$218 ? wb_ad$218 : y$14[4+:13];
	assign wb_in_d$249 = wb_we$218 ? wb_d$218 : acc$14[0+:32];
	assign wb_in_op$249 = wb_we$218 ? wb_op$218 : y$14[31-:8];
	assign wb_in_we$249 = wb_we$218 | y_en$14[8];
	assign wb_in_ad$250 = wb_we$219 ? wb_ad$219 : y$14[4+:13];
	assign wb_in_d$250 = wb_we$219 ? wb_d$219 : acc$14[0+:32];
	assign wb_in_op$250 = wb_we$219 ? wb_op$219 : y$14[31-:8];
	assign wb_in_we$250 = wb_we$219 | y_en$14[9];
	assign wb_in_ad$251 = wb_we$220 ? wb_ad$220 : y$14[4+:13];
	assign wb_in_d$251 = wb_we$220 ? wb_d$220 : acc$14[0+:32];
	assign wb_in_op$251 = wb_we$220 ? wb_op$220 : y$14[31-:8];
	assign wb_in_we$251 = wb_we$220 | y_en$14[10];
	assign wb_in_ad$252 = wb_we$221 ? wb_ad$221 : y$14[4+:13];
	assign wb_in_d$252 = wb_we$221 ? wb_d$221 : acc$14[0+:32];
	assign wb_in_op$252 = wb_we$221 ? wb_op$221 : y$14[31-:8];
	assign wb_in_we$252 = wb_we$221 | y_en$14[11];
	assign wb_in_ad$253 = wb_we$222 ? wb_ad$222 : y$14[4+:13];
	assign wb_in_d$253 = wb_we$222 ? wb_d$222 : acc$14[0+:32];
	assign wb_in_op$253 = wb_we$222 ? wb_op$222 : y$14[31-:8];
	assign wb_in_we$253 = wb_we$222 | y_en$14[12];
	assign wb_in_ad$254 = wb_we$223 ? wb_ad$223 : y$14[4+:13];
	assign wb_in_d$254 = wb_we$223 ? wb_d$223 : acc$14[0+:32];
	assign wb_in_op$254 = wb_we$223 ? wb_op$223 : y$14[31-:8];
	assign wb_in_we$254 = wb_we$223 | y_en$14[13];
	assign wb_in_ad$255 = y$14[4+:13];
	assign wb_in_d$255 = acc$14[0+:32];
	assign wb_in_op$255 = y$14[31-:8];
	assign wb_in_we$255 = y_en$14[14];
	assign wb_in_ad$240 = wb_we$224 ? wb_ad$224 : y$14[4+:13];
	assign wb_in_d$240 = wb_we$224 ? wb_d$224 : acc$14[0+:32];
	assign wb_in_op$240 = wb_we$224 ? wb_op$224 : y$14[31-:8];
	assign wb_in_we$240 = wb_we$224 | y_en$14[15];
	assign acc_in$15 = acc_out$14;
	assign pc_in$15 = pc_out$14;
	assign wb_in_ad$0 = wb_we$225 ? wb_ad$225 : y$15[4+:13];
	assign wb_in_d$0 = wb_we$225 ? wb_d$225 : acc$15[0+:32];
	assign wb_in_op$0 = wb_we$225 ? wb_op$225 : y$15[31-:8];
	assign wb_in_we$0 = wb_we$225 | y_en$15[0];
	assign wb_in_ad$1 = wb_we$226 ? wb_ad$226 : y$15[4+:13];
	assign wb_in_d$1 = wb_we$226 ? wb_d$226 : acc$15[0+:32];
	assign wb_in_op$1 = wb_we$226 ? wb_op$226 : y$15[31-:8];
	assign wb_in_we$1 = wb_we$226 | y_en$15[1];
	assign wb_in_ad$2 = wb_we$227 ? wb_ad$227 : y$15[4+:13];
	assign wb_in_d$2 = wb_we$227 ? wb_d$227 : acc$15[0+:32];
	assign wb_in_op$2 = wb_we$227 ? wb_op$227 : y$15[31-:8];
	assign wb_in_we$2 = wb_we$227 | y_en$15[2];
	assign wb_in_ad$3 = wb_we$228 ? wb_ad$228 : y$15[4+:13];
	assign wb_in_d$3 = wb_we$228 ? wb_d$228 : acc$15[0+:32];
	assign wb_in_op$3 = wb_we$228 ? wb_op$228 : y$15[31-:8];
	assign wb_in_we$3 = wb_we$228 | y_en$15[3];
	assign wb_in_ad$4 = wb_we$229 ? wb_ad$229 : y$15[4+:13];
	assign wb_in_d$4 = wb_we$229 ? wb_d$229 : acc$15[0+:32];
	assign wb_in_op$4 = wb_we$229 ? wb_op$229 : y$15[31-:8];
	assign wb_in_we$4 = wb_we$229 | y_en$15[4];
	assign wb_in_ad$5 = wb_we$230 ? wb_ad$230 : y$15[4+:13];
	assign wb_in_d$5 = wb_we$230 ? wb_d$230 : acc$15[0+:32];
	assign wb_in_op$5 = wb_we$230 ? wb_op$230 : y$15[31-:8];
	assign wb_in_we$5 = wb_we$230 | y_en$15[5];
	assign wb_in_ad$6 = wb_we$231 ? wb_ad$231 : y$15[4+:13];
	assign wb_in_d$6 = wb_we$231 ? wb_d$231 : acc$15[0+:32];
	assign wb_in_op$6 = wb_we$231 ? wb_op$231 : y$15[31-:8];
	assign wb_in_we$6 = wb_we$231 | y_en$15[6];
	assign wb_in_ad$7 = wb_we$232 ? wb_ad$232 : y$15[4+:13];
	assign wb_in_d$7 = wb_we$232 ? wb_d$232 : acc$15[0+:32];
	assign wb_in_op$7 = wb_we$232 ? wb_op$232 : y$15[31-:8];
	assign wb_in_we$7 = wb_we$232 | y_en$15[7];
	assign wb_in_ad$8 = wb_we$233 ? wb_ad$233 : y$15[4+:13];
	assign wb_in_d$8 = wb_we$233 ? wb_d$233 : acc$15[0+:32];
	assign wb_in_op$8 = wb_we$233 ? wb_op$233 : y$15[31-:8];
	assign wb_in_we$8 = wb_we$233 | y_en$15[8];
	assign wb_in_ad$9 = wb_we$234 ? wb_ad$234 : y$15[4+:13];
	assign wb_in_d$9 = wb_we$234 ? wb_d$234 : acc$15[0+:32];
	assign wb_in_op$9 = wb_we$234 ? wb_op$234 : y$15[31-:8];
	assign wb_in_we$9 = wb_we$234 | y_en$15[9];
	assign wb_in_ad$10 = wb_we$235 ? wb_ad$235 : y$15[4+:13];
	assign wb_in_d$10 = wb_we$235 ? wb_d$235 : acc$15[0+:32];
	assign wb_in_op$10 = wb_we$235 ? wb_op$235 : y$15[31-:8];
	assign wb_in_we$10 = wb_we$235 | y_en$15[10];
	assign wb_in_ad$11 = wb_we$236 ? wb_ad$236 : y$15[4+:13];
	assign wb_in_d$11 = wb_we$236 ? wb_d$236 : acc$15[0+:32];
	assign wb_in_op$11 = wb_we$236 ? wb_op$236 : y$15[31-:8];
	assign wb_in_we$11 = wb_we$236 | y_en$15[11];
	assign wb_in_ad$12 = wb_we$237 ? wb_ad$237 : y$15[4+:13];
	assign wb_in_d$12 = wb_we$237 ? wb_d$237 : acc$15[0+:32];
	assign wb_in_op$12 = wb_we$237 ? wb_op$237 : y$15[31-:8];
	assign wb_in_we$12 = wb_we$237 | y_en$15[12];
	assign wb_in_ad$13 = wb_we$238 ? wb_ad$238 : y$15[4+:13];
	assign wb_in_d$13 = wb_we$238 ? wb_d$238 : acc$15[0+:32];
	assign wb_in_op$13 = wb_we$238 ? wb_op$238 : y$15[31-:8];
	assign wb_in_we$13 = wb_we$238 | y_en$15[13];
	assign wb_in_ad$14 = wb_we$239 ? wb_ad$239 : y$15[4+:13];
	assign wb_in_d$14 = wb_we$239 ? wb_d$239 : acc$15[0+:32];
	assign wb_in_op$14 = wb_we$239 ? wb_op$239 : y$15[31-:8];
	assign wb_in_we$14 = wb_we$239 | y_en$15[14];
	assign wb_in_ad$15 = y$15[4+:13];
	assign wb_in_d$15 = acc$15[0+:32];
	assign wb_in_op$15 = y$15[31-:8];
	assign wb_in_we$15 = y_en$15[15];
	assign acc_in$0 = acc_out$15;
	assign pc_in$0 = pc_out$15;
	always @(*) begin
		// io_init
		p_io$0 = 0;
		d_io$0 = 0;
		p_io$1 = 0;
		d_io$1 = 0;
		p_io$2 = 0;
		d_io$2 = 0;
		p_io$3 = 0;
		d_io$3 = 0;
		p_io$4 = 0;
		d_io$4 = 0;
		p_io$5 = 0;
		d_io$5 = 0;
		p_io$6 = 0;
		d_io$6 = 0;
		p_io$7 = 0;
		d_io$7 = 0;
		p_io$8 = 0;
		d_io$8 = 0;
		p_io$9 = 0;
		d_io$9 = 0;
		p_io$10 = 0;
		d_io$10 = 0;
		p_io$11 = 0;
		d_io$11 = 0;
		p_io$12 = 0;
		d_io$12 = 0;
		p_io$13 = 0;
		d_io$13 = 0;
		p_io$14 = 0;
		d_io$14 = 0;
		// io_access
		acc_io$0 = 0;
		p_io$0 = p_io$0 | ({33{op_en$0[0]}} & {1'd1, y$0});
		d_io$0 = d_io$0 | ({33{op_en$0[0]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$0[1]}} & {1'd1, y$0});
		d_io$1 = d_io$1 | ({33{op_en$0[1]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$0[2]}} & {1'd1, y$0});
		d_io$2 = d_io$2 | ({33{op_en$0[2]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$0[3]}} & {1'd1, y$0});
		d_io$3 = d_io$3 | ({33{op_en$0[3]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$0[4]}} & {1'd1, y$0});
		d_io$4 = d_io$4 | ({33{op_en$0[4]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$0[5]}} & {1'd1, y$0});
		d_io$5 = d_io$5 | ({33{op_en$0[5]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$0[6]}} & {1'd1, y$0});
		d_io$6 = d_io$6 | ({33{op_en$0[6]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$0[7]}} & {1'd1, y$0});
		d_io$7 = d_io$7 | ({33{op_en$0[7]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$0[8]}} & {1'd1, y$0});
		d_io$8 = d_io$8 | ({33{op_en$0[8]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$0[9]}} & {1'd1, y$0});
		d_io$9 = d_io$9 | ({33{op_en$0[9]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$0[10]}} & {1'd1, y$0});
		d_io$10 = d_io$10 | ({33{op_en$0[10]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$0[11]}} & {1'd1, y$0});
		d_io$11 = d_io$11 | ({33{op_en$0[11]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$0[12]}} & {1'd1, y$0});
		d_io$12 = d_io$12 | ({33{op_en$0[12]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$0[13]}} & {1'd1, y$0});
		d_io$13 = d_io$13 | ({33{op_en$0[13]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$0[14]}} & {1'd1, y$0});
		d_io$14 = d_io$14 | ({33{op_en$0[14]}} & acc$0);
		acc_io$0 = acc_io$0 | ({33{op_en$0[14]}} & q_io$14);
		retry_io$0 = op$0[4] & acc_io$0[32];
		if (retry_io$0) begin
			acc_io$0 = acc$0;
		end
		acc_io$1 = 0;
		p_io$0 = p_io$0 | ({33{op_en$1[0]}} & {1'd1, y$1});
		d_io$0 = d_io$0 | ({33{op_en$1[0]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$1[1]}} & {1'd1, y$1});
		d_io$1 = d_io$1 | ({33{op_en$1[1]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$1[2]}} & {1'd1, y$1});
		d_io$2 = d_io$2 | ({33{op_en$1[2]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$1[3]}} & {1'd1, y$1});
		d_io$3 = d_io$3 | ({33{op_en$1[3]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$1[4]}} & {1'd1, y$1});
		d_io$4 = d_io$4 | ({33{op_en$1[4]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$1[5]}} & {1'd1, y$1});
		d_io$5 = d_io$5 | ({33{op_en$1[5]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$1[6]}} & {1'd1, y$1});
		d_io$6 = d_io$6 | ({33{op_en$1[6]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$1[7]}} & {1'd1, y$1});
		d_io$7 = d_io$7 | ({33{op_en$1[7]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$1[8]}} & {1'd1, y$1});
		d_io$8 = d_io$8 | ({33{op_en$1[8]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$1[9]}} & {1'd1, y$1});
		d_io$9 = d_io$9 | ({33{op_en$1[9]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$1[10]}} & {1'd1, y$1});
		d_io$10 = d_io$10 | ({33{op_en$1[10]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$1[11]}} & {1'd1, y$1});
		d_io$11 = d_io$11 | ({33{op_en$1[11]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$1[12]}} & {1'd1, y$1});
		d_io$12 = d_io$12 | ({33{op_en$1[12]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$1[13]}} & {1'd1, y$1});
		d_io$13 = d_io$13 | ({33{op_en$1[13]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$1[14]}} & {1'd1, y$1});
		d_io$14 = d_io$14 | ({33{op_en$1[14]}} & acc$1);
		acc_io$1 = acc_io$1 | ({33{op_en$1[14]}} & q_io$14);
		retry_io$1 = op$1[4] & acc_io$1[32];
		if (retry_io$1) begin
			acc_io$1 = acc$1;
		end
		acc_io$2 = 0;
		p_io$0 = p_io$0 | ({33{op_en$2[0]}} & {1'd1, y$2});
		d_io$0 = d_io$0 | ({33{op_en$2[0]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$2[1]}} & {1'd1, y$2});
		d_io$1 = d_io$1 | ({33{op_en$2[1]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$2[2]}} & {1'd1, y$2});
		d_io$2 = d_io$2 | ({33{op_en$2[2]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$2[3]}} & {1'd1, y$2});
		d_io$3 = d_io$3 | ({33{op_en$2[3]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$2[4]}} & {1'd1, y$2});
		d_io$4 = d_io$4 | ({33{op_en$2[4]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$2[5]}} & {1'd1, y$2});
		d_io$5 = d_io$5 | ({33{op_en$2[5]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$2[6]}} & {1'd1, y$2});
		d_io$6 = d_io$6 | ({33{op_en$2[6]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$2[7]}} & {1'd1, y$2});
		d_io$7 = d_io$7 | ({33{op_en$2[7]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$2[8]}} & {1'd1, y$2});
		d_io$8 = d_io$8 | ({33{op_en$2[8]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$2[9]}} & {1'd1, y$2});
		d_io$9 = d_io$9 | ({33{op_en$2[9]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$2[10]}} & {1'd1, y$2});
		d_io$10 = d_io$10 | ({33{op_en$2[10]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$2[11]}} & {1'd1, y$2});
		d_io$11 = d_io$11 | ({33{op_en$2[11]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$2[12]}} & {1'd1, y$2});
		d_io$12 = d_io$12 | ({33{op_en$2[12]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$2[13]}} & {1'd1, y$2});
		d_io$13 = d_io$13 | ({33{op_en$2[13]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$2[14]}} & {1'd1, y$2});
		d_io$14 = d_io$14 | ({33{op_en$2[14]}} & acc$2);
		acc_io$2 = acc_io$2 | ({33{op_en$2[14]}} & q_io$14);
		retry_io$2 = op$2[4] & acc_io$2[32];
		if (retry_io$2) begin
			acc_io$2 = acc$2;
		end
		acc_io$3 = 0;
		p_io$0 = p_io$0 | ({33{op_en$3[0]}} & {1'd1, y$3});
		d_io$0 = d_io$0 | ({33{op_en$3[0]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$3[1]}} & {1'd1, y$3});
		d_io$1 = d_io$1 | ({33{op_en$3[1]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$3[2]}} & {1'd1, y$3});
		d_io$2 = d_io$2 | ({33{op_en$3[2]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$3[3]}} & {1'd1, y$3});
		d_io$3 = d_io$3 | ({33{op_en$3[3]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$3[4]}} & {1'd1, y$3});
		d_io$4 = d_io$4 | ({33{op_en$3[4]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$3[5]}} & {1'd1, y$3});
		d_io$5 = d_io$5 | ({33{op_en$3[5]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$3[6]}} & {1'd1, y$3});
		d_io$6 = d_io$6 | ({33{op_en$3[6]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$3[7]}} & {1'd1, y$3});
		d_io$7 = d_io$7 | ({33{op_en$3[7]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$3[8]}} & {1'd1, y$3});
		d_io$8 = d_io$8 | ({33{op_en$3[8]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$3[9]}} & {1'd1, y$3});
		d_io$9 = d_io$9 | ({33{op_en$3[9]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$3[10]}} & {1'd1, y$3});
		d_io$10 = d_io$10 | ({33{op_en$3[10]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$3[11]}} & {1'd1, y$3});
		d_io$11 = d_io$11 | ({33{op_en$3[11]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$3[12]}} & {1'd1, y$3});
		d_io$12 = d_io$12 | ({33{op_en$3[12]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$3[13]}} & {1'd1, y$3});
		d_io$13 = d_io$13 | ({33{op_en$3[13]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$3[14]}} & {1'd1, y$3});
		d_io$14 = d_io$14 | ({33{op_en$3[14]}} & acc$3);
		acc_io$3 = acc_io$3 | ({33{op_en$3[14]}} & q_io$14);
		retry_io$3 = op$3[4] & acc_io$3[32];
		if (retry_io$3) begin
			acc_io$3 = acc$3;
		end
		acc_io$4 = 0;
		p_io$0 = p_io$0 | ({33{op_en$4[0]}} & {1'd1, y$4});
		d_io$0 = d_io$0 | ({33{op_en$4[0]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$4[1]}} & {1'd1, y$4});
		d_io$1 = d_io$1 | ({33{op_en$4[1]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$4[2]}} & {1'd1, y$4});
		d_io$2 = d_io$2 | ({33{op_en$4[2]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$4[3]}} & {1'd1, y$4});
		d_io$3 = d_io$3 | ({33{op_en$4[3]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$4[4]}} & {1'd1, y$4});
		d_io$4 = d_io$4 | ({33{op_en$4[4]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$4[5]}} & {1'd1, y$4});
		d_io$5 = d_io$5 | ({33{op_en$4[5]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$4[6]}} & {1'd1, y$4});
		d_io$6 = d_io$6 | ({33{op_en$4[6]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$4[7]}} & {1'd1, y$4});
		d_io$7 = d_io$7 | ({33{op_en$4[7]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$4[8]}} & {1'd1, y$4});
		d_io$8 = d_io$8 | ({33{op_en$4[8]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$4[9]}} & {1'd1, y$4});
		d_io$9 = d_io$9 | ({33{op_en$4[9]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$4[10]}} & {1'd1, y$4});
		d_io$10 = d_io$10 | ({33{op_en$4[10]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$4[11]}} & {1'd1, y$4});
		d_io$11 = d_io$11 | ({33{op_en$4[11]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$4[12]}} & {1'd1, y$4});
		d_io$12 = d_io$12 | ({33{op_en$4[12]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$4[13]}} & {1'd1, y$4});
		d_io$13 = d_io$13 | ({33{op_en$4[13]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$4[14]}} & {1'd1, y$4});
		d_io$14 = d_io$14 | ({33{op_en$4[14]}} & acc$4);
		acc_io$4 = acc_io$4 | ({33{op_en$4[14]}} & q_io$14);
		retry_io$4 = op$4[4] & acc_io$4[32];
		if (retry_io$4) begin
			acc_io$4 = acc$4;
		end
		acc_io$5 = 0;
		p_io$0 = p_io$0 | ({33{op_en$5[0]}} & {1'd1, y$5});
		d_io$0 = d_io$0 | ({33{op_en$5[0]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$5[1]}} & {1'd1, y$5});
		d_io$1 = d_io$1 | ({33{op_en$5[1]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$5[2]}} & {1'd1, y$5});
		d_io$2 = d_io$2 | ({33{op_en$5[2]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$5[3]}} & {1'd1, y$5});
		d_io$3 = d_io$3 | ({33{op_en$5[3]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$5[4]}} & {1'd1, y$5});
		d_io$4 = d_io$4 | ({33{op_en$5[4]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$5[5]}} & {1'd1, y$5});
		d_io$5 = d_io$5 | ({33{op_en$5[5]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$5[6]}} & {1'd1, y$5});
		d_io$6 = d_io$6 | ({33{op_en$5[6]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$5[7]}} & {1'd1, y$5});
		d_io$7 = d_io$7 | ({33{op_en$5[7]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$5[8]}} & {1'd1, y$5});
		d_io$8 = d_io$8 | ({33{op_en$5[8]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$5[9]}} & {1'd1, y$5});
		d_io$9 = d_io$9 | ({33{op_en$5[9]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$5[10]}} & {1'd1, y$5});
		d_io$10 = d_io$10 | ({33{op_en$5[10]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$5[11]}} & {1'd1, y$5});
		d_io$11 = d_io$11 | ({33{op_en$5[11]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$5[12]}} & {1'd1, y$5});
		d_io$12 = d_io$12 | ({33{op_en$5[12]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$5[13]}} & {1'd1, y$5});
		d_io$13 = d_io$13 | ({33{op_en$5[13]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$5[14]}} & {1'd1, y$5});
		d_io$14 = d_io$14 | ({33{op_en$5[14]}} & acc$5);
		acc_io$5 = acc_io$5 | ({33{op_en$5[14]}} & q_io$14);
		retry_io$5 = op$5[4] & acc_io$5[32];
		if (retry_io$5) begin
			acc_io$5 = acc$5;
		end
		acc_io$6 = 0;
		p_io$0 = p_io$0 | ({33{op_en$6[0]}} & {1'd1, y$6});
		d_io$0 = d_io$0 | ({33{op_en$6[0]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$6[1]}} & {1'd1, y$6});
		d_io$1 = d_io$1 | ({33{op_en$6[1]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$6[2]}} & {1'd1, y$6});
		d_io$2 = d_io$2 | ({33{op_en$6[2]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$6[3]}} & {1'd1, y$6});
		d_io$3 = d_io$3 | ({33{op_en$6[3]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$6[4]}} & {1'd1, y$6});
		d_io$4 = d_io$4 | ({33{op_en$6[4]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$6[5]}} & {1'd1, y$6});
		d_io$5 = d_io$5 | ({33{op_en$6[5]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$6[6]}} & {1'd1, y$6});
		d_io$6 = d_io$6 | ({33{op_en$6[6]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$6[7]}} & {1'd1, y$6});
		d_io$7 = d_io$7 | ({33{op_en$6[7]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$6[8]}} & {1'd1, y$6});
		d_io$8 = d_io$8 | ({33{op_en$6[8]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$6[9]}} & {1'd1, y$6});
		d_io$9 = d_io$9 | ({33{op_en$6[9]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$6[10]}} & {1'd1, y$6});
		d_io$10 = d_io$10 | ({33{op_en$6[10]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$6[11]}} & {1'd1, y$6});
		d_io$11 = d_io$11 | ({33{op_en$6[11]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$6[12]}} & {1'd1, y$6});
		d_io$12 = d_io$12 | ({33{op_en$6[12]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$6[13]}} & {1'd1, y$6});
		d_io$13 = d_io$13 | ({33{op_en$6[13]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$6[14]}} & {1'd1, y$6});
		d_io$14 = d_io$14 | ({33{op_en$6[14]}} & acc$6);
		acc_io$6 = acc_io$6 | ({33{op_en$6[14]}} & q_io$14);
		retry_io$6 = op$6[4] & acc_io$6[32];
		if (retry_io$6) begin
			acc_io$6 = acc$6;
		end
		acc_io$7 = 0;
		p_io$0 = p_io$0 | ({33{op_en$7[0]}} & {1'd1, y$7});
		d_io$0 = d_io$0 | ({33{op_en$7[0]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$7[1]}} & {1'd1, y$7});
		d_io$1 = d_io$1 | ({33{op_en$7[1]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$7[2]}} & {1'd1, y$7});
		d_io$2 = d_io$2 | ({33{op_en$7[2]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$7[3]}} & {1'd1, y$7});
		d_io$3 = d_io$3 | ({33{op_en$7[3]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$7[4]}} & {1'd1, y$7});
		d_io$4 = d_io$4 | ({33{op_en$7[4]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$7[5]}} & {1'd1, y$7});
		d_io$5 = d_io$5 | ({33{op_en$7[5]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$7[6]}} & {1'd1, y$7});
		d_io$6 = d_io$6 | ({33{op_en$7[6]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$7[7]}} & {1'd1, y$7});
		d_io$7 = d_io$7 | ({33{op_en$7[7]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$7[8]}} & {1'd1, y$7});
		d_io$8 = d_io$8 | ({33{op_en$7[8]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$7[9]}} & {1'd1, y$7});
		d_io$9 = d_io$9 | ({33{op_en$7[9]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$7[10]}} & {1'd1, y$7});
		d_io$10 = d_io$10 | ({33{op_en$7[10]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$7[11]}} & {1'd1, y$7});
		d_io$11 = d_io$11 | ({33{op_en$7[11]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$7[12]}} & {1'd1, y$7});
		d_io$12 = d_io$12 | ({33{op_en$7[12]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$7[13]}} & {1'd1, y$7});
		d_io$13 = d_io$13 | ({33{op_en$7[13]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$7[14]}} & {1'd1, y$7});
		d_io$14 = d_io$14 | ({33{op_en$7[14]}} & acc$7);
		acc_io$7 = acc_io$7 | ({33{op_en$7[14]}} & q_io$14);
		retry_io$7 = op$7[4] & acc_io$7[32];
		if (retry_io$7) begin
			acc_io$7 = acc$7;
		end
		acc_io$8 = 0;
		p_io$0 = p_io$0 | ({33{op_en$8[0]}} & {1'd1, y$8});
		d_io$0 = d_io$0 | ({33{op_en$8[0]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$8[1]}} & {1'd1, y$8});
		d_io$1 = d_io$1 | ({33{op_en$8[1]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$8[2]}} & {1'd1, y$8});
		d_io$2 = d_io$2 | ({33{op_en$8[2]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$8[3]}} & {1'd1, y$8});
		d_io$3 = d_io$3 | ({33{op_en$8[3]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$8[4]}} & {1'd1, y$8});
		d_io$4 = d_io$4 | ({33{op_en$8[4]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$8[5]}} & {1'd1, y$8});
		d_io$5 = d_io$5 | ({33{op_en$8[5]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$8[6]}} & {1'd1, y$8});
		d_io$6 = d_io$6 | ({33{op_en$8[6]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$8[7]}} & {1'd1, y$8});
		d_io$7 = d_io$7 | ({33{op_en$8[7]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$8[8]}} & {1'd1, y$8});
		d_io$8 = d_io$8 | ({33{op_en$8[8]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$8[9]}} & {1'd1, y$8});
		d_io$9 = d_io$9 | ({33{op_en$8[9]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$8[10]}} & {1'd1, y$8});
		d_io$10 = d_io$10 | ({33{op_en$8[10]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$8[11]}} & {1'd1, y$8});
		d_io$11 = d_io$11 | ({33{op_en$8[11]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$8[12]}} & {1'd1, y$8});
		d_io$12 = d_io$12 | ({33{op_en$8[12]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$8[13]}} & {1'd1, y$8});
		d_io$13 = d_io$13 | ({33{op_en$8[13]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$8[14]}} & {1'd1, y$8});
		d_io$14 = d_io$14 | ({33{op_en$8[14]}} & acc$8);
		acc_io$8 = acc_io$8 | ({33{op_en$8[14]}} & q_io$14);
		retry_io$8 = op$8[4] & acc_io$8[32];
		if (retry_io$8) begin
			acc_io$8 = acc$8;
		end
		acc_io$9 = 0;
		p_io$0 = p_io$0 | ({33{op_en$9[0]}} & {1'd1, y$9});
		d_io$0 = d_io$0 | ({33{op_en$9[0]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$9[1]}} & {1'd1, y$9});
		d_io$1 = d_io$1 | ({33{op_en$9[1]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$9[2]}} & {1'd1, y$9});
		d_io$2 = d_io$2 | ({33{op_en$9[2]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$9[3]}} & {1'd1, y$9});
		d_io$3 = d_io$3 | ({33{op_en$9[3]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$9[4]}} & {1'd1, y$9});
		d_io$4 = d_io$4 | ({33{op_en$9[4]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$9[5]}} & {1'd1, y$9});
		d_io$5 = d_io$5 | ({33{op_en$9[5]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$9[6]}} & {1'd1, y$9});
		d_io$6 = d_io$6 | ({33{op_en$9[6]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$9[7]}} & {1'd1, y$9});
		d_io$7 = d_io$7 | ({33{op_en$9[7]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$9[8]}} & {1'd1, y$9});
		d_io$8 = d_io$8 | ({33{op_en$9[8]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$9[9]}} & {1'd1, y$9});
		d_io$9 = d_io$9 | ({33{op_en$9[9]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$9[10]}} & {1'd1, y$9});
		d_io$10 = d_io$10 | ({33{op_en$9[10]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$9[11]}} & {1'd1, y$9});
		d_io$11 = d_io$11 | ({33{op_en$9[11]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$9[12]}} & {1'd1, y$9});
		d_io$12 = d_io$12 | ({33{op_en$9[12]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$9[13]}} & {1'd1, y$9});
		d_io$13 = d_io$13 | ({33{op_en$9[13]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$9[14]}} & {1'd1, y$9});
		d_io$14 = d_io$14 | ({33{op_en$9[14]}} & acc$9);
		acc_io$9 = acc_io$9 | ({33{op_en$9[14]}} & q_io$14);
		retry_io$9 = op$9[4] & acc_io$9[32];
		if (retry_io$9) begin
			acc_io$9 = acc$9;
		end
		acc_io$10 = 0;
		p_io$0 = p_io$0 | ({33{op_en$10[0]}} & {1'd1, y$10});
		d_io$0 = d_io$0 | ({33{op_en$10[0]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$10[1]}} & {1'd1, y$10});
		d_io$1 = d_io$1 | ({33{op_en$10[1]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$10[2]}} & {1'd1, y$10});
		d_io$2 = d_io$2 | ({33{op_en$10[2]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$10[3]}} & {1'd1, y$10});
		d_io$3 = d_io$3 | ({33{op_en$10[3]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$10[4]}} & {1'd1, y$10});
		d_io$4 = d_io$4 | ({33{op_en$10[4]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$10[5]}} & {1'd1, y$10});
		d_io$5 = d_io$5 | ({33{op_en$10[5]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$10[6]}} & {1'd1, y$10});
		d_io$6 = d_io$6 | ({33{op_en$10[6]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$10[7]}} & {1'd1, y$10});
		d_io$7 = d_io$7 | ({33{op_en$10[7]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$10[8]}} & {1'd1, y$10});
		d_io$8 = d_io$8 | ({33{op_en$10[8]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$10[9]}} & {1'd1, y$10});
		d_io$9 = d_io$9 | ({33{op_en$10[9]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$10[10]}} & {1'd1, y$10});
		d_io$10 = d_io$10 | ({33{op_en$10[10]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$10[11]}} & {1'd1, y$10});
		d_io$11 = d_io$11 | ({33{op_en$10[11]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$10[12]}} & {1'd1, y$10});
		d_io$12 = d_io$12 | ({33{op_en$10[12]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$10[13]}} & {1'd1, y$10});
		d_io$13 = d_io$13 | ({33{op_en$10[13]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$10[14]}} & {1'd1, y$10});
		d_io$14 = d_io$14 | ({33{op_en$10[14]}} & acc$10);
		acc_io$10 = acc_io$10 | ({33{op_en$10[14]}} & q_io$14);
		retry_io$10 = op$10[4] & acc_io$10[32];
		if (retry_io$10) begin
			acc_io$10 = acc$10;
		end
		acc_io$11 = 0;
		p_io$0 = p_io$0 | ({33{op_en$11[0]}} & {1'd1, y$11});
		d_io$0 = d_io$0 | ({33{op_en$11[0]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$11[1]}} & {1'd1, y$11});
		d_io$1 = d_io$1 | ({33{op_en$11[1]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$11[2]}} & {1'd1, y$11});
		d_io$2 = d_io$2 | ({33{op_en$11[2]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$11[3]}} & {1'd1, y$11});
		d_io$3 = d_io$3 | ({33{op_en$11[3]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$11[4]}} & {1'd1, y$11});
		d_io$4 = d_io$4 | ({33{op_en$11[4]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$11[5]}} & {1'd1, y$11});
		d_io$5 = d_io$5 | ({33{op_en$11[5]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$11[6]}} & {1'd1, y$11});
		d_io$6 = d_io$6 | ({33{op_en$11[6]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$11[7]}} & {1'd1, y$11});
		d_io$7 = d_io$7 | ({33{op_en$11[7]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$11[8]}} & {1'd1, y$11});
		d_io$8 = d_io$8 | ({33{op_en$11[8]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$11[9]}} & {1'd1, y$11});
		d_io$9 = d_io$9 | ({33{op_en$11[9]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$11[10]}} & {1'd1, y$11});
		d_io$10 = d_io$10 | ({33{op_en$11[10]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$11[11]}} & {1'd1, y$11});
		d_io$11 = d_io$11 | ({33{op_en$11[11]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$11[12]}} & {1'd1, y$11});
		d_io$12 = d_io$12 | ({33{op_en$11[12]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$11[13]}} & {1'd1, y$11});
		d_io$13 = d_io$13 | ({33{op_en$11[13]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$11[14]}} & {1'd1, y$11});
		d_io$14 = d_io$14 | ({33{op_en$11[14]}} & acc$11);
		acc_io$11 = acc_io$11 | ({33{op_en$11[14]}} & q_io$14);
		retry_io$11 = op$11[4] & acc_io$11[32];
		if (retry_io$11) begin
			acc_io$11 = acc$11;
		end
		acc_io$12 = 0;
		p_io$0 = p_io$0 | ({33{op_en$12[0]}} & {1'd1, y$12});
		d_io$0 = d_io$0 | ({33{op_en$12[0]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$12[1]}} & {1'd1, y$12});
		d_io$1 = d_io$1 | ({33{op_en$12[1]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$12[2]}} & {1'd1, y$12});
		d_io$2 = d_io$2 | ({33{op_en$12[2]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$12[3]}} & {1'd1, y$12});
		d_io$3 = d_io$3 | ({33{op_en$12[3]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$12[4]}} & {1'd1, y$12});
		d_io$4 = d_io$4 | ({33{op_en$12[4]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$12[5]}} & {1'd1, y$12});
		d_io$5 = d_io$5 | ({33{op_en$12[5]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$12[6]}} & {1'd1, y$12});
		d_io$6 = d_io$6 | ({33{op_en$12[6]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$12[7]}} & {1'd1, y$12});
		d_io$7 = d_io$7 | ({33{op_en$12[7]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$12[8]}} & {1'd1, y$12});
		d_io$8 = d_io$8 | ({33{op_en$12[8]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$12[9]}} & {1'd1, y$12});
		d_io$9 = d_io$9 | ({33{op_en$12[9]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$12[10]}} & {1'd1, y$12});
		d_io$10 = d_io$10 | ({33{op_en$12[10]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$12[11]}} & {1'd1, y$12});
		d_io$11 = d_io$11 | ({33{op_en$12[11]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$12[12]}} & {1'd1, y$12});
		d_io$12 = d_io$12 | ({33{op_en$12[12]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$12[13]}} & {1'd1, y$12});
		d_io$13 = d_io$13 | ({33{op_en$12[13]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$12[14]}} & {1'd1, y$12});
		d_io$14 = d_io$14 | ({33{op_en$12[14]}} & acc$12);
		acc_io$12 = acc_io$12 | ({33{op_en$12[14]}} & q_io$14);
		retry_io$12 = op$12[4] & acc_io$12[32];
		if (retry_io$12) begin
			acc_io$12 = acc$12;
		end
		acc_io$13 = 0;
		p_io$0 = p_io$0 | ({33{op_en$13[0]}} & {1'd1, y$13});
		d_io$0 = d_io$0 | ({33{op_en$13[0]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$13[1]}} & {1'd1, y$13});
		d_io$1 = d_io$1 | ({33{op_en$13[1]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$13[2]}} & {1'd1, y$13});
		d_io$2 = d_io$2 | ({33{op_en$13[2]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$13[3]}} & {1'd1, y$13});
		d_io$3 = d_io$3 | ({33{op_en$13[3]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$13[4]}} & {1'd1, y$13});
		d_io$4 = d_io$4 | ({33{op_en$13[4]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$13[5]}} & {1'd1, y$13});
		d_io$5 = d_io$5 | ({33{op_en$13[5]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$13[6]}} & {1'd1, y$13});
		d_io$6 = d_io$6 | ({33{op_en$13[6]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$13[7]}} & {1'd1, y$13});
		d_io$7 = d_io$7 | ({33{op_en$13[7]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$13[8]}} & {1'd1, y$13});
		d_io$8 = d_io$8 | ({33{op_en$13[8]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$13[9]}} & {1'd1, y$13});
		d_io$9 = d_io$9 | ({33{op_en$13[9]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$13[10]}} & {1'd1, y$13});
		d_io$10 = d_io$10 | ({33{op_en$13[10]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$13[11]}} & {1'd1, y$13});
		d_io$11 = d_io$11 | ({33{op_en$13[11]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$13[12]}} & {1'd1, y$13});
		d_io$12 = d_io$12 | ({33{op_en$13[12]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$13[13]}} & {1'd1, y$13});
		d_io$13 = d_io$13 | ({33{op_en$13[13]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$13[14]}} & {1'd1, y$13});
		d_io$14 = d_io$14 | ({33{op_en$13[14]}} & acc$13);
		acc_io$13 = acc_io$13 | ({33{op_en$13[14]}} & q_io$14);
		retry_io$13 = op$13[4] & acc_io$13[32];
		if (retry_io$13) begin
			acc_io$13 = acc$13;
		end
		acc_io$14 = 0;
		p_io$0 = p_io$0 | ({33{op_en$14[0]}} & {1'd1, y$14});
		d_io$0 = d_io$0 | ({33{op_en$14[0]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$14[1]}} & {1'd1, y$14});
		d_io$1 = d_io$1 | ({33{op_en$14[1]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$14[2]}} & {1'd1, y$14});
		d_io$2 = d_io$2 | ({33{op_en$14[2]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$14[3]}} & {1'd1, y$14});
		d_io$3 = d_io$3 | ({33{op_en$14[3]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$14[4]}} & {1'd1, y$14});
		d_io$4 = d_io$4 | ({33{op_en$14[4]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$14[5]}} & {1'd1, y$14});
		d_io$5 = d_io$5 | ({33{op_en$14[5]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$14[6]}} & {1'd1, y$14});
		d_io$6 = d_io$6 | ({33{op_en$14[6]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$14[7]}} & {1'd1, y$14});
		d_io$7 = d_io$7 | ({33{op_en$14[7]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$14[8]}} & {1'd1, y$14});
		d_io$8 = d_io$8 | ({33{op_en$14[8]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$14[9]}} & {1'd1, y$14});
		d_io$9 = d_io$9 | ({33{op_en$14[9]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$14[10]}} & {1'd1, y$14});
		d_io$10 = d_io$10 | ({33{op_en$14[10]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$14[11]}} & {1'd1, y$14});
		d_io$11 = d_io$11 | ({33{op_en$14[11]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$14[12]}} & {1'd1, y$14});
		d_io$12 = d_io$12 | ({33{op_en$14[12]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$14[13]}} & {1'd1, y$14});
		d_io$13 = d_io$13 | ({33{op_en$14[13]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$14[14]}} & {1'd1, y$14});
		d_io$14 = d_io$14 | ({33{op_en$14[14]}} & acc$14);
		acc_io$14 = acc_io$14 | ({33{op_en$14[14]}} & q_io$14);
		retry_io$14 = op$14[4] & acc_io$14[32];
		if (retry_io$14) begin
			acc_io$14 = acc$14;
		end
		acc_io$15 = 0;
		p_io$0 = p_io$0 | ({33{op_en$15[0]}} & {1'd1, y$15});
		d_io$0 = d_io$0 | ({33{op_en$15[0]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[0]}} & q_io$0);
		p_io$1 = p_io$1 | ({33{op_en$15[1]}} & {1'd1, y$15});
		d_io$1 = d_io$1 | ({33{op_en$15[1]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[1]}} & q_io$1);
		p_io$2 = p_io$2 | ({33{op_en$15[2]}} & {1'd1, y$15});
		d_io$2 = d_io$2 | ({33{op_en$15[2]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[2]}} & q_io$2);
		p_io$3 = p_io$3 | ({33{op_en$15[3]}} & {1'd1, y$15});
		d_io$3 = d_io$3 | ({33{op_en$15[3]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[3]}} & q_io$3);
		p_io$4 = p_io$4 | ({33{op_en$15[4]}} & {1'd1, y$15});
		d_io$4 = d_io$4 | ({33{op_en$15[4]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[4]}} & q_io$4);
		p_io$5 = p_io$5 | ({33{op_en$15[5]}} & {1'd1, y$15});
		d_io$5 = d_io$5 | ({33{op_en$15[5]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[5]}} & q_io$5);
		p_io$6 = p_io$6 | ({33{op_en$15[6]}} & {1'd1, y$15});
		d_io$6 = d_io$6 | ({33{op_en$15[6]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[6]}} & q_io$6);
		p_io$7 = p_io$7 | ({33{op_en$15[7]}} & {1'd1, y$15});
		d_io$7 = d_io$7 | ({33{op_en$15[7]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[7]}} & q_io$7);
		p_io$8 = p_io$8 | ({33{op_en$15[8]}} & {1'd1, y$15});
		d_io$8 = d_io$8 | ({33{op_en$15[8]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[8]}} & q_io$8);
		p_io$9 = p_io$9 | ({33{op_en$15[9]}} & {1'd1, y$15});
		d_io$9 = d_io$9 | ({33{op_en$15[9]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[9]}} & q_io$9);
		p_io$10 = p_io$10 | ({33{op_en$15[10]}} & {1'd1, y$15});
		d_io$10 = d_io$10 | ({33{op_en$15[10]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[10]}} & q_io$10);
		p_io$11 = p_io$11 | ({33{op_en$15[11]}} & {1'd1, y$15});
		d_io$11 = d_io$11 | ({33{op_en$15[11]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[11]}} & q_io$11);
		p_io$12 = p_io$12 | ({33{op_en$15[12]}} & {1'd1, y$15});
		d_io$12 = d_io$12 | ({33{op_en$15[12]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[12]}} & q_io$12);
		p_io$13 = p_io$13 | ({33{op_en$15[13]}} & {1'd1, y$15});
		d_io$13 = d_io$13 | ({33{op_en$15[13]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[13]}} & q_io$13);
		p_io$14 = p_io$14 | ({33{op_en$15[14]}} & {1'd1, y$15});
		d_io$14 = d_io$14 | ({33{op_en$15[14]}} & acc$15);
		acc_io$15 = acc_io$15 | ({33{op_en$15[14]}} & q_io$14);
		retry_io$15 = op$15[4] & acc_io$15[32];
		if (retry_io$15) begin
			acc_io$15 = acc$15;
		end
		// accumlator
		casex (op$0[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$0[32] <= acc$0[32];
				acc_out$0[31:0] <= {32{op$0[3]}} ^ (~ax$0[31:0] & ay$0[31:0]) ^ ({32{~op$0[0]}} & acc$0[31:0] & y$0);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$0 <= ax$0 + ay$0 + {32'd0, op$0[2] ^ op$0[1] ^ (op$0[0] & acc$0[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$0[32] <= op$0[0] ? xy$0[32] : xy$0[31];
				acc_out$0[31:0] <= ({32{op$0[1]}} & xy$0[32+:32]) ^ ({32{op$0[0]}} & xy$0[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$0 <= acc_io$0;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$0 <= acc$0;
			end
		endcase
		casex (op$1[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$1[32] <= acc$1[32];
				acc_out$1[31:0] <= {32{op$1[3]}} ^ (~ax$1[31:0] & ay$1[31:0]) ^ ({32{~op$1[0]}} & acc$1[31:0] & y$1);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$1 <= ax$1 + ay$1 + {32'd0, op$1[2] ^ op$1[1] ^ (op$1[0] & acc$1[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$1[32] <= op$1[0] ? xy$1[32] : xy$1[31];
				acc_out$1[31:0] <= ({32{op$1[1]}} & xy$1[32+:32]) ^ ({32{op$1[0]}} & xy$1[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$1 <= acc_io$1;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$1 <= acc$1;
			end
		endcase
		casex (op$2[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$2[32] <= acc$2[32];
				acc_out$2[31:0] <= {32{op$2[3]}} ^ (~ax$2[31:0] & ay$2[31:0]) ^ ({32{~op$2[0]}} & acc$2[31:0] & y$2);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$2 <= ax$2 + ay$2 + {32'd0, op$2[2] ^ op$2[1] ^ (op$2[0] & acc$2[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$2[32] <= op$2[0] ? xy$2[32] : xy$2[31];
				acc_out$2[31:0] <= ({32{op$2[1]}} & xy$2[32+:32]) ^ ({32{op$2[0]}} & xy$2[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$2 <= acc_io$2;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$2 <= acc$2;
			end
		endcase
		casex (op$3[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$3[32] <= acc$3[32];
				acc_out$3[31:0] <= {32{op$3[3]}} ^ (~ax$3[31:0] & ay$3[31:0]) ^ ({32{~op$3[0]}} & acc$3[31:0] & y$3);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$3 <= ax$3 + ay$3 + {32'd0, op$3[2] ^ op$3[1] ^ (op$3[0] & acc$3[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$3[32] <= op$3[0] ? xy$3[32] : xy$3[31];
				acc_out$3[31:0] <= ({32{op$3[1]}} & xy$3[32+:32]) ^ ({32{op$3[0]}} & xy$3[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$3 <= acc_io$3;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$3 <= acc$3;
			end
		endcase
		casex (op$4[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$4[32] <= acc$4[32];
				acc_out$4[31:0] <= {32{op$4[3]}} ^ (~ax$4[31:0] & ay$4[31:0]) ^ ({32{~op$4[0]}} & acc$4[31:0] & y$4);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$4 <= ax$4 + ay$4 + {32'd0, op$4[2] ^ op$4[1] ^ (op$4[0] & acc$4[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$4[32] <= op$4[0] ? xy$4[32] : xy$4[31];
				acc_out$4[31:0] <= ({32{op$4[1]}} & xy$4[32+:32]) ^ ({32{op$4[0]}} & xy$4[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$4 <= acc_io$4;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$4 <= acc$4;
			end
		endcase
		casex (op$5[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$5[32] <= acc$5[32];
				acc_out$5[31:0] <= {32{op$5[3]}} ^ (~ax$5[31:0] & ay$5[31:0]) ^ ({32{~op$5[0]}} & acc$5[31:0] & y$5);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$5 <= ax$5 + ay$5 + {32'd0, op$5[2] ^ op$5[1] ^ (op$5[0] & acc$5[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$5[32] <= op$5[0] ? xy$5[32] : xy$5[31];
				acc_out$5[31:0] <= ({32{op$5[1]}} & xy$5[32+:32]) ^ ({32{op$5[0]}} & xy$5[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$5 <= acc_io$5;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$5 <= acc$5;
			end
		endcase
		casex (op$6[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$6[32] <= acc$6[32];
				acc_out$6[31:0] <= {32{op$6[3]}} ^ (~ax$6[31:0] & ay$6[31:0]) ^ ({32{~op$6[0]}} & acc$6[31:0] & y$6);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$6 <= ax$6 + ay$6 + {32'd0, op$6[2] ^ op$6[1] ^ (op$6[0] & acc$6[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$6[32] <= op$6[0] ? xy$6[32] : xy$6[31];
				acc_out$6[31:0] <= ({32{op$6[1]}} & xy$6[32+:32]) ^ ({32{op$6[0]}} & xy$6[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$6 <= acc_io$6;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$6 <= acc$6;
			end
		endcase
		casex (op$7[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$7[32] <= acc$7[32];
				acc_out$7[31:0] <= {32{op$7[3]}} ^ (~ax$7[31:0] & ay$7[31:0]) ^ ({32{~op$7[0]}} & acc$7[31:0] & y$7);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$7 <= ax$7 + ay$7 + {32'd0, op$7[2] ^ op$7[1] ^ (op$7[0] & acc$7[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$7[32] <= op$7[0] ? xy$7[32] : xy$7[31];
				acc_out$7[31:0] <= ({32{op$7[1]}} & xy$7[32+:32]) ^ ({32{op$7[0]}} & xy$7[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$7 <= acc_io$7;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$7 <= acc$7;
			end
		endcase
		casex (op$8[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$8[32] <= acc$8[32];
				acc_out$8[31:0] <= {32{op$8[3]}} ^ (~ax$8[31:0] & ay$8[31:0]) ^ ({32{~op$8[0]}} & acc$8[31:0] & y$8);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$8 <= ax$8 + ay$8 + {32'd0, op$8[2] ^ op$8[1] ^ (op$8[0] & acc$8[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$8[32] <= op$8[0] ? xy$8[32] : xy$8[31];
				acc_out$8[31:0] <= ({32{op$8[1]}} & xy$8[32+:32]) ^ ({32{op$8[0]}} & xy$8[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$8 <= acc_io$8;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$8 <= acc$8;
			end
		endcase
		casex (op$9[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$9[32] <= acc$9[32];
				acc_out$9[31:0] <= {32{op$9[3]}} ^ (~ax$9[31:0] & ay$9[31:0]) ^ ({32{~op$9[0]}} & acc$9[31:0] & y$9);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$9 <= ax$9 + ay$9 + {32'd0, op$9[2] ^ op$9[1] ^ (op$9[0] & acc$9[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$9[32] <= op$9[0] ? xy$9[32] : xy$9[31];
				acc_out$9[31:0] <= ({32{op$9[1]}} & xy$9[32+:32]) ^ ({32{op$9[0]}} & xy$9[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$9 <= acc_io$9;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$9 <= acc$9;
			end
		endcase
		casex (op$10[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$10[32] <= acc$10[32];
				acc_out$10[31:0] <= {32{op$10[3]}} ^ (~ax$10[31:0] & ay$10[31:0]) ^ ({32{~op$10[0]}} & acc$10[31:0] & y$10);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$10 <= ax$10 + ay$10 + {32'd0, op$10[2] ^ op$10[1] ^ (op$10[0] & acc$10[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$10[32] <= op$10[0] ? xy$10[32] : xy$10[31];
				acc_out$10[31:0] <= ({32{op$10[1]}} & xy$10[32+:32]) ^ ({32{op$10[0]}} & xy$10[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$10 <= acc_io$10;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$10 <= acc$10;
			end
		endcase
		casex (op$11[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$11[32] <= acc$11[32];
				acc_out$11[31:0] <= {32{op$11[3]}} ^ (~ax$11[31:0] & ay$11[31:0]) ^ ({32{~op$11[0]}} & acc$11[31:0] & y$11);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$11 <= ax$11 + ay$11 + {32'd0, op$11[2] ^ op$11[1] ^ (op$11[0] & acc$11[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$11[32] <= op$11[0] ? xy$11[32] : xy$11[31];
				acc_out$11[31:0] <= ({32{op$11[1]}} & xy$11[32+:32]) ^ ({32{op$11[0]}} & xy$11[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$11 <= acc_io$11;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$11 <= acc$11;
			end
		endcase
		casex (op$12[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$12[32] <= acc$12[32];
				acc_out$12[31:0] <= {32{op$12[3]}} ^ (~ax$12[31:0] & ay$12[31:0]) ^ ({32{~op$12[0]}} & acc$12[31:0] & y$12);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$12 <= ax$12 + ay$12 + {32'd0, op$12[2] ^ op$12[1] ^ (op$12[0] & acc$12[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$12[32] <= op$12[0] ? xy$12[32] : xy$12[31];
				acc_out$12[31:0] <= ({32{op$12[1]}} & xy$12[32+:32]) ^ ({32{op$12[0]}} & xy$12[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$12 <= acc_io$12;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$12 <= acc$12;
			end
		endcase
		casex (op$13[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$13[32] <= acc$13[32];
				acc_out$13[31:0] <= {32{op$13[3]}} ^ (~ax$13[31:0] & ay$13[31:0]) ^ ({32{~op$13[0]}} & acc$13[31:0] & y$13);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$13 <= ax$13 + ay$13 + {32'd0, op$13[2] ^ op$13[1] ^ (op$13[0] & acc$13[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$13[32] <= op$13[0] ? xy$13[32] : xy$13[31];
				acc_out$13[31:0] <= ({32{op$13[1]}} & xy$13[32+:32]) ^ ({32{op$13[0]}} & xy$13[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$13 <= acc_io$13;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$13 <= acc$13;
			end
		endcase
		casex (op$14[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$14[32] <= acc$14[32];
				acc_out$14[31:0] <= {32{op$14[3]}} ^ (~ax$14[31:0] & ay$14[31:0]) ^ ({32{~op$14[0]}} & acc$14[31:0] & y$14);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$14 <= ax$14 + ay$14 + {32'd0, op$14[2] ^ op$14[1] ^ (op$14[0] & acc$14[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$14[32] <= op$14[0] ? xy$14[32] : xy$14[31];
				acc_out$14[31:0] <= ({32{op$14[1]}} & xy$14[32+:32]) ^ ({32{op$14[0]}} & xy$14[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$14 <= acc_io$14;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$14 <= acc$14;
			end
		endcase
		casex (op$15[7:4])
			4'b0xxx: begin
				// 0---nxay logic  n:not x:acc a:acc&y ~y:y
				acc_out$15[32] <= acc$15[32];
				acc_out$15[31:0] <= {32{op$15[3]}} ^ (~ax$15[31:0] & ay$15[31:0]) ^ ({32{~op$15[0]}} & acc$15[31:0] & y$15);
				end
			4'b1100: begin
				// 1100-xyc add/sub  x:subx y:suby c:carry
				acc_out$15 <= ax$15 + ay$15 + {32'd0, op$15[2] ^ op$15[1] ^ (op$15[0] & acc$15[32])};
				end
			4'b1101: begin
				// 1101sehl mul/shift  s:signed e:shift h:high l:low
				acc_out$15[32] <= op$15[0] ? xy$15[32] : xy$15[31];
				acc_out$15[31:0] <= ({32{op$15[1]}} & xy$15[32+:32]) ^ ({32{op$15[0]}} & xy$15[0+:32]);
				end
			4'b111x: begin
				// 111rdddd io  r:retry d:device
				acc_out$15 <= acc_io$15;
				end
			default begin
				// 10cccccc jump  c:condition
				acc_out$15 <= acc$15;
			end
		endcase
		// jump
		casex ({retry_io$0 | retry_lock$0 | retry_put$0, op$0[7:4], cond$0})
			6'b00000x: begin
				// 0000---- get
				pc_out$0 <= acc$0[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$0 <= y$0[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$0 <= pc$0;
				end
			default begin
				// otherwise
				pc_out$0 <= {pc$0[4+:13], 4'd1};
			end
		endcase
		casex ({retry_io$1 | retry_lock$1 | retry_put$1, op$1[7:4], cond$1})
			6'b00000x: begin
				// 0000---- get
				pc_out$1 <= acc$1[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$1 <= y$1[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$1 <= pc$1;
				end
			default begin
				// otherwise
				pc_out$1 <= {pc$1[4+:13], 4'd2};
			end
		endcase
		casex ({retry_io$2 | retry_lock$2 | retry_put$2, op$2[7:4], cond$2})
			6'b00000x: begin
				// 0000---- get
				pc_out$2 <= acc$2[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$2 <= y$2[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$2 <= pc$2;
				end
			default begin
				// otherwise
				pc_out$2 <= {pc$2[4+:13], 4'd3};
			end
		endcase
		casex ({retry_io$3 | retry_lock$3 | retry_put$3, op$3[7:4], cond$3})
			6'b00000x: begin
				// 0000---- get
				pc_out$3 <= acc$3[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$3 <= y$3[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$3 <= pc$3;
				end
			default begin
				// otherwise
				pc_out$3 <= {pc$3[4+:13], 4'd4};
			end
		endcase
		casex ({retry_io$4 | retry_lock$4 | retry_put$4, op$4[7:4], cond$4})
			6'b00000x: begin
				// 0000---- get
				pc_out$4 <= acc$4[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$4 <= y$4[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$4 <= pc$4;
				end
			default begin
				// otherwise
				pc_out$4 <= {pc$4[4+:13], 4'd5};
			end
		endcase
		casex ({retry_io$5 | retry_lock$5 | retry_put$5, op$5[7:4], cond$5})
			6'b00000x: begin
				// 0000---- get
				pc_out$5 <= acc$5[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$5 <= y$5[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$5 <= pc$5;
				end
			default begin
				// otherwise
				pc_out$5 <= {pc$5[4+:13], 4'd6};
			end
		endcase
		casex ({retry_io$6 | retry_lock$6 | retry_put$6, op$6[7:4], cond$6})
			6'b00000x: begin
				// 0000---- get
				pc_out$6 <= acc$6[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$6 <= y$6[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$6 <= pc$6;
				end
			default begin
				// otherwise
				pc_out$6 <= {pc$6[4+:13], 4'd7};
			end
		endcase
		casex ({retry_io$7 | retry_lock$7 | retry_put$7, op$7[7:4], cond$7})
			6'b00000x: begin
				// 0000---- get
				pc_out$7 <= acc$7[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$7 <= y$7[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$7 <= pc$7;
				end
			default begin
				// otherwise
				pc_out$7 <= {pc$7[4+:13], 4'd8};
			end
		endcase
		casex ({retry_io$8 | retry_lock$8 | retry_put$8, op$8[7:4], cond$8})
			6'b00000x: begin
				// 0000---- get
				pc_out$8 <= acc$8[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$8 <= y$8[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$8 <= pc$8;
				end
			default begin
				// otherwise
				pc_out$8 <= {pc$8[4+:13], 4'd9};
			end
		endcase
		casex ({retry_io$9 | retry_lock$9 | retry_put$9, op$9[7:4], cond$9})
			6'b00000x: begin
				// 0000---- get
				pc_out$9 <= acc$9[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$9 <= y$9[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$9 <= pc$9;
				end
			default begin
				// otherwise
				pc_out$9 <= {pc$9[4+:13], 4'd10};
			end
		endcase
		casex ({retry_io$10 | retry_lock$10 | retry_put$10, op$10[7:4], cond$10})
			6'b00000x: begin
				// 0000---- get
				pc_out$10 <= acc$10[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$10 <= y$10[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$10 <= pc$10;
				end
			default begin
				// otherwise
				pc_out$10 <= {pc$10[4+:13], 4'd11};
			end
		endcase
		casex ({retry_io$11 | retry_lock$11 | retry_put$11, op$11[7:4], cond$11})
			6'b00000x: begin
				// 0000---- get
				pc_out$11 <= acc$11[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$11 <= y$11[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$11 <= pc$11;
				end
			default begin
				// otherwise
				pc_out$11 <= {pc$11[4+:13], 4'd12};
			end
		endcase
		casex ({retry_io$12 | retry_lock$12 | retry_put$12, op$12[7:4], cond$12})
			6'b00000x: begin
				// 0000---- get
				pc_out$12 <= acc$12[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$12 <= y$12[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$12 <= pc$12;
				end
			default begin
				// otherwise
				pc_out$12 <= {pc$12[4+:13], 4'd13};
			end
		endcase
		casex ({retry_io$13 | retry_lock$13 | retry_put$13, op$13[7:4], cond$13})
			6'b00000x: begin
				// 0000---- get
				pc_out$13 <= acc$13[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$13 <= y$13[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$13 <= pc$13;
				end
			default begin
				// otherwise
				pc_out$13 <= {pc$13[4+:13], 4'd14};
			end
		endcase
		casex ({retry_io$14 | retry_lock$14 | retry_put$14, op$14[7:4], cond$14})
			6'b00000x: begin
				// 0000---- get
				pc_out$14 <= acc$14[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$14 <= y$14[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$14 <= pc$14;
				end
			default begin
				// otherwise
				pc_out$14 <= {pc$14[4+:13], 4'd15};
			end
		endcase
		casex ({retry_io$15 | retry_lock$15 | retry_put$15, op$15[7:4], cond$15})
			6'b00000x: begin
				// 0000---- get
				pc_out$15 <= acc$15[0+:17];
				end
			6'b010xx1: begin
				// 10------ jump and cond=ok
				pc_out$15 <= y$15[0+:17];
				end
			6'b1xxxxx,
			6'b00011x: begin
				// 0011---- halt or retry
				pc_out$15 <= pc$15;
				end
			default begin
				// otherwise
				pc_out$15 <= {pc$15[4+:13] + 13'd1, 4'd0};
			end
		endcase
	end
endmodule
