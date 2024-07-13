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
	output wire[1:0] ResultSrcD, // 
	output wire MemWriteD, // Memory write enable
	output wire JumpD,
	output wire BranchD,
	output wire[2:0] ALUControlD,
	output wire ALUSrcD,
	output wire[1:0] ImmSRCD,

	output reg[31:0] RD1,
	output reg[31:0] RD2,
	output reg[31:0] PCD,
	output reg[4:0] Rs1D,
	output reg[4:0] Rs2D,
	output reg[31:0] ImmExtD,
	output reg[31:0] PCPlus4D_out
);

// Run PCPlus4D straight through decode stage
always @(posedge clk) begin
	PCPlus4D_out <= PCplus4D;
end

endmodule /*decode*/
`default_nettype wire
