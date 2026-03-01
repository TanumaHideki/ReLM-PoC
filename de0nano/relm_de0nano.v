module relm_dpmem(clk, we_in, wa_in, ra_in, d_in, q_out);
	parameter WAD = 0;
	parameter WAD2 = 0;
	parameter WD = 0;
	parameter FILEH = 0;
	parameter FILEB = 0;
	input clk, we_in;
	input [WAD-1:0] wa_in, ra_in;
	input [WD-1:0] d_in;
	output reg [WD-1:0] q_out = 0;
	generate
		if (WAD2) begin
			reg [WD-1:0] q1 = 0;
			reg [WD-1:0] q2 = 0;
			reg q_sel = 0;
			always @* q_out <= q_sel ? q2 : q1;
			(* ramstyle = "M9K" *) reg [WD-1:0] mem [0:2**(WAD-1)-1];
			(* ramstyle = "M9K" *) reg [WD-1:0] mem2 [0:2**WAD2-1];
			always @(posedge clk)
			begin
				if (we_in && !wa_in[WAD-1]) mem[wa_in[0+:WAD-1]] <= d_in;
				if (we_in && wa_in[WAD-1]) mem2[wa_in[0+:WAD2]] <= d_in;
				q1 <= mem[ra_in[0+:WAD-1]];
				q2 <= mem2[ra_in[0+:WAD2]];
				q_sel <= ra_in[WAD-1];
			end
		end
		else begin
			(* ramstyle = "M9K" *) reg [WD-1:0] mem [0:2**WAD-1];
			always @(posedge clk)
			begin
				if (we_in) mem[wa_in] <= d_in;
				q_out <= mem[ra_in];
			end
		end
	endgenerate
	initial if (FILEH) $readmemh(FILEH, mem);
	initial if (FILEB) $readmemb(FILEB, mem);
endmodule

module relm_unused(d_in, q_out);
	parameter WD = 32;
	input [WD:0] d_in;
	output [WD:0] q_out = d_in;
endmodule

module relm_de0nano(clk, sw_in, key_in, led_out,
	adc_cs_n_out, adc_saddr_out, adc_sdat_in, adc_sclk_out,
	i2c_scl_out, i2c_sda_inout,	gs_int_in, gs_cs_n_out,
	scd_pwron_n_out, mtrr_n_out, mtrr_p_out, mtrl_p_out, mtrl_n_out, mtr_sleep_n_out, mtr_fault_n_in,
	ir_adc_convst_out, ir_adc_sck_out, ir_adc_sdo_in, ir_adc_sdi_out, ir_led_on_out, led_left_out, led_right_out
	);
	parameter WD = 32;
	parameter WC = `WC;

	(* chip_pin = "R8" *)
	input clk;

	wire [WD:0] timer_d;
	relm_unused unused_timer(timer_d);
	reg [WD-1:0] timer = 0;
	always @(posedge clk) timer <= timer + 1;
	wire [WD:0] timer_q = {1'b0, timer};

	(* chip_pin = "M15, B9, T8, M1" *)
	input [3:0] sw_in;
	(* chip_pin = "E1, J15" *)
	input [1:0] key_in;
	wire [WD:0] key_d;
	relm_unused unused(key_d);
	reg [5:0] key;
	always @(posedge clk) key <= {sw_in, ~key_in};
	wire [WD:0] key_q = {{WD-5{1'b0}}, key};

	(* chip_pin = "L3, B1, F3, D1, A11, B13, A13, A15" *)
	output reg [7:0] led_out;
	wire [WD:0] led_d;
	always @(posedge clk) begin
		if (led_d[WD]) led_out <= led_d[0+:8];
	end
	wire led_retry = 0;

	(* chip_pin = "F2" *)
	output reg i2c_scl_out = 1;
	(* chip_pin = "F1" *)
	inout i2c_sda_inout;
	reg [1:0] i2c_sda = 3;
	assign i2c_sda_inout = i2c_sda[0] ? 1'bz : i2c_sda[1];
	reg [1:0] i2c_sda_reg = 3;
	(* chip_pin = "M2" *)
	input gs_int_in;
	(* chip_pin = "G5" *)
	output reg gs_cs_n_out = 1;
	wire [WD:0] i2c_d;
	wire [WD:0] i2c_q = {{WD-24{1'b0}}, i2c_sda_reg[1], 24'd0};
	always @(posedge clk) begin
		i2c_sda_reg <= {i2c_sda_reg[0], i2c_sda_inout};
		if (i2c_d[WD]) begin
			i2c_sda[1] <= i2c_d[WD-1];
			gs_cs_n_out <= i2c_d[2];
			i2c_sda[0] <= i2c_d[1];
			i2c_scl_out <= i2c_d[0];
		end
	end

	(* chip_pin = "A10" *)
	output reg adc_cs_n_out = 1;
	(* chip_pin = "B10" *)
	output reg adc_saddr_out = 0;
	(* chip_pin = "A9" *)
	input adc_sdat_in;
	reg [1:0] adc_sdat_reg = 0;
	(* chip_pin = "B14" *)
	output reg adc_sclk_out = 1;
	wire [WD:0] adc_d;
	wire [WD:0] adc_q = {{WD{1'b0}}, adc_sdat_reg[1]};
	always @(posedge clk) begin
		adc_sdat_reg <= {adc_sdat_reg[0], adc_sdat_in};
		if (adc_d[WD]) begin
			adc_saddr_out <= adc_d[WD-1];
			adc_cs_n_out <= adc_d[1];
			adc_sclk_out <= adc_d[0];
		end
	end

	(* chip_pin = "B12" *)
	output scd_pwron_n_out = 0;
	(* chip_pin = "A2" *)
	output reg mtrr_n_out = 0;
	(* chip_pin = "A3" *)
	output reg mtrr_p_out = 0;
	(* chip_pin = "B3" *)
	output reg mtrl_p_out = 0;
	(* chip_pin = "B4" *)
	output reg mtrl_n_out = 0;
	(* chip_pin = "A4" *)
	output mtr_sleep_n_out = 1;
	(* chip_pin = "B5" *)
	input mtr_fault_n_in;
	(* chip_pin = "A7" *)
	output reg led_left_out = 0;
	(* chip_pin = "C6" *)
	output reg led_right_out = 0;
	reg [1:0] mtr_fault_n = 2'b11;
	wire [WD:0] mtr_d;
	wire [WD:0] mtr_q = {{WD{1'b0}}, mtr_fault_n[1]};
	always @(posedge clk) begin
		mtr_fault_n <= {mtr_fault_n[0], mtr_fault_n_in};
		if (mtr_d[WD]) begin
			mtrl_n_out <= mtr_d[3];
			mtrl_p_out <= mtr_d[2];
			mtrr_p_out <= mtr_d[1];
			mtrr_n_out <= mtr_d[0];
			led_right_out <= mtr_d[3];
			led_left_out <= mtr_d[1];
		end
	end

	(* chip_pin = "A5" *)
	output reg ir_adc_convst_out = 0;
	(* chip_pin = "D5" *)
	output reg ir_adc_sck_out = 0;
	(* chip_pin = "B6" *)
	input ir_adc_sdo_in;
	(* chip_pin = "A6" *)
	output reg ir_adc_sdi_out = 0;
	(* chip_pin = "D12" *)
	output ir_led_on_out = 1;
	reg ir_adc_sdi = 0;
	wire [WD:0] ir_adc_d;
	wire [WD:0] ir_adc_q = {{WD-11{1'b0}}, ir_adc_d[11:1], ir_adc_d[WD-2] ? ir_adc_d[0] : ir_adc_sdo_in};
	always @(posedge clk) begin
		ir_adc_sck_out <= ir_adc_d[WD] ? ~ir_adc_d[WD-2] : 1'b0;
		if (ir_adc_d[WD]) begin
			ir_adc_convst_out <= ir_adc_d[WD-1];
			ir_adc_sdi <= ir_adc_d[11];
		end
		ir_adc_sdi_out <= ir_adc_sdi;
	end

	parameter NFIFO = 2;

	wire [(WD+1)*NFIFO-1:0] pushf_d, popf_d, popf_q;
	wire [NFIFO-1:0] pushf_retry;
	generate
		genvar i;
		for (i = 0; i < NFIFO; i = i + 1) begin : fifo
			relm_fifo_io #(
				.WAD(8),
				.WD(WD)
			) fifo_io(
				.clk(clk),
				.push_d(pushf_d[(WD+1)*i+:WD+1]),
				.push_retry(pushf_retry[i]),
				.pop_d(popf_d[(WD+1)*i+:WD+1]),
				.pop_q(popf_q[(WD+1)*i+:WD+1])
			);
		end
	endgenerate

	parameter WID = 3;
	parameter WAD = 11;
	parameter WAD2 = 9;
	parameter WOP = 5;

	parameter NPUSH = 1 + NFIFO;
	parameter NPOP = 6 + NFIFO;

	wire [NPUSH*(WD+1)-1:0] push_d;
	assign {led_d, pushf_d} = push_d;
	wire [NPUSH-1:0] push_retry = {led_retry, pushf_retry};
	wire [NPOP*(WD+1)-1:0] pop_d;
	assign {ir_adc_d, mtr_d, timer_d, i2c_d, adc_d, key_d, popf_d} = pop_d;
	wire [NPOP*(WD+1)-1:0] pop_q = {ir_adc_q, mtr_q, timer_q, i2c_q, adc_q, key_q, popf_q};

`include "coverage.txt"
	generate
		if (!USE_POP_JTAG && !USE_PUSH_PUTOP) begin : no_loader
			relm #(
				.WID(WID),
				.WAD(WAD),
				.WAD2(WAD2),
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
		end
		else begin : use_loader
			wire [WD:0] putop_d;
			wire [WD:0] jtag_d;
			wire [23:0] jtag_ir;
			reg jtag_ready = 0;

			relm #(
				.WID(WID),
				.WAD(WAD),
				.WAD2(WAD2),
				.NPUSH(NPUSH),
				.MPUSH(USE_PUSH_PUTOP),
				.NPOP(NPOP),
				.MPOP(USE_POP_JTAG),
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
		end
	endgenerate
endmodule
