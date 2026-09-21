// ============================================================
// Lab 4-2 : Testbench
// ============================================================
`timescale 1ns/1ps
module lab4_2_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    task check;
        input condition;
        input [255:0] msg;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("FAIL: %0s (time=%0t)", msg, $time);
            end
            else begin
              $display("PASS: %0s (time=%0t)", msg, $time);
            end
        end
    endtask

    reg        reset, up_down;
    wire [7:0] count;
    counter dut (.reset(reset), .clock(clk), .up_down(up_down), .count(count));

    initial begin
        reset = 0; up_down = 1;

        // -- asynchronous reset pulse --
        @(negedge clk); reset = 1; #1;
        check(count === 8'd0, "async reset to 0");
        @(negedge clk); reset = 0;

        // -- count up --
        repeat (6) @(posedge clk); #1;
        check(count === 8'd6, "counted up to 6");

        // -- count down --
        @(negedge clk); up_down = 0;
        repeat (3) @(posedge clk); #1;
        check(count === 8'd3, "counted down to 3");

        // -- count down through zero (wrap) --
        repeat (3) @(posedge clk); #1;
        check(count === 8'd0, "counted down to 0");

        // -- async reset overrides counting (reset mid-cycle) --
        @(negedge clk); up_down = 1;
        repeat (2) @(posedge clk);
        @(negedge clk); reset = 1; #1;
        check(count === 8'd0, "async reset works while counting");
        @(negedge clk); reset = 0;

        // -- count up again from 0 --
        repeat (4) @(posedge clk); #1;
        check(count === 8'd4, "counted up to 4 after re-reset");

        if (errors == 0) $display("LAB 4-2 PASSED");
        else             $display("LAB 4-2 FAILED (%0d errors)", errors);
        $finish;
    end
endmodule
