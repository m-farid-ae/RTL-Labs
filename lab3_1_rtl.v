// Lab 3-1 : 8-to-1 multiplexer, eight 5-bit inputs, 3-bit select, 5-bit output
module mux8to1 (a0, a1, a2, a3, a4, a5, a6, a7, sel, dout);
    input  [4:0] a0, a1, a2, a3, a4, a5, a6, a7;
    input  [2:0] sel;
    output reg [4:0] dout;

    // Using case statement
    always @(*) begin
        case (sel)
            3'd0:    dout = a0;
            3'd1:    dout = a1;
            3'd2:    dout = a2;
            3'd3:    dout = a3;
            3'd4:    dout = a4;
            3'd5:    dout = a5;
            3'd6:    dout = a6;
            3'd7:    dout = a7;
            default: dout = 5'b0;
        endcase
    end
endmodule
