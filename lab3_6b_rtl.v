// Lab 3-6b : Multiply a 6-bit number by 3 using synthesizable RTL
//            WITHOUT the '*' operator:  x*3 = (x<<1) + x
//            6-bit input, up to 63*3 = 189, so 8-bit output.
module mult3 (mult_in, en, mult_out);
    input  [5:0] mult_in;
    input        en;
    output [7:0] mult_out;

    wire [6:0] shifted;   // mult_in << 1 (needs 7 bits)
    wire [7:0] sum;       // (mult_in<<1) + mult_in

    assign shifted = {mult_in, 1'b0};
    assign sum     = {1'b0, shifted} + {2'b00, mult_in};

    assign mult_out = en ? sum : 8'd0;
endmodule
