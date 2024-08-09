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

module relm_lower(d_in, q_out);
	parameter WD = 32;
	input [WD-1:0] d_in;
	output [WD-1:0] q_out;
	wire [WD-1:0] d1 = d_in | (d_in >> 1);
	wire [WD-1:0] d2 = d1 | (d1 >> 2);
	wire [WD-1:0] d4 = d2 | (d2 >> 4);
	wire [WD-1:0] d8 = d4 | (d4 >> 8);
	assign q_out = d8 | (d8 >> 16);
endmodule

module relm_compare(a_in, b_in, gt_out);
	parameter WD = 32;
	input [WD-1:0] a_in, b_in;
	output gt_out;
	wire [WD-1:0] ab, ba;
	relm_lower #(WD) ab_lower(a_in & ~b_in, ab);
	relm_lower #(WD) ba_lower(b_in & ~a_in, ba);
	assign gt_out = |(ab & ~ba);
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
	wire [WD-1:0] a_lower;
	relm_lower #(WD) lower_a(a_in, a_lower);
	wire [7:0] a_exp = a_in[WD-2:WD-9];
	wire a_zero = !a_exp;
	wire a_inf = &a_exp;
	wire a_nan = a_inf & |a_in[WD-10:0];
	wire [7:0] xb_exp = xb_in[WD-2:WD-9];
	wire xb_zero = !xb_exp;
	wire xb_inf = &xb_exp;
	wire xb_nan = xb_inf & |xb_in[WD-10:0];

	reg [30:0] itof_mul;
	wire [4:0] itof_dif;
	assign itof_dif[4] = !a_lower[15];
	wire [15:0] itof_dif4 = itof_dif[4] ? {a_lower[14:1], 2'b11} : a_lower[30:15];
	assign itof_dif[3] = !itof_dif4[8];
	wire [7:0] itof_dif3 = itof_dif[3] ? itof_dif4[7:0] : itof_dif4[15:8];
	assign itof_dif[2] = !itof_dif3[4];
	wire [3:0] itof_dif2 = itof_dif[2] ? itof_dif3[3:0] : itof_dif3[7:4];
	assign itof_dif[1] = !itof_dif2[2];
	assign itof_dif[0] = itof_dif[1] ? !itof_dif2[1] : !itof_dif2[3];

	wire itofx_s = |a_in[5:0];
	wire itofx_nan = &cb_in[WD-10:WD-11];
	wire itofx_u1 = itofx_nan ? ~a_in[8] : a_in[7] & |{a_in[8], a_in[6], itofx_s};
	wire itofx_u0 = itofx_nan ? ~a_in[7] : a_in[6] & |{a_in[7], itofx_s};
	wire itofx_c = a_in[31] | &a_in[30:6];
	wire [8:0] itofx_em1 = {1'b0, cb_in[WD-2:WD-9]} - {4'd0, cb_in[4:0] + {4'd0, ~itofx_c}};
	wire itofx_zero = itofx_em1[8] | cb_in[WD-11];
	wire [7:0] itofx_ep1 = {1'b0, itofx_em1[7:1]} + 8'd1;
	wire itofx_inf = (!itofx_em1[8] & itofx_ep1[7]) | cb_in[WD-10];

	wire [9:0] fmul_e = {2'b00, a_exp} + {2'b00, xb_exp} - 10'h7F;
	wire fmul_zero = fmul_e[9] | a_zero | xb_zero | a_nan | xb_nan;
	wire fmul_inf = (fmul_e[9:8] == 2'b01) | a_inf | xb_inf;

	wire fadd_gt;
	relm_compare #(WD-1) compare(a_in[30:0], xb_in[30:0], fadd_gt);
	wire [31:0] fadd_max = fadd_gt ? a_in : xb_in;
	wire fadd_inf = fadd_gt ? a_inf : xb_inf;
	wire fadd_zero = fadd_gt ? a_zero | a_nan : xb_zero | xb_nan;
	wire [7:0] fadd_d = fadd_gt ? a_exp - xb_exp : xb_exp - a_exp;
	wire [4:0] fadd_dif = fadd_d[7:5] ? 5'd31 : fadd_d[4:0];
	wire [23:0] fadd_m = (a_zero | xb_zero) ? 24'd0 : {1'b1, fadd_gt ? xb_in[22:0] : a_in[22:0]};

	wire [24:0] faddx_m0 = cb_in[5] ? {1'd0, a_in[23:0]} : {a_in[23:0], 1'd0};
	wire [26:0] faddx_m1 = cb_in[6] ? {2'd0, faddx_m0} : {faddx_m0, 2'd0};
	wire [30:0] faddx_m2 = cb_in[7] ? {4'd0, faddx_m1} : {faddx_m1, 4'd0};
	wire [30:0] faddx_m3 = cb_in[8] ? {8'd0, faddx_m2[30:9], |faddx_m2[8:0]} : faddx_m2;
	wire [31:0] faddx_mr = {1'b0, cb_in[9] ? {16'd0, faddx_m3[30:17], |faddx_m3[16:0]} : faddx_m3};
	wire [31:0] faddx_ml = {2'b01, cb_in[WD+:23], 7'd0};
	wire [31:0] faddx_m = a_in[31] ? faddx_ml - faddx_mr : faddx_ml + faddx_mr;

	wire ftoi_f = (a_in[WD-2] || &a_in[WD-3:WD-4]);
	wire [23:0] ftoi_m = {ftoi_f, a_in[22:0]};
	wire [24:0] ftoi_m0 = a_in[WD-9] ? {ftoi_m, 1'd0} : {1'd0, ftoi_m};
	wire [26:0] ftoi_m1 = a_in[WD-8] ? {ftoi_m0, 2'd0} : {2'd0, ftoi_m0};
	wire [30:0] ftoi_m2 = a_in[WD-7] ? {ftoi_m1, 4'd0} : {4'd0, ftoi_m1};
	wire [38:0] ftoi_m3 = a_in[WD-6] ? {ftoi_m2, 8'd0} : {8'd0, ftoi_m2};
	wire [54:0] ftoi_m4 = a_in[WD-5] ? {ftoi_m3, 16'd0} : {16'd0, ftoi_m3};
	wire [86:0] ftoi_m5 = (a_in[WD-4] || !ftoi_f) ? {32'd0, ftoi_m4} : {ftoi_m4, 32'd0};

	wire [21:0] trunc_m = (a_in[23] ? 22'h155555 : 22'h2AAAAA) & (a_in[24] ? 22'h0CCCCC : 22'h333333) & (a_in[25] ? 22'h03C3C3 : 22'h3C3C3C) & (a_in[26] ? 22'h003FC0 : 22'h3FC03F) & (a_in[27] ? 22'h00003F : 22'h3FFFC0);
	wire [21:0] trunc_ml;
	relm_lower #(22) lower_trunc(trunc_m, trunc_ml);
	wire [30:0] trunc_fmask = a_in[30] ? {9'd0, trunc_ml} : {&a_in[29:23] ? 8'h00 : 8'hFF, 23'h7FFFFF};
	wire trunc_fract = |(a_in[30:0] & trunc_fmask);

	wire [WD-1:0] div_s = a_lower ^ (a_lower >> 1);
	wire [WD-1:0] div_r = cb_in[WD+:WD] - a_in;
	wire [WD-1:0] div_n = cb_in[WD+:WD] >> 1;
	wire [WD-1:0] div_m = (div_r > div_n) ? div_r : div_n;
	wire [WD-1:0] div_nn = cb_in[WD+:WD] - mul_ax_in[0+:WD];
	integer i;
	always @*
	begin
		itof_mul[0] <= a_lower[30];
		for (i = 1; i < 31; i = i + 1) itof_mul[i] <= div_s[30-i];
		casez ({opb_in, x_in[WOP], op_in[2:0]})
			5'b0?000, 5'b10000: begin // (OPB) ITOF
				mul_a_out <= (x_in[WOP] & a_in[WD-1]) ? -a_in : a_in;
				mul_x_out <= {1'b0, itof_mul};
				a_out <= mul_ax_in[31:0];
				cb_out <= {cb_in[WD+:WC], x_in[WOP] ? a_in[WD-1] : xb_in[WD-1], xb_in[WD-2:WD-10], xb_in[WD-11] | !a_lower[0], {WD-16{1'bx}}, xb_in[4:0] + itof_dif};
			end
			5'b11000: begin // OPB ITOFX
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out[WD-1] <= cb_in[WD-1];
				a_out[WD-2:WD-9] <= itofx_inf ? 8'hFF : itofx_zero ? 8'h00 : itofx_em1[7:0] + 8'h01;
				a_out <= {9'd0, (itofx_inf ^ itofx_zero) ? 23'd0 : (a_in[31] ? a_in[30:8] + {22'd0, itofx_u1} : a_in[29:7] + {22'd0, itofx_u0})};
				cb_out <= cb_in;
			end
			5'b??001: begin // (OPB) FMUL
				mul_a_out <= {9'd1, a_in[22:0]};
				mul_x_out <= {9'd1, xb_in[22:0]};
				a_out <= {mul_ax_in[47:17], |mul_ax_in[16:0]};
				cb_out <= {cb_in[WD+:WC], a_in[WD-1] ^ xb_in[WD-1], fmul_e[9:8] ? 8'h7F : fmul_e[7:0], fmul_inf, fmul_zero, {WD-16{1'bx}}, 5'd0};
			end
			5'b0?011: begin // ROUND
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= a_in;
				cb_out <= {cb_in[WD+:WC], a_in[WD-1], !a_in[23] ? 8'h7E : (a_in[WD-1] == x_in[WD-1] && trunc_fract) ? 8'h7F : 8'h00, 23'd0};
			end
			5'b10011: begin // OPB TRUNC
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= {a_in[WD-1], a_in[30:0] & ~trunc_fmask};
				cb_out <= cb_in;
			end
			5'b11011: begin // (OPB) FTOI
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= a_in[WD-1] ? -ftoi_m5[31+:WD] : ftoi_m5[31+:WD];
				cb_out <= cb_in;
			end
			5'b0?010, 5'b10010: begin // (OPB) FADD
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= {a_in[WD-1] ^ xb_in[WD-1], 7'bxxxxxxx, fadd_m};
				cb_out <= {{WC-23{1'bx}}, fadd_max[22:0], fadd_max[31:23], fadd_inf, fadd_zero, {WD-21{1'bx}}, fadd_dif, 5'd0};
			end
			5'b11010: begin // OPB FADDX
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= faddx_m;
				cb_out <= cb_in;
			end
			5'b10101: begin // OPB DIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= a_lower ^ (a_lower >> 1);
				cb_out <= {cb_in[0+:WD], a_in};
			end
			5'b0?101: begin // DIV
				mul_a_out <= a_in;
				mul_x_out <= xb_in;
				a_out <= div_nn;
				cb_out <= {div_nn, cb_in[0+:WD] + a_in};
			end
			5'b11101: begin // OPB DIVX
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= div_m;
				cb_out <= cb_in;
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

module relm_unused(d_in, q_out);
	parameter WD = 32;
	input [WD:0] d_in;
	output [WD:0] q_out = d_in;
endmodule

module relm_c5g(clk, sw_in, key_in, uart_in, uart_out,
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
	relm_unused unused(key_d);
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
			if (uart_t[8:1]) begin
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

	parameter NFIFO = 1;

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

	parameter WID = 4;
	parameter WAD = 12;
	parameter WOP = 5;

	parameter NPUSH = 2 + NFIFO;
	parameter NPOP = 2 + NFIFO;

	wire [NPUSH*(WD+1)-1:0] push_d;
	assign {hex_d, led_d, pushf_d} = push_d;
	wire [NPUSH-1:0] push_retry = {hex_retry, led_retry, pushf_retry};
	wire [NPOP*(WD+1)-1:0] pop_d;
	assign {key_d, uart_d, popf_d} = pop_d;
	wire [NPOP*(WD+1)-1:0] pop_q = {key_q, uart_q, popf_q};

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
