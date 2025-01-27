/*
 * Simple register file. Implements the RV32I base register set.
 * Integer only.
 */
`default_nettype none
module registerfile(
	input wire clk,
	input wire rst_n,
	
	input wire[4:0] RA1,			// Read address 1
	input wire[4:0] RA2,			// Read address 2

	input wire[4:0] WA,				// Write address
	input wire WE,					// Write enable
	input wire[31:0] WD,			// Write data
	
	output wire[31:0] RD1,			// Data out 1
	output wire[31:0] RD2			// Data out 2
);

reg[31:0] array[0:31];

reg[4:0] RA1_i;
reg[4:0] RA2_i;

reg[4:0] WA_i;
reg WE_i;
reg[31:0] WD_i;

always @(posedge clk, negedge rst_n) begin
	
end

assign RD1 = A1==0 ? 'b0 : array[A1];
assign RD2 = A2==0 ? 'b0 : array[A2];

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		reg[5:0] i;
		array[0] <= 32'b0;
		for(i = 1; i < 32; ++i) begin
			array[i] <= 32'hDEADBEEF;
		end
	end
	if(WE && WA) begin
		array[WA] <= WD;
	end
end

endmodule;
`default_nettype wire
