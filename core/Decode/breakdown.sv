`default_nettype none
module Breakdown (
	input wire [31:0] instruction,
	output wire [6:0] op,
	output wire [2:0] funct3,
	output wire [6:0] funct7,
	output wire [4:0] rs1,
	output wire [4:0] rs2,
	output wire [4:0] rd
);

assign op <= instruction[6:0];
assign funct3 <= instruction[14:12];
assign funct7 <= instruction[31:25];
assign rs1 <= instruction[19:15];
assign rs2 <= instruction[24:20];
assign rd <= instruction[11:7];

endmodule;
`default_nettype wire