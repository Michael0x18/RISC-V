module fetch_tb();

reg clk;
reg rst_n;

wire branch_prediction;

wire[31:0] instruction;
wire[31:0] PC_f;
wire[31:0] PC_fp4;
wire[31:0] branch_target;

fetch f(
	.rst_n(rst_n),
	.clk(clk),
	.mispredict(1'b0),
	.override_addr(32'b0),
	.mstall(1'b0),
	.bp_w_addr(8'b0),
	.bp_did_branch(1'b0),
	.bp_we(1'b0),
	.branch_prediction(branch_prediction),
	.instruction(instruction),
	.PC_f(PC_f),
	.PC_fp4(PC_fp4),
	.branch_target(branch_target),
	.L2_block_read('b0),
	.L2_addr_read('b0),
	.L2_stall('b0)
);

initial begin
	int i = 0;
	clk = 0;
	rst_n = 0;

	@(negedge clk);
	@(negedge clk);
	rst_n = 1'b1;
	for(i = 0; i < 100; ++i)
		@(negedge clk);

	$stop();
end

always #5 clk = ~clk;





endmodule
