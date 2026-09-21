// Lab 2-5: Divide a 16-bit input by 3 using while loop
// result = din / 3, remainder = din % 3
module div_by_3 (
    input  wire [15:0] din,
    output reg  [14:0] result,
    output reg  [1:0]  remainder
);

integer temp;

always @(*) begin
    result    = 0;
    remainder = 0;
    temp      = din;
    // Successive subtraction: count how many times 3 fits into din
    while (temp >= 3) begin
        temp   = temp - 3;
        result = result + 1;
    end
    remainder = temp[1:0];
end

endmodule
