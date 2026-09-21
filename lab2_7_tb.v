// Lab 2-7 Testbench
`timescale 1ns/1ps
module tb_lab27_shift;

reg  clock;
wire [3:0] regA;

lab27_shift dut (.clock(clock), .regA(regA));

always #5 clock = ~clock;

initial begin
    clock = 0;
    $display("Time\t regA (expected 8 / 1000 every cycle)");
    repeat (6) begin
        @(posedge clock);
        #1 $display("%0t\t %b (%0d)", $time, regA, regA);
    end
    if (regA == 4'b1000)
        $display("PASS: regA == 4'b1000");
    else
        $display("FAIL: regA = %b", regA);
    $display("Lab 2-7 simulation finished.");
    $finish;
end

endmodule
