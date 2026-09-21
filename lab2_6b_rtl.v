// Lab 2-6b: 8-bit Shifter
// Load has highest priority, then shift left (zero fill), then shift right
module shifter_8bit (
    input  wire       CLK,
    input  wire       SHL,   // shift left
    input  wire       SHR,   // shift right
    input  wire       Load,  // load value
    input  wire [7:0] din,   // value to load
    output reg  [7:0] dout
);

always @(posedge CLK) begin
    if (Load)
        dout <= din;            // load value
    else if (SHL)
        dout <= dout << 1;      // shift left, 0 shifted in
    else if (SHR)
        dout <= dout >> 1;      // shift right, 0 shifted in
    else
        dout <= dout;           // hold
end

endmodule
