`default_nettype none
module ALU_tb();
    logic[2:0] alu_op1;
    logic[6:0] alu_op2;
    logic[31:0] s1;
    logic[31:0] s2;
    logic[31:0] res;

    ALU alu(
        .alu_op1(alu_op1), .alu_op2(alu_op2), .s1(s1), .s2(s2), .res(res)
    );

    initial begin
        // ALU_ADD test
        alu_op1 = 3'b0;
        alu_op2 = 7'b0;
        s1 = 5;
        s2 = 7;
        #10;
        if (res != 12) begin
            $display("ALU_ADD error, result should be 12 instead of %b", res);
            $stop();
        end

        alu_op1 = 3'b0;
        alu_op2 = 7'b0100000;
        s1 = 7;
        s2 = 2;
        #10;
        if (res != 5) begin
            $display("ALU_SUB error, result should be 5 instead of %d", res);
            $stop();
        end

        alu_op1 = 3'b100;
        alu_op2 = 7'b0;
        s1 = 3;
        s2 = 1;
        #10;
        if (res != 2) begin
            $display("ALU_XOR error, result should be 2 instead of %d", res);
            $stop();
        end

        alu_op1 = 3'b110;
        alu_op2 = 7'b0;
        s1 = 2;
        s2 = 6;
        #10;
        if (res != 6) begin
            $display("ALU_OR error, result should be 6 instead of %d", res);
            $stop();
        end

        alu_op1 = 3'b111;
        alu_op2 = 7'b0;
        s1 = 3;
        s2 = 2;
        #10;
        if (res != 2) begin
            $display("ALU_AND error, result should be 2 instead of %d", res);
            $stop();
        end

        alu_op1 = 3'b001;
        alu_op2 = 7'b0;
        s1 = 32'h80000000;
        s2 = 0;
        #10;
        if (res != 0) begin
            $display("ALU_SLL error, result should be 0 instead of %d", res);
            $stop();
        end

        alu_op1 = 3'b101;
        alu_op2 = 7'b0;
        s1 = 1;
        s2 = 0;
        #10;
        if (res != 0) begin
            $display("ALU_SRL error, result should be 0 instead of %d", res);
            $stop();
        end

        alu_op1 = 3'b101;
        alu_op2 = 7'b0100000;
        s1 = 32'h80000000;
        s2 = 0;
        #10;
        if (res != 32'hC0000000) begin
            $display("ALU_SRA error, result should be 32'hC0000000 instead of %h", res);
            $stop();
        end

        // ALU_SLTU Test 
        alu_op1 = 3'b010;
        alu_op2 = 7'b0;
        s1 = 32'hFFFFFFFF; // -1 in two’s complement
        s2 = 0;
        #10;
        if (res != 1) begin
            $display("ALU_SLT error, result should be 1 instead of %d", res);
            $stop();
        end

        // Unsigned Comparison
        alu_op1 = 3'b011; 
        alu_op2 = 7'b0;
        s1 = 32'hFFFFFFFF; 
        s2 = 1;
        #10;
        if (res != 0) begin
            $display("ALU_SLTU error, result should be 0 instead of %d", res);
            $stop();
        end

        // Checking for X values in res
        alu_op1 = 3'b101;
        alu_op2 = 7'b0;
        s1 = 1;
        s2 = 0;
        #10;
        if ($isunknown(res)) begin
            $display("Result contains unknown values as expected.");
            $stop();
        end

        
        $display("YAHOOO! All Test Passed");
    end

endmodule 