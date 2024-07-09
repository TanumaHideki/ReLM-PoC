# ReLM Instruction Set

ReLM architecture boasts the below-mentioned features;

* No need for a complex access arbitration mechanism
* Good operability in using shared memory
* Availability for relatively small systems

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

Though BLOAD(X) and BSLOAD(X), (the latter is related to shift operations), are the only four of basic instructions to change Register (B), they enable various operations in combination with OPB.

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD X | B := Acc, Acc := X | |
| OPB BLOAD | (Acc, B) := (B, Acc) | swap Acc <=> B |
| OPB BLOADX | B := Acc | keep Acc, only with OPB |
| BSLOAD X | B := 1 << Acc, Acc := X | used for shift operation |
| OPB BSLOAD | (Acc, B) := (B, 1<<Acc) | used for shift operation |
| OPB BSLOADX | B := 1<<Acc | keep Acc, only with OPB |
| LOAD X | Acc := X | |
| OPB LOAD | Acc := B | |

No instruction enables assigning an immediate value to the Register (B) as "B := X", however, the combination of two instructions with OPB realizes the same effects.

| Code | Action | Comment |
| --- | --- | --- |
| BLOAD X | B := Acc, Acc := X | |
| OPB BLOAD | swap Acc <=> B | finally, B := X |

## OpCode Table

Each OpCode consists of five bits, having an instruction assigned as follows.

| OpCode | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0x00 | LOAD | SWAP/SHIFT | BLOAD BLOADX | BSLOAD BSLOADX | ADD | AND | XOR | OR |
| 0x08 | PUSH/OUT | POP/IO | PUT | PUTS | RSUB | JEQ | JNE | JUMP |
| 0x10 | UGT | ULT | IGT | ILT | SUB | MUL | SHR | SAR |
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

Placing "MUL 8" is enough for left shift (Acc << 3), as an example, but right shift (Acc >> 3) requires either "SHR 8" or "SAR 8" according to the integer type of unsigned or signed.

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

In addition, from other threads, memory update appears delayed by up to a lap of CPUs' ring which requires caution.

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
Then, the running thread jumps to the address pointed by the previous value of Acc before the assignment, and returns from the getter mode.

On the software side, placing the return address to Acc in advance and then jumping to the address where MSB is set to 1 enables obtaining the operand value of the instruction at that address.

As a normal instruction execution without flow control increments the program counter PC, so the lower bits of the address keep corresponding to the accessible memory bank.

Change of PC by the flow control such as JUMP instruction may result in temporarily shifting this correspondence, and then the running thread loses sight of the memory bank to be executed.

In such a case, instruction execution has to be suspended until restoring the access to the memory bank of the next instruction.

In other words, executing JUMP instruction results in latency up to a lap of CPUs' ring at maximum.

However, this latency (= 1 + penalty) is predictable.  
In case of jumping to the bank next to JUMP instruction, the latency is 1 with no penalty, while jumping to the same bank as JUMP instruction brings the worst latency of a lap of CPUs' ring.

This cost is controllable to some extent at compile time, resulting in optimization to reduce the penalty as much as possible at code placement.

## Comparison Instruction

Comparison instruction is to calculate conditions to construct more complex branches.

While conforming to LLVM IR's [icmp](https://llvm.org/docs/LangRef.html#icmp-instruction), the instruction sets exclude conditions with the equal sign (e.g. greater __or equal__), assuming logic inversion at the compile time.

| OpCode | Action | Comment |
| --- | --- | --- |
| UGT | Acc := (Acc > XB) ? 1 : 0 | unsigned greater than |
| ULT | Acc := (Acc < XB) ? 1 : 0 | unsigned less than |
| IGT | Acc := (Acc > XB) ? 1 : 0 | signed greater than |
| ILT | Acc := (Acc < XB) ? 1 : 0 | signed less than |

## I/O Access

Instructions related to I/O access are as follows.

| OpCode | Action |
| --- | --- |
| PUSH/OUT | port(Acc) <= XB |
| | if (retry) PC := PC else ++PC |
| POP/IO | port(XB) <= Acc |
| | if (retry) PC := PC else ++PC, Acc := result |

PUSH/OUT only outputs the value to the port but not receiving the result.  
The port number is specified by Acc, and the output value is specified by the operand (XB).

This instruction is on the assumption of continuous data output to the same port, enabling to receive retry request instead of accepting a return value from the device related to the port.

If the device is a built-in FIFO, it performs retries while the buffer is full.

POP/IO receives the result along with outputting the value.  
The port number is specified by Operand (XB), while assigning both input and output values to Acc.

This instruction also allows a retry upon a request from the device, enabling to repeat access with the same output value, since retry brings no update to Acc.

If the device is a built-in FIFO, the least significant bit (LSB) of the output value serves as the readout request flag.  
If the readout request is 0, the return value, depending on the buffer status, will be 1 if the buffer is not empty, and will be 0 if it is empty.  
If the readout request is 1, the first value will be read if the buffer is not empty, but if the buffer is empty, it will cause repeating retries until the buffer is not empty.  
The MSB of the output value is a special command, once set to 1, it fixes readout request to 1 from the setting onwards regardless of the output value.

If different threads access the same port at the same time, the logical OR of all output values is sent to the device.

For example, if thread A executes "PUSH 1" to a FIFO port, and at the same time thread B executes "PUSH 2" to the same FIFO port, the logical OR value (1 | 2) = 3 will be input.

However, even though assigned to the same port number, the PUSH/OUT port and POP/IO port are treated as completely different ports, causing no such interference.

Particularly, executing PUSH and POP instruction for the same FIFO by  different threads will cause no trouble, as is a very effective inter-thread communication tool.

## Exclusion Control

Lazy writeback to an operand due to PUT instruction is executed along with the readout of the operand at instruction fetch, so writes and reads to the same address often conflict.

This case recognizes the written-in value as the latest and so employs it as the operand, while discarding the value read out from the memory.

Retrieving a value from the memory before overwriting can easily realize [atomic swap](https://en.wikipedia.org/wiki/Linearizability#Primitive_atomic_instructions).

SWAP instruction is to intentionally retrieve this old value output from the memory, but atomic swap is achievable by combination of PUT and SWAP instructions as shown below.

| Address | Code | Action |
| --- | --- | --- |
| | PUT Atomic: | atomic_X := Acc |
| Atomic: | SWAP atomic_X | Acc := old_X |

The atomic swap serves as building blocks to construct concurrency control objects such as [critical sections](https://en.wikipedia.org/wiki/Critical_section), [mutexes](https://en.wikipedia.org/wiki/Lock_(computer_science)) and thread pools.

## Custom Extension Instructions

The basic instructions are yet to support integer division, floating point, etc., enabling to extend these functions as custom instructions.

HDL code for extension shown below is an example of instructions implemented to support integer division.

Just linking a Verilog HDL module helps add instructions so easily and enables compact circuit implementation by sharing multiplier circuit with the basic instructions.

Additionally, since Custom register (C) dedicated to the custom instructions is available as a payload, it is also possible to implement pipeline processing that spans multiple stages while retaining the internal state.

In the example below, two-words-length Custom register (C) is allocated.

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
