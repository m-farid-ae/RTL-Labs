// Lab 2-4 Testbench
`timescale 1ns/1ps
module tb_counter_case;

reg  [7:0] din;
reg  [1:0] c;
reg        clk;
wire [7:0] dout;

counter_case dut (.din(din), .c(c), .clk(clk), .dout(dout));

// Clock: 10 ns period
always #5 clk = ~clk;

initial begin
    clk = 0; din = 8'd0; c = 2'b11;
    $display("Time\t c   din    dout");
    $monitor("%0t\t %b  %0d  %0d", $time, c, din, dout);

    // Reset
    @(negedge clk); c = 2'b11;
    @(negedge clk);

    // Load din = 100
    c = 2'b00; din = 8'd100;
    @(negedge clk);

    // Increment 3 times
    c = 2'b01;
    repeat (3) @(negedge clk);

    // Decrement 5 times
    c = 2'b10;
    repeat (5) @(negedge clk);

    // Reset
    c = 2'b11;
    @(negedge clk);

    $display("Lab 2-4 simulation finished.");
    $finish;
end

endmodule
