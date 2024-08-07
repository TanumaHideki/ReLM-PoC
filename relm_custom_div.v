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

`define WC 65

module relm_custom(op_in, a_in, cb_in, x_in, xb_in, opb_in, a_out, cb_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = `WC;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	wire [WD:0] d_in;
	wire [WD-1:0] c_in, b_in;
	assign {d_in, c_in, b_in} = cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	output reg [WD-1:0] a_out;
	output [WC+WD-1:0] cb_out;
	reg [WD:0] d_out;
	reg [WD-1:0] c_out, b_out;
	assign cb_out = {d_out, c_out, b_out};

	wire [WD+1:0] div_3d = {2'd0, xb_in} + {1'b0, xb_in, 1'b0}; // 3D
	wire [WD+1:0] div_n00 = {b_in, a_in[WD-1:WD-2]};
	wire div_gt01;
	relm_compare #(WD+2) compare_gt01({2'd0, c_in}, div_n00, div_gt01);
	wire div_gt1;
	relm_compare #(WD+1) compare_gt1({1'd0, c_in}, div_n00[WD+1:1], div_gt1);
	wire [WD+1:0] div_d11 = {d_in, c_in[0]};
	wire div_gt11;
	relm_compare #(WD+2) compare_gt11(div_d11, div_n00, div_gt11);
	wire div_gtx1 = div_gt1 ? div_gt01 : div_gt11;
	wire [WD:0] div_nxx0 = {div_gt1 ? (div_gt01 ? div_n00[WD-1:0] : div_n00[WD-1:0] - c_in) : div_gt11 ? div_n00[WD-1:0] - (c_in << 1) : div_n00[WD-1:0] - div_d11[WD-1:0], a_in[WD-3]};
	wire div_gtxx1;
	relm_compare #(WD+1) compare_gtxx1({1'd0, c_in}, div_nxx0, div_gtxx1);
	wire [WD-1:0] div_nxxx = div_gtxx1 ? div_nxx0[WD-1:0] : div_nxx0[WD-1:0] - c_in;
	wire [1:0] div_q = xb_in[WD-1:2] ? 2'b00 : (xb_in[1:0] == 2'b11) ? {1'b0, &a_in[WD-1:WD-2]} : (xb_in[1:0] == 2'b10) ? {1'b0, a_in[WD-1]} : (xb_in[1:0] == 2'b01) ? a_in[WD-1:WD-2] : 2'bxx;
	wire [1:0] div_r = xb_in[WD-1:2] ? a_in[WD-1:WD-2] : (xb_in[1:0] == 2'b11) ? {a_in[WD-1] & !a_in[WD-2], a_in[WD-2] & !a_in[WD-1]} : (xb_in[1:0] == 2'b10) ? {1'b0, a_in[WD-2]} : (xb_in[1:0] == 2'b01) ? 2'b00 : 2'bxx;

	always @*
	begin
		casez ({opb_in, x_in[WOP+1:WOP], op_in[2:0]})
			6'b0??011, 6'b1?0011: begin // (OPB) DIV
				d_out <= div_3d[WD+1:1]; // 3D >> 1
				c_out <= xb_in; // D
				b_out <= {30'd0, div_r}; // R
				a_out <= {a_in[WD-3:0], div_q}; // N, Q
			end
			6'b1?1011: begin // OPB DIVLOOP
				d_out <= d_in; // 3D >> 1
				c_out <= c_in; // D
				b_out <= div_nxxx; // R
				a_out <= {a_in[WD-4:0], !div_gt1, !div_gtx1, !div_gtxx1}; // N, Q
			end
			default: begin
				d_out <= {WD{1'bx}};;
				c_out <= {WD{1'bx}};;
				b_out <= {WD{1'bx}};;
				a_out <= {WD{1'bx}};;
			end
		endcase
	end
endmodule
