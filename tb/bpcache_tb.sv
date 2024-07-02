module bpcache_tb();
reg clk;
reg rst_n;

reg[7:0] addr;
wire branch;

reg[7:0] w_addr;
reg did_branch;
reg we;

int i;
int j;

reg[1:0] dbg;
reg dbg2;

bpcache bp(
	.clk(clk),
	.rst_n(rst_n),
	.addr(addr),
	.branch(branch),
	.w_addr(w_addr),
	.did_branch(did_branch),
	.we(we)
);


always @(addr, bp.arr[addr]) begin
	dbg<=bp.arr[addr];
	dbg2<=dbg[1];
end

initial begin
	$dumpfile("test.vcd");
	$dumpvars(0, clk, addr, w_addr, did_branch, we, branch, dbg, dbg2);
end

initial begin
	clk=1'b0;
	rst_n = 'b0;
	w_addr = 'b0;
	did_branch = 1'b0;
	we = 1'b0;

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

	// Start branches
	@(negedge clk);
	// Take a branch at every location. This should switch to the weak taken
	// state
	
	for(i = 0; i < 255; ++i) begin
		// Attempt to write there
		w_addr = i;
		did_branch = 1'b1;
		we = 1'b1;
		@(negedge clk); // Let it update
		we = 1'b0;
		// Need to wait another clock cycle since we have sync reads
		addr = i;
		@(negedge clk);
		if(branch !== 1'b1) begin
			$display("Branch did not correctly move to weak taken state %x", bp.arr[i][1]);
			$finish();
		end

		// Now unbranch it
		did_branch = 0;
		we = 1'b1;
		@(negedge clk);
		we = 1'b0;
		@(negedge clk);
		if(branch !== 1'b0) begin
			$display("Branch did not correctly move to weak not taken state %x", bp.arr[i][1]);
			$finish();
		end
		
	end
	
	

	$display("Yahoo! All tests passed!");
	$finish();
end

always #5 clk = ~clk;



endmodule
