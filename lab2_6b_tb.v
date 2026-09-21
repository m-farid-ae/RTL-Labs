// Lab 2-6b Testbench
`timescale 1ns/1ps
module tb_shifter_8bit;

reg        CLK, SHL, SHR, Load;
reg  [7:0] din;
wire [7:0] dout;

shifter_8bit dut (.CLK(CLK), .SHL(SHL), .SHR(SHR), .Load(Load), .din(din), .dout(dout));

always #5 CLK = ~CLK;

task tick;
    begin
        @(negedge CLK);
        $display("t=%0t  Load=%b SHL=%b SHR=%b  dout = %b (%0d)",
                 $time, Load, SHL, SHR, dout, dout);
    end
endtask

initial begin
    CLK = 0; SHL = 0; SHR = 0; Load = 0; din = 8'h00;
    $display("--- Lab 2-6b: 8-bit shifter ---");

    // Load 0b1011_0011 = 179
    din = 8'b1011_0011; Load = 1; tick;
    Load = 0;

    // Shift left twice
    SHL = 1; tick;
    tick;
    SHL = 0;

    // Shift right three times
    SHR = 1; tick;
    tick;
    tick;
    SHR = 0;

    // Hold
    tick;

    // Load then shift right (check zero fill on MSB)
    din = 8'h80; Load = 1; tick;
    Load = 0; SHR = 1; tick;
    SHL = 1; SHR = 0; tick;

    $display("Lab 2-6b simulation finished.");
    $finish;
end

endmodule
