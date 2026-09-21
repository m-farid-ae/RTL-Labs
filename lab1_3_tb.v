// Lab 1-3: Testbench for 2:1 mux (mux21)

`timescale 1ns/1ps

module tb_mux21;

    reg  in1, in2, sel;
    wire out;
    integer errors;

    mux21 dut (
        .in1 (in1),
        .in2 (in2),
        .sel (sel),
        .out (out)
    );

    task check;
        input exp;
        begin
            #10;
            if (out === exp)
                $display("  in1=%b in2=%b sel=%b | out=%b (exp=%b) | PASS",
                         in1, in2, sel, out, exp);
            else begin
                $display("  in1=%b in2=%b sel=%b | out=%b (exp=%b) | FAIL",
                         in1, in2, sel, out, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        $display("-----------------------------------------------");
        $display(" Lab 1-3 : 2:1 Mux Simulation Results");
        $display("-----------------------------------------------");

        in1 = 0; in2 = 0; sel = 0; check(0);
        in1 = 0; in2 = 1; sel = 0; check(1);   // sel=0 -> out = in2
        in1 = 1; in2 = 0; sel = 0; check(0);
        in1 = 1; in2 = 1; sel = 0; check(1);
        in1 = 0; in2 = 0; sel = 1; check(0);
        in1 = 0; in2 = 1; sel = 1; check(0);   // sel=1 -> out = in1
        in1 = 1; in2 = 0; sel = 1; check(1);
        in1 = 1; in2 = 1; sel = 1; check(1);

        $display("-----------------------------------------------");
        if (errors == 0)
            $display(" RESULT: ALL TESTS PASSED (8/8) - Lab 1-3 OK");
        else
            $display(" RESULT: %0d TEST(S) FAILED", errors);
        $display("-----------------------------------------------");
        $finish;
    end

endmodule
