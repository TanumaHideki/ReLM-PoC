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
	wire [WD-1:0] div_s = a_lower ^ (a_lower >> 1);
	wire [WD:0] div_q = {1'b0, d_in} + {1'b0, mul_ax_in[0+:WD]};
	relm_lower lower(a_in, a_lower);
	always @*
	begin
		casez ({opb_in, x_in[WOP+2:WOP], op_in[2:0]})
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
