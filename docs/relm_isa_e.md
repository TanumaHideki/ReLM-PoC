# ReLM Instruction Set

ReLM architecture boasts the below-mentioned features;

* No need for a complex access arbitration mechanism
* Good operability in using shared memory
* Available for relatively small systems

These requirements are achieved by distinctive instruction sets.

## Instruction Format

In ReLM, an instruction is always fetched in the fixed-length form of five-bit operation code (OpCode) together with one-word (32bits) operand.

| OpCode | Operand |
| --- | --- |
| OP (5 bits) | X (1 word = 32bits) |

Operands of usual calculation instructions are processed as immediate values subject to calculations.

The ADD instruction for adding, for example, renews the accumulator Acc with the result of calculation executing "Acc := Acc + X".

Operands are overwritable by PUT instruction.  
Once executed, PUT instruction specifies the address of an instruction by its own operand and then overwrites the operand of that instruction with the value of Acc.

PUT instruction also enables overwriting the operand of its following instruction.  
For example, as tabulated below, PUT instruction overwrites the operand of following ADD instruction, resulting in doubling the value of Acc (while PUT instruction does not change the value of Acc).

| Address | OpCode | Operand |
| --- | --- | --- |
|        | PUT | address of Label |
| Label: | ADD | overwritten by PUT |

In this way, replacing all such bothersome processes as [register selection and indirect addressing](https://en.wikipedia.org/wiki/Addressing_mode) before calculation with operand overwriting enables one-cycle instruction execution.

In addition, operands of code memory practically play the act of [register file](https://en.wikipedia.org/wiki/Register_file), helping a drastic reduction in the number of registers within a CPU.


また、オペランドが実質的に[レジスタファイル](https://ja.wikipedia.org/wiki/%E3%83%AC%E3%82%B8%E3%82%B9%E3%82%BF%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB)代りとなるため、CPU内部のレジスタ数を大幅に削減することが可能です。

## Register Structure

The register structure of ReLM consists of the following elements:

* Program counter (PC)
* Accumulator (Acc)
* Register (B)
  * To reduce the cost of PUT instructions
* Custom register (C)
  * Payload to hold internal data dedicated to custom instructions (option)
  * Inaccessible by basic instructions

Theoretically, necessary minimum registers are a program counter (PC) and an accumulator (Acc).

But this minimum structure is so inefficient because most of the right-hand side of binary operation must be replaced by PUT instruction.

Furthermore, PUT instruction has a weak point in terms of lazy write back.  
In a situation where a request for writing back to the target bank is already in a waiting state, the issuance of PUT instruction to the same bank causes the collision of requests. 

To prevent this trouble with simple hardware implementation, it requires suspending instruction execution by a lap of CPUs' ring and completing all requests for writing back before accepting a new request for writing PUT instruction.

In a word, too many PUT instructions would increase the risk of such penalties.  
Instead, this structure introduces a one-word Register (B) available separately from Acc.  
OPB instruction enables to use Register (B) in lieu of Operand (X).  
The operand of OPB instruction is an opcode to execute the instruction specified by X while using Register (B) as its operand.

| OpCode | Operand |
| --- | --- |
| OPB | OpCode (LSB 5bits used) |

In the case of specifying ADD instruction as the opcode, for example, OPB ADD (which means OPB instruction with the operand representing ADD opcode) executes "Acc := Acc + B" using Register (B) in lieu of Operand (X).

Assigning process of Register (B) takes place in a bit of a roundabout way, as it mainly aims to reduce compiler output.

To assign an immediate value to Acc, LOAD instruction executes "Acc := X".  
On the other hand, there is no instruction to directly assign an immediate value to Register (B), which results in employing BLOAD instruction to execute "B := Acc, Acc := X" in a roundabout way.

Here, let LHS denote the code sequence that calculates the left-hand side of the expression to assign it to Acc, and let RHS denote the code sequence for the right-hand side of the expression.  
The following table shows the code sequence that calculates the sum of both sides (LHS) + (RHS).

| Label | Code(s) | Action |
| --- | --- | --- |
| | LHS | Acc := (LHS) |
| | PUT Sum: | X_lhs := Acc |
| | RHS | Acc := (RHS) |
| Sum: | ADD X_lhs | Acc := Acc + X_lhs |

Now, if it is obvious that RHS does not change Register (B), the code sequence can be optimized as follows.

| Label | Code(s) | Action | Comment |
| --- | --- | --- | --- |
| | LHS | Acc := (LHS) | |
| | RHS' | B := Acc, Acc := (RHS) | change first LOAD to BLOAD
| | OPB ADD | Acc := Acc + B | |

However, replace a LOAD instruction to BLOAD in the case that the LOAD is the first instruction to change Acc in RHS sequence (which is often the case in the compiler output), and rename it RHS'.  
(If not, an additional instruction is to place "BLOAD 0" before RHS sequence.)

Though BLOAD and BSLOAD, (the latter is related to shift operations), are the only two of basic instructions to change Register (B), they enable various operations in combination with OPB.

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD X | B := Acc, Acc := X | |
| OPB BLOAD | (Acc, B) := (B, Acc) | swap Acc <=> B |
| BSLOAD X | B := 1 << Acc, Acc := X | used for shift operation |
| OPB BSLOAD | (Acc, B) := (B, 1<<Acc) | used for shift operation |
| LOAD X | Acc := X | |
| OPB LOAD | Acc := B | |

No instruction enables assigning Register (B) either an immediate value as "B := X" or "B := Acc" directly with no change to the accumulator, however, the combination of two instructions with OPB realizes the same effects.

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD X | B := Acc, Acc := X | |
| OPB BLOAD | swap Acc <=> B | finally, B := X |

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD 0 | B := Acc, Acc := 0 | |
| OPB LOAD | Acc := B | finally, B := Acc |

## OpCode Table

Each OpCode consists of five bits, having an instruction assigned as follows.

| OpCode | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0x00 | LOAD | SWAP/SHIFT | BLOAD | BSLOAD | ADD | AND | XOR | OR |
| 0x08 | PUSH/OUT | POP/IO | PUT | PUTS | RSUB | JEQ | JNE | JUMP |
| 0x10 | UGT | ULT | IGT | ILT | SUB | MUL | SAR | SHR |
| 0x18 | custom0 | custom1 | custom2 | custom3 | custom4 | custom5 | custom6 | OPB/HALT |

The table shows the basic instruction set of ReLM architecture except the reserved codes assigned from custom0 to custom6.

SWAP/SHIFT is an example of instructions with the same assigned code but to bring completely different operations with or without OPB instruction.

SWAP is an instruction to implement [atomic swap](https://en.wikipedia.org/wiki/Linearizability#Primitive_atomic_instructions).  
Since it makes no meaningful operation in combination with OPB, it assigns "Acc := 1 << Acc", an operation requiring no operand, to "OPB SHIFT".

OPB/HALT indicates that it will be interpreted as a HALT instruction to stop operation if OPB instruction code is specified again in the operand of OPB.

PUSH/OUT and POP/IO are instructions related to I/O ports, but when [FIFO](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics)) is specified as a device, the [mnemonics](https://en.wikipedia.org/wiki/Assembly_language#Opcode_mnemonics_and_extended_mnemonics) PUSH and POP are assigned to distinguish them for ease of understanding.

## Binary Operation

ReLM's basic instructions support the following logical operations.

| Code | Action |
| --- | --- |
| AND X | Acc := Acc & X |
| OPB AND | Acc := Acc & B |
| XOR X | Acc := Acc ^ X |
| OPB XOR | Acc := Acc ^ B |
| OR X | Acc := Acc \| X |
| OPB OR | Acc := Acc \| B |

Since basic instructions often perform the same operation regardless of the presence or absence of OPB, following instructions are expressed by OpCode (mnemonic) with implicit operand XB which means X or B.

| OpCode | Action |
| --- | --- |
| AND | Acc := Acc & XB |
| XOR | Acc := Acc ^ XB |
| OR | Acc := Acc \| XB |

Addition and subtraction operations are denoted as follows.

| OpCode | Action |
| --- | --- |
| ADD | Acc := Acc + XB |
| SUB | Acc := Acc - XB |
| RSUB | Acc := XB - Acc |

Multiplication instructions are denoted as follows and also applied to shift operation.

| OpCode | Action | Comment |
| --- | --- | --- |
| MUL | Acc := Acc * XB | used for shift left |
| SHR | Acc := rev(rev(Acc) * XB) | used for logical shift right |
| SAR | Acc := rev(rev(Acc ^ sign) * XB) ^ sign | used for arithmetic shift right |
| | rev( ) means bit reverse | |

For shift operation, binary multiplier is employed instead of [barrel shifter](https://en.wikipedia.org/wiki/Barrel_shifter) to downsize circuits.

To implement a shift operation using a multiplier, firstly, the shift amount is to be converted to a power of 2 and then multiplied. (if the shift amount is a constant value, it is convertible at compile time)

In the case of a right shift, the procedure is to reverse the bit order and multiply the bits, and then to reverse the bit order again.

Placing "MUL 8" is enough for left shift (Acc << 3), as an example, but right shift (Acc >> 3) requires either "SHR 8" or "SAR 8", respect to the integer type is unsigned or signed.

SHIFT instruction enables converting the shift amount to a power of 2.  
But PUTS and BSLOAD instructions also enables transferring the result to the operand along with the conversion, resulting in downsizing the code amount.

| OpCode | Action | Comment |
| --- | --- | --- |
| OPB SHIFT | Acc := 1 << Acc | used for shift operation |
| PUTS | Operand\[XB] := 1 << Acc | used for shift operation |
| BSLOAD | B := 1 << Acc, Acc := XB | used for shift operation |

## Transfer Instruction

The following instructions execute writing memory or transferring values from Acc to an operand.

| OpCode | Action | Comment |
| --- | --- | --- |
| PUT | Operand\[XB] := Acc | |
| PUTS | Operand\[XB] := 1 << Acc | used for shift operation |

When transfers to the same memory bank concur before completion, it may cause the penalty of a lap of CPUs' ring, depending on the hardware implementation.

In addition, from other threads, memory update appears like delayed by up to a lap of CPUs' ring which requires caution.

In the case of having Register (B) as the operand instead of usual Operand (X), BLOAD and BSLOAD instructions correspond to PUT and PUTS.

These instructions assume simultaneous execution along with LOAD instruction to assign an immediate value to the accumulator Acc.

| OpCode | Action | Comment |
| --- | --- | --- |
| LOAD | Acc := XB | |
| BLOAD | B := Acc, Acc := XB | |
| BSLOAD | B := 1 << Acc, Acc := XB | used for shift operation |

These instructions execute a transfer to Register (B) with no penalty as PUT instruction may cause.

## Jump Instructions and Peeking to Operands

Jump instructions to change the program counter PC (of the running thread) are as follows.

| OpCode | Action | Comment |
| --- | --- | --- |
| JUMP | PC := XB | unconditional jump |
| JEQ | if (Acc == 0) PC := XB | conditional jump |
| JNE | if (Acc != 0) PC := XB | conditional jump |
| (getter) | if (PC.msb == 1) PC := Acc, Acc := X | get operand value |

The flow control instructions are an unconditional JUMP, and conditional JEQ and JNE to branch dependently on whether the accumulator Acc is 0 or not.

When the most significant bit (MSB) of JUMP instruction's destination address (assigned value to PC) is set (to 1), the running thread enters [getter](https://en.wikipedia.org/wiki/Mutator_method) mode to peek to an arbitrary operand.

In the getter mode, the instruction at the destination is not executed but its operand value is assigned to Acc.  
Then, the running thread jumps to the address pointed by the previous value of Acc had before the assignment, and returns from the getter mode.

On the software side, placing the return address to Acc in advance and then jumping to the address where MSB is set to 1 enables obtaining the operand value of the instruction at that address.

As a normal instruction execution without flow control increments the program counter PC, so the lower bits of the address keep corresponding to the accessible memory bank.

Change of PC by the flow control such as JUMP instruction may results in temporarily shifting this correspondence, and then the running thread loses sight of the memory bank to be executed.

In such a case, instruction execution has to be suspended until the access to the memory bank of the next instruction restores.

In other words, executing JUMP instruction results in latency up to a lap of CPUs' ring at maximum.

However, this latency (= 1 + penalty) is predictable.  
In case of jumping to the bank next to JUMP instruction, the latency is 1 with no penalty, while jumping to the same bank as JUMP instruction brings the worst latency of a lap of CPUs' ring.

This cost is controllable to some extent at compile time, resulting in optimization to reduce the penalty as much as possible at code placement.

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
