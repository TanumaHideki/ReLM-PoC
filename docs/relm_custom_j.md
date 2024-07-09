# ReLMのカスタマイズ

ReLMアーキテクチャは、ハードウェア構成や利用目的に応じて以下の手段でカスタマイズが可能になっています。

* I/Oポートへの拡張デバイス接続
* カスタム拡張命令セット

これらのソフトウェア（アプリケーション）への影響を比較すると、前者は比較的小規模なデバイスドライバの開発に留まるのに対し、後者は比較的大規模で、例えば浮動小数点への対応では複雑な命令アーキテクチャ体系の拡張が必要となります。

ハードウェア面では、I/Oポート上のデバイスは全プロセッサで共有されるのに対し、カスタム拡張命令セットの回路は全てのプロセッサで個別に付加されますので、それだけ回路規模や動作周波数に対する条件は厳しくなります。

## カスタム拡張命令用モジュール

ReLMアーキテクチャの論理合成の際、何らかのカスタム拡張命令用回路モジュールをリンクする必要があります。

現在用意済みの拡張命令モジュールは以下になります。

* カスタム拡張命令無し（relm_custom_none.v）
* 整数除算命令対応（relm_custom_div.v）
* 整数除算および浮動小数点演算対応（relm_custom_div_fp.v）

以下はカスタム拡張命令無し（relm_custom_none.v）のモジュールで、回路規模を抑えたい場合や自前で拡張命令を開発する際の雛型として使用します。

~~~ v
module relm_custom(clk, op_in, a_in, cb_in, x_in, xb_in, opb_in, mul_ax_in, mul_a_out, mul_x_out, a_out, cb_out, retry_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = 0;
	input clk;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	input [WD*2-1:0] mul_ax_in;
	output [WD-1:0] mul_a_out;
	assign mul_a_out = {WD{1'bx}};
	output [WD-1:0] mul_x_out;
	assign mul_x_out = {WD{1'bx}};
	output [WD-1:0] a_out;
	assign a_out = {WD{1'bx}};
	output [WC+WD-1:0] cb_out;
	assign cb_out = {WC+WD{1'bx}};
	output retry_out;
	assign retry_out = 0;
endmodule
~~~

以下がパラメータおよび入出力信号になります。

* parameter WD = 32;  
  ワードビット長。
* parameter WOP = 5;  
  命令コードビット長。
* parameter WC = 0;  
  カスタムレジスタ（C）ビット長。使用しない場合は０を指定。
* input clk;  
  クロック信号。基本的に命令実行は１クロック内で完了する組み合わせ回路となるため、通常は使用しない。
* input [WOP-1:0] op_in;  
  命令コード。
* input [WD-1:0] a_in;  
  アキュムレータ（Acc）入力。
* input [WC+WD-1:0] cb_in;  
  カスタムレジスタ（C）とレジスタ（B）の入力。
* input [WD-1:0] x_in;  
  コードメモリ上のオペランド値。OPB命令の場合は命令コード。
* input [WD-1:0] xb_in;  
  演算用オペランド値。OPB命令の場合はレジスタ（B）の値。
* input opb_in;  
  OPB命令フラグ。
* input [WD*2-1:0] mul_ax_in;  
  基本命令用乗算器出力。
* output [WD-1:0] mul_a_out;  
  基本命令用乗算器入力。
* output [WD-1:0] mul_x_out;  
  基本命令用乗算器入力。
* output [WD-1:0] a_out;  
  アキュムレータ（Acc）出力。
* output [WC+WD-1:0] cb_out;  
  カスタムレジスタ（C）とレジスタ（B）の出力。
* output retry_out;
  リトライ出力。１を出力した場合、PUT命令の衝突時と同様に命令を再実行する。

カスタム拡張命令用モジュールは、基本的に演算前のレジスタ値と命令コードを入力して、演算結果のレジスタ値を出力するという構成になっています。

演算処理が複雑になれば演算結果出力に遅延が発生し、動作可能なクロック周波数が低下します。

そのため、整数除算や浮動小数点演算のような複雑な演算処理の場合、１クロック内で実行可能な処理に分割して実行する必要があります。

後述の整数除算や浮動小数点演算に関しては、比較的低性能の旧ターゲットボードDE0-CVで８コア50MHzでの動作が可能となるような命令の粒度で構成されています。

## 整数除算命令拡張

以下は整数除算命令拡張用のモジュール（relm_custom_div.v）になります。

~~~ v
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
~~~


| OpCode | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0x00 | LOAD | SWAP/SHIFT | BLOAD | BSLOAD | ADD | AND | XOR | OR |
| 0x08 | PUSH/OUT | POP/IO | PUT | PUTS | RSUB | JEQ | JNE | JUMP |
| 0x10 | UGT | ULT | IGT | ILT | SUB | MUL | SHR | SAR |
| 0x18 | custom0 | custom1 | custom2 | custom3 | custom4 | **DIV** | custom6 | OPB/HALT |
| 0x20 | | | BLOADX | BSLOADX | | | | |
| 0x38 | | | | | | **DIVX** | | |
| 0x58 | | | | | | **DIVPRE** | | |
| 0x78 | | | | | | **DIVPREX** | | |
| 0x98 | | | | | | **DIVINIT** | | |




