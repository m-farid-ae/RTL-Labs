`timescale 1ns/1ps
module tb_count_ones;
    reg        clk, reset;
    reg  [7:0] val;
    wire [3:0] Num, pos;
    integer errors;

    count_ones dut (.clk(clk), .reset(reset), .val(val), .Num(Num), .pos(pos));

    always #5 clk = ~clk;

    task check;
        input [7:0] tval;
        input [3:0] exp_num;
        input [3:0] exp_pos;
        begin
            val = tval;
            @(posedge clk); #1;   // result appears one clock cycle later
            if ((Num !== exp_num) || (pos !== exp_pos)) begin
                errors = errors + 1;
                $display("FAIL val=%b Num=%0d (exp %0d) pos=%0d (exp %0d)",
                         val, Num, exp_num, pos, exp_pos);
            end else
                $display("PASS val=%b Num=%0d pos=%0d", val, Num, pos);
        end
    endtask

    initial begin
        clk = 0; reset = 1; val = 0; errors = 0;
        repeat (2) @(posedge clk);
        reset = 0; #1;
        check(8'b00000000, 4'd0, 4'd8);  // no ones
        check(8'b00010001, 4'd2, 4'd0);  // ones at 0 and 4
        check(8'b10000000, 4'd1, 4'd7);  // one at bit 7
        check(8'b01101100, 4'd4, 4'd2);  // ones at 2,3,5,6
        check(8'b11111111, 4'd8, 4'd0);
        check(8'b00001000, 4'd1, 4'd3);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
