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

`define WC 32

module relm_custom(op_in, a_in, cb_in, x_in, xb_in, opb_in, a_out, cb_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = `WC;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	wire [WD-1:0] c_in, b_in;
	assign {c_in, b_in} = cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	output reg [WD-1:0] a_out;
	output [WC+WD-1:0] cb_out;
	reg [WD-1:0] c_out, b_out;
	assign cb_out = {c_out, b_out};

	wire [WD:0] div_n0 = {b_in, a_in[WD-1]};
	wire [WD:0] div_n1 = div_n0 - {1'b0, c_in};
	wire div_gt1 = div_n1[WD] & !div_n0[WD];
	wire [WD:0] div_nx0 = {div_gt1 ? div_n0[WD-1:0] : div_n1[WD-1:0], a_in[WD-2]};
	wire [WD:0] div_nx1 = div_nx0 - {1'b0, c_in};
	wire div_gtx1 = div_nx1[WD] & !div_nx0[WD];
	wire [WD-1:0] div_nxx = div_gtx1 ? div_nx0[WD-1:0] : div_nx1[WD-1:0];
	wire [1:0] div_q = xb_in[WD-1:2] ? 2'b00 : (xb_in[1:0] == 2'b11) ? {1'b0, &a_in[WD-1:WD-2]} : (xb_in[1:0] == 2'b10) ? {1'b0, a_in[WD-1]} : (xb_in[1:0] == 2'b01) ? a_in[WD-1:WD-2] : 2'bxx;
	wire [1:0] div_r = xb_in[WD-1:2] ? a_in[WD-1:WD-2] : (xb_in[1:0] == 2'b11) ? {a_in[WD-1] & !a_in[WD-2], a_in[WD-2] & !a_in[WD-1]} : (xb_in[1:0] == 2'b10) ? {1'b0, a_in[WD-2]} : (xb_in[1:0] == 2'b01) ? 2'b00 : 2'bxx;

	always @*
	begin
		casez ({opb_in, x_in[WOP+1:WOP], op_in[2:0]})
			6'b0??011, 6'b1?0011: begin // (OPB) DIV
				c_out <= xb_in; // D
				b_out <= {30'd0, div_r}; // R
				a_out <= {a_in[WD-3:0], div_q}; // N, Q
			end
			6'b1?1011: begin // OPB DIVLOOP
				c_out <= c_in; // D
				b_out <= div_nxx; // R
				a_out <= {a_in[WD-3:0], !div_gt1, !div_gtx1}; // N, Q
			end
			default: begin
				c_out <= {WD{1'bx}};;
				b_out <= {WD{1'bx}};;
				a_out <= {WD{1'bx}};;
			end
		endcase
	end
endmodule
