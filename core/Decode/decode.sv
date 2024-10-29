// TODO for Aug 31 weekend:
// - Write immediate decoder
// - Fan out the rest of the signals
// - Poison!! IMPORTANT TO HAVE




`default_nettype none
module decode(
	input logic clk,
	input logic rst_n,

	input logic[31:0] InstrF,	// raw instruction binary, comes from fetch stage
	input logic[31:0] PCF,		// Current program counter, from fetch
	input logic[31:0] PCplus4F, // Current program counter, plus 4 (next instruction w/o branch), from fetch
	input logic branch_taken,	// Branch taken signal, from fetch stage
	input logic branch_target,	// Branch target address, from fetch stage
	input logic mstall_n,		// Stall signal

	output logic RegWriteD,		// Write enable for register file
	output logic[1:0] ResultSrcD,// Source for result mux at the write back stage (00 = ALU, 01 = memory, 10 = PC+4)
	output logic MemWriteD,		// Memory write enable
	output logic JumpD,			// Jump enable
	output logic BranchD,		// Branch enable
	output logic[2:0] ALUControlD,	// ALU control signal
	output logic ALUSrcD,		// ALU source signal (0 = register, 1 = immediate)

	output reg[31:0] RD1,		// Destination register 1
	output reg[31:0] RD2,		// Destination register 2
	output reg[31:0] PCD,		// Program counter
	output reg[31:0] ImmExtD,	// Extended immediate value
	output reg[31:0] PCPlus4D	// PC plus 4
);

	logic [6:0] op;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [2:0] immSrc;

	// If stall hold state.
	
	reg[31:0]	InstrF_reg;
	reg[31:0]	PCF_reg;
	reg[31:0]	PCplus4F_reg;
	reg			
	
	// If no operation, pass through



	breakdown bd(
		.Instruction(InstrF),
		.op(op),
		.funct3(funct3),
		.funct7(funct7),
		.rs1(Rs1D),
		.rs2(Rs2D),
		.rd(RdD)
	);

	ControlUnit cu(
		.op(op),
		.funct3(funct3),
		.funct7(funct7),
		.RegWriteD(RegWriteD),
		.ResultSrcD(ResultSrcD),
		.MemWriteD(MemWriteD),
		.JumpD(JumpD),
		.BranchD(BranchD),
		.ALUControlD(ALUControlD),
		.ALUSrcD(ALUSrcD),
		.immSrcD(ImmSrcD)
	);

	immExtend ie(
		.Instr(InstrF[31:7]),
		.immSrc(ImmSrc),
		.immext(ImmExtD)
	);

	registerfile rf(
		.clk(clk),
		.rst_n(rst_n),
		.A1(Rs1D),
		.A2(Rs2D),
		.A3(A3),
		.WE3(RegWriteW),
		.WD3(WD3),
		.RD1(RD1),
		.RD2(RD2)
	);

	assign PCPlus4D = PCplus4F;
	assign branch_taken ? PCD = branch_target : PCD = PCF;

endmodule /*decode*/
`default_nettype wire
