`default_nettype none
module ControlUnit (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output logic RegWriteD,
    output logic [1:0] ResultSrcD,
    output logic MemWriteD,
    output logic JumpD,
    output logic BranchD,
    output logic [2:0] ALUControlD,
    output logic ALUSrcD,
    output logic [2:0] immSrcD
);

// Control signals for each instruction
always_comb begin
    case (op)
        // R-type instructions
        7'b0110011:
            begin
                RegWriteD = 1;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 0;
                BranchD = 0;
                ALUSrcD = 0;
                immSrcD = 3'bxxx;
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
                immSrcD = 3'b000;
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
                    ALUControlD = `ALU_SLL;
                3'b101:
                    case (funct7)
                        7'b0000000:
                            ALUControlD = `ALU_SRL;
                        7'b0100000:
                            ALUControlD = `ALU_SRA;
                    endcase
            endcase

        // S-type instructions
        7'b0100011:
            begin
                RegWriteD = 0;
                ResultSrcD = 2'b00;
                MemWriteD = 1;
                JumpD = 0;
                BranchD = 0;
                ALUSrcD = 1;
                immSrcD = 3'b001;
            end

        // B-type instructions 
        7'b1100011:
            begin
                RegWriteD = 0;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 0;
                BranchD = 1;
                ALUSrcD = 0;
                immSrcD = 3'b010;
            end

            case (func3)
                3'b000:
                    ALUControlD = `ALU_BEQ;
                3'b001:
                    ALUControlD = `ALU_BNE;
                3'b100:
                    ALUControlD = `ALU_BLT;
                3'b101:
                    ALUControlD = `ALU_BGE;
                3'b110:
                    ALUControlD = `ALU_BLTU;
                3'b111:
                    ALUControlD = `ALU_BGEU;
            endcase

        // JAL
        7'b1101111:
            begin
                RegWriteD = 1;
                ResultSrcD = 2'b01;
                MemWriteD = 0;
                JumpD = 1;
                BranchD = 0;
                ALUControlD = `ALU_ADD;
                ALUSrcD = 1;
                immSrcD = 3'b011;
            end

        // JALR
        7'b1100111:
            begin
                RegWriteD = 1;
                ResultSrcD = 2'b01;
                MemWriteD = 0;
                JumpD = 1;
                BranchD = 0;
                ALUControlD = `ALU_ADD;
                ALUSrcD = 1;
                immSrcD = 3'b000;
            end

        // LUI
        7'b0110111:
            begin
                RegWriteD = 1;
                ResultSrcD = 2'bxx;
                MemWriteD = 0;
                JumpD = 0;
                BranchD = 0;
                ALUControlD = 3'bxxx;
                ALUSrcD = 1'bx;
                immSrcD = 3'b100;
            end

        // AUIPC
        7'b0010111:
            begin
                RegWriteD = 1;
                ResultSrcD = 2'b00;
                MemWriteD = 0;I
                JumpD = 0;
                BranchD = 0;
                ALUControlD = `ALU_ADD;
                ALUSrcD = 1;
                immExtD = 3'b100;
            end
        
        default: 
            begin
                RegWriteD = 1'bx;
                ResultSrcD = 2'bxx;
                MemWriteD = 1'bx;
                JumpD = 1'bx;I
                BranchD = 0;
                ALUControlD = 3'bxxx;
                ALUSrcD = 1'bx;
                immSrcD = 3'bxxx;
            end
    endcase
end

endmodule
`default_nettype wire