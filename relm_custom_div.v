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
	wire [WD-1:0] div_n10 = c_in - d_in;
	wire [WD-1:0] div_q10 = a_in;
	wire div_gt10;
	relm_compare #(WD) compare_gt10(d_in, c_in, div_gt10);
	wire [WD-1:0] div_n11 = div_n10 - (d_in >> 1);
	wire [WD-1:0] div_q11 = a_in | (a_in >> 1);
	wire div_gt11;
	relm_compare #(WD) compare_gt11(d_in >> 1, div_n10, div_gt11);
	wire [WD-1:0] div_n01 = c_in - (d_in >> 1);
	wire [WD-1:0] div_q01 = a_in >> 1;
	wire div_gt01;
	relm_compare #(WD) compare_gt01(d_in >> 1, c_in, div_gt01);
	always @*
	begin
		casez ({opb_in, x_in[WOP+1:WOP], op_in[2:0]})
			6'b0??101, 6'b100101: begin // (OPB) DIV
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= xb_in; // D
				c_out <= a_in; // N
				b_out <= div_d; // d
				a_out <= div_n; // n
			end
			6'b101101: begin // OPB DIVLOOP
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= a_in[1:0] ? 32'd0 : d_in >> 2; // 0 : Dq >> 2
				c_out <= div_gt10 ? ((div_gt01 | a_in[0]) ? c_in : div_n01) : ((div_gt11 | a_in[0]) ? div_n10 : div_n11); // N : N - Dq/2 : N - Dq : N - Dq - Dq/2
				b_out <= b_in | (div_gt10 ? (div_gt01 ? 32'd0 : div_q01) : (div_gt11 ? div_q10 : div_q11)); // Q : Q + q/2 : Q + q : Q + q + q/2
				a_out <= a_in >> 2; // q >> 2
			end
			6'b110101: begin // OPB DIVINIT
				mul_a_out <= a_in; // q
				mul_x_out <= d_in; // D
				d_out <= mul_ax_in[WD-1:0]; // Dq
				c_out <= c_in; // N
				b_out <= 0; // Q
				a_out <= a_in; // q
			end
			6'b111101: begin // OPB DIVMOD
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				d_out <= d_in; // Dq
				c_out <= c_in; // N
				b_out <= b_in; // Q
				a_out <= c_in; // N
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
