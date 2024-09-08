module Breakdown (
	input wire [31:0] instruction,
	output wire [6:0] opcode,
	output wire [4:0] rs1,
	output wire [4:0] rs2,
	output wire [4:0] rd,
	output wire [2:0] funct3,
	output wire [6:0] funct7,
	output wire [11:0] I_imm,
	output wire [6:0] SB_imm1,
	output wire [4:0] SB_imm2,
	output wire [19:0] UJ_imm,
);

assign opcode <= instruction[6:0];
assign funct3 <= instruction[14:12];
assign funct7 <= instruction[31:25];
assign rs1 <= instruction[19:15];
assign rs2 <= instruction[24:20];
assign rd <= instruction[11:7];
assign I_imm <= instruction[31:20];
assign SB_imm1 <= instruction[31:25];
assign SB_imm2 <= instruction[11:7];
assign UJ_imm <= instruction[31:12];

endmodule;
`default_nettype wire