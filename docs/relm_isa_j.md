# ReLM命令セット

ReLMアーキテクチャには、以下の特徴があります。

* 複雑なアクセス調停機構を必要としない。
* 共有メモリの利用が容易。
* 比較的小規模なシステムにも対応可能。

これらを実現するため、命令セットもかなり特徴的なものとなっています。

## 命令形式

ReLMの命令形式は常に固定長で、５ビットの命令コードと１ワード（32ビット）のオペランドが同時にフェッチされます。

| OpCode | Operand |
| --- | --- |
| OP (5 bits) | X (1 word = 32bits) |

通常の演算命令ではオペランドは即値として扱われ、値そのものが演算の対象となります。

例えば加算を行うADD命令では、アキュムレータAccに対し Acc := Acc + X を実行して演算結果でアキュムレータを更新します。

オペランドはPUT命令により書き換えが可能で、PUT命令を実行するとオペランドで指定されるアドレスの命令オペランドをアキュムレータの値に変更します。

PUT命令は直後の命令のオペランド書き換えも可能なので、例えば以下の様にPUT命令で直後のADD命令のオペランドを書き換えると、アキュムレータの値が２倍になります。（PUT命令自体はアキュムレータの値を変更しない）

| Address | OpCode | Operand |
| --- | --- | --- |
|        | PUT | address of Label |
| Label: | ADD | overwritten by PUT |

このように、演算前のレジスタ選択や間接的な[アドレッシング](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%89%E3%83%AC%E3%83%83%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%A2%E3%83%BC%E3%83%89)を全て排除して演算後のオペランド書き換えに置き換えることにより、１サイクルでの命令実行が可能となります。

また、オペランドが実質的に[レジスタファイル](https://ja.wikipedia.org/wiki/%E3%83%AC%E3%82%B8%E3%82%B9%E3%82%BF%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB)代りとなるため、CPU内部のレジスタ数を大幅に削減することが可能です。

## レジスタ構成

ReLMのレジスタ構成は以下になります。

* プログラムカウンタ（PC）
* アキュムレータ（Acc）
* レジスタ（B）
  * PUT命令負荷軽減用
* カスタムレジスタ（C）
  * カスタム命令専用内部データ保持（オプション）
  * 基本命令からはアクセス不可

理論的に最低限必要となるレジスタは、プログラムカウンタ（PC）とアキュムレータ（Acc）です。

ただし、この最低限の構成のままでは演算の右辺を大部分PUT命令で置き換えなければならず、あまり効率が良くありません。

また、PUT命令には遅延書き込みに関する弱点があり、対象となるバンクへの書き込み予約が既にある状況で同一バンクに対するPUT命令が発行された場合、予約の衝突が発生します。

その場合、通常のハードウェア実装では回路の単純化のために、一周分スレッドの命令実行を停止した上で書き込み予約を全て消化し、改めてPUT命令の書き込み予約を受理します。

つまり、PUT命令が多すぎるとこのようなペナルティが発生する可能性が高くなります。

そこで、アキュムレータとは別に利用可能な１ワードのレジスタ（B）を導入します。

OPBという命令では、レジスタ（B）をオペランド（X）の代わりとして利用することができます。

| OpCode | Operand |
| --- | --- |
| OPB | OpCode (LSB 5bits used) |

OPB命令のオペランドは命令コードで、レジスタ（B）をオペランドとして指定された命令を実行します。

例えばOpCodeとしてADD命令を指定した場合、OPB ADDはオペランド（X）の代わりにレジスタ（B）を使用して Acc := Acc + B を実行します。

レジスタ（B）の代入操作に関しては、コンパイラ出力の効率化が主目的のため、若干回りくどい方法をとることになります。

アキュムレータ（Acc）の即値代入はLOAD命令で、Acc := X を実行します。

一方、レジスタ（B）に直接即値代入する命令は無く、BLOADという命令で間接的に B := Acc, Acc := X とすることになります。

例えば式の左辺を計算してアキュムレータに代入するコード列を LHS、右辺のコード列を RHS とします。

ここで両辺の合計 (LHS) + (RHS) を計算するコード列を展開すると、以下の様になります。

| Label | Code(s) | Action |
| --- | --- | --- |
| | LHS | Acc := (LHS) |
| | PUT Sum: | X_lhs := Acc |
| | RHS | Acc := (RHS) |
| Sum: | ADD X_lhs | Acc := Acc + X_lhs |

ここでもし、RHS がレジスタ（B）を変更しないことがわかっている場合、以下の様に最適化できます。

| Label | Code(s) | Action | Comment |
| --- | --- | --- | --- |
| | LHS | Acc := (LHS) | |
| | RHS' | B := Acc, Acc := (RHS) | change first LOAD to BLOAD
| | OPB ADD | Acc := Acc + B | |

ただしここで、RHS で最初にアキュムレータを変更する命令がLOADとなる（コンパイラ出力では大体そうなる）場合に、これをBLOADに置き換えたものを RHS' とします。（もしそうならない場合、１命令増えるが RHS の前に BLOAD 0 を置く）

基本的な命令でレジスタ（B）を変更できるのはBLOADとBSLOAD（後者はシフト演算関連）のみですが、OPBとの組み合わせで様々な操作が可能になります。

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD X | B := Acc, Acc := X | |
| OPB BLOAD | (Acc, B) := (B, Acc) | swap Acc <=> B |
| BSLOAD X | B := 1 << Acc, Acc := X | used for shift operation |
| OPB BSLOAD | (Acc, B) := (B, 1<<Acc) | used for shift operation |
| LOAD X | Acc := X | |
| OPB LOAD | Acc := B | |

レジスタ（B）の即値代入 B := X やアキュムレータを保持した代入 B := Acc の命令はありませんが、組合せで実現可能です。

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD X | B := Acc, Acc := X | |
| OPB BLOAD | swap Acc <=> B | finally, B := X |

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD 0 | B := Acc, Acc := 0 | |
| OPB LOAD | Acc := B | finally, B := Acc |

## 命令コード表

命令コード（OpCode）は５ビットで表され、以下の命令が割り当てられています。

| OpCode | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0x00 | LOAD | SWAP/SHIFT | BLOAD | BSLOAD | ADD | AND | XOR | OR |
| 0x08 | PUSH/OUT | POP/IO | PUT | PUTS | RSUB | JEQ | JNE | JUMP |
| 0x10 | UGT | ULT | IGT | ILT | SUB | MUL | SAR | SHR |
| 0x18 | custom0 | custom1 | custom2 | custom3 | custom4 | custom5 | custom6 | OPB/HALT |

custom0～custom6はカスタム拡張命令用の空きコードになります。

上記のカスタム拡張以外の命令を、ReLMアーキテクチャの基本命令とします。

SWAP/SHIFTは同一のコードが割り当てられていますが、OPBの有無で全く動作が異なる命令の例になります。

SWAPは[アトミックスワップ](https://en.wikipedia.org/wiki/Linearizability#Primitive_atomic_instructions)を実現するための命令ですが、OPB付きでは意味のある動作をしないので、OPB SHIFTでオペランドを必要としない演算 Acc := 1 << Acc に割り当てています。

OPB/HALTは、もしOPB命令のオペランドに再びOPB命令のコードを指定した場合、動作を停止するHALT命令と解釈されることを表しています。

PUSH/OUTとPOP/IOはI/Oポート関連の命令ですが、デバイスとして[FIFO](https://ja.wikipedia.org/wiki/FIFO)を指定した場合、わかりやすさのため[ニーモニック](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%82%BB%E3%83%B3%E3%83%96%E3%83%AA%E8%A8%80%E8%AA%9E#%E3%83%8B%E3%83%BC%E3%83%A2%E3%83%8B%E3%83%83%E3%82%AF)にPUSHとPOPを割り当てて区別しています。

## 演算命令

基本命令では、以下の論理演算に対応しています。

| Code | Action |
| --- | --- |
| AND X | Acc := Acc & X |
| OPB AND | Acc := Acc & B |
| XOR X | Acc := Acc ^ X |
| OPB XOR | Acc := Acc ^ B |
| OR X | Acc := Acc \| X |
| OPB OR | Acc := Acc \| B |

ここで、OPBの有無で両方示すのは煩わしいので、以降はオペランドを XB とまとめて以下の様に表記することにします。

| OpCode | Action |
| --- | --- |
| AND | Acc := Acc & XB |
| XOR | Acc := Acc ^ XB |
| OR | Acc := Acc \| XB |

加減算命令は以下になります。

| OpCode | Action |
| --- | --- |
| ADD | Acc := Acc + XB |
| SUB | Acc := Acc - XB |
| RSUB | Acc := XB - Acc |

乗算命令は以下になりますが、これはシフト演算にも使用されます。

| OpCode | Action | Comment |
| --- | --- | --- |
| MUL | Acc := Acc * XB | used for shift left |
| SHR | Acc := rev(rev(Acc) * XB) | used for logical shift right |
| SAR | Acc := rev(rev(Acc ^ sign) * XB) ^ sign | used for arithmetic shift right |
| | rev( ) means bit reverse | |

シフト演算は回路規模を抑えるため、[バレルシフタ](https://ja.wikipedia.org/wiki/%E3%83%90%E3%83%AC%E3%83%AB%E3%82%B7%E3%83%95%E3%82%BF)ではなく乗算器を兼用します。

乗算器でシフト演算を実現する場合、あらかじめシフト量を２冪に変換してから乗算を実行します。（シフト量が固定ならコンパイル時に変換可能）

右シフトの場合は、ビットを逆順にして乗算し、また元に戻す操作をすることで対応します。

例えば左シフト Acc << 3 の場合は MUL 8 とすればOKですが、右シフト Acc >> 3 の場合は符号に応じて SHR 8 または SAR 8 とする必要があります。

シフト量の２冪への変換はSHIFT命令で可能ですが、PUTSやBSLOADではオペランドへの転送を同時に実行出来るので、コード量が削減できます。

| OpCode | Action | Comment |
| --- | --- | --- |
| OPB SHIFT | Acc := 1 << Acc | used for shift operation |
| PUTS | Operand\[XB] := 1 << Acc | used for shift operation |
| BSLOAD | B := 1 << Acc, Acc := XB | used for shift operation |

## 転送命令

メモリ書き込み、もしくはアキュムレータからオペランドへの転送は以下の命令になります。

| OpCode | Action | Comment |
| --- | --- | --- |
| PUT | Operand\[XB] := Acc | |
| PUTS | Operand\[XB] := 1 << Acc | used for shift operation |

ハードウェア実装に依存しますが、同一バンクへの転送が解決前に重複した場合、CPU一周分のペナルティが発生する可能性があります。

また、他のスレッドからはメモリの更新が最大CPU一周分遅れて見えることに注意が必要です。

レジスタ（B）をオペランドとする場合、BLOADとBSLOADがこれに対応します。

これらはアキュムレータ（Acc）の即値代入であるLOAD命令と同時に実行されることを想定しています。

| OpCode | Action | Comment |
| --- | --- | --- |
| LOAD | Acc := XB | |
| BLOAD | B := Acc, Acc := XB | |
| BSLOAD | B := 1 << Acc, Acc := XB | used for shift operation |

レジスタ（B）への転送ではPUT命令の様なペナルティは発生しません。

## ジャンプ命令およびオペランド読み出し

プログラムカウンタ（PC）の操作を行うジャンプ命令は以下になります。

| OpCode | Action | Comment |
| --- | --- | --- |
| JUMP | PC := XB | unconditional jump |
| JEQ | if (Acc == 0) PC := XB | conditional jump |
| JNE | if (Acc != 0) PC := XB | conditional jump |
| (getter) | if (PC.msb == 1) PC := Acc, Acc := X | get operand value |

ジャンプ命令は無条件ジャンプと、アキュムレータ（Acc）が０かどうかで分岐する条件ジャンプのみとなります。

ジャンプ命令の飛び先アドレスの最上位ビットを立てると、任意のオペランドを読み出す[getter](https://en.wikipedia.org/wiki/Mutator_method)モードに入ります。

getterモードでは命令を実行せずにオペランドの値をアキュムレータに代入し、代入前のアキュムレータの番地にジャンプしてgetterモードから復帰します。

ソフトウェア側では、あらかじめアキュムレータ（Acc）に戻り番地を入れた上で、最上位ビットを立てたアドレスにジャンプすると、そのアドレスにある命令のオペランド値を取得することが可能になります。

通常の命令実行ではプログラムカウンタ（PC）がインクリメントされるので、アドレスの下位ビットとアクセス可能なメモリバンクが一致し続けることになります。

ジャンプ命令実行の結果プログラムカウンタ（PC）が変更されると、この関係が一時的にずれて実行すべきメモリバンクがスレッドから見えなくなります。

そのような場合、命令実行を一時的に停止して実行対象のメモリバンクが見えるようになるまで回転待ちを行う必要があります。

つまり、ジャンプ命令実行の結果、最大CPU一周分のペナルティが発生することになります。

ただし、このペナルティは予測可能で、ジャンプ命令の次のバンクへ飛んだ場合ペナルティは０で、ジャンプ命令と同じバンクへ飛んだ場合は最悪のCPU一周分となります。

これはコンパイル時にある程度コントロール可能なので、コード配置時になるべくペナルティを減らせるように最適化することになります。

## 比較命令

より複雑な条件分岐は、比較命令の結果を利用することになります。

この比較命令はLLVM IRの[icmp](https://llvm.org/docs/LangRef.html#icmp-instruction)に準じていますが、等号付きの比較結果（greater or equal等）についてはコンパイラ側での論理反転を想定していますので、命令セットからは削除しています。

| OpCode | Action | Comment |
| --- | --- | --- |
| UGT | Acc := (Acc > XB) ? 1 : 0 | unsigned greater than |
| ULT | Acc := (Acc < XB) ? 1 : 0 | unsigned less than |
| IGT | Acc := (Acc > XB) ? 1 : 0 | signed greater than |
| ILT | Acc := (Acc < XB) ? 1 : 0 | signed less than |

## I/Oアクセス

I/Oアクセス関連の命令は以下になります。

| OpCode | Action |
| --- | --- |
| PUSH/OUT | port(Acc) <= XB |
| | if (retry) PC := PC else ++PC |
| POP/IO | port(XB) <= Acc |
| | if (retry) PC := PC else ++PC, Acc := result |

PUSH/OUTはポートに値を出力するだけで結果を受け取らない形式で、ポート番号はアキュムレータ（Acc）で指定して、出力値はオペランド（XB）で指定します。

この命令は、同じポートに連続してデータを出力することを想定していますが、デバイスからは値を返せない代わりにリトライを要請することが可能です。

デバイスが組み込みのFIFOの場合、バッファがフルになるとリトライを実行します。

POP/IOは値の出力と同時に結果を受け取る形式で、ポート番号はオペランド（XB）で指定して、入出力値はともにアキュムレータ（Acc）になります。

こちらもデバイスからの要請によるリトライが可能で、リトライ発生時はアキュムレータ（Acc）を更新しないので、同じ出力値でのアクセスを繰り返すことになります。

デバイスが組み込みのFIFOの場合、出力値の最下位ビットは読み出し要求フラグになります。

読み出し要求が０の場合、戻り値はバッファの状況で、バッファが空でなければ１、空の時は０を返します。

読み出し要求が１の場合、バッファが空でなければ先頭値が読み出されますが、バッファが空の場合はリトライが発生し、バッファが空でなくなるまでリトライを繰り返します。

出力値の最上位ビットは特殊な指令で、これを１とすると以後は出力値に関わらず読み出し要求を１にロックします。

異なるスレッドで同時に同じポートへアクセスがあった場合、デバイスへは全ての出力値の論理和が送られます。

例えばスレッドAであるFIFOポートにPUSH 1 が実行され、同時にスレッドBで同じFIFOポートに対してPUSH 2 が実行されたとすると、そのFIFOには論理和で 1 | 2 = 3 が入力されることになります。

ただし、PUSH/OUTのポートとPOP/IOのポートはポート番号が同じでも全く別のポートとして扱われるので、このような混信は起きません。

特に、同じFIFOのPUSHとPOPは別々のスレッドで実行しても全く問題が起きないので、スレッド間通信の手段として非常に有効です。

## 排他制御

PUT命令によるオペランドの遅延書き込みは、実際には命令フェッチ時のオペランド読み出しと同時に実行されますので、しばしば同じアドレスへの書き込みと読み出しが衝突します。

この場合、書き込み値の方が最新だと考えられますので、こちらをオペランドとして採用した上で、メモリからの読み出し値は捨てられることになります。

そこで、メモリからの読み出し値として書き込み前の値が取り出せれば、容易に[アトミックスワップ](https://en.wikipedia.org/wiki/Linearizability#Primitive_atomic_instructions)が実現できます。

SWAP命令は、このメモリ出力の旧値を意図的に取り出す命令ですが、実際にはPUT命令と組み合わせて以下の様にアトミックスワップを構築することになります。

| Address | Code | Action |
| --- | --- | --- |
| | PUT Atomic: | atomic_X := Acc |
| Atomic: | SWAP atomic_X | Acc := old_X |

このアトミックスワップをベースに、[クリティカルセクション](https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AA%E3%83%86%E3%82%A3%E3%82%AB%E3%83%AB%E3%82%BB%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3)や[ミューテックス](https://ja.wikipedia.org/wiki/%E3%83%9F%E3%83%A5%E3%83%BC%E3%83%86%E3%83%83%E3%82%AF%E3%82%B9)、スレッドプール等を構築することが可能です。

## カスタム拡張命令

基本命令では整数除算、浮動小数点等には未対応なので、カスタム拡張命令としてこれらの機能を追加することが可能です。

以下に整数除算用サポート命令の拡張コード例を示します。

Verilog HDLのモジュールをリンクするだけで容易に命令が追加できますが、乗算器を基本命令と共有できるので、コンパクトな回路実装が可能です。

また、カスタム命令専用のレジスタ（C）が利用可能なので、内部状態を保持しながら複数ステージにわたるパイプライン処理を実装することも可能です。

以下の例では、１ワード分のカスタムレジスタ（C）を割り当てています。

~~~ v
module relm_custom(clk, op_in, a_in, cb_in, x_in, xb_in, opb_in, mul_ax_in, mul_a_out, mul_x_out, a_out, cb_out, retry_out);
	parameter WD = 32;
	parameter WOP = 5;
	parameter WC = 32;
	input clk;
	input [WOP-1:0] op_in;
	input [WD-1:0] a_in;
	input [WC+WD-1:0] cb_in;
	input [WD-1:0] x_in;
	input [WD-1:0] xb_in;
	input opb_in;
	input [WD*2-1:0] mul_ax_in;
	output reg [WD-1:0] mul_a_out;
	output reg [WD-1:0] mul_x_out;
	output reg [WD-1:0] a_out;
	output reg [WC+WD-1:0] cb_out;
	output retry_out;
	assign retry_out = 0;
	function [WD-1:0] div_s;
		input [WD-1:0] b_in;
		reg [WD-1:0] d;
		begin
			d = b_in;
			d = d | (d >> 1);
			d = d | (d >> 2);
			d = d | (d >> 4);
			d = d | (d >> 8);
			d = d | (d >> 16);
			div_s = d ^ (d >> 1);
		end
	endfunction
	wire [WD-1:0] div_r = cb_in[WD+:WD] - a_in;
	wire [WD-1:0] div_n = cb_in[WD+:WD] >> 1;
	wire [WD-1:0] div_m = (div_r > div_n) ? div_r : div_n;
	wire [WD-1:0] div_nn = cb_in[WD+:WD] - mul_ax_in[0+:WD];
	always @*
	begin
		casez ({opb_in, x_in[WOP], op_in[2:0]})
			5'b11101: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= div_s(cb_in[0+:WD]);
				cb_out <= {a_in, cb_in[0+:WD]};
			end
			5'b10101: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= div_m;
				cb_out <= cb_in;
			end
			5'b0?101: begin
				mul_a_out <= a_in;
				mul_x_out <= xb_in;
				a_out <= div_nn;
				cb_out <= {div_nn, cb_in[0+:WD] + a_in};
			end
			default: begin
				mul_a_out <= {WD{1'bx}};
				mul_x_out <= {WD{1'bx}};
				a_out <= a_in;
				cb_out <= cb_in;
			end
		endcase
	end
endmodule
~~~
