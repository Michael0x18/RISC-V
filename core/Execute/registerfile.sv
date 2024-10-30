`default_nettype none
module registerfile(
	input wire clk,
	input wire rst_n,
	
	input wire[4:0] A1,
	input wire[4:0] A2,
	input wire[4:0] A3,
	input wire WE3,
	input wire[31:0] WD3,
	
	output wire[31:0] RD1,
	output wire[31:0] RD2
);

reg[31:0] array[0:31];

assign RD1 = A1==0 ? 'b0 : array[A1];
assign RD2 = A2==0 ? 'b0 : array[A2];

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		reg[5:0] i;
		for(i = 0; i < 32; ++i) begin
			array[i] <= 32'hDEADBEEF;
		end
	end
	if(WE3) begin
		array[A3] <= WD3;
	end
end

endmodule;
`default_nettype wire
