module relm_decode(e_in, d_in, q_out);
	parameter WE = 1;
	parameter WD = 1;
	input [WE-1:0] e_in;
	input [WD-1:0] d_in;
	localparam WH = WE * (2 ** (WD - 1));
	output [WH*2-1:0] q_out;
	generate
		if (WD == 1)
		begin : d1
			assign q_out = {e_in & {WE{d_in[0]}}, e_in & {WE{~d_in[0]}}};
		end
		else
		begin : d2
			wire [WH-1:0] e;
			relm_decode #(WE, WD-1) e_decode(.e_in(e_in), .d_in(d_in[0+:WD-1]), .q_out(e));
			relm_decode #(WH, 1) q_decode(.e_in(e), .d_in(d_in[WD-1]), .q_out(q_out));
		end
	endgenerate
endmodule

module relm_decode_shared(d_in, q_out, r_out);
	parameter WDQ = 1;
	parameter WDR = 1;
	localparam WD = (WDQ > WDR) ? WDQ : WDR;
	input [WD-1:0] d_in;
	localparam WQ = 2 ** WDQ;
	output [WQ-1:0] q_out;
	localparam WR = 2 ** WDR;
	output [WR-1:0] r_out;
	generate
		if (WDQ < WDR)
		begin : ds1
			relm_decode #(1, WDQ) q_decode(.e_in(1'b1), .d_in(d_in[0+:WDQ]), .q_out(q_out));
			relm_decode #(WQ, WDR-WDQ) r_decode(.e_in(q_out), .d_in(d_in[WDR-1:WDQ]), .q_out(r_out));
		end
		else if (WDR < WDQ)
		begin : ds2
			relm_decode #(1, WDR) r_decode(.e_in(1'b1), .d_in(d_in[0+:WDR]), .q_out(r_out));
			relm_decode #(WR, WDQ-WDR) q_decode(.e_in(r_out), .d_in(d_in[WDQ-1:WDR]), .q_out(q_out));
		end
		else
		begin : ds3
			relm_decode #(1, WDQ) q_decode(.e_in(1'b1), .d_in(d_in), .q_out(q_out));
			assign r_out = q_out;
		end
	endgenerate
endmodule

module relm_shrink(d_in, q_out);
	parameter WS = 1;
	parameter WQ = 1;
	input [WS*WQ-1:0] d_in;
	output reg [WQ-1:0] q_out;
	integer i;
	always @*
	begin
		for (i = 0; i < WQ; i = i + 1)
			q_out[i] <= |d_in[i*WS+:WS];
	end
endmodule

module relm_select(s_in, d1_in, d0_in, q_out);
	parameter WS = 1;
	parameter WD = 1;
	input [WS-1:0] s_in;
	input [WS*WD-1:0] d1_in;
	input [WS*WD-1:0] d0_in;
	output reg [WS*WD-1:0] q_out;
	integer i;
	always @*
	begin
		for (i = 0; i < WS; i = i + 1)
			q_out[i*WD+:WD] <= s_in[i] ? d1_in[i*WD+:WD] : d0_in[i*WD+:WD];
	end
endmodule

module relm_mix(s_in, d_in, q_out);
	parameter WS = 1;
	parameter WQ = 1;
	input [WS-1:0] s_in;
	input [WS*WQ-1:0] d_in;
	output reg [WQ-1:0] q_out;
	integer i;
	always @*
	begin
		q_out = {WQ{1'b0}};
		for (i = 0; i < WS; i = i + 1)
			q_out = q_out | (d_in[i*WQ+:WQ] & {WQ{s_in[i]}});
	end
endmodule

module relm_pe(clk, pc_in, pc_out, a_in, a_out, cb_in, cb_out,
		wb_ad_in, wb_ad_out, wb_d_in, wb_d_out, wb_en_in, wb_en_out,
		push_out, push_in, pop_out, pop_in, op_we_in, op_wa_in, op_d_in);
	parameter ID = 0;
	parameter WID = 0;
	parameter WAD = 0;
	parameter NPUSH = 0;
	parameter NPOP = 0;
	parameter WSHIFT = 5;
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = 0;
	parameter CODE = "code00";
	parameter DATA = "data00";
	parameter EXT = ".txt";
	localparam NID = 2 ** WID;
	input clk;
	input [WAD+WID:0] pc_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	input [NID*WAD-1:0] wb_ad_in;
	input [NID*WD-1:0] wb_d_in;
	input [NID-1:0] wb_en_in;
	reg [WAD+WID:0] pc = ID[0+:WAD+WID+1];
	reg [WD-1:0] a = 0;
	reg [WC+WD-1:0] cb = 0;
	reg [NID*WAD-1:0] wb_ad;
	reg [NID*WD-1:0] wb_d;
	reg [NID-1:0] wb_en_reg = 0;
	wire [NID-1:0] wb_en = wb_en_reg & {{NID-ID-1{1'b1}}, 1'b0, {ID{1'b1}}};
	reg active = 0;
	reg fetch = 0;
	always @(posedge clk)
	begin
		pc <= pc_in;
		a <= a_in;
		cb <= cb_in;
		wb_ad <= wb_ad_in;
		wb_d <= wb_d_in;
		wb_en_reg <= wb_en_in;
		active <= (pc_in[0+:WID] == ID[0+:WID]);
		fetch <= !(wb_en_in[ID] && pc_in[WID+:WAD] == wb_ad_in[ID*WAD+:WAD]);
	end
	wire [WD-1:0] x_mem;
	relm_dpmem #(
		.WAD(WAD),
		.WD(WD),
		.FILEH({DATA + ID / 10 * 256 + ID % 10, EXT})
	) dpmem_x(
		.clk(clk),
		.we_in(wb_en_in[ID]),
		.wa_in(wb_ad_in[ID*WAD+:WAD]),
		.d_in(wb_d_in[ID*WD+:WD]),
		.ra_in(pc_in[WID+:WAD]),
		.q_out(x_mem)
	);
	input op_we_in;
	input [WAD+WID-1:0] op_wa_in;
	input [WOP-1:0] op_d_in;
	wire [WOP-1:0] op_mem;
	relm_dpmem #(
		.WAD(WAD),
		.WD(WOP),
		.FILEB({CODE + ID / 10 * 256 + ID % 10, EXT})
	) dpmem_op(
		.clk(clk),
		.we_in(op_we_in && op_wa_in[0+:WID] == ID[0+:WID]),
		.wa_in(op_wa_in[WID+:WAD]),
		.d_in(op_d_in),
		.ra_in(pc_in[WID+:WAD]),
		.q_out(op_mem)
	);
	wire [WD-1:0] x = fetch ? x_mem : wb_d[ID*WD+:WD];
	wire opb = &op_mem; // OPB(5'b11111)
	wire [WOP-1:0] op = active ? (pc[WAD+WID] ? 5'b00000 : (opb ? x[0+:WOP] : op_mem)) : 5'b11111; // LOAD, HALT
	wire [WD-1:0] xb = (!pc[WAD+WID] & opb) ? cb[WD-1:0] : x;

	wire [NID-1:0] put_decode;
	localparam WPOP = $clog2(NPOP);
	wire [2**WPOP-1:0] pop_decode;
	localparam WXB = (WID > WPOP) ? WID : WPOP;
	relm_decode_shared #(WID, WPOP) xb_decode(
		.d_in(xb[0+:WXB]),
		.q_out(put_decode),
		.r_out(pop_decode)
	);
	wire [NID-1:0] ad_ne_xb;
	relm_shrink #(WAD, NID) ad_xb_compare(
		.d_in(wb_ad ^ {NID{xb[WID+:WAD]}}),
		.q_out(ad_ne_xb)
	);
	output [NID*WAD-1:0] wb_ad_out;
	relm_select #(NID, WAD) wb_ad_select(
		.s_in(wb_en),
		.d1_in(wb_ad),
		.d0_in({NID{xb[WID+:WAD]}}),
		.q_out(wb_ad_out)
	);

	localparam NSHIFT = 2 ** WSHIFT;
	wire [NSHIFT-1:0] a_shift;
	localparam WPUSH = $clog2(NPUSH);
	wire [2**WPUSH-1:0] push_decode;
	localparam WA = (WSHIFT > WPUSH) ? WSHIFT : WPUSH;
	relm_decode_shared #(WSHIFT, WPUSH) a_decode(
		.d_in(a[0+:WA]),
		.q_out(a_shift),
		.r_out(push_decode)
	);
	wire [WD-1:0] a_put = (op[0] && (!op[3] || x[WD-1])) ? a_shift[WD-1:0] : {op[0] ^ a[WD-1], a[WD-2:0]};

	reg put;
	wire [NID-1:0] put_stb = put_decode & {NID{put}};
	output [NID*WD-1:0] wb_d_out;
	relm_select #(NID, WD) wb_d_select(
		.s_in(put_stb & ~ad_ne_xb | ~wb_en),
		.d1_in({NID{a_put}}),
		.d0_in(wb_d),
		.q_out(wb_d_out)
	);
	output [NID-1:0] wb_en_out;
	assign wb_en_out = put_stb | wb_en;
	wire retry_put = |(put_decode & ad_ne_xb & wb_en);

	reg push;
	wire [NPUSH-1:0] push_stb = push_decode[NPUSH-1:0] & {NPUSH{push}};
	output [NPUSH*(WD+1)-1:0] push_out;
	relm_select #(NPUSH, WD+1) push_select(
		.s_in(push_stb),
		.d1_in({NPUSH{1'b1, xb}}),
		.d0_in({NPUSH*(WD+1){1'b0}}),
		.q_out(push_out)
	);
	input [NPUSH-1:0] push_in;
	wire retry_push = |(push_decode[NPUSH-1:0] & push_in);

	reg pop;
	wire [NPOP-1:0] pop_stb = pop_decode[NPOP-1:0] & {NPOP{pop}};
	output [NPOP*(WD+1)-1:0] pop_out;
	relm_select #(NPOP, WD+1) pop_select(
		.s_in(pop_stb),
		.d1_in({NPOP{1'b1, a}}),
		.d0_in({NPOP*(WD+1){1'b0}}),
		.q_out(pop_out)
	);
	input [NPOP*(WD+1)-1:0] pop_in;
	wire [WD:0] a_pop;
	relm_mix #(NPOP, WD+1) pop_mix(
		.s_in(pop_decode),
		.d_in(pop_in),
		.q_out(a_pop)
	);
	wire retry_pop = a_pop[WD];

	reg [WD-1:0] mul_a;
	reg [WD-1:0] mul_x;
	wire [WD*2-1:0] mul_ax = mul_a * mul_x;
	wire [WD-1:0] a_custom;
	wire [WC+WD-1:0] cb_custom;
	relm_custom #(WD, WOP, WC) custom(
		.op_in(op),
		.a_in(a),
		.cb_in(cb),
		.x_in(x),
		.xb_in(xb),
		.opb_in(opb),
		.a_out(a_custom),
		.cb_out(cb_custom)
	);
	wire sar_sign = a[WD-1] & op[0];
	reg [WD-1:0] sar_a;
	reg [WD-1:0] sar_ax;
	integer i;
	always @*
	begin
		for (i = 0; i < WD; i = i + 1) sar_a[i] <= a[WD-1-i] ^ sar_sign;
		for (i = 0; i < WD; i = i + 1) sar_ax[i] <= mul_ax[WD-1-i] ^ sar_sign;
		casez (op[1:0])
			2'b01: begin // MUL
				mul_a <= a;
				mul_x <= xb;
			end
			2'b1?: begin // SAR, SHR
				mul_a <= sar_a;
				mul_x <= xb;
			end
			default: begin // otherwise
				mul_a <= {WD{1'bx}};
				mul_x <= {WD{1'bx}};
			end
		endcase
	end

	localparam [WID-1:0] ID1 = ID[WID-1:0] + {{WID-1{1'b0}}, 1'b1};
	localparam [WAD-1:0] PC1 = {{WAD-1{1'd0}}, !ID1};
	wire [WAD+WID:0] pc_inc = {pc[WAD+WID], pc[WID+:WAD] + PC1, ID1};
	output reg [WAD+WID:0] pc_out;
	always @*
	begin
		casez (op)
			5'b01000: // PUSH/OUT
				{push, pop, put, pc_out} <= {3'b100, retry_push ? pc : pc_inc};
			5'b01001: // POP/IO
				{push, pop, put, pc_out} <= {3'b010, retry_pop ? pc : pc_inc};
			5'b0101?: // PUT, PUTS
				{push, pop, put, pc_out} <= {3'b001, retry_put ? pc : pc_inc};
			5'b011??: // RSUB, JEQ, JNE, JUMP
				{push, pop, put, pc_out} <= {3'b000, (!a ? op[0] : op[1]) ? {xb[WD-1], xb[0+:WAD+WID]} : pc_inc};
			5'b11111: // HALT, inactive
				{push, pop, put, pc_out} <= {3'b000, pc};
			default: // get, otherwise
				{push, pop, put, pc_out} <= {3'b000, pc[WAD+WID] ? {1'b0, a[0+:WAD+WID]} : pc_inc};
		endcase
	end

	wire [WD-1:0] a_sign = {WD{op[3]}} ^ {op[1], {WD-1{1'b0}}};
	wire [WD-1:0] x_sign = {WD{op[4]}} ^ {op[1], {WD-1{1'b0}}};
	wire [WD:0] a_add = {1'b0, a ^ a_sign} + {1'b1, xb ^ x_sign} + {{WD{1'b0}}, op[3] | op[4]};
	wire [WD-1:0] a_xor = a ^ xb;
	wire [WD-1:0] a_logic = (op[0] ? a & xb : {WD{1'b0}}) | (op[1] ? a_xor : {WD{1'b0}});
	output reg [WD-1:0] a_out;
	output reg [WC+WD-1:0] cb_out;
	always @*
	begin
		casez (op)
			5'b00000, 5'b0001?: // LOAD, BLOAD, BSLOAD, BLOADX, BSLOADX
				a_out <= (opb && x[WOP]) ? a : xb;
			5'b00001: // SWAP/SHIFT
				a_out <= opb ? a_shift[WD-1:0] : x_mem;
			5'b0?100, 5'b10100: // ADD, RSUB, SUB
				a_out <= a_add[WD-1:0];
			5'b00101, 5'b0011?: // AND, XOR, OR
				a_out <= a_logic;
			5'b01001: // POP/IO
				a_out <= retry_pop ? a : a_pop[WD-1:0];
			5'b100??: // UGT, ULT, IGT, ILT
				a_out <= {{WD-1{1'b0}}, a_add[WD] == op[0] && a_xor};
			5'b10101: // MUL
				a_out <= mul_ax[WD-1:0];
			5'b1011?: // SAR, SHR
				a_out <= sar_ax;
			5'b110??, 5'b1110?, 5'b11110: // custom
				a_out <= a_custom;
			default: // otherwise
				a_out <= a;
		endcase
		casez (op)
			5'b0001?: // BLOAD, BSLOAD
				cb_out <= WC ? {cb[WC+WD-1-:WC], a_put} : a_put;
			5'b110??, 5'b1110?, 5'b11110: // custom
				cb_out <= cb_custom;
			default: // otherwise
				cb_out <= cb;
		endcase
	end
endmodule

module relm(clk, push_out, push_in, pop_out, pop_in, op_we_in, op_wa_in, op_d_in);
	parameter WID = 0;
	localparam NID = 2 ** WID;
	parameter WAD = 0;
	parameter NPUSH = 0;
	parameter [NID-1:0] MPUSH = 0;
	localparam LPUSH = MPUSH ? NPUSH + 1 : NPUSH;
	parameter NPOP = 0;
	parameter [NID-1:0] MPOP = 0;
	localparam LPOP = MPOP ? NPOP + 1 : NPOP;
	parameter WSHIFT = 5;
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = 0;
	parameter CODE = "code00";
	parameter DATA = "data00";
	parameter EXT = ".txt";
	input clk;
	wire [NID*(WAD+WID+1)-1:0] pc;
	wire [NID*WD-1:0] a;
	wire [NID*(WC+WD)-1:0] cb;
	wire [NID*NID*WAD-1:0] wb_ad;
	wire [NID*NID*WD-1:0] wb_d;
	wire [NID*NID-1:0] wb_en;
	wire [NID*LPUSH*(WD+1)-1:0] push;
	output [LPUSH*(WD+1)-1:0] push_out;
	relm_mix #(NID, LPUSH*(WD+1)) mix_push(
		.s_in({NID{1'b1}}),
		.d_in(push),
		.q_out(push_out)
	);
	input [LPUSH-1:0] push_in;
	wire [NID*LPOP*(WD+1)-1:0] pop;
	output [LPOP*(WD+1)-1:0] pop_out;
	relm_mix #(NID, LPOP*(WD+1)) mix_pop(
		.s_in({NID{1'b1}}),
		.d_in(pop),
		.q_out(pop_out)
	);
	input [LPOP*(WD+1)-1:0] pop_in;
	input op_we_in;
	input [WAD+WID-1:0] op_wa_in;
	input [WOP-1:0] op_d_in;
	genvar i;
	generate
		for (i = 0; i < NID - 1; i = i + 1) begin : ring
			localparam NMPUSH = MPUSH[i] ? NPUSH + 1 : NPUSH;
			localparam NMPOP = MPOP[i] ? NPOP + 1 : NPOP;
			wire [NMPUSH*(WD+1)-1:0] push_mix;
			assign push[i*LPUSH*(WD+1)+:LPUSH*(WD+1)] = {{(LPUSH-NMPUSH)*(WD+1){1'b0}}, push_mix};
			wire [NMPOP*(WD+1)-1:0] pop_mix;
			assign pop[i*LPOP*(WD+1)+:LPOP*(WD+1)] = {{(LPOP-NMPOP)*(WD+1){1'b0}}, pop_mix};
			relm_pe #(
				.ID(i),
				.WID(WID),
				.WAD(WAD),
				.NPUSH(NMPUSH),
				.NPOP(NMPOP),
				.WSHIFT(WSHIFT),
				.WD(WD),
				.WOP(WOP),
				.WC(WC),
				.CODE(CODE),
				.DATA(DATA),
				.EXT(EXT)
			) pe(
				.clk(clk),
				.pc_in(pc[i*(WAD+WID+1)+:WAD+WID+1]),
				.pc_out(pc[(i+1)*(WAD+WID+1)+:WAD+WID+1]),
				.a_in(a[i*WD+:WD]),
				.a_out(a[(i+1)*WD+:WD]),
				.cb_in(cb[i*(WC+WD)+:WC+WD]),
				.cb_out(cb[(i+1)*(WC+WD)+:WC+WD]),
				.wb_ad_in(wb_ad[i*NID*WAD+:NID*WAD]),
				.wb_ad_out(wb_ad[(i+1)*NID*WAD+:NID*WAD]),
				.wb_d_in(wb_d[i*NID*WD+:NID*WD]),
				.wb_d_out(wb_d[(i+1)*NID*WD+:NID*WD]),
				.wb_en_in(wb_en[i*NID+:NID]),
				.wb_en_out(wb_en[(i+1)*NID+:NID]),
				.push_out(push_mix),
				.push_in(push_in[NMPUSH-1:0]),
				.pop_out(pop_mix),
				.pop_in(pop_in[NMPOP*(WD+1)-1:0]),
				.op_we_in(op_we_in),
				.op_wa_in(op_wa_in),
				.op_d_in(op_d_in)
			);
		end
	endgenerate
	localparam NMPUSH = MPUSH[NID-1] ? NPUSH + 1 : NPUSH;
	localparam NMPOP = MPOP[NID-1] ? NPOP + 1 : NPOP;
	wire [NMPUSH*(WD+1)-1:0] push_mix;
	assign push[NID*LPUSH*(WD+1)-1-:LPUSH*(WD+1)] = {{(LPUSH-NMPUSH)*(WD+1){1'b0}}, push_mix};
	wire [NMPOP*(WD+1)-1:0] pop_mix;
	assign pop[NID*LPOP*(WD+1)-1-:LPOP*(WD+1)] = {{(LPOP-NMPOP)*(WD+1){1'b0}}, pop_mix};
	relm_pe #(
		.ID(NID-1),
		.WID(WID),
		.WAD(WAD),
		.NPUSH(NMPUSH),
		.NPOP(NMPOP),
		.WSHIFT(WSHIFT),
		.WD(WD),
		.WOP(WOP),
		.WC(WC),
		.CODE(CODE),
		.DATA(DATA),
		.EXT(EXT)
	) last_pe(
		.clk(clk),
		.pc_in(pc[NID*(WAD+WID+1)-1-:WAD+WID+1]),
		.pc_out(pc[0+:WAD+WID+1]),
		.a_in(a[NID*WD-1-:WD]),
		.a_out(a[0+:WD]),
		.cb_in(cb[NID*(WC+WD)-1-:WC+WD]),
		.cb_out(cb[0+:WC+WD]),
		.wb_ad_in(wb_ad[NID*NID*WAD-1-:NID*WAD]),
		.wb_ad_out(wb_ad[0+:NID*WAD]),
		.wb_d_in(wb_d[NID*NID*WD-1-:NID*WD]),
		.wb_d_out(wb_d[0+:NID*WD]),
		.wb_en_in(wb_en[NID*NID-1-:NID]),
		.wb_en_out(wb_en[0+:NID]),
		.push_out(push_mix),
		.push_in(push_in[NMPUSH-1:0]),
		.pop_out(pop_mix),
		.pop_in(pop_in[NMPOP*(WD+1)-1:0]),
		.op_we_in(op_we_in),
		.op_wa_in(op_wa_in),
		.op_d_in(op_d_in)
	);
endmodule

module relm_fifo(clk, re_in, we_in, d_in, empty_out, full_out, q_out);
	parameter WAD = 0;
	parameter WD = 0;
	input clk, re_in, we_in;
	input [WD-1:0] d_in;
	reg ready = 0;
	output empty_out;
	assign empty_out = ~ready;
	reg [WAD:0] ra = 0;
	wire [WAD:0] ra_next = ra + {{WAD{1'b0}}, ready & re_in};
	reg full = 0;
	output full_out;
	assign full_out = full & ~re_in;
	wire we = ~full_out & we_in;
	reg [WAD:0] wa = 0;
	wire [WAD:0] wa_next = wa + {{WAD{1'b0}}, we};
	output [WD-1:0] q_out;
	always @(posedge clk)
	begin
		{ready, full} <= (ra_next[0+:WAD] != wa_next[0+:WAD]) ?
			{ra_next[0+:WAD] != wa[0+:WAD], 1'b0} :
			{2{ra_next[WAD] ^ wa_next[WAD]}};
		ra <= ra_next;
		wa <= wa_next;
	end
	relm_dpmem #(
		.WAD(WAD),
		.WD(WD)
	) demem(
		.clk(clk),
		.we_in(we),
		.wa_in(wa[0+:WAD]),
		.ra_in(ra_next[0+:WAD]),
		.d_in(d_in),
		.q_out(q_out)
	);
endmodule

module relm_fifo_io(clk, push_d, push_retry, pop_d, pop_q);
	parameter WAD = 0;
	parameter WD = 0;
	input clk;
	input [WD:0] push_d;
	output push_retry;
	input [WD:0] pop_d;
	output [WD:0] pop_q;
	reg lock_stb = 0;
	always @(posedge clk) if (pop_d[WD-1]) lock_stb <= 1;
	wire pop_stb = lock_stb | pop_d[0];
	wire empty;
	wire [WD-1:0] pop;
	assign pop_q = (pop_stb) ? {empty, pop} : {{WD{1'b0}}, ~empty};
	relm_fifo #(
		.WAD(WAD),
		.WD(WD)
	) fifo(
		.clk(clk),
		.re_in(pop_stb & pop_d[WD]),
		.we_in(push_d[WD]),
		.d_in(push_d[0+:WD]),
		.empty_out(empty),
		.full_out(push_retry),
		.q_out(pop)
	);
endmodule

module relm_sram_io(clk, sram_wr_d, sram_ad_d, sram_rd_q);
	parameter WAD = 0;
	parameter WD = 0;
	input clk;
	input [WD:0] sram_wr_d;
	input [WD:0] sram_ad_d;
	output [WD:0] sram_rd_q;
	assign sram_rd_q[WD] = 0;
	reg [WAD-1:0] sram_wa;
	wire [WAD-1:0] sram_ra = sram_ad_d[WD] ? sram_ad_d[0+:WAD] : sram_wa;
	always @(posedge clk) begin
		if (sram_ad_d[WD]) sram_wa <= sram_ad_d[0+:WAD];
		else if (sram_wr_d[WD]) sram_wa <= sram_wa + {{WAD-1{1'b0}}, 1'b1};
	end
	relm_dpmem #(
		.WAD(WAD),
		.WD(WD)
	) demem(
		.clk(clk),
		.we_in(sram_wr_d[WD]),
		.wa_in(sram_wa),
		.ra_in(sram_ra),
		.d_in(sram_wr_d[0+:WD]),
		.q_out(sram_rd_q[0+:WD])
	);
endmodule
