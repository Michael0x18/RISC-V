`default_nettype none

module icache_cacheline_tb();

reg clk;
reg rst_n;

reg[31:0] r_addr;
reg[31:0] w_addr;

reg we;

wire hit;

wire[255:0] data_out;

reg[255:0] data_in;

icacheline iDUT(
	.clk(clk), .rst_n(rst_n), .r_addr(r_addr), .w_addr(w_addr), .we(we), .hit(hit), .data_out(data_out), .data_in(data_in)
);

localparam DB32 = 32'hDEADBEEF;
localparam DB64 = {DB32,DB32};
localparam DB128 = {DB64, DB64};
localparam DB256 = {DB128, DB128};

initial begin

	clk = 1'b0;
	rst_n = 1'b0;

	@(negedge clk);

	// Write to address 0 in the cache
	rst_n = 1'b1;
	r_addr = 32'b0;
	w_addr = 32'b0;
	we = 1'b1;
	data_in = DB256;

	@(negedge clk);

	@(negedge clk);

	@(negedge clk);

	$stop();



end


always #5 clk <= ~clk;

endmodule

`default_nettype wire
