// Lab 3-6a : Parity generator for 32-bit data.
//            Generates 4 parity bits which are appended in bits [35:32]:
//            dout = {parity[3:0], din[31:0]}
//            parity[0] = even parity of din[7:0]
//            parity[1] = even parity of din[15:8]
//            parity[2] = even parity of din[23:16]
//            parity[3] = even parity of din[31:24]
//            Output is registered on the clock.
module parity_gen (clk, din, dout);
    input        clk;
    input  [31:0] din;
    output [35:0] dout;

    reg [35:0] dout;
    reg        p0, p1, p2, p3;

    always @(posedge clk) begin
        p0 = ^din[7:0];
        p1 = ^din[15:8];
        p2 = ^din[23:16];
        p3 = ^din[31:24];
        dout <= {p3, p2, p1, p0, din};
    end
endmodule
