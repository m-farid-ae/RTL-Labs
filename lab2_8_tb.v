// Lab 2-8 Testbench
`timescale 1ns/1ps
module tb_mux_8to1;

reg  [7:0] d0, d1, d2, d3, d4, d5, d6, d7;
reg  [2:0] sel;
wire [7:0] out;

mux_8to1 dut (.d0(d0), .d1(d1), .d2(d2), .d3(d3),
              .d4(d4), .d5(d5), .d6(d6), .d7(d7),
              .sel(sel), .out(out));

integer k;
reg [7:0] data [0:7];
reg [7:0] exp;

initial begin
    d0 = 8'h11; d1 = 8'h22; d2 = 8'h33; d3 = 8'h44;
    d4 = 8'h55; d5 = 8'h66; d6 = 8'h77; d7 = 8'h88;
    data[0] = d0; data[1] = d1; data[2] = d2; data[3] = d3;
    data[4] = d4; data[5] = d5; data[6] = d6; data[7] = d7;

    $display("sel  out  expected  result");
    for (k = 0; k < 8; k = k + 1) begin
        sel = k; #10;
        exp = data[k];
        $display("%0d    %h   %h      %s", sel, out, exp, (out == exp) ? "PASS" : "FAIL");
    end
    $display("Lab 2-8 simulation finished.");
    $finish;
end

endmodule
