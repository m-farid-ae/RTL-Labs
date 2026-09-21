// Lab 2-7: Shift Operator example
// Functionality:
//   On every positive edge of the clock, the 4-bit register regA is
//   loaded with the value (1'b1 << 3). The literal 1'b1 is extended to
//   4'b0001, then shifted left by 3 positions, giving 4'b1000.
//   So regA is forced to decimal 8 (binary 1000) every clock cycle,
//   regardless of any other logic. The non-blocking assignment (<=)
//   means the update takes effect after the edge.
module lab27_shift (
    input  wire       clock,
  output reg  [3:0] regA
);

always @(posedge clock)
  regA[3:0] <= 1'b1 << 3;   // 4'b0001 << 3 = 4'b1000 = 8

endmodule
