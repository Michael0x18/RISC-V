// TODO for Aug 31 weekend:
// - Write immediate decoder
// - Fan out the rest of the signals
// - Poison!! IMPORTANT TO HAVE

`default_nettype none
module decode(
	input wire clk,
	input wire rst_n,

	input wire[31:0] InstrD, // raw instruction binary, comes from fetch stage
	input wire[31:0] PCD, // Current program counter, from fetch
	input wire[31:0] PCplus4D, // Current program counter, plus 4 (next instruction w/o branch), from fetch
	input wire[4:0] A3, // Destination register, from write back stage
	input wire[31:0] WD3, // Data to write, from write back stage
	input wire WE3, // Write enable, from write back stage

	output wire RegWriteD,	// Write enable for register file
	output wire[1:0] ResultSrcD, // Source for result mux at the write back stage
	output wire MemWriteD, // Memory write enable
	output wire JumpD,	// Jump enable
	output wire BranchD,	// Branch enable
	output wire[2:0] ALUControlD,	// ALU control signal
	output wire ALUSrcD,	// ALU source signal (0 = register, 1 = immediate)

	output reg[31:0] RD1,	// Destination register 1
	output reg[31:0] RD2,	// Destination register 2
	output reg[31:0] PCD_out,	// Program counter
	output reg[4:0] Rs1D,
	output reg[4:0] Rs2D,
	output reg[4:0] rdD,
	output reg[31:0] ImmExtD,
	output reg[31:0] PCPlus4D_out
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [11:0] I_imm;
logic [6:0] SB_imm1;
logic [4:0] SB_imm2;
logic [19:0] UJ_imm;

// Run PCPlus4D straight through decode stage
always @(posedge clk) begin
	PCPlus4D_out <= PCplus4D;

	// Breakdown Module
	Breakdown breakdown (
		.Instruction(InstrD),
		.opcode(opcode),
		.rs1(Rs1D),
		.rs2(Rs2D),
		.rd(rdD),
		.funct3(funct3),
		.funct7(funct7),
		.I_imm(I_imm),
		.SB_imm1(SB_imm1),
		.SB_imm2(SB_imm2),
		.UJ_imm(UJ_imm)
	);

	// Control Unit Module
	ControlUnit controlunit (
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.I_imm(I_imm),
		.SB_imm1(SB_imm1),
		.SB_imm2(SB_imm2),
		.UJ_imm(UJ_imm),

		.RegWriteD(RegWriteD),
		.ResultSrcD(ResultSrcD),
		.MemWriteD(MemWriteD),
		.JumpD(JumpD),
		.BranchD(BranchD),
		.ALUControlD(ALUControlD),
		.ALUSrcD(ALUSrcD),
		.ImmExtD(ImmExtD)
	);


end

endmodule /*decode*/
`default_nettype wire
