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
	wire [WD-1:0] div_n = a_lower ^ (a_lower >> 1);
	relm_lower #(WD) lower_a(a_in, a_lower);
	wire [WD-1:0] xb_lower;
	wire [WD-1:0] div_d = xb_lower ^ (xb_lower >> 1);
	relm_lower #(WD) lower_xb(xb_in, xb_lower);
	wire [WD-1:0] div_n000 = c_in;
	wire [WD-1:0] div_d100 = a_in;
	wire div_gt100;
	relm_compare #(WD) compare_gt100(div_d100, div_n000, div_gt100);
	wire [WD-1:0] div_nx00 = div_gt100 ? div_n000 : div_n000 - div_d100;
	wire [WD-1:0] div_qx00 = div_gt100 ? 32'd0 : d_in;

	wire [WD-1:0] div_d010 = a_in >> 1;
	wire div_gtx10;
	relm_compare #(WD) compare_gtx10(div_d010, div_nx00, div_gtx10);
	wire [WD-1:0] div_nxx0 = div_gtx10 ? div_nx00 : div_nx00 - div_d010;
	wire [WD-1:0] div_qxx0 = div_gtx10 ? 32'd0 : d_in >> 1;

	wire [WD-1:0] div_d001 = a_in >> 2;
	wire [WD:0] div_nxx1 = {1'b0, div_nxx0} - {1'b0, div_d001};
	wire [WD-1:0] div_nxxx = div_nxx1[WD] ? div_nxx0 : div_nxx1;
	wire [WD-1:0] div_qxxx = div_nxx1[WD] ? 32'd0 : d_in >> 2;

	wire [7:0] a_exp = a_in[WD-2:WD-9];
	wire a_zero = !a_exp;
	wire a_inf = &a_exp;
	wire a_nan = a_inf & |a_in[WD-10:0];
	wire [7:0] xb_exp = xb_in[WD-2:WD-9];
	wire xb_zero = !xb_exp;
	wire xb_inf = &xb_exp;
	wire xb_nan = xb_inf & |xb_in[WD-10:0];

	wire fadd_gte;
	relm_compare #(8) compare_fadd_e(a_exp, xb_exp, fadd_gte);
	wire [7:0] fadd_d = fadd_gte ? a_exp - xb_exp : xb_exp - a_exp;
	wire fadd_gt;
	relm_compare #(WD-1) compare_fadd(a_in[30:0], xb_in[30:0], fadd_gt);
	wire fadd_rsub = opb_in & x_in[WOP];
	wire fadd_sub = opb_in & x_in[WOP+1];
	wire [31:0] fadd_max = fadd_gt ? {fadd_rsub, 31'd0} ^ a_in : {fadd_sub, 31'd0} ^ xb_in;
	wire fadd_inf = a_inf | xb_inf;
	wire fadd_zero = (a_zero & xb_zero) | a_nan | xb_nan;
	wire [23:0] fadd_xb = {1'b1, xb_in[22:0]};
	wire [24:0] fadd_xb0 = fadd_d[0] ? {1'd0, fadd_xb} : {fadd_xb, 1'd0};
	wire [26:0] fadd_xb1 = fadd_d[1] ? {2'd0, fadd_xb0} : {fadd_xb0, 2'd0};
	wire [30:0] fadd_xb2 = fadd_d[2] ? {4'd0, fadd_xb1} : {fadd_xb1, 4'd0};
	wire [23:0] fadd_a = {1'b1, a_in[22:0]};
	wire [24:0] fadd_a0 = fadd_d[0] ? {1'd0, fadd_a} : {fadd_a, 1'd0};
	wire [26:0] fadd_a1 = fadd_d[1] ? {2'd0, fadd_a0} : {fadd_a0, 2'd0};
	wire [30:0] fadd_a2 = fadd_d[2] ? {4'd0, fadd_a1} : {fadd_a1, 4'd0};
	wire [30:0] fadd_m2 = fadd_gt ? fadd_xb2 : fadd_a2;
	wire [30:0] fadd_m3 = fadd_d[3] ? {8'd0, fadd_m2[30:9], |fadd_m2[8:0]} : fadd_m2;
	wire [30:0] fadd_m4 = fadd_d[4] ? {16'd0, fadd_m3[30:17], |fadd_m3[16:0]} : fadd_m3;
	wire [31:0] fadd_mr = {1'b0, (a_zero | xb_zero) ? 31'd0 : fadd_d[7:5] ? {31'd1} : fadd_m4};
	wire [31:0] fadd_ml = {2'b01, fadd_max[22:0], 7'd0};
	wire [31:0] fadd_mlr = (fadd_rsub ^ a_in[WD-1] ^ fadd_sub ^ xb_in[WD-1]) ? fadd_ml - fadd_mr : fadd_ml + fadd_mr;

	wire [9:0] fmul_e = {2'b00, a_exp} + {2'b00, xb_exp} - 10'h7F;
	wire fmul_zero = fmul_e[9] | a_zero | xb_zero | a_nan | xb_nan;
	wire fmul_inf = (fmul_e[9:8] == 2'b01) | a_inf | xb_inf;
	wire [47:0] fmul_ax = {1'd1, a_in[22:0]} * {1'd1, xb_in[22:0]};

	wire [4:0] itof_dif;
	assign itof_dif[4] = !a_lower[15];
	wire [15:0] itof_dif4 = itof_dif[4] ? {a_lower[14:1], 2'b11} : a_lower[30:15];
	wire [31:0] itof_m4 = itof_dif[4] ? a_in << 16 : a_in;
	assign itof_dif[3] = !itof_dif4[8];
	wire [7:0] itof_dif3 = itof_dif[3] ? itof_dif4[7:0] : itof_dif4[15:8];
	wire [31:0] itof_m3 = itof_dif[3] ? itof_m4 << 8 : itof_m4;
	assign itof_dif[2] = !itof_dif3[4];
	wire [3:0] itof_dif2 = itof_dif[2] ? itof_dif3[3:0] : itof_dif3[7:4];
	wire [31:0] itof_m2 = itof_dif[2] ? itof_m3 << 4 : itof_m3;
	assign itof_dif[1] = !itof_dif2[2];
	wire [31:0] itof_m1 = itof_dif[1] ? itof_m2 << 2 : itof_m2;
	assign itof_dif[0] = itof_dif[1] ? !itof_dif2[1] : !itof_dif2[3];
	wire [31:0] itof_m = itof_dif[0] ? itof_m1 << 1 : itof_m1;
	wire itof_s = |itof_m[5:0];
	wire itof_u1 = itof_m[7] & |{itof_m[8], itof_m[6], itof_s};
	wire itof_u0 = itof_m[6] & |{itof_m[7], itof_s};
	wire [7:0] itof_e = xb_in[WD-2:WD-9];
	wire itof_c = itof_m[31] | &itof_m[30:6];
	wire [1:0] itof_inf_gt = {1'b0, itof_e[0]} + {1'b0, ~itof_dif[0]} + {1'b0, itof_c};
	wire itof_inf = xb_in[WD-10] | (&itof_e[7:1] & !itof_dif[4:1] & itof_inf_gt[1]);
	wire [7:0] itof_difc = {3'd0, itof_dif} + {7'd0, ~itof_c};
	wire itof_zero_gt;
	relm_compare #(8) compare_itofx_zero(itof_difc, itof_e, itof_zero_gt);
	wire itof_zero = itof_zero_gt | xb_in[WD-11] | !a_lower[0];
	wire [31:0] itof_a;
	assign itof_a[WD-1] = b_in[WD-1];
	assign itof_a[WD-2:WD-9] = itof_inf ? 8'hFF : itof_zero ? 8'h00 : itof_e - itof_difc + 8'd1;
	assign itof_a[WD-10:0] = (itof_inf | itof_zero) ? {&xb_in[WD-10:WD-11], 22'd0} : (itof_m[31] ? itof_m[30:8] + {22'd0, itof_u1} : itof_m[29:7] + {22'd0, itof_u0});

	wire [22:0] trunc_m = (a_in[23] ? 23'h2AAAAA : 23'h555555) & (a_in[24] ? 23'h199999 : 23'h666666) & (a_in[25] ? 23'h078787 : 23'h787878) & (a_in[26] ? 23'h007F80 : 23'h7F807F) & (a_in[27] ? 23'h00007F : 23'h7FFF80);
	wire [21:0] trunc_ml;
	relm_lower #(22) lower_trunc(trunc_m[22:1], trunc_ml);
	wire [30:0] trunc_fmask = a_in[30] ? {9'd0, !a_in[29:28] ? trunc_ml : 22'd0} : {&a_in[29:23] ? 8'h00 : 8'hFF, 23'h7FFFFF};
	wire trunc_fract = |(a_in[30:0] & trunc_fmask);

	wire [31:0] ftoi_m = {9'b1, a_in[22:0]};
	wire [31:0] ftoi_s = a_in[30] ? {9'd0, trunc_m} : &a_in[29:23] ? 32'h00800000 : 32'h01000000;

	wire [9:0] fdiv_e = {2'b00, xb_exp} - {2'b00, a_exp} + 10'h7F;
	wire fdiv_zero = fdiv_e[9] | xb_zero | a_inf;
	wire fdiv_inf = (fdiv_e[9:8] == 2'b01) | xb_inf | a_zero;
	wire fdiv_nan = (xb_zero & a_zero) | (xb_inf & a_inf) | xb_nan | a_nan;

	wire [31:0] fcomp_a = !a_in[WD-2:WD-9] ? 32'h80000000 : {~a_in[WD-1], a_in[WD-1] ? ~a_in[WD-2:0] : a_in[WD-2:0]};
	wire [31:0] fcomp_xb = !xb_in[WD-2:WD-9] ? 32'h80000000 : {~xb_in[WD-1], xb_in[WD-1] ? ~xb_in[WD-2:0] : xb_in[WD-2:0]};
	wire fcomp_gt;
	relm_compare #(WD) compare_fcomp(fcomp_a, fcomp_xb, fcomp_gt);

	always @*
	begin
		casez ({opb_in, x_in[WOP+1:WOP], op_in[2:0]})
			6'b???000: begin // (OPB) FADD, OPB FRSUB, OPB FSUB, OPB FADDM
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {fadd_max[31:23], fadd_inf, fadd_zero, {WD-11{1'bx}}};
				a_out <= fadd_mlr;
			end
			6'b???001: begin // (OPB) FMUL, OPB FMUL(M)
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {fadd_rsub ^ a_in[WD-1] ^ xb_in[WD-1], fmul_e[9:8] ? 8'h7F : fmul_e[7:0], fmul_inf, fmul_zero, {WD-11{1'bx}}};
				a_out <= {fmul_ax[47:17], |fmul_ax[16:0]};
			end
			6'b0??010: begin // ROUND
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {a_in[WD-1], (!x_in[WD-9] || (a_in[WD-1] == x_in[WD-1] && trunc_fract)) ? x_in[WD-2:WD-9] : 8'h00, x_in[WD-10:0]};
				a_out <= a_in;
			end
			6'b1?0010: begin // OPB TRUNC
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out <= {a_in[WD-1], a_in[30:0] & ~trunc_fmask};
			end
			6'b1?1010: begin // OPB FTOI
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= ftoi_s;
				a_out <= a_in[WD-1] ? -ftoi_m : ftoi_m;
			end
			6'b0??011, 6'b1?0011: begin // (OPB) FCOMP
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out <= fcomp_gt ? 32'd1 : (fcomp_a == fcomp_xb) ? 32'd0 : 32'hFFFFFFFF;
			end
			6'b1?1011: begin // OPB ISIGN
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {a_in[WD-1], 8'd157, 2'd0, {WD-11{1'bx}}};
				a_out <= a_in[WD-1] ? -a_in : a_in;
			end
			6'b???100: begin // (OPB) ITOF, OPB ITOF(S)(G)(B)
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= (opb_in & x_in[WOP+2]) ? itof_a : d_in;
				c_out <= fadd_rsub ? itof_a : c_in;
				b_out <= fadd_sub ? d_in : c_in;
				a_out <= itof_a;
			end
			6'b0??101, 6'b100101: begin // (OPB) DIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= xb_in; // D
				c_out <= a_in; // N
				b_out <= div_d; // d
				a_out <= div_n; // n
			end
			6'b101101: begin // OPB DIVINIT
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= a_in; // q
				c_out <= c_in; // N
				b_out <= a_in; // q
				a_out <= d_in; // D
			end
			6'b11?101: begin // OPB DIVLOOP
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in >> 3; // q >> 3
				c_out <= div_nxxx; // N
				b_out <= b_in | div_qx00 | div_qxx0 | div_qxxx; // Q
				a_out <= d_in[2:0] ? 32'd0 : (a_in + 32'd4) >> 3; // Dq >> 3
			end
			6'b0??110, 6'b100110: begin // (OPB) FDIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= {WD{1'bx}};
				c_out <= a_in;
				b_out <= {WD{1'bx}};
				a_out <= {a_in[WD-1] ^ xb_in[WD-1], fdiv_inf ? 8'hFF : fdiv_zero ? 8'h00 : fdiv_e[7:0], (fdiv_inf || fdiv_zero) ? {fdiv_nan, 21'd0} : xb_in[22:0]};
			end
			6'b101110: begin // OPB FDIVINIT
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= 32'h40000000;
				c_out <= 32'h80000000;
				b_out <= 32'd0;
				a_out <= {9'h7F, c_in[22:0]};
			end
			6'b11?110: begin // OPB FDIVLOOP
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= {WD{1'bx}};
				c_out <= {WD{1'bx}};
				b_out <= {9'h7F, 23'd0}; // 1.0
				a_out <= b_in | (d_in >> 1); // Q
			end
			default: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= {WD{1'bx}};
				c_out <= {WD{1'bx}};
				b_out <= {WD{1'bx}};
				a_out <= {WD{1'bx}};
			end
		endcase
	end
endmodule
