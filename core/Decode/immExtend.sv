`default_nettype none

module immExtend(
    input logic [31:7] instr,
    input logic [2:0] immSrc,
    output logic [31:0] immext
);

always_comb
    case(immSrc)
        // I-type
        3'b000: immext = {{20{instr[31]}}, isntr[31:20]};

        // S-type
        3'b001: immext = {{20{instr[31]}}, isntr[31:25], isntr[11:7]};

        // B-type
        3'b010: immext = {{20{instr[31]}}, instr[7], instr[31:25], instr[11:8], 1'b0};

        // J-type
        3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

        // U-type
        3'b100: immext = {instr[31:12]};

        default: immext = 32'bx; // undefined
    endcase

endmodule
`default_nettype wire