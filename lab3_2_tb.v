`timescale 1ns/1ps
module tb_comparator_rel;
    reg  [7:0] a, b;
    wire EQ, GT, LT;
    integer errors;

    comparator_rel dut (.a(a), .b(b), .EQ(EQ), .GT(GT), .LT(LT));

    task check;
        input [7:0] ta, tb;
        begin
            a = ta; b = tb; #10;
            if ((EQ !== (a==b)) || (GT !== (a>b)) || (LT !== (a<b))) begin
                errors = errors + 1;
                $display("FAIL a=%0d b=%0d EQ=%b GT=%b LT=%b", a, b, EQ, GT, LT);
            end else
                $display("PASS a=%0d b=%0d EQ=%b GT=%b LT=%b", a, b, EQ, GT, LT);
        end
    endtask

    initial begin
        errors = 0;
        check(8'd10, 8'd10);  // equal
        check(8'd200, 8'd100); // greater
        check(8'd50, 8'd75);  // less
        check(8'd0, 8'd0);
        check(8'd255, 8'd1);
        check(8'd1, 8'd255);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
