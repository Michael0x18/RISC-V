

`default_nettype none
module execute(
	input wire clk,
	input wire rst_n,

	input wire			RegWrite,	// High if the register file should be written to
	input wire[1:0]		ResultSrc,	// Determines where the result should go. Passed directly to write back stage
	input wire			MemWrite,	// Mem write enable. Not used here
	input wire			MemRead,	// Mem read enable. Not used here
	input wire			Jump,		// Jump enable
	input wire			Branch,		// Branch enable
	input wire[2:0]		ALUControl,	// Control signal for the ALU
	input wire			ALUSrc,		// ALU source signal. High to use immediate

	input wire[31:0]	PC,			// Program counter
	input wire[4:0]		RS1,		// Register source signal
	input wire[4:0]		RS2,		// Register source signal
	input wire[4:0]		RD,			// Register destination signal
	input wire[31:0]	ImmExt,		// Immediate extended
	input wire[31:0]	PCPlus4,	// Incremented PC
	input wire[2:0]		func3,		// FUNC3 field from decode
	input wire[6:0]		func7,		// FUNC7 field from decode
	input wire[6:0]		op,			// OPCODE

	input wire[31:0]	brtarget,	// Branch target

	output wire[31:0]	ALU_RES,	// ALU Result
	output wire[31:0]	PC,
	output wire[31:0]   PCPlus4,
	output wire[31:0]	brtarget,	// Branch target
	output wire			MemWrite,
	output wire			MemRead,
	output wire			Jump,
	output wire			Branch,
	output wire[2:0]	func3,
	output wire[6:0]	func7,
	output wire[6:0]	op,
);

/*
 * There is no need for this particular unit to make provisions for the memory
 * stall, beyond not asserting the register file's write enable. The decode
 * stage will sustain the same outputs, as it will hold state with its inputs.
 * The write back stage will retain the same output as there is no memory 
 * 
 *





endmodule
`default_nettype wire
