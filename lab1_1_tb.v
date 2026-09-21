// Lab 1-1: Testbench for full_adder
// Applies all 8 input combinations and checks sum/carry against expected truth table

`timescale 1ns/1ps

module tb_full_adder;

    reg  a, b, cin;
    wire sum, cout;
    integer i;
    integer errors;

    // Expected outputs for {a,b,cin} = 000..111 (truth table)
    reg expected_sum  [0:7];
    reg expected_cout [0:7];

    full_adder dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .sum  (sum),
        .cout (cout)
    );

    initial begin
        // Initialize expected truth table
        expected_sum[0]  = 0; expected_cout[0] = 0; // 0+0+0
        expected_sum[1]  = 1; expected_cout[1] = 0; // 0+0+1
        expected_sum[2]  = 1; expected_cout[2] = 0; // 0+1+0
        expected_sum[3]  = 0; expected_cout[3] = 1; // 0+1+1
        expected_sum[4]  = 1; expected_cout[4] = 0; // 1+0+0
        expected_sum[5]  = 0; expected_cout[5] = 1; // 1+0+1
        expected_sum[6]  = 0; expected_cout[6] = 1; // 1+1+0
        expected_sum[7]  = 1; expected_cout[7] = 1; // 1+1+1

        errors = 0;
        $display("---------------------------------------------------");
        $display(" Lab 1-1 : Full Adder Simulation Results");
        $display("---------------------------------------------------");
        $display("  a b cin | sum cout | Expected | Status");
        $display("---------------------------------------------------");

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #10;
            if (sum === expected_sum[i] && cout === expected_cout[i])
                $display("  %b %b  %b  |  %b    %b   |   %b    %b   | PASS",
                         a, b, cin, sum, cout, expected_sum[i], expected_cout[i]);
            else begin
                $display("  %b %b  %b  |  %b    %b   |   %b    %b   | FAIL",
                         a, b, cin, sum, cout, expected_sum[i], expected_cout[i]);
                errors = errors + 1;
            end
        end

        $display("---------------------------------------------------");
        if (errors == 0)
            $display(" RESULT: ALL TESTS PASSED (8/8) - Lab 1-1 OK");
        else
            $display(" RESULT: %0d TEST(S) FAILED", errors);
        $display("---------------------------------------------------");
        $finish;
    end

endmodule
