// TODO for AUG 31 weekend:
// - Fully implement the cache as a meta-cache that can actually be backed by
// any of the following:
// 	 - Dummy cache: Does what it currently does
// 	 - Harvard architecture: Is its own memory
// 	 - Standard Level 1 instruction cache
//
// - Implement the Harvard Arch - write and embed a test program that will use
// the debug instructions to print to the console

`default_nettype none
module fetch(
	// GLOBAL CLOCK AND RESET
	input	wire		rst_n,
	input	wire		clk,
	// Asserted high on branch mispredict
	input	wire		mispredict,
	// Address to override to on mispredict
	input	wire[31:0]	override_addr,
	// Data cache stall signal
	input	wire		mstall,

	// Branch predictor wb signals
	input	wire[7:0]	bp_w_addr,
	input	wire		bp_did_branch,
	input	wire		bp_we,

	// High if the branch was assumed taken
	output	logic		branch_prediction,
	// Instruction data stuff
	output	logic[31:0]	instruction,
	output	logic[31:0]	PC_f,
	output 	logic[31:0]	PC_fp4,
	output	logic[31:0]	branch_target,

	// Pass this stuff through to the L1I cache
	input	wire[255:0]	L2_block_read,
	output	wire[31:0]	L2_addr_read,
	input	wire		L2_stall,
	output  wire		L2_read_en
);

reg mstall_flop;
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		mstall_flop <= 1'b0;
	end else begin
		mstall_flop <= mstall;
	end
end

// Address of current instruction being processed by the fetch stage.
// This is the captured version of the previous clock's next_addr
reg[31:0] curr_addr;

// Instruction cache stall. High if the i cache has experienced a miss
wire istall; // Instruction cache stall

// Loops back to fetch stage - so keep it internal to this
// This holds the next instruction that's going to get fed into the branch
// predictor, the instruction cache, and back into the fetch logic.
logic[31:0] next_addr;

// Branch predictor output
// Used internally to decide whether to assume a branch is taken or not
// depending on other factors.
wire bpout;

// Internal branch predictor
bpcache bp(
	.clk(clk),	// Share clk
	.rst_n(rst_n), // Share rst
	.addr(next_addr[7:0]), // Pass through output of next instruction
	.branch(bpout),

	// Pass through the rest of the inputs to allow the write back stage to
	// update the branch predictor cache. Otherwise it will just default to
	// saying everything is "weak not taken"
	.w_addr(bp_w_addr), .did_branch(bp_did_branch), .we(bp_we)
);

// Temp values for decoded immedates
wire[31:0] j_imm;
wire[31:0] b_imm;

// Instruction data from the instruction cache
wire[31:0] instruction_ic;
// Opcode - used to do early decode of branch instructions
wire[6:0] opcode = instruction_ic[6:0];
// Branch prediction output from the branch predictor, but filtered to only
// include actual branch instructions that we care about (NOTE: indirect
// branches are NOT supported due to a lack of a branch target buffer in the
// branch predictor - we can't know where it's going to branch to because of
// dependencies on the register file.)
wire branch_prediction_extra;

// Opcode == JAL -- Always yes
// Opcode == branch -- Depends
// Otherwise -- No
assign branch_prediction_extra = opcode == 1101111 | ((opcode == 1100011) ? bpout : 1'b0);
wire imm;

// Only JAL uses this j_imm
assign imm = opcode == 1101111 ? j_imm : b_imm;

assign branch_target = imm + PC_f;

// Instruction cache. 
icache ic(
	.clk(clk),
	.rst_n(rst_n),
	.addr(next_addr),
	.out(instruction_ic),
	.stall(istall),

	// Data lines that run out to the level 2 cache
	.L2_block_read(L2_block_read),
	.L2_addr_read(L2_addr_read),
	.L2_stall(L2_stall),
	.L2_read_en(L2_read_en)
);

// Flop the next address of the instruction; it's a combinational signal
// that loops back from the fetch stage, so we need to capture it on posedge
// clk in order to do any work with it.
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		curr_addr<='b0; // Async reset - jump to instruction 0
	else
		curr_addr<=next_addr; // Pass through and capture on posedge clk
end

// Flop the mispredict enable and override address - these are combinational
// outputs from later in the pipeline where branches are actually executed.
// These again need to be captured in order to do real work with them.
reg mispredict_en;
reg[31:0] mispredict_override_addr;
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		mispredict_en <= 1'b0; // On async reset, disable mispredicts so we stay at instruction 0
		mispredict_override_addr = 32'b0;
	end else begin
		mispredict_en <= mispredict;
		mispredict_override_addr = override_addr;
	end
end

logic[31:0] next_addr_tmp;
assign next_addr = {32{rst_n}} & next_addr_tmp;



assign b_imm = { {20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
assign j_imm = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };

// Fetch-stage combinational logic
always_comb begin
	// Default to no branch
	branch_prediction = 1'b0;
	// Program counters to send through pipeline
	// Address of current instruction
	PC_f=curr_addr;
	// +4 for use later with branches
	PC_fp4=curr_addr+4;
	// Insert NO-OP into pipeline
	// ADD x0, x0, x0
	next_addr_tmp=curr_addr; // Assume pipeline stall
	instruction = 32'b0000000_00000_00000_000_00000_0110011;
	if(mispredict_en) begin
		// We have mispredicted in the past; need to correct this.
		// All signals default to zero. Only one we need to change
		// is the next instruction address
		next_addr_tmp=mispredict_override_addr;
		// Override that with the actual address the branch went to
	end else if (istall | mstall_flop) begin
		// If either the instruction cache or the data cache experiences
		// a miss, a stall will occur. In the case of an icache miss, feed
		// no-ops into the pipeline to let the backend run ahead of the
		// frontend. Hold state at the current instruction.
		//
		// In case of a data cache miss, freeze the pipeline. Still feed
		// no-ops, but these will be rejected by the decode stage's pipeline
		// registers. Still allow for this to be overridden by fixing
		// mispredictions.

		// Use default values - not shown here
	end else begin
		// Forward the data from the instruction cache output
		instruction = instruction_ic;
		branch_prediction = branch_prediction_extra;
		if(branch_prediction_extra) begin
			next_addr_tmp = branch_target;
		end else begin
			next_addr_tmp = PC_fp4;
		end
	end
	


end

endmodule
`default_nettype wire
