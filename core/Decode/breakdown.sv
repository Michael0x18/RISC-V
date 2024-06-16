`default_nettype none
module breakdown(
	input wire[31:0] instruction,
	
	output wire[6:0] opcode,
	output wire[2:0] funct3,
	output wire[6:0] funct7,
	output wire[4:0] Rs1D,
	output wire[4:0] Rs2D,
	output wire[4:0] RdD,
	output wire[31:0] R_imm,
	output wire[31:0] I_imm,
	output wire[31:0] S_imm,
	output wire[31:0] U_imm,
	output wire[31:0] B_imm,
	output wire[31:0] J_imm
);



endmodule;
`default_nettype wire
