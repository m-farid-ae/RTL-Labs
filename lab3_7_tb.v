`timescale 1ns/1ps
module tb_alu;
    reg  [31:0] A, B;
    reg  [3:0]  Opcode;
    reg         Reset, clock;
    wire [31:0] Dout;
    wire        Zero, CarryOut, Overflow;
    integer errors;

    alu dut (.A(A), .B(B), .Opcode(Opcode), .Reset(Reset), .clock(clock),
             .Dout(Dout), .Zero(Zero), .CarryOut(CarryOut), .Overflow(Overflow));

    always #5 clock = ~clock;

    task check;
        input [3:0]  op;
        input [31:0] ta, tb;
        input [31:0] exp_dout;
        input        exp_zero;
        begin
            Opcode = op; A = ta; B = tb;
            @(posedge clock); #1;
            if ((Dout !== exp_dout) || (Zero !== exp_zero)) begin
                errors = errors + 1;
                $display("FAIL op=%h A=%h B=%h Dout=%h (exp %h) Zero=%b (exp %b)",
                         op, ta, tb, Dout, exp_dout, Zero, exp_zero);
            end else
                $display("PASS op=%h A=%h B=%h Dout=%h Zero=%b Carry=%b Ovfl=%b",
                         op, ta, tb, Dout, Zero, CarryOut, Overflow);
        end
    endtask

    initial begin
        clock = 0; Reset = 1; errors = 0;
        A = 0; B = 0; Opcode = 0;
        repeat (2) @(posedge clock);
        Reset = 0; #1;

        check(4'h0, 32'd15,   32'd10,  32'd25,  1'b0);  // ADD
        check(4'h0, 32'hFFFFFFFF, 32'd1, 32'd0, 1'b1);  // ADD wrap, Zero
        check(4'h1, 32'd15,   32'd10,  32'd5,   1'b0);  // SUB
        check(4'h1, 32'd10,   32'd15,  -32'sd5, 1'b0);  // SUB negative
        check(4'h2, 32'hF0F0, 32'h0FF0, 32'h00F0, 1'b0); // AND
        check(4'h3, 32'hF0F0, 32'h0FF0, 32'hFFF0, 1'b0); // OR
        check(4'h4, 32'hF0F0, 32'h0FF0, 32'hFF00, 1'b0); // XOR
        check(4'h5, 32'h80000000, 32'd4, 32'h08000000, 1'b0); // SHR
        check(4'h6, 32'd1,    32'd4,   32'd16,  1'b0);  // SHL
        check(4'h7, 32'h80000001, 32'd1, 32'h00000003, 1'b0); // rotate left
        check(4'h8, 32'h00000001, 32'd1, 32'h80000000, 1'b0); // rotate right
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
