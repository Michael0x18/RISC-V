module ControlUnit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [11:0] I_imm,
    input logic [6:0] SB_imm1,
    input logic [4:0] SB_imm2,
    input logic [19:0] UJ_imm,

    output logic RegWriteD,
    output logic [1:0] ResultSrcD,
    output logic MemWriteD,
    output logic JumpD,
    output logic BranchD,
    output logic [2:0] ALUControlD,
    output logic ALUSrcD,
    output logic [31:0] ImmExtD
);

// Breakdown module
Breakdown breakdown (
    .instruction(instruction),
    .opcode(opcode),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .funct3(func3),
    .funct7(funct7),
    .I_imm(I_imm),
    .SB_imm1(SB_imm1),
    .SB_imm2(SB_imm2),
    .UJ_imm(UJ_imm)
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
                ImmExtD = 32'bxx;
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
                BranchD = 1;
                ALUSrcD = 1;
                ImmExtD = {{20{I_imm[11]}}, I_imm};
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
                    ImmD = {{27{instruction[4]}}, I_imm[4:0]};
                3'b101:
                    begin
                        ImmD = {{27{instruction[4]}}, I_imm[4:0]}; 
                    end
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
                ResultSrcD = 2'bxx;
                MemWriteD = 1;
                JumpD = 0;
                BranchD = 0;
                ALUControlD = `ALU_ADD;
                ALUSrcD = 0;
                ImmExtD = {{20{SB_imm1[6]}}, SB_imm1[6:0], SB_imm2[4:0]};
            end

        // B-type instructions 
        7'b1100011:
            begin
                RegWriteD = 0;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 0;
                BranchD = 1;
                ALUControlD = `ALU_COMP;
                ALUSrcD = 0;
                ImmExtD = {{19{SB_imm2[6]}}, SB_imm1[6], SB_imm2[0], SB_imm1[5:0], SB_imm2[4:1], 1'b0};
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
                RegWriteD = 0;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 1;
                BranchD = 0;
                ALUControlD = `ALU_ADD;
                ALUSrcD = 1;
                ImmExtD = {{12{UJ_imm[19]}},UJ_imm[7:0],UJ_imm[8], UJ_imm[18:9], 1'b0};
            end

        // JALR
        7'b1100111:
            begin
                RegWriteD = 0;
                ResultSrcD = 2'b00;
                MemWriteD = 0;
                JumpD = 1;
                BranchD = 0;
                ALUControlD = `ALU_ADD;
                ALUSrcD = `ALU_SRC_IMM;
                ImmExtD = I_imm[11:0];
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
                ImmExtD = UJ_imm[19:0];
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
                ImmExtD = UJ_imm[19:0];
            end
    endcase
end

endmodule
