// ============================================================
// Lab 4-3 : Testbench
// Sends 40 random bits and checks out against an independent
// majority computation each clock.
// ============================================================
`timescale 1ns/1ps
module lab4_3_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer k;

    reg  in;
    wire out;
    majority_counter dut (.in(in), .clk(clk), .out(out));

    // independent reference model
    reg [2:0] tb_s;
    wire tb_maj = (tb_s[0]&tb_s[1]) | (tb_s[1]&tb_s[2]) | (tb_s[0]&tb_s[2]);
    always @(posedge clk) tb_s <= {tb_s[1:0], in};

    initial begin
        in = 0;
        @(negedge clk);
        // random stimulus, sampled on negedge so it is stable at posedge
        for (k = 0; k < 40; k = k + 1) begin
            in = ($random % 3 == 0) ? 1'b0 : ($random % 2); // slightly biased
            @(negedge clk);
            #1;
            if (out !== tb_maj) begin
                errors = errors + 1;
                $display("FAIL: t=%0t in=%b out=%b expected=%b", $time, in, out, tb_maj);
            end
        end

        // directed check: 1,1,0 -> majority 1 ; then 0,0 -> majority 0
        in = 1; @(negedge clk); #1;
        in = 1; @(negedge clk); #1;
        in = 0; @(negedge clk); #1;
        check_out(1'b1, "majority of 1,1,0 is 1");
        in = 0; @(negedge clk); #1;
        in = 0; @(negedge clk); #1;
        check_out(1'b0, "majority of 1,0,0 is 0");
        in = 1; @(negedge clk); #1;
        in = 1; @(negedge clk); #1;
        in = 1; @(negedge clk); #1;
        check_out(1'b1, "majority of 0,1,1 is 1");

        if (errors == 0) $display("LAB 4-3 PASSED");
        else             $display("LAB 4-3 FAILED (%0d errors)", errors);
        $finish;
    end

    task check_out;
        input exp;
        input [255:0] msg;
        begin
            if (out !== exp) begin
                errors = errors + 1;
                $display("FAIL: %0s (out=%b exp=%b)", msg, out, exp);
            end
          else begin
            $display("PASS: %0s (out=%b exp=%b time=%0t)", msg, out, exp, $time);
            end
        end
    endtask
endmodule
