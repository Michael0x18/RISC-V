module bpcache_tb();
reg clk;
reg rst_n;

reg[7:0] addr;
wire branch;

reg[7:0] w_addr;
reg[7:0] did_branch;
reg we;

int i;
int j;

bpcache bp(
	.clk(clk),
	.rst_n(rst_n),
	.addr(addr),
	.branch(branch),
	.w_addr(w_addr),
	.did_branch(did_branch),
	.we(we)
);

initial begin
	clk=1'b0;
	rst_n = 0;

	@(negedge clk);
	@(negedge clk);

	if(branch!==1'b0) begin
		$display("Branch should be held low on reset");
		$finish();
	end

	@(negedge clk);
	
	// Raise reset condition
	rst_n = 1'b1;

	@(negedge clk);

	for(i = 0; i < 255; ++i) begin
		addr = i;
		@(negedge clk);
		if(branch !== 1'b0) begin
			$display("Branch should not be taken on reset condition");
			$finish();
		end
	end

	$display("Yahoo! All tests passed!");
	$finish();
end

always #5 clk = ~clk;



endmodule
