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

module relm_unused(d_in, q_out);
	parameter WD = 32;
	input [WD:0] d_in;
	output [WD:0] q_out = d_in;
endmodule

module relm_de0cv(clk, sw_in, key_in, ps2_inout, vga_r_out, vga_g_out, vga_b_out, vga_s_out,
		hex5_out, hex4_out, hex3_out, hex2_out, hex1_out, hex0_out, led_out);
	parameter WD = 32;
	parameter WC = 64;

	(* chip_pin = "M9" *)
	input clk;

	(* chip_pin = "AB12, AB13, AA13, AA14, AB15, AA15, T12, T13, V13, U13" *)
	input [9:0] sw_in;
	(* chip_pin = "M6, M7, W9, U7, P22" *)
	input [4:0] key_in;
	wire [WD:0] key_d;
	relm_unused unused(key_d);
	reg [14:0] key;
	always @(posedge clk) key <= {sw_in, ~key_in};
	wire [WD:0] key_q = {{WD-14{1'b0}}, key};

	(* chip_pin = "AA20, AA17, AB20, U22, AB18, AA19, AA18" *)
	output reg [6:0] hex1_out;
	(* chip_pin = "U21, Y21, V21, AA22, Y22, W22, W21" *)
	output reg [6:0] hex0_out;
	(* chip_pin = "L1, L2, U1, U2, N1, N2, Y3, W2, AA1, AA2" *)
	output reg [9:0] led_out;
	wire [WD:0] led0_d;
	always @(posedge clk) begin
		if (led0_d[0]) led_out <= led0_d[1+:10];
		if (led0_d[16]) hex0_out <= ~led0_d[17+:7];
		if (led0_d[24]) hex1_out <= ~led0_d[25+:7];
	end
	wire led0_retry = 0;

	(* chip_pin = "N9, C2, M8, W19, C1, T14, P14" *)
	output reg [6:0] hex5_out;
	(* chip_pin = "U20, Y15, Y20, P9, U15, V20, U16" *)
	output reg [6:0] hex4_out;
	(* chip_pin = "Y16, V18, W16, V19, U17, Y17, V16" *)
	output reg [6:0] hex3_out;
	(* chip_pin = "Y19, AB22, AB17, AB21, V14, AA10, Y14" *)
	output reg [6:0] hex2_out;
	wire [WD:0] led1_d;
	always @(posedge clk) begin
		if (led1_d[0]) hex2_out <= ~led1_d[1+:7];
		if (led1_d[8]) hex3_out <= ~led1_d[9+:7];
		if (led1_d[16]) hex4_out <= ~led1_d[17+:7];
		if (led1_d[24]) hex5_out <= ~led1_d[25+:7];
	end
	wire led1_retry = 0;

	(* chip_pin = "A5, C9, B10, A9" *)
	output reg [3:0] vga_r_out;
	(* chip_pin = "J8, J7, K7, L7" *)
	output reg [3:0] vga_g_out;
	(* chip_pin = "A7, A8, B7, B6" *)
	output reg [3:0] vga_b_out;
	(* chip_pin = "G8, H8" *)
	output reg [1:0] vga_s_out;
	wire vga_empty;
	reg [10:0] vga_x = 0;
	wire [10:0] vga_x_next = vga_x + {10'd0, ~vga_empty};
	reg [9:0] vga_y = 0;
	wire [9:0] vga_y_next = vga_y + 10'd1;
	wire [WD-1:0] vga_q;
	reg [1:0] vga_en = 0;
	reg [31:0] vga_pixel;
	wire [WD:0] vgapal_d;
	(* ramstyle = "no_rw_check, MLAB" *) reg [11:0] vga_palette [0:15];
	always @(posedge clk) begin
		case (vga_x)
			100*16-1: begin
				vga_s_out[0] <= 0; // HSYNC
				vga_x <= 0;
				case (vga_y)
					524: begin
						vga_s_out[1] <= 0; // VSYNC
						vga_y <= 0;
					end
					1: begin
						vga_s_out[1] <= 1;
						vga_y <= vga_y_next;
					end
					default: vga_y <= vga_y_next;
				endcase
			end
			12*16-1: begin
				vga_s_out[0] <= 1;
				vga_x <= vga_x_next;
			end
			default: vga_x <= vga_x_next;
		endcase
		case (vga_x)
			18*16-3: begin
				vga_en[0] <= 1;
				if (vga_y == 35) vga_en[1] <= 1;
			end
			98*16-3: begin
				vga_en[0] <= 0;
				if (vga_y == 35+479) vga_en[1] <= 0;
			end
		endcase
		if (vgapal_d[WD]) vga_palette[vgapal_d[3:0]] <= vgapal_d[15:4];
		casez (vga_x[3:0])
			4'b???1: begin
				vga_pixel <= {vga_pixel[27:0], 4'd0};
				{vga_r_out, vga_g_out, vga_b_out} <= vga_palette[vga_pixel[31:28]];
			end
			4'b1110: if (&vga_en) vga_pixel <= vga_q;
		endcase
	end
	wire [WD:0] vga_d;
	wire vga_retry;
	wire vgapal_retry = 0;
	relm_fifo #(
		.WAD(8),
		.WD(WD)
	) fifo_vga(
		.clk(clk),
		.re_in(vga_x[3:0] == 4'b1110 && &vga_en),
		.we_in(vga_d[WD]),
		.d_in(vga_d[0+:WD]),
		.empty_out(vga_empty),
		.full_out(vga_retry),
		.q_out(vga_q)
	);

	(* chip_pin = "G2, D3" *)
	inout reg [1:0] ps2_inout;
	reg [7:0] ps2_clk_filter;
	reg [7:0] ps2_dat_filter;
	wire [WD:0] ps2_d;
	wire ps2_retry = (!ps2_d[WD-1] && ps2_clk_filter != {8{ps2_d[WD-2]}});
	wire [WD:0] ps2_q = {ps2_retry, {WD-1{1'b0}}, ps2_dat_filter[0]};
	always @(posedge clk) begin
		if (ps2_d[WD]) begin
			ps2_inout[0] <= (ps2_d[WD-1]) ? 1'b0 : 1'bz;
			ps2_inout[1] <= (ps2_d[0]) ? 1'bz : 1'b0;
		end
		ps2_clk_filter <= {ps2_inout[0], ps2_clk_filter[7:1]};
		ps2_dat_filter <= {ps2_inout[1], ps2_dat_filter[7:1]};
	end

	wire [WD:0] sram_wr_d, sram_ad_d, sram_rd_q;
	wire sram_retry = 0;
	relm_sram_io #(
		.WAD(13),
		.WD(WD)
	) sram(
		.clk(clk),
		.sram_wr_d(sram_wr_d),
		.sram_ad_d(sram_ad_d),
		.sram_rd_q(sram_rd_q)
	);

	wire [WD:0] push1_d, pop1_d, pop1_q;
	wire push1_retry;
	relm_fifo_io #(
		.WAD(11),
		.WD(WD)
	) fifo1(
		.clk(clk),
		.push_d(push1_d),
		.push_retry(push1_retry),
		.pop_d(pop1_d),
		.pop_q(pop1_q)
	);

	wire [WD:0] push2_d, pop2_d, pop2_q;
	wire push2_retry;
	relm_fifo_io #(
		.WAD(11),
		.WD(WD)
	) fifo2(
		.clk(clk),
		.push_d(push2_d),
		.push_retry(push2_retry),
		.pop_d(pop2_d),
		.pop_q(pop2_q)
	);

	wire [WD:0] push3_d, pop3_d, pop3_q;
	wire push3_retry;
	relm_fifo_io #(
		.WAD(11),
		.WD(WD)
	) fifo3(
		.clk(clk),
		.push_d(push3_d),
		.push_retry(push3_retry),
		.pop_d(pop3_d),
		.pop_q(pop3_q)
	);

	parameter WID = 3;
	parameter WAD = 13;
	parameter WOP = 5;

	parameter NPUSH = 8;
	parameter NPOP = 6;

	wire [NPUSH*(WD+1)-1:0] push_d;
	assign {led1_d, led0_d, vgapal_d, vga_d, push3_d, push2_d, push1_d, sram_wr_d} = push_d;
	wire [NPUSH-1:0] push_retry = {led1_retry, led0_retry, vgapal_retry, vga_retry,
		push3_retry, push2_retry, push1_retry, sram_retry};
	wire [NPOP*(WD+1)-1:0] pop_d;
	assign {key_d, ps2_d, pop3_d, pop2_d, pop1_d, sram_ad_d} = pop_d;
	wire [NPOP*(WD+1)-1:0] pop_q = {key_q, ps2_q, pop3_q, pop2_q, pop1_q, sram_rd_q};

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
