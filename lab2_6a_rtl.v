// Lab 2-6a: Count overlapping '010' patterns in a 32-bit input
// Example: 01010 counts as two patterns
module pattern_count (
    input  wire [31:0] din,
    output reg  [3:0]  count
);

integer i;

always @(*) begin
    count = 0;
    for (i = 0; i < 30; i = i + 1) begin
        if (din[i+2] == 1'b0 && din[i+1] == 1'b1 && din[i] == 1'b0)
            count = count + 1;
    end
end

endmodule
