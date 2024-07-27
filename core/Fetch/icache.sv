`default_nettype none
module icache(
	input wire clk,
	input wire rst_n,
	input wire[31:0] addr,
	output wire stall,
	output wire[31:0] out,

	input wire[255:0] L2_block_read,
	input wire L2_stall,
	output wire[31:0] L2_addr_read
);

// TODO make this actually not a dummy cache

//assign out=32'b0000000_00000_00000_000_00000_0110011;

reg[31:0] tmp;
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

endmodule
`default_nettype wire
