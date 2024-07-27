module Breakdown (
	output wire[4:0] Rs1D,
	output wire[4:0] Rs2D,
	output wire[4:0] RdD,
	output wire[31:0] I_imm,
	output wire[31:0] S_imm1,
	output wire[31:0] S_imm2,
	output wire[31:0] B_imm1,
	output wire[31:0] B_imm2,
	output wire[31:0] U_imm,
	output wire[31:0] J_imm
);

assign opcode <= instruction[6:0];
assign funct3 <= instruction[14:12];
assign funct7 <= instruction[31:25];
assign Rs1D <= instruction[19:15];
assign Rs2D <= instruction[24:20];
assign RdD <= instruction[11:7];
assign I_imm <= instruction[31:20];
assign S_imm1 <= instruction[31:25];
assign S_imm2 <= instruction[11:7];
assign B_imm1 <= instruction[31:25];
assign B_imm1 <= instruction[11:7];
assign U_imm <= instruction[31:12];
assign J_imm <= instruction[31:12];

endmodule;
`default_nettype wire