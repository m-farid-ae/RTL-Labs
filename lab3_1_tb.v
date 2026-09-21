`timescale 1ns/1ps
module tb_mux8to1;
    reg  [4:0] a0, a1, a2, a3, a4, a5, a6, a7;
    reg  [2:0] sel;
    wire [4:0] dout;
    integer i;

    mux8to1 dut (.a0(a0), .a1(a1), .a2(a2), .a3(a3),
                 .a4(a4), .a5(a5), .a6(a6), .a7(a7),
                 .sel(sel), .dout(dout));

    initial begin
        a0 = 5'd0;  a1 = 5'd1;  a2 = 5'd2;  a3 = 5'd3;
        a4 = 5'd4;  a5 = 5'd5;  a6 = 5'd6;  a7 = 5'd7;
        $display("Time  sel  dout (expected)");
        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0];
            #10;
            $display("%0t    %0d    %0d (exp %0d) %s",
                     $time, sel, dout, i, (dout == i[4:0]) ? "PASS" : "FAIL");
        end
        $finish;
    end
   
endmodule
