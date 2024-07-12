`default_nettype none
module ALU(
	input wire[2:0] alu_op1, // Connect to funct3 signal from decoder
	input wire[6:0] alu_op2,// Connect to funct7 signal from decoder
	input wire[31:0] s1,    // Source data 1
	input wire[31:0] s2,    // Source data 2
	output logic[31:0] res   // Result -- INFER WIRE
);

wire[3:0] alu_op = {alu_op1,alu_op2[5]};

localparam ALU_ADD  = 4'h0; // 000 0
localparam ALU_SUB  = 4'h1; // 000 1
localparam ALU_XOR  = 4'h8; // 100 0
localparam ALU_OR   = 4'hC; // 110 0
localparam ALU_AND  = 4'hE; // 111 0
localparam ALU_SLL  = 4'h2; // 001 0
localparam ALU_SRL  = 4'hA; // 101 0
localparam ALU_SRA  = 4'hB; // 101 1
localparam ALU_SLT  = 4'h4; // 010 0
localparam ALU_SLTU = 4'h6; // 011 0

wire signed s1s = s1;
wire signed s2s = s2;

always_comb begin
	unique case(alu_op)
	ALU_ADD:
		res = s1 + s2;
	ALU_SUB:
		res = s1 - s2;
	ALU_XOR:
		res = s1 ^ s2;
	ALU_OR:
		res = s1 | s2;
	ALU_AND:
		res = s1 & s2;
	ALU_SLL:
		res = {s1[30:0],1'b0};
	ALU_SRL:
		res = {1'b0, s1[31:1]};
	ALU_SRA:
		res = {s1[31], s1[31:1]};
	ALU_SLT:
		res = s1s<s2s ? 32'b1 : 32'b0;
	ALU_SLTU:
		res = s1<s2 ? 32'b1 : 32'b0;
	default:
		res = 32'hXXXXXXXX;
	endcase
end

endmodule
`default_nettype wire