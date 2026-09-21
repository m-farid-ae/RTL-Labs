// ============================================================
// Lab 4-5 : Testbench
// Drives a known number of rising/falling edges and checks the
// count for each mode (positive only, negative only, both).
// ============================================================
`timescale 1ns/1ps
module lab4_5_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0,  tb_one_edge_count = 0, tb_both_edge_count = 0;
    integer k;

    reg        insig, p_edge, n_edge, reset;
    wire [7:0] count;
    edge_detect dut (.insig(insig), .p_edge(p_edge), .n_edge(n_edge),
                     .clk(clk), .reset(reset), .count(count));

    task check_count;
        input [7:0] exp;
        input [255:0] msg;
        begin
            if (count !== exp) begin
                errors = errors + 1;
                $display("FAIL: %0s (count=%0d exp=%0d)", msg, count, exp);
            end
          else 
            $display("PASS: %0s (count=%0d exp=%0d)", msg, count, exp);
        end
    endtask

    // one full toggle (one posedge + one negedge of insig)
    task toggle;
        begin
            @(negedge clk); insig = ~insig;
          tb_one_edge_count = tb_one_edge_count + 1;
          tb_both_edge_count = tb_both_edge_count + 1;
            repeat (2) @(negedge clk);
            insig = ~insig;
          if (p_edge == 1 && n_edge ==1) tb_both_edge_count = tb_both_edge_count + 1;
            repeat (2) @(negedge clk);
        end
    endtask
  always @(posedge reset) begin
  if(reset == 1) begin
            tb_one_edge_count = 0;
          tb_both_edge_count = 0;
          end
end
    initial begin
        insig = 0; p_edge = 0; n_edge = 0; reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;
        @(negedge clk);

        // ---- mode 1: count positive edges only (6 toggles -> 3 rising) ----
        p_edge = 1; n_edge = 0;
        for (k = 0; k < 6; k = k + 1) toggle();
        repeat (4) @(negedge clk);   // let synchronizer settle
      check_count(tb_one_edge_count, "positive-edge mode counts rising edges = ");

        // ---- mode 2: count negative edges only (4 toggles -> 2 falling) ----
        p_edge = 0; n_edge = 1;
        for (k = 0; k < 4; k = k + 1) toggle();
        repeat (4) @(negedge clk);
      check_count(tb_one_edge_count, "negative-edge mode adds falling edges = ");

        // ---- mode 3: count both edges (6 toggles -> 6 edges) ----
        p_edge = 1; n_edge = 1;
        for (k = 0; k < 6; k = k + 1) toggle();
        repeat (4) @(negedge clk);
      check_count(tb_both_edge_count, "both-edge mode adds edges = ");

        // ---- reset ----
        reset = 1; #1;
      check_count(tb_one_edge_count, "reset clears count");
        @(negedge clk); reset = 0;

        if (errors == 0) $display("LAB 4-5 PASSED");
        else             $display("LAB 4-5 FAILED (%0d errors)", errors);
        $finish;
    end
  initial begin
	$dumpfile("dump.vcd"); // waveform file name
	$dumpvars; 
  end
endmodule

