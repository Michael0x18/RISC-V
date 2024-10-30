module fetch_tb();

reg clk;
reg rst_n;

wire branch_prediction;

wire[31:0] instruction;
wire[31:0] PC_f;
wire[31:0] PC_fp4;
wire[31:0] branch_target;

reg[255:0] L2_data;
wire[31:0] L2_addr;
reg L2_stall;
wire L2_read_en;

reg mstall;

int i;
localparam NOP = 32'h00000033;
localparam BEQ_F_4 = 32'h00000263;
localparam BEW_F_8 = 32'h00000463;

localparam eight32 = 32'h88888888;

// Address to override to
reg[31:0] override_addr;
// Enable for the override
reg mispredict;

fetch f(
	.rst_n(rst_n),
	.clk(clk),
	.mispredict(mispredict),
	.override_addr(override_addr),
	.mstall(mstall),
	.bp_w_addr(8'b0),
	.bp_did_branch(1'b0),
	.bp_we(1'b0),
	.branch_prediction(branch_prediction),
	.instruction(instruction),
	.PC_f(PC_f),
	.PC_fp4(PC_fp4),
	.branch_target(branch_target),
	.L2_block_read(L2_data),
	.L2_addr_read(L2_addr),
	.L2_stall(L2_stall),
	.L2_read_en(L2_read_en)
);

initial begin
	clk = 0;
	rst_n = 0;
	mispredict = 1'b0;

	mstall = 1'b0;

	L2_stall = 1'b1; // Cache starts stalled

	@(negedge clk);
	@(negedge clk);
	rst_n = 1'b1;
	/* BEGIN TESTBENCH */

	// First, check to make sure addr requested is address 0
	if(L2_addr !== 0) begin
		$display("addr was not 0! got %x", L2_addr);
		$stop();
	end
	// Check to ensure it's feeding NOPs
	if(instruction !== NOP) begin
		$display("Wrong NOP! Expected %x got %x", NOP, instruction);
		$stop();
	end
	if(PC_f !== 0) begin
		$display("PC was not 0");
		$stop();
	end

	// Keep stall asserted for another few clocks and ensure it doesn't budge
	
	@(negedge clk);
	if(L2_addr != 0) begin
		$display("addr was not 0! got %x", L2_addr);
		$stop();
	end
	@(negedge clk);
	if(L2_addr != 0) begin
		$display("addr was not 0! got %x", L2_addr);
		$stop();
	end
	@(negedge clk);
	if(L2_addr != 0) begin
		$display("addr was not 0! got %x", L2_addr);
		$stop();
	end

	// Feed it a some data and see it advance to 1, then stall again
	
	L2_data = {32'h0,32'h1,32'h2,32'h3,32'h4,32'h5,32'h6,32'h7};
	L2_stall = 1'b0;

	// Cache setup here has two cycle latency
	@(negedge clk);
	// Still a No-Op
	@(negedge clk);

	// Should be 7 now
	if(L2_read_en !== 1'b0) begin
		$display("L1 still reading from L2 when hit");
		$stop();
	end
	if(instruction !== 7) begin
		$display("Got wrong data");
		if(instruction === NOP) begin
			$display("Still missed L1I");
		end
		$stop();
	end

	@(negedge clk);

	// Now, test other stalls
	mstall = 1'b1;
	@(negedge clk);
	@(negedge clk);
	mstall = 1'b0;
	@(negedge clk);
	@(negedge clk);

	// Branch mispredict test
	override_addr = 964;
	mispredict = 1'b1;
	@(negedge clk);
	mispredict = 1'b0;
	override_addr = 0;
	// We have one bubble. Ensure that there is a NOP inserted
	if(instruction !== NOP) begin
		$display("Did not fetch a NOP on branch mispredict");
		$stop();
	end
	// Ensure that we have gone to the right address ASAP
	@(negedge clk);
	if(PC_f !== 964) begin
		$display("Did not go to right addr");
		$stop();
	end

	i = 0;
	// Wait for a read from L2
	while(L2_read_en !== 1'b1) begin
		i = i + 1;
		@(negedge clk);
		if ( i > 100 ) begin
			$display("Timed out while waiting for read from L2");
			$stop();
		end
	end

	// Check the address
	// It better be trying to get 964
	if(L2_addr !== 964) begin
		$display("Bad read (not override)");
		$stop();
	end
	// Feed it some data
	//                  C        8        4        0         C       8       4       0
	L2_data = {255'h99999999_88888888_77777777_66666666_55555555_44444444_33333333_22222222};

	// Wait until no more NOP
	i=0;
	while (instruction === NOP) begin
		i = i + 1;
		@(negedge clk);
		if ( i > 100 ) begin
			$display("Didn't get actual data here");
			$stop();
		end
	end
	// Check the actual data. It better be the 3. If it's 8 you got the
	// endianness wrong. Fix that.
	if(instruction !== 32'h33333333) begin
		if(instruction === 32'h88888888) begin
			$display ("Wrong endianness. RISC-V uses little endian.");
		end
		$display("Wrong data. This should be 32'h33333333. Got %x", instruction);
		$stop();
	end
	
	// Test reset condition of the CPU
	
	// First need to reset all the control signals so we can observe the
	// passive state. It should just go from zero anyway, and we can just
	// block until we hit a certain address;
	
	L2_data = 256'h90909090_90909090_90909090_90909090_90909090_90909090_90909090_FFFFFFFF; // Give it just all ones

	rst_n = 1'b0; // RESET

	@(negedge clk);

	// Release reset signal
	rst_n = 1'b1;

	i=0;
	// Wait while nop
	while(instruction === NOP) begin
		i = i + 1;
		@(negedge clk);
		if ( i > 100 ) begin
			$display("Frontend did not recover from a RESET signal");
			$stop;
		end
	end

	if(instruction !== 32'hFFFFFFFF) begin
		$display("Did not correctly reset to zero");
		$stop();
	end

	// TODO test the branch predictor
	// I'll let kenneth do this one
	// It should work, since it has its own testbench, however it still needs
	// to be tested as a part of the entire stack

	$display("Yahoo! All tests passed.");

	$stop();
	

end

always #5 clk = ~clk;





endmodule
