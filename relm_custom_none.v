`define WC 0

module relm_custom(op_in, a_in, cb_in, x_in, xb_in, opb_in, a_out, cb_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = `WC;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	output [WD-1:0] a_out;
	assign a_out = {WD{1'bx}};
	output [WC+WD-1:0] cb_out;
	assign cb_out = {WC+WD{1'bx}};
endmodule
