// Lab 2-4: 8-bit Counter using case construct
// c=00: load din, c=01: increment, c=10: decrement, c=11: reset to 0
module counter_case (
    input  wire [7:0] din,
    input  wire [1:0] c,
    input  wire       clk,
    output reg  [7:0] dout
);

always @(posedge clk) begin
    case (c)
        2'b00:   dout <= din;      // Load data
        2'b01:   dout <= dout + 1; // Increment by 1
        2'b10:   dout <= dout - 1; // Decrement by 1
        2'b11:   dout <= 8'd0;     // Reset
        default: dout <= dout;
    endcase
end

endmodule
