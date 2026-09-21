`timescale 1ns/1ps
module tb_parity_gen;
    reg         clk;
    reg  [31:0] din;
    wire [35:0] dout;
    integer errors;

    parity_gen dut (.clk(clk), .din(din), .dout(dout));
    always #5 clk = ~clk;

    task check;
        input [31:0] tdata;
        reg   [3:0]  exp_par;
        begin
            exp_par = {^tdata[31:24], ^tdata[23:16], ^tdata[15:8], ^tdata[7:0]};
            din = tdata;
            @(posedge clk); #1;
            if (dout !== {exp_par, tdata}) begin
                errors = errors + 1;
                $display("FAIL din=%h dout=%h (exp %h)", tdata, dout, {exp_par, tdata});
            end else
                $display("PASS din=%h dout=%h", tdata, dout);
        end
    endtask

    initial begin
        clk = 0; din = 0; errors = 0;
        check(32'h00000000);
        check(32'hFFFFFFFF);
        check(32'h12345678);
        check(32'hDEADBEEF);
        check(32'h00000001);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
