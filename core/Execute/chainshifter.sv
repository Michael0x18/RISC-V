`default_nettype none
module chainshifter(
	input wire[31:0]	in,
	input wire[4:0]		shft,
	input wire			arith,
	output wire[31:0]	out
);
wire[31:0] stage1;
wire[31:0] stage2;
wire[31:0] stage3;
wire[31:0] stage4;

assign stage1	= shft[4] ? {{16{arith ? in[31] : 1'b0}}, {in[31:16]}} : in;
assign stage2	= shft[3] ? {{8{arith ? in[31] : 1'b0}}, {stage1[31:8]}} : stage1;
assign stage3	= shft[2] ? {{4{arith ? in[31] : 1'b0}}, {stage2[31:4]}} : stage2;
assign stage4	= shft[1] ? {{2{arith ? in[31] : 1'b0}}, {stage3[31:2]}} : stage3;
assign out		= shft[0] ? {{1{arith ? in[31] : 1'b0}}, {stage4[31:1]}} : stage4;
endmodule
`default_nettype wire
