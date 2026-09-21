// ============================================================
// Lab 4-2 : 8-bit Up/Down Counter
// Objective: Design an 8-bit counter with an up/down control input.
//   reset   : asynchronous reset (positive edge of the reset pulse)
//   up_down : count up when 1, count down when 0
// ============================================================
`timescale 1ns/1ps

module counter (reset, clock, up_down, count);
    input        reset, clock, up_down;
    output reg [7:0] count;

    always @(posedge clock or posedge reset) begin
        if (reset)
            count <= 8'd0;                  // asynchronous reset
        else if (up_down)
            count <= count + 8'd1;          // count up
        else
            count <= count - 8'd1;          // count down
    end
endmodule
