// Lab 2-6a Testbench
`timescale 1ns/1ps
module tb_pattern_count;

reg  [31:0] din;
wire [3:0]  count;

pattern_count dut (.din(din), .count(count));

task check;
    input [31:0] val;
    input [3:0]  exp;
    begin
        din = val; #10;
        $display("din = %h  count = %0d  expected = %0d  %s",
                 din, count, exp, (count == exp) ? "PASS" : "FAIL");
    end
endtask

initial begin
    $display("--- Lab 2-6a: 010 pattern counter ---");
    check(32'b01010, 2);                          // overlapping example
    check(32'b0, 0);                              // no pattern
    check(32'hAAAAAAAA, 15);                      // 1010... -> 15 overlapping 010s
    check(32'h55555555, 15);                      // all 0101... -> 15 patterns
    check(32'h55555554, 15);
    check(32'h00000000, 0);
  check(32'b00100010001000100010001000100010, 8);
  check(32'h24924924, 10);
    check({28'd0, 4'b0101}, 1);
    check(32'h95555555, 14);
    $display("Lab 2-6a simulation finished.");
    $finish;
end

endmodule
