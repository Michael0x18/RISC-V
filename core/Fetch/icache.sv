/**
 * This file implements the ATLAS core's L1 instruction cache
 * The cache is a 32 entry, two way set associative cache.
 * It uses an internal block size of 256 bits.
 * The output block size is 32 bits.
 * This cache is not byte addressable.
 *
 * S bits = 5
 * b bits = 5
 *
 * This cache is read only
 */




`default_nettype none

module icacheline(
	input wire clk,
	input wire rst_n,

	input wire[31:0] r_addr,
	input wire[31:0] w_addr,
	
	input wire we,

	// High if hit
	output reg hit,
	// Data output from this cache line
	output wire[255:0] data_out,

	input wire[255:0] data_in,
);

	// The data stored in the cache 
	reg[255:0] entries[0:31];

	// high if the cache line is valid
	reg[31:0]	valid;
	reg[21:0]  tags[0:31];


	// Read from this cacheline
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			// On reset, the cache is filled with invalid, unknown, data. This
			// means we need to have a bunch of special cases.
			// We do not hit. The cache has no data in it, so it is a guaranteed
			// miss.
			hit <= 1'b0;
			// The specific data we put out does not matter, but here is a magic
			// debug value. If this shows up anywhere we have a problem
			data_out <= 256'hDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF;
		end else begin
			// Just read this out
			data_out <= entries[r_addr[9:5]];
			hit <= // To determine if we hit the cache or not
				valid[r_addr[9:5]] & // Cache line must be valid and
				tags[r_addr[9:5]] == r_addr[31:10];
		end
	end

	// Write to this cacheline
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			// Nothing is valid
			valid <= 'b0;
		end else if (we) begin
			// Insert tag
			tags[w_addr[9:5]] <= w_addr[31:10];
			// Insert data
			entries[w_addr[9:5]] <= w_data;
		end
	end

endmodule

module icache(
	// Global clock, same as the core clock
	input wire clk,

	// Global reset, when pulled low cache will be initialized
	input wire rst_n,

	// Read address - address used to read *from* the cache
	input wire[31:0] addr,

	// High = stall, low = hit
	output wire stall,

	// Output data
	output wire[31:0] out,

	// Incoming data from the lower level cache
	input wire[255:0] L2_block_read,

	// High = L2 is stalled on main memory
	// Low = L2 hit, data is valid
	input wire L2_stall,

	// Address asserted to read from L2
	output reg[31:0] L2_addr_read,

	// Asserted high if we need to read from the Level two cache
	output reg L2_read_en
);



endmodule
`default_nettype wire
