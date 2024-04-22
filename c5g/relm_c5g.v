module relm_dpmem(clk, we_in, wa_in, ra_in, d_in, q_out);
	parameter WAD = 0;
	parameter WD = 0;
	parameter FILEH = 0;
	parameter FILEB = 0;
	input clk, we_in;
	input [WAD-1:0] wa_in, ra_in;
	input [WD-1:0] d_in;
	output reg [WD-1:0] q_out = 0;
	(* ramstyle = "M10K", max_depth = 2048 *) reg [WD-1:0] mem [0:2**WAD-1];
	initial if (FILEH) $readmemh(FILEH, mem);
	initial if (FILEB) $readmemb(FILEB, mem);
	always @(posedge clk)
	begin
		if (we_in) mem[wa_in] <= d_in;
		q_out <= mem[ra_in];
	end
endmodule

module relm_custom(clk, op_in, a_in, cb_in, x_in, xb_in, opb_in, mul_ax_in, mul_a_out, mul_x_out, a_out, cb_out, retry_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = 32;
	input clk;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	input [WD*2-1:0] mul_ax_in;
	output reg [WD-1:0] mul_a_out;
	output reg [WD-1:0] mul_x_out;
	output reg [WD-1:0] a_out;
	output reg [WC+WD-1:0] cb_out;
	output retry_out;
	assign retry_out = 0;
	function [WD-1:0] div_s;
		input [WD-1:0] b_in;
		reg [WD-1:0] d;
		begin
			d = b_in;
			d = d | (d >> 1);
			d = d | (d >> 2);
			d = d | (d >> 4);
			d = d | (d >> 8);
			d = d | (d >> 16);
			div_s = d ^ (d >> 1);
		end
	endfunction
	wire [WD-1:0] div_r = cb_in[WD+:WD] - a_in;
	wire [WD-1:0] div_n = cb_in[WD+:WD] >> 1;
	wire [WD-1:0] div_m = (div_r > div_n) ? div_r : div_n;
	wire [WD-1:0] div_nn = cb_in[WD+:WD] - mul_ax_in[0+:WD];
	always @*
	begin
		casez ({opb_in, x_in[WOP], op_in[2:0]})
			5'b11101: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= div_s(cb_in[0+:WD]);
				cb_out <= {a_in, cb_in[0+:WD]};
			end
			5'b10101: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= div_m;
				cb_out <= cb_in;
			end
			5'b0?101: begin
				mul_a_out <= a_in;
				mul_x_out <= xb_in;
				a_out <= div_nn;
				cb_out <= {div_nn, cb_in[0+:WD] + a_in};
			end
			default: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= a_in;
				cb_out <= cb_in;
			end
		endcase
	end
endmodule

module relm_c5g(clk, sw_in, key_in,
		hex3_out, hex2_out, hex1_out, hex0_out, ledr_out, ledg_out);
	parameter WD = 32;
	parameter WC = 32;

	(* chip_pin = "R20" *)
	input clk;

	(* chip_pin = "AE19, Y11, AC10, V10, AB10, W11, AC8, AD13, AE10, AC9" *)
	input [9:0] sw_in;
	(* chip_pin = "AB24, Y16, Y15, P12, P11" *)
	input [4:0] key_in;
	wire [WD:0] key_d;
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

	parameter WID = 4;
	parameter WAD = 12;
	parameter WOP = 5;

	parameter NPUSH = 2;
	parameter NPOP = 1;

	wire [NPUSH*(WD+1)-1:0] push_d;
	assign {hex_d, led_d} = push_d;
	wire [NPUSH-1:0] push_retry = {hex_retry, led_retry};
	wire [NPOP*(WD+1)-1:0] pop_d;
	assign {key_d} = pop_d;
	wire [NPOP*(WD+1)-1:0] pop_q = {key_q};

`ifdef NO_LOADER
	relm #(
		.WID(WID),
		.WAD(WAD),
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
`else
	wire [WD:0] putop_d;
	wire [WD:0] jtag_d;
	wire [23:0] jtag_ir;
	reg jtag_ready = 0;

	relm #(
		.WID(WID),
		.WAD(WAD),
		.NPUSH(NPUSH + 1),
		.NPOP(NPOP + 1),
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
`endif
endmodule
