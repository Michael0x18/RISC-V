`default_nettype none
/*
 * Branch predictor cache
 * Used to implement a 2 bit counter
 * Highly specialized, unlikely to be re-used outside of this
 *
 * This module consists of two parts:
 * 1) Read module -- intended to be fed from the fetch stage, will have data
 * ready by end of decode stage. Only needs PC.
 *
 * 2) Branch update status -- Fed from later in the pipeline. Will adjust 
 * the branch state as needed.
 *
 * Overall, this is not an actual cache:
 *  - does not check/store tag bits
 *  - no concept of write allocate / no write allocate
 *  - no concept of write through / back
 *  - does not use blocks
 *  - does not actually make use of spatial locality
 *
 *  etc
 */

module bpcache(
	input wire clk,
	input wire rst_n,
	
	input wire[7:0] addr,	// Lowest 8 bits of address of branch instruction
	output reg branch, // Active high branch signal. Asserted high if the predictor thinks a branch should take place.
	
	input wire[7:0] w_addr,	// Lowest 8 bits of address of branch instruction to update
	input wire[7:0] did_branch, // Active high if the specified branch instruction did actually branch.
	input wire we			// Active high WE
);

reg[1:0] arr[0:255]; // Backing cache for the branch predictor
// Note: 4 states:
// 00 - strong not taken
// 01 - weak not taken
// 10 - weak taken
// 11 - strong taken

// Read out
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		branch <= 1'b0;
	else
		branch <= arr[addr][1]; // Return MSB of the branch cache location
end

int i;
// Write back
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		for (i = 0; i < 255; ++i) begin
			arr[i] <= 2'b01;
		end
	end else if(we) begin
		if(did_branch) begin
			// Increment and saturate
			arr[addr] <= arr[addr]==2'b11 ? 2'b11 : arr[addr]+1;
		end else begin
			// Decrement and saturate
			arr[addr] <= arr[addr]==2'b00 ? 2'b00 : arr[addr]-1;
		end
	end
end

endmodule
`default_nettype wire
