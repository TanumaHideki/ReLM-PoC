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
	parameter WC = 64;
	input clk;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	wire [WD-1:0] d_in, c_in, b_in;
	assign {d_in, c_in, b_in} = cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	input [WD*2-1:0] mul_ax_in;
	output reg [WD-1:0] mul_a_out;
	output reg [WD-1:0] mul_x_out;
	output reg [WD-1:0] a_out;
	output [WC+WD-1:0] cb_out;
	reg [WD-1:0] d_out, c_out, b_out;
	assign cb_out = {d_out, c_out, b_out};
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
	wire itofx_u1 = a_in[7] & |{a_in[8], a_in[6], itofx_s};
	wire itofx_u0 = a_in[6] & |{a_in[7], itofx_s};
	wire [7:0] itofx_e = b_in[WD-2:WD-9];
	wire [4:0] itofx_dif = b_in[4:0];
	wire itofx_c = a_in[31] | &a_in[30:6];
	wire [1:0] itofx_inf_gt = {1'b0, itofx_e[0]} + {1'b0, ~itofx_dif[0]} + {1'b0, itofx_c};
	wire itofx_inf = b_in[WD-10] | (&itofx_e[7:1] & !itofx_dif[4:1] & itofx_inf_gt[1]);
	wire [7:0] itofx_difc = {3'd0, itofx_dif} + {7'd0, ~itofx_c};
	wire itofx_zero_gt;
	relm_compare #(8) compare_itofx_zero(itofx_difc, itofx_e, itofx_zero_gt);
	wire itofx_zero = itofx_zero_gt | b_in[WD-11];

	wire [9:0] fmul_e = {2'b00, a_exp} + {2'b00, xb_exp} - 10'h7F;
	wire fmul_zero = fmul_e[9] | a_zero | xb_zero | a_nan | xb_nan;
	wire fmul_inf = (fmul_e[9:8] == 2'b01) | a_inf | xb_inf;
	wire [47:0] fmul_ax = {1'd1, a_in[22:0]} * {1'd1, xb_in[22:0]};

	wire fadd_gt;
	relm_compare #(WD-1) compare_fadd(a_in[30:0], xb_in[30:0], fadd_gt);
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
	wire [31:0] faddx_mr = {1'b0, b_in[9] ? {16'd0, faddx_m3[30:17], |faddx_m3[16:0]} : faddx_m3};
	wire [31:0] faddx_ml = {2'b01, c_in[22:0], 7'd0};
	wire [31:0] faddx_m = a_in[31] ? faddx_ml - faddx_mr : faddx_ml + faddx_mr;

	wire [22:0] trunc_m = (a_in[23] ? 23'h2AAAAA : 23'h555555) & (a_in[24] ? 23'h199999 : 23'h666666) & (a_in[25] ? 23'h078787 : 23'h787878) & (a_in[26] ? 23'h007F80 : 23'h7F807F) & (a_in[27] ? 23'h00007F : 23'h7FFF80);
	wire [21:0] trunc_ml;
	relm_lower #(22) lower_trunc(trunc_m[22:1], trunc_ml);
	wire [30:0] trunc_fmask = a_in[30] ? {9'd0, !a_in[29:28] ? trunc_ml : 22'd0} : {&a_in[29:23] ? 8'h00 : 8'hFF, 23'h7FFFFF};
	wire trunc_fract = |(a_in[30:0] & trunc_fmask);

	wire [31:0] ftoi_m = {9'b1, a_in[22:0]};
	wire [31:0] ftoi_s = a_in[30] ? {9'd0, trunc_m} : &a_in[29:23] ? 32'h00800000 : 32'h01000000;

	wire [WD-1:0] div_s = a_lower ^ (a_lower >> 1);
	wire [WD:0] div_q = {1'b0, d_in} + {1'b0, mul_ax_in[0+:WD]};
	integer i;
	always @*
	begin
		itof_mul[0] <= a_lower[30];
		for (i = 1; i < 31; i = i + 1) itof_mul[i] <= div_s[30-i];
		casez ({opb_in, x_in[WOP+2:WOP], op_in[2:0]})
			7'b0???000, 7'b1??0000: begin // (OPB) ITOF
				mul_a_out <= (x_in[WOP] & a_in[WD-1]) ? -a_in : a_in;
				mul_x_out <= {1'b0, itof_mul};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {x_in[WOP] ? a_in[WD-1] : xb_in[WD-1], xb_in[WD-2:WD-10], xb_in[WD-11] | !a_lower[0], {WD-16{1'bx}}, xb_in[4:0] + itof_dif};
				a_out <= mul_ax_in[31:0];
			end
			7'b1??1000: begin // OPB ITOFX
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out[WD-1] <= b_in[WD-1];
				a_out[WD-2:WD-9] <= itofx_inf ? 8'hFF : itofx_zero ? 8'h00 : itofx_e - itofx_difc + 8'd1;
				a_out[WD-10:0] <= (itofx_inf | itofx_zero) ? {&b_in[WD-10:WD-11], 22'd0} : (a_in[31] ? a_in[30:8] + {22'd0, itofx_u1} : a_in[29:7] + {22'd0, itofx_u0});
			end
			7'b????001: begin // (OPB) FMUL
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= {fmul_ax[47:17], |fmul_ax[16:0]};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {a_in[WD-1] ^ xb_in[WD-1], fmul_e[9:8] ? 8'h7F : fmul_e[7:0], fmul_inf, fmul_zero, {WD-16{1'bx}}, 5'd0};
			end
			7'b0???010, 7'b1??0010: begin // (OPB) FADD
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= {c_in[WD-1:23], fadd_max[22:0]};
				b_out <= {fadd_max[31:23], fadd_inf, fadd_zero, {WD-21{1'bx}}, fadd_dif, 5'd0};
				a_out <= {a_in[WD-1] ^ xb_in[WD-1], 7'bxxxxxxx, fadd_m};
			end
			7'b1??1010: begin // OPB FADDX
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out <= faddx_m;
			end
			7'b0???011: begin // ROUND
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {a_in[WD-1], (!a_in[WD-9] || (a_in[WD-1] == x_in[WD-1] && trunc_fract)) ? a_in[WD-2:WD-9] : 8'h00, 22'd0};
				a_out <= a_in;
			end
			7'b1??0011: begin // OPB TRUNC
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out <= {a_in[WD-1], a_in[30:0] & ~trunc_fmask};
			end
			7'b1??1011: begin // (OPB) FTOI
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= ftoi_s;
				a_out <= a_in[WD-1] ? -ftoi_m : ftoi_m;
			end
			7'b11??101: begin // OPB DIVINIT
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= b_in; // N
				c_out <= div_s - a_in; // -d = s - D
				b_out <= b_in >> 1; // N / 2
				a_out <= div_s; // s
			end
			7'b101?101: begin // OPB DIVPRE, DIVPREX
				mul_a_out <= a_in; // q
				mul_x_out <= c_in; // -d
				d_out <= d_in; // N
				c_out <= x_in[WOP] ? b_in + c_in : c_in; // s - d : -d
				b_out <= b_in; // s
				a_out <= div_q[0+:WD]; // N - d * q
			end
			7'b100?101: begin // OPB DIV, DIVX
				mul_a_out <= a_in; // q
				mul_x_out <= c_in; // s - d
				d_out <= d_in; // N
				c_out <= c_in; // s - d
				b_out <= x_in[WOP] ? a_in : b_in; // q : s
				a_out <= div_q[WD:1]; // (N - (s - d) * q) / 2
			end
			7'b0???101: begin // DIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in; // N
				c_out <= c_in; // s - d
				b_out <= (b_in == a_in || !a_in) ? a_in : x_in; // q : s
				a_out <= (b_in == a_in) ? {WD{1'b0}} : a_in; // 0 : q
			end
			default: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= {WD{1'bx}};;
				c_out <= {WD{1'bx}};;
				b_out <= {WD{1'bx}};;
				a_out <= {WD{1'bx}};;
			end
		endcase
	end
endmodule
