/**
 * This file implements the ATLAS core's L1 instruction cache
 * The cache is a 32 entry, two way set associative cache.
 * It uses an internal block size of 256 bits.
 * The output block size is 32 bits.
 * This cache is not byte addressable.
 *
 * S bits = 5
 * b bits = 5 -> 256 bit blocks = 32 byte blocks = 5 b bits. -> 3 block, two
 * byte.
 *
 * This cache is read only
 */
`default_nettype none

/**
 * Chain shifter to trim a raw cache line output to a single 32 bit value.
 * This is rather important, because this can be extended in the future to
 * allow sized access. However I think that functionality is going to be moved
 * into the core's load store unit in the memory stage. There should also be
 * the capability to load shorts and chars, for example.
**/
module icache_chainshifter(
	input wire[255:0] in,
	input wire[2:0] shift,
	output wire[31:0] out
);
wire[127:0] stage1;
wire[63:0] stage2;

assign stage1 = shift[2] ? in[255:128] : in[127:0];
assign stage2 = shift[1] ? stage1[127:64] : stage1[63:0];
assign out = shift[0] ? stage2[63:32] : stage2[31:0];

endmodule

module icacheline(
	input wire clk,
	input wire rst_n,

	input wire[31:0] r_addr,
	input wire[31:0] w_addr,
	
	input wire we,

	// High if hit
	output reg hit,
	// Data output from this cache line
	output reg[255:0] data_out,

	input wire[255:0] data_in
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
				valid[r_addr[9:5]] ? // Cache line must be valid and
				tags[r_addr[9:5]] == r_addr[31:10] : 'b0;
		end
	end

	// Write to this cacheline
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			// Nothing is valid
			valid <= 'b0;
		end else if (we) begin
			// Insert tag
			$display("write");
			tags[w_addr[9:5]] <= w_addr[31:10];
			// Insert data
			entries[w_addr[9:5]] <= data_in;
			valid[w_addr[9:5]] <= 1'b1;
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
	output logic stall,

	// Output data
	output wire[31:0] out,

	// Incoming data from the lower level cache
	input wire[255:0] L2_block_read,

	// High = L2 is stalled on main memory
	// Low = L2 hit, data is valid
	input wire L2_stall,

	// Address asserted to read from L2
	output wire[31:0] L2_addr_read,

	// Asserted high if we need to read from the Level two cache
	output logic L2_read_en
);

/**
 * Captured write address
**/
reg[31:0] write_addr;
logic	ic0_we;
logic	ic1_we;

/**
 * Enumerated states for the instruction cache
 * READY	--	Cache has been hit. It is actively returning data.
 * STALL	--  Cache has been missed. It is waiting on the next level cache.
 * UPDATE	--  Cache is writing data from the next level. It will be ready on
 * the next cycle of the global core clock.
 * FAULT1	--	Unused state. If this is reached, global CATERR should be
 * asserted and a Machine Check Exception produced
**/
typedef enum reg[1:0] {READY, STALL, UPDATE, FAULT1}  icache_state_t;

icache_state_t icache_state;
// Assigned via combinational logic only
icache_state_t icache_state_next;

// Pre shifted output signal. This gets fed through the input of the chain
// shifter, and the bottom bits of the address are used to mask off and shift
// the correct section of the output data. The memory and cache subsystem are
// addressable in four byte increments.
wire[255:0] tmp_out;

wire[31:0] shifted_out;

// Need to cut down a 256 bit (32 byte) cache line output into a 32 bit (four
// byte) output to send to the core.
icache_chainshifter ics(
	.in(tmp_out),
	.shift(write_addr[4:2]), // changed from addr
	.out(shifted_out)
);

logic tmp_stall;

assign out = tmp_stall ? 32'h600DBEEF : shifted_out;


wire ic0_hit;
wire ic1_hit;

wire[255:0] ic0_out;
wire[255:0] ic1_out;

// This is the data that comes straight from the level two cache
wire[255:0] L2_out;
assign L2_out  = L2_block_read;

icacheline ic0(
	.clk(clk),
	.rst_n(rst_n),
	.r_addr(addr),
	.w_addr(write_addr),
	.we(ic0_we),
	.hit(ic0_hit),
	.data_out(ic0_out),
	.data_in(L2_out)
);
icacheline ic1(
	.clk(clk),
	.rst_n(rst_n),
	.r_addr(addr),
	.w_addr(write_addr),
	.we(ic1_we),
	.hit(ic1_hit),
	.data_out(ic1_out),
	.data_in(L2_out)
);

// Least Recently Used registry
// 0 -> cache line 0 is oldest
// 1 -> cache line 1 is newest
reg[31:0] LRU;

//always @(posedge clk, negedge rst_n) begin
//	if(!rst_n)
//		stall <= 1'b1;
//	else
//		stall <= tmp_stall;
//end
assign stall = tmp_stall;

// High if the LRU subsystem should update the LRU bits this cycle. It can
// either take them from the write or read cycles.
logic LRU_we;
// 0 -> update from read address
logic LRU_rw;
// 1 -> update from write address

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		// Set this to all zeroes. This ensures that the first cache line will
		// be replaced first.
		LRU <= 32'b0;
	end else if(LRU_we) begin
		// Writing back to the LRU state is enabled
		if(LRU_rw) begin
			// We need to update from the write address
			// Asserting this means we are updating the cache. It will update
			// the oldest. Therefore, just toggle this
			LRU[write_addr[9:5]] <= ~LRU[write_addr[9:5]];
		end else begin
			// We need to update from the read address
			// This means normal operation. However in this case, there is not
			// an implicit replacement. Therefore there is no particular cache
			// line that is being evicted. And we could very well see a case
			// where the most recent cache line is accessed again. Therefore
			// a simple toggle would be insufficient. There needs to be a bit
			// more complicated logic based on which is actually being
			// accessed
			// If ic0 hits, slap a 1 into there to indicate that ic1 is now
			// the oldest. Otherwise put zero.
			LRU[write_addr[9:5]] <= ic0_hit; // Note: write_addr gets read_addr
			// Unless we miss. Then, don't update this at all.
		end
	end
end

// This is the signal that is fed into the chain shifter. In the event that
// there is no hit, this is undefined.
assign tmp_out = ic0_hit ? ic0_out : ic1_out;

// Clock logic for trapping the write address
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		// On power on reset, the system will load the required bootcode into
		// memory starting at address 0 and then jump to it. We know this
		// ahead of time - therefore, keep this at zero. The core will stall
		// because no data in the caches is valid, and therefore the core will
		// wait until the required code makes it into the fetch stage before
		// executing anything (it will run a stream of No-Ops until then)
		write_addr <= 32'b0;
	end else if (~tmp_stall) begin
		// If the core is not currently stalled, continuously capture the
		// input address and store it in the write_addr register. This ensures
		// that if the core does stall, we immediately know what address it
		// was looking for. This is because on the posedge of the clock, the
		// cachelines will update their state (they have clocked reads) and
		// this will update in sync.
		// We need to trap this because it is not guaranteed that that the
		// fetch stage will maintain its output when not receiving any
		// output. I know it will, because I wrote it, but it's good to be
		// sure to avoid corrupting the cache by putting data that's marked as
		// valid in the wrong spot.
		write_addr <= addr;
	end else begin
		// Explicitly hold state - we are stalled and need to preserve this so
		// we know where to write the data when it comes back from L2
		write_addr <= write_addr;
	end
end

// The write address is always going to be the same that we use to write to L2
// cache.
// Just assign it
assign L2_addr_read = write_addr;

always_comb begin
	// Default to being in the same state as before
	icache_state_next = icache_state;
	// Don't write either cache line by default
	ic0_we = 1'b0;
	ic1_we = 1'b0;
	// State dependent logic
	case (icache_state)
	READY: begin
		// Cache is currently in the READY state. This means it is producing
		// output for use in the fetch stage of the core.
		// Stall must be low, because the core is not stalled
		tmp_stall = 1'b0;
		// Default to not reading from the Level two cache. This frees up
		// a read port.
		L2_read_en = 1'b0;
		// We need to update the LRU subsystem
		LRU_we = 1'b1;
		// We are only reading from the cache
		LRU_rw = 1'b0;

		if(!(ic0_hit || ic1_hit)) begin
			// Neither of the two cache lines has the required data and
			// matching tag. This means we missed the cache.
			// Assert stall high because we do not want random data to proceed
			// to the fetch stage
			tmp_stall = 1'b1;
			// Move to the stall state
			icache_state_next = STALL;
			// May as well assert this early. This saves a clock cycle - not
			// just of the core clock but the uncore clock since the L2 is
			// disaggregated from the normal core in order to allow it to have
			// a much larger capacity.
			// This also ensures that the write_addr flop will hold state.
			L2_read_en = 1'b1;
			// If we are in this state, both cache lines lack the required
			// data. Disable the LRU update so we will know which one to
			// replace.
			LRU_we = 1'b0;
		end
	end
	STALL: begin
		// Cache is currently stalled. We need to read data from L2, and
		// remain in this state until L2 is no longer stalled
		// Hold the stall signal high. This ensures that the fetch stage does
		// not trust the output of this functional unit until all required
		// data is present.
		tmp_stall = 1'b1;
		// Hold L2_read_en
		L2_read_en = 1'b1;
		// Don't update the LRU
		LRU_we = 1'b0;
		LRU_rw = 1'b1;
		if(~L2_stall) begin
			// Data is ready from L2 - it is no longer in the stalled
			// state. This means we need to proceed to the UPDATE state
			// and write back into the cache
			icache_state_next = UPDATE;
			// If L2 is ready, the data is ready. Determine where to write the
			// data.
			if(LRU[write_addr[9:5]]) begin
				// Cache line 1 is the oldest
				ic1_we = 1'b1;
			end else begin
				// Cache line 0 is the oldest
				ic0_we = 1'b1;
			end
			// Update the LRU state
			LRU_we = 1'b1;
			// This time it comes from the write
			LRU_rw = 1'b1;
		end
	end
	UPDATE: begin
		// No need to read any more
		L2_read_en = 1'b0;
		// Cache is currently taking a cycle to update. Continue to hold
		// stall.
		tmp_stall = 1'b1;
		// Move to READY state during the next clock cycle
		icache_state_next = READY;
	end
	endcase
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		icache_state <= STALL;
	end else begin
		icache_state <= icache_state_next;
	end
end

endmodule
`default_nettype wire
