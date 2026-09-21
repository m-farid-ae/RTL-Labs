// Lab 2-5 Testbench
`timescale 1ns/1ps
module tb_div_by_3;

reg  [15:0] din;
wire [14:0] result;
wire [1:0]  remainder;

div_by_3 dut (.din(din), .result(result), .remainder(remainder));

integer i;
integer exp_result, exp_rem;

initial begin
    $display("din     result  remainder  (expected result, rem)");
    for (i = 0; i < 12; i = i + 1) begin
        din = i * 137 + (i % 7);   // some pseudo-random values
        #10;
        exp_result = din / 3;
        exp_rem    = din % 3;
        $display("%0d  %0d  %0d   (%0d, %0d) %s",
                 din, result, remainder, exp_result, exp_rem,
                 (result == exp_result && remainder == exp_rem) ? "PASS" : "FAIL");
    end
	// dirtected case
  	din = 16'd28;    #10;
    exp_result = din / 3;
        exp_rem    = din % 3;
        $display("%0d  %0d  %0d   (%0d, %0d) %s",
                 din, result, remainder, exp_result, exp_rem,
                 (result == exp_result && remainder == exp_rem) ? "PASS" : "FAIL");
    // Edge cases
    din = 16'd0;    #10;
    $display("%0d  %0d  %0d   (0, 0) %s", din, result, remainder,
             (result == 0 && remainder == 0) ? "PASS" : "FAIL");
    din = 16'd65535; #10;
    $display("%0d  %0d  %0d   (21845, 0) %s", din, result, remainder,
             (result == 21845 && remainder == 0) ? "PASS" : "FAIL");

    $display("Lab 2-5 simulation finished.");
    $finish;
end

endmodule
