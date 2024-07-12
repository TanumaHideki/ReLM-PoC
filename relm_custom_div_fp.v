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
	wire [WD-1:0] div_n10 = d_in - c_in;
	wire [WD-1:0] div_q10 = a_in;
	wire div_gt10;
	relm_compare #(WD) compare_gt10(c_in, d_in, div_gt10);
	wire [WD-1:0] div_n11 = div_n10 - (c_in >> 1);
	wire [WD-1:0] div_q11 = a_in | (a_in >> 1);
	wire div_gt11;
	relm_compare #(WD) compare_gt11(c_in >> 1, div_n10, div_gt11);
	wire [WD-1:0] div_n01 = d_in - (c_in >> 1);
	wire [WD-1:0] div_q01 = a_in >> 1;
	wire div_gt01;
	relm_compare #(WD) compare_gt01(c_in >> 1, d_in, div_gt01);
	
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
	wire [62:0] itof_mul_ax = itof_mul * ((x_in[WOP] & a_in[WD-1]) ? -a_in : a_in);

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
	wire [9:0] fsqu_e = {1'b0, a_exp, 1'b0} - 10'h7F;
	wire fsqu_zero = fsqu_e[9] | a_zero | a_nan;
	wire fsqu_inf = (fsqu_e[9:8] == 2'b01) | a_inf;
	wire [47:0] fmul_ax = {1'd1, a_in[22:0]} * {1'd1, (opb_in && x_in[WOP]) ? a_in[22:0] : xb_in[22:0]};

	wire [9:0] fdiv_e = {2'b00, xb_exp} - {2'b00, a_exp} + 10'h7F;
	wire fdiv_zero = fdiv_e[9] | xb_zero | a_inf;
	wire fdiv_inf = (fdiv_e[9:8] == 2'b01) | xb_inf | a_zero;
	wire fdiv_nan = (xb_zero & a_zero) | (xb_inf & a_inf) | xb_nan | a_nan;

	wire fadd_gte;
	relm_compare #(8) compare_fadd_e(a_exp, xb_exp, fadd_gte);
	wire [7:0] fadd_d = fadd_gte ? a_exp - xb_exp : xb_exp - a_exp;
	wire fadd_gt;
	relm_compare #(WD-1) compare_fadd(a_in[30:0], xb_in[30:0], fadd_gt);
	wire [31:0] fadd_max = fadd_gt ? a_in : xb_in;
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
	wire [31:0] fadd_mr = {1'b0, fadd_d[7:5] ? {31'd1} : fadd_m4};
	wire [31:0] fadd_ml = {2'b01, fadd_max[22:0], 7'd0};
	wire [31:0] fadd_mlr = (a_zero | xb_zero) ? fadd_ml : (a_in[WD-1] ^ xb_in[WD-1]) ? fadd_ml - fadd_mr : fadd_ml + fadd_mr;

	wire [22:0] trunc_m = (a_in[23] ? 23'h2AAAAA : 23'h555555) & (a_in[24] ? 23'h199999 : 23'h666666) & (a_in[25] ? 23'h078787 : 23'h787878) & (a_in[26] ? 23'h007F80 : 23'h7F807F) & (a_in[27] ? 23'h00007F : 23'h7FFF80);
	wire [21:0] trunc_ml;
	relm_lower #(22) lower_trunc(trunc_m[22:1], trunc_ml);
	wire [30:0] trunc_fmask = a_in[30] ? {9'd0, !a_in[29:28] ? trunc_ml : 22'd0} : {&a_in[29:23] ? 8'h00 : 8'hFF, 23'h7FFFFF};
	wire trunc_fract = |(a_in[30:0] & trunc_fmask);

	wire [31:0] ftoi_m = {9'b1, a_in[22:0]};
	wire [31:0] ftoi_s = a_in[30] ? {9'd0, trunc_m} : &a_in[29:23] ? 32'h00800000 : 32'h01000000;

	wire [31:0] fcomp_a = !a_in[WD-2:WD-9] ? 32'h80000000 : {~a_in[WD-1], a_in[WD-1] ? ~a_in[WD-2:0] : a_in[WD-2:0]};
	wire [31:0] fcomp_xb = !xb_in[WD-2:WD-9] ? 32'h80000000 : {~xb_in[WD-1], xb_in[WD-1] ? ~xb_in[WD-2:0] : xb_in[WD-2:0]};
	wire fcomp_gt;
	relm_compare #(WD) compare_fcomp(fcomp_a, fcomp_xb, fcomp_gt);

	integer i;
	always @*
	begin
		itof_mul[0] <= a_lower[30];
		for (i = 1; i < 31; i = i + 1) itof_mul[i] <= div_n[30-i];
		casez ({opb_in, x_in[WOP+1:WOP], op_in[2:0]})
			6'b0??000, 6'b1?0000: begin // (OPB) ITOF
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {x_in[WOP] ? a_in[WD-1] : xb_in[WD-1], xb_in[WD-2:WD-10], xb_in[WD-11] | !a_lower[0], {WD-16{1'bx}}, xb_in[4:0] + itof_dif};
				a_out <= itof_mul_ax[31:0];
			end
			6'b1?1000: begin // OPB ITOFX
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= d_in;
				a_out[WD-1] <= b_in[WD-1];
				a_out[WD-2:WD-9] <= itofx_inf ? 8'hFF : itofx_zero ? 8'h00 : itofx_e - itofx_difc + 8'd1;
				a_out[WD-10:0] <= (itofx_inf | itofx_zero) ? {&b_in[WD-10:WD-11], 22'd0} : (a_in[31] ? a_in[30:8] + {22'd0, itofx_u1} : a_in[29:7] + {22'd0, itofx_u0});
			end
			6'b0??001, 6'b1?0001: begin // (OPB) FMUL
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {a_in[WD-1] ^ xb_in[WD-1], fmul_e[9:8] ? 8'h7F : fmul_e[7:0], fmul_inf, fmul_zero, {WD-16{1'bx}}, 5'd0};
				a_out <= {fmul_ax[47:17], |fmul_ax[16:0]};
			end
			6'b1?1001: begin // OPB FSQU
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {1'b0, fsqu_e[9:8] ? 8'h7F : fsqu_e[7:0], fsqu_inf, fsqu_zero, {WD-16{1'bx}}, 5'd0};
				a_out <= {fmul_ax[47:17], |fmul_ax[16:0]};
			end
			6'b???010: begin // (OPB) FADD
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {fadd_max[31:23], fadd_inf, fadd_zero, {WD-16{1'bx}}, 5'd0};
				a_out <= fadd_mlr;
			end
			6'b0??011: begin // ROUND
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= {a_in[WD-1], (!x_in[WD-9] || (a_in[WD-1] == x_in[WD-1] && trunc_fract)) ? x_in[WD-2:WD-9] : 8'h00, 23'd0};
				a_out <= a_in;
			end
			6'b1?0011: begin // OPB TRUNC
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out <= {a_in[WD-1], a_in[30:0] & ~trunc_fmask};
			end
			6'b1?1011: begin // OPB FTOI
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= ftoi_s;
				a_out <= a_in[WD-1] ? -ftoi_m : ftoi_m;
			end
			6'b???100: begin // (OPB) FCOMP
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in;
				c_out <= c_in;
				b_out <= b_in;
				a_out <= fcomp_gt ? 32'd1 : (fcomp_a == fcomp_xb) ? 32'd0 : 32'hFFFFFFFF;
			end
			6'b0??101, 6'b100101: begin // DIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= a_in; // N
				c_out <= xb_in; // D
				b_out <= div_d; // d
				a_out <= div_n; // n
			end
			6'b101101: begin // OPB DIVINIT
				mul_a_out <= a_in; // q
				mul_x_out <= c_in; // D
				d_out <= d_in; // N
				c_out <= mul_ax_in[WD-1:0]; // Dq
				b_out <= 0; // Q
				a_out <= a_in; // q
			end
			6'b110101: begin // OPB DIVLOOP
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= div_gt10 ? ((div_gt01 | a_in[0]) ? d_in : div_n01) : ((div_gt11 | a_in[0]) ? div_n10 : div_n11); // N : N - Dq/2 : N - Dq : N - Dq - Dq/2
				c_out <= a_in[1:0] ? 32'd0 : c_in >> 2; // 0 : Dq >> 2
				b_out <= b_in | (div_gt10 ? (div_gt01 ? 32'd0 : div_q01) : (div_gt11 ? div_q10 : div_q11)); // Q : Q + q/2 : Q + q : Q + q + q/2
				a_out <= a_in >> 2; // q >> 2
			end
			6'b111101: begin // OPB DIVMOD
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in; // N
				c_out <= c_in; // Dq
				b_out <= b_in; // Q
				a_out <= d_in; // N
			end
			6'b???110: begin // (OPB) FDIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= {a_in[WD-1] ^ xb_in[WD-1], fdiv_inf ? 8'hFF : fdiv_zero ? 8'h00 : fdiv_e[7:0], (fdiv_inf || fdiv_zero) ? {fdiv_nan, 21'd0} : xb_in[22:0]};
				c_out <= c_in;
				b_out <= b_in;
				a_out <= {9'h7F, a_in[22:0]};
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
