module ControlUnit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic RegWriteD,
    output logic [1:0] ResultSrcD,
    output logic MemWriteD,
    output logic JumpD,
    output logic BranchD,
    output logic [2:0] ALUControlD,
    output logic ALUSrcD,
    output logic [31:0] ImmD
);

    // Control signals for each instruction
    always_comb begin
        case (opcode)
            // R-type instructions
            7'b0110011:
                begin
                    RegWriteD = 1;
                    ResultSrcD = 2'b00;
                    MemWriteD = 0;
                    JumpD = 0;
                    BranchD = 0;
                    ALUSrcD = 0;
                    ImmD = 2'bxx;
                end

                case (func3)
                    3'b000:
                        case (funct7)
                            7'b0000000:
                                ALUControlD = `ALU_ADD;
                            7'b0100000:
                                ALUControlD = `ALU_SUB;
                        endcase
                    3'b001:
                        ALUControlD = `ALU_SLL;
                    3'b010:
                        ALUControlD = `ALU_SLT;
                    3'b011:
                        ALUControlD = `ALU_SLTU;
                    3'b100:
                        ALUControlD = `ALU_XOR;
                    3'b101:
                        case (funct7)
                            7'b0000000:
                                ALUControlD = `ALU_SRL;
                            7'b0100000:
                                ALUControlD = `ALU_SRA;
                        endcase
                    3'b110:
                        ALUControlD = `ALU_OR;
                    3'b111:
                        ALUControlD = `ALU_AND;
                endcase

            // I-type instructions
            7'b0010011:
                begin
                    RegWriteD = 1;
                    ResultSrcD = 2'b00;
                    MemWriteD = 0;
                    JumpD = 0;
                    BranchD = 0;
                    ALUSrcD = 1;
                    ImmD = 2'b00; //??
                end

                case (funct3)
                    3'b000:
                        ALUControlD = `ALU_ADD;
                    3'b010:
                        ALUControlD = `ALU_SLT;
                    3'b011:
                        ALUControlD = `ALU_SLTU;
                    3'b100:
                        ALUControlD = `ALU_XOR;
                    3'b110:
                        ALUControlD = `ALU_OR;
                    3'b111:
                        ALUControlD = `ALU_AND;
                    3'b001:
                        begin
                            ImmD = 2'b00; //??
                        end
                        case (funct7)
                            7'b0000000:
                                ALUControlD = `ALU_SLL;
                            7'b0100000:
                                ALUControlD = `ALU_SRA;
                        endcase
                endcase

            // S-type instructions
            7'b0100011:
                begin
                    RegWriteD = 0;
                    ResultSrcD = 2'bxx;
                    MemWriteD = 1;
                    JumpD = 0;
                    BranchD = 0;
                    ALUControlD = `ALU_ADD;
                    ALUSrcD = 0;
                    ImmD = {funct7[6:0], } //??
                end

            // B-type instructions
            7'b1100011:
                begin
                    RegWriteD = 0;
                    ResultSrcD = 2'b00;
                    MemWriteD = 0;
                    JumpD = 0;
                    BranchD = 1;
                    ALUControlD = `ALU_ADD;
                    ALUSrcD = 1;
                    ImmSRCD = 2'b00; //??
                end

            // LUI
            7'b0110111:
                begin
                    RegWriteD = 1;
                    ResultSrcD = 2'b00;
                    MemWriteD = 0;
                    JumpD = 0;
                    BranchD = 0;
                    ALUControlD = 3'bxxx;
                    ALUSrcD = 1'bx;
                    ImmSRCD = 2'b10; //??
                end

            // AUIPC
            7'b0010111:
                begin
                    RegWriteD = 1;
                    ResultSrcD = 2'b00;
                    MemWriteD = 0;
                    JumpD = 0;
                    BranchD = 0;
                    ALUControlD = `ALU_ADD;
                    ALUSrcD = 1;
                    ImmSRCD = 2'b10; //??
                end

            // J-type instructions
            7'b1101111:
                begin
                    RegWriteD = 0;
                    ResultSrcD = 2'b00;
                    MemWriteD = 0;
                    JumpD = 1;
                    BranchD = 0;
                    ALUControlD = `ALU_ADD;
                    ALUSrcD = `ALU_SRC_IMM;
                    ImmSRCD = 2'b00;
                end
        endcase
    end

endmodule