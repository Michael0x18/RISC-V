`default_nettype none
module controlunit_tb();
    logic op;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic RegWriteD;
    logic [1:0] ResultSrcD;
    logic MemWriteD;
    logic JumpD;
    logic BranchD;
    logic [2:0] ALUControlD;
    logic ALUSrcD;
    logic [2:0] immSrcD;

    ControlUnit cu(
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .immSrcD(immSrcD)
    );

    initial begin
        // R-type instructions
        op = 7'b0110011;
        if (RegWriteD != 1 || ResultSrcD != 2'b00 || MemWriteD != 0 || JumpD != 0 || BranchD != 0 || ALUSrcD != 0 || immSrcD != 3'bxxx) begin
            $display("Error in R-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // I-type instructions
        op = 7'b0010011;
        if (RegWriteD != 1 || ResultSrcD != 2'b00 || MemWriteD != 0 || JumpD != 0 || BranchD != 0 || ALUSrcD != 1 || immSrcD != 3'b000) begin
            $display("Error in R-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // S-type instructions
        op = 7'b0100011;
        if (RegWriteD != 0 || ResultSrcD != 2'b00 || MemWriteD != 1 || JumpD != 0 || BranchD != 0 || ALUSrcD != 1 || immSrcD != 3'b001) begin
            $display("Error in S-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // B-type instructions
        op = 7'b1100011;
        if (RegWriteD != 0 || ResultSrcD != 2'b00 || MemWriteD != 0 || JumpD != 0 || BranchD != 1 || ALUSrcD != 1 || immSrcD != 3'b010) begin
            $display("Error in B-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // JAL
        op = 7'b1101111;
        if (RegWriteD != 1 || ResultSrcD != 2'b01 || MemWriteD != 0 || JumpD != 1 || BranchD != 0 || ALUSrcD != 1 || immSrcD != 3'b011) begin
            $display("Error in B-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // JALR
        op = 7'b1100111;
        if (RegWriteD != 1 || ResultSrcD != 2'b01 || MemWriteD != 0 || JumpD != 1 || BranchD != 0 || ALUSrcD != 1 || immSrcD != 3'b000) begin
            $display("Error in B-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // LUI
        op = 7'b0110111;
        if (RegWriteD != 1 || ResultSrcD != 2'bxx || MemWriteD != 0 || JumpD != 0 || BranchD != 0 || ALUSrcD != x || immSrcD != 3'b100) begin
            $display("Error in B-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end

        // AUIPC
        op = 7'b0010111;
        if (RegWriteD != 1 || ResultSrcD != 2'b00 || MemWriteD != 0 || JumpD != 0 || BranchD != 0 || ALUSrcD != 1 || immSrcD != 3'b100) begin
            $display("Error in B-type instructions");
            $display("RegWriteD: %b", RegWriteD);
            $display("ResultSrcD: %b", ResultSrcD);
            $display("MemWriteD: %b", MemWriteD);
            $display("JumpD: %b", JumpD);
            $display("BranchD: %b", BranchD);
            $display("ALUControlD: %b", ALUControlD);
            $display("ALUSrcD: %b", ALUSrcD);
            $display("immSrcD: %b", immSrcD);
        end
    end



endmodule
`default_nettype wire