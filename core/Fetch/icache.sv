`default_nettype none
module icache(
	input wire clk,											// Clock
	input wire rst_n,										// Global active low reset signal

	input wire[31:0] addr,									// The address to read from
	output wire stall,										// High if the cache should stall
	output wire[31:0] out,									// Data output by the cache

	input wire[255:0] L2_block_read,						// Used to read from L2
	input wire L2_stall,									// Held high if L2 is busy
	output wire[31:0] L2_addr_readaddr,						// Address to read from L2
	output wire[31:0] L2_addr_re							// Read enable for L2 cache
);

wire[21:0] tag_read;										//  Tag, parsed from the input address
wire set_read;												//  Set, parsed from the input address
wire block_read;											//Block, parsed from the input address


assign tag_read = addr[31:10];
assign set_read = addr[9:5];
assign block_read = addr[4:0];


// There are 4 ways, each with 32 cachelines of size 256 bytes
reg[255:0] cachelines[0:31][0:3];

// Each cacheline has a valid bit
reg[31:0] valid[0:3];

// Each cacheline has a tag too
reg[21:0] tags[0:31][0:3];

// You will always read some kind of data from the cache, so no read enable is
// needed on the instruction cache side of things. If the pipeline is stalled
// on memory, it will continue to read the same address, keeping it active in
// the LRU state
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		
	end
end




// TODO make this actually not a dummy cache

//assign out=32'b0000000_00000_00000_000_00000_0110011;

/*reg[31:0] tmp;
reg i;

reg s;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		tmp<= 32'b0000000_00000_00000_000_00000_0110011;
		i<=1'b0;
		s<=1'b0;
	end else begin
		tmp<= addr | 32'h8000;
		if(addr & 32'b100) begin
			i <= ~i;
			if(i) begin
				s <= 1'b0;
			end else begin
				s <= 1'b1;
			end
		end
	end
end

assign out=tmp;
assign stall=s;
*/
endmodule
`default_nettype wire
