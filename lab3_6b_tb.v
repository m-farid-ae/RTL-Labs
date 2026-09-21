`timescale 1ns/1ps
module tb_mult3;
    reg  [5:0] mult_in;
    reg        en;
    wire [7:0] mult_out;
    integer i, errors;

    mult3 dut (.mult_in(mult_in), .en(en), .mult_out(mult_out));

    initial begin
        errors = 0;
        // check enable = 0
        en = 0; mult_in = 6'd21; #10;
        if (mult_out !== 8'd0) begin errors = errors + 1;
            $display("FAIL en=0: mult_out=%0d (exp 0)", mult_out); end
        else $display("PASS en=0: mult_out=%0d", mult_out);
        // check all 64 input values
        en = 1;
        for (i = 0; i < 64; i = i + 1) begin
            mult_in = i[5:0]; #10;
            if (mult_out !== (i*3)) begin
                errors = errors + 1;
                $display("FAIL in=%0d out=%0d (exp %0d)", i, mult_out, i*3);
            end
        end
        $display("Exhaustive test done (i=0..63).");
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
