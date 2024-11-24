/*
 * Decode stage for ATLAS RV32I core
 * Note: ECALL and EBREAK instructions are currently not supported
 * We have plans to support using ECALL for traps. However EBREAK will most
 * likely never make it into the final designs.
 */

`default_nettype none
module decode(
	input logic clk,
	input logic rst_n,

	input wire[31:0] InstrF,	// raw instruction binary, comes from fetch stage/
	input wire[31:0] PCF,		// Current program counter, from fetch/
	input wire[31:0] PCplus4F, // Current program counter, plus 4 (next instruction w/o branch), from fetch/
	input wire branch_predicted_taken_in,	// Branch taken signal, from fetch stage. This is from branch_prediction/
	input wire[31:0] branch_target_in,	// Predicted branch target address, from fetch stage. This is accurate unless uses register/
	input wire mstall_n_in,		// Stall signal/

	output wire[31:0] instruction_out,///
	output wire[31:0] PC_out,///
	output wire[31:0] PCplus4_out,///
	output wire branch_predict_out,///
	output wire[31:0] branch_target_predict_out,///

	output wire[6:0] opcode,	// Opcode field/
	output wire[2:0] funct3,
	output wire[6:0] funct7,
	output wire[4:0] RD,		// Destination register/
	output wire[4:0] RS1,		// Source Register 1/
	output wire[4:0] RS2,		// Source Register 2/

	output wire RegWriteD,		// Write enable for register file/
	output wire MemWriteD,		// Memory write enable/
	output wire MemReadD,		// Memory read enable/
	
	output wire IsJumpD,		// High if this is a branch instruction/
	output wire IsBranchD,		// High if this is a jump instruction/

	output logic[3:0] alu_op,	// OP for the ALU to use
	output logic AS1,			// ALU source 1: 0: Register RS1, 1: PC
	output logic AS2,			// ALU source 2: 0: Register RS2, 2: IMM

	output wire[31:0] ImmExtD,	// Extended immediate value/

	output wire[1:0] ResultSrcD		// 0: ALU output, 1: Memory, 2: PC plus 4
);

localparam NOP = 32'h33;

// Localparams for Opcodes
localparam OP_ARITH  =7'b0110011;
localparam OP_ARITHI =7'b0010011;
localparam OP_LOAD   =7'b0000011;
localparam OP_STORE  =7'b0100011;
localparam OP_BRANCH =7'b1100011;
localparam OP_JAL    =7'b1101111;
localparam OP_JALR   =7'b1100111;
localparam OP_LUI    =7'b0110111;
localparam OP_AUIPC  =7'b0010111;
localparam OP_ECALL  =7'b1110011;
localparam OP_EBREAK =7'b1110011;

// localparams for ImmSrc values
localparam TYPE_R =3'b111; // Unused. No immediate here.
localparam TYPE_I =3'b000;
localparam TYPE_S =3'b001;
localparam TYPE_B =3'b010;
localparam TYPE_J =3'b011;
localparam TYPE_U =3'b100;
localparam TYPE_N =3'bxxx; // Don't care, TYPE NONE

localparam ALU_INVL = 4'b0000; // Invalid. Put DEADBEEF as the ALU output
localparam ALU_ADD  = 4'b0001; // Add 
localparam ALU_SUB  = 4'b0010; // Subtract
localparam ALU_XOR  = 4'b0011; // XOR
localparam ALU_OR   = 4'b0100; // Normal OR
localparam ALU_AND  = 4'b0101; // AND
localparam ALU_SLL  = 4'b0110; // Logical left shift : note on shifts: will use lower 5 bits only
localparam ALU_SRL  = 4'b0111; // Logical right shift
localparam ALU_SRA  = 4'b1000; // Arith right shift
localparam ALU_SLT  = 4'b1001; // Set less than
localparam ALU_SLTU = 4'b1010; // Set less than unsigned



/*==================FLOP INPUTS====================*/
	reg[31:0] instruction;
	assign instruction_out = instruction;
	reg[31:0] pc;
	assign PC_out = pc;
	reg[31:0] pcplus4;
	assign PCplus4_out = pcplus4;
	reg branch_predicted_taken;
	assign branch_predict_out = branch_predicted_taken;
	reg[31:0] branch_target;
	assign branch_target_predict_out = branch_target;
	reg mstall_flop;

	// Reset condition: NOP
	// This will ensure that our processor starts up in a known state and does
	// not execute any incorrect instructions during the boot sequence.
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			instruction <= NOP;
		end else begin
			instruction <= InstrF;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			pc <= 32'h0;
		end else begin
			pc <= PCF;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			pcplus4 <= 32'h0;
		end else begin
			pcplus4 <= PCplus4F;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			branch_predicted_taken <= 1'b0;
		end else begin
			branch_predicted_taken <= branch_predicted_taken_in;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			branch_target <= 32'h0;
		end else begin
			branch_target <= branch_target_in;
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			mstall_flop <= 1'b0;
		end else begin
			mstall_flop <= mstall_n_in;
		end
	end

/*=================================================*/

	/*
	 * The following signals come straight from the instruction.
	 * RISC-V is nice in that they're always in the same spot.
	 * Just break them out with simple assign statements (Except RS1)
	 */
	assign RD = instruction[11:7];
	assign RS1 = (opcode == OP_LUI) ? 5'b0 : instruction[19:15]; // Special exception cause for this we want it to be x0 always
	assign RS2 = instruction[24:20];
	assign opcode = instruction[6:0];
	assign funct3 = instruction[14:12];
	assign funct7 = instruction[31:25];

	/*
	 * Determine where the immediate field comes from. This is based off of
	 * the opcode.
	 */

	wire[2:0] ImmSrc;
	assign ImmSrc = 
			opcode == OP_ARITHI || opcode == OP_LOAD ||
			  opcode == OP_JALR || opcode == OP_ECALL ||
			  opcode == OP_EBREAK ? TYPE_I :
			opcode == OP_STORE ? TYPE_S :
			opcode == OP_BRANCH ? TYPE_B : 
			opcode == OP_JAL ? TYPE_J :
			opcode == OP_LUI || opcode == OP_AUIPC ? TYPE_U :
			TYPE_N;
		

	/*
	 * Extended immediate comes from this functional unit. This will decide
	 * based on the Immediate Source, which comes from the opcode
	 */
	immExtend ie(
		.instr(instruction),
		.immSrc(ImmSrc),
		.immext(ImmExtD)
	);

	/*
	 * Write enable to the register file
	 * This controls whether or not the RD field will actually be used in the
	 * write back stage (register file lives partially in execute and write
	 * back pipeline stages)
	 *
	 * ARITH, ARITHI, LOAD, JAL, JALR, LUI, AUIPC
	 * are the instructions that will make this high. Else low.
	 */
	assign RegWriteD = 
		opcode == OP_ARITH || opcode == OP_ARITHI || opcode == OP_LOAD || opcode == OP_JAL ||
		opcode == OP_JALR || opcode == OP_LUI || opcode == OP_AUIPC;
	
	/*
	 * Mem read/write.
	 * Each has a single class of instructions that can do it
	 */
	assign MemWriteD = opcode == OP_STORE;
	assign MemReadD = opcode == OP_LOAD;

	/*
	 * High if this is a jump instruction
	 */
	assign IsJumpD = opcode == OP_JAL || OP_JALR;

	/*
	 * Conditional branch
	 */
	assign IsBranchD = opcode == OP_BRANCH;

	/*
	 * Result Source.
	 * This is from the ALU unless it's a load (Not all will be used)
	 * Those come straight from memory, after the conclusion of the
	 * execute stage
	 *
	 * Or, unless it's a JAL or JALR instruction. Those we need to do PC+4
	 * for. And that can't be done with the ALU since that will be used for
	 * the PC + IMM or rs1 + IMM parts.
	 */
	assign ResultSrcD = (opcode == OP_LUI) ? 2'b01 : (opcode == OP_JAL || opcode == OP_JALR) ? 2'b10 : 2'b00;

	/*
	 * Assign the ALU op
	 */
	always_comb begin
		alu_op = ALU_INVL;
		AS1 = 0;
		AS2 = 0;
		case (opcode)
		OP_ARITH, OP_ARITHI: begin
			AS2 = ~opcode[5]; // Identify OP_ARITHI
			case (funct3)
			3'h0: alu_op = funct7[1] ? ALU_SUB : ALU_ADD;
			3'h4: alu_op = ALU_XOR;
			// TODO fill in the rest of this. This should be all that's left
			// for decode

			// Over here, do the ALU operations for arithmetic instructions.
			// Both immediate and non immediate varieties are done here.

			endcase
		end
		OP_LOAD, OP_STORE: begin
			// Load/store instructions use the ALU to compute rs1 + imm for use as
			// the address of the load/store
			alu_op = ALU_ADD;
			AS1 = 0;
			AS2 = 1;
		end
		OP_BRANCH: begin
			// This doesn't use the ALU. There's a dedicated branch unit in
			// the execute stage.
		end
		OP_JAL, OP_AUIPC: begin
			// Do PC + imm
			alu_op = ALU_ADD;
			AS1 = 1; // PC
			AS2 = 1; // IMM
		end
		OP_JALR, OP_LUI: begin
			alu_op = ALU_ADD;
			AS1 = 0; // Fine to use this cause x0 is forced to 0 on OP_LUI
			AS2 = 1;
		end
		endcase
	end


endmodule /*decode*/
`default_nettype wire
