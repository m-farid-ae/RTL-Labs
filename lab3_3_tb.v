`timescale 1ns/1ps
module tb_decoder3to8;
    reg  [2:0] d_in;
    reg        en;
    wire [7:0] d;

    decoder3to8 dut (.d_in(d_in), .en(en),
                     .d0(d[0]), .d1(d[1]), .d2(d[2]), .d3(d[3]),
                     .d4(d[4]), .d5(d[5]), .d6(d[6]), .d7(d[7]));
    integer i;
    initial begin
        $display("Time  en  d_in  d[7:0]   (expected)");
        en = 1'b0; d_in = 3'd5; #10;
        $display("%0t   %b   %0d   %b  (exp 00000000) %s",
                 $time, en, d_in, d, (d == 8'b0) ? "PASS" : "FAIL");
        for (i = 0; i < 8; i = i + 1) begin
            en = 1'b1; d_in = i[2:0]; #10;
            $display("%0t   %b   %0d   %b  (exp %b) %s",
                     $time, en, d_in, d, (8'b1 << i),
                     (d == (8'b1 << i)) ? "PASS" : "FAIL");
        end
        $finish;
    end
endmodule
