// ============================================================
// Lab 4-6 : Testbench
// Streams random bits and compares against an independent
// non-overlapping sequence scanner (scoreboard).
// ============================================================
`timescale 1ns/1ps

module lab4_6_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer k;
    integer detections = 0;

    reg  in_wire, reset;
    wire out;
    seq_detect dut (.in_wire(in_wire), .out(out), .clk(clk), .reset(reset));

    // ---- scoreboard: scan for non-overlapping 0110 / 0101 ----
  reg [3:0] window, temp_out;
    reg       sb_out;
   always @(posedge clk or posedge reset) begin
       if (reset) begin
           window  <= 4'd0;
            sb_out  <= 1'd0;
       end else begin
         sb_out  <= temp_out;
           window <= {window[2:0], in_wire};
          //sb_out <= (window[2:0] == 3'b011 && !in_wire && !sb_out) ||   // 0110
          //(window[2:0] == 3'b010 &&  in_wire && !sb_out);     // 0101
            //non-overlap: after a detection the window restarts
           if ((window[2:0] == 3'b011 && !in_wire) ||
               (window[2:0] == 3'b010 &&  in_wire))
               window <= 4'd0;
       end
    end
  assign temp_out = (window[2:0] == 3'b011 && !in_wire) ||   // 0110
          			(window[2:0] == 3'b010 &&  in_wire);     // 0101

    initial begin
        in_wire = 0; reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // random stream
       for (k = 0; k < 400; k = k + 1) begin
           @(negedge clk);
           in_wire = $random;
           @(posedge clk); #1;
            if (out !== sb_out) begin
               errors = errors + 1;
             $display("FAIL: t=%0t in=%b out=%b exp=%b", $time, in_wire, out, sb_out);
            end
          else $display("PASS: t=%0t in=%b out=%b exp=%b", $time, in_wire, out, sb_out);
          if (out === 1'b1) detections = detections + 1;
        end

        // directed: clean 0110 then clean 0101 (non-overlapping)
        @(negedge clk); in_wire = 0; @(posedge clk); #1; check_pulse(0, "bit1 of 0110");
        @(negedge clk); in_wire = 1; @(posedge clk); #1; check_pulse(0, "bit2 of 0110");
        @(negedge clk); in_wire = 1; @(posedge clk); #1; check_pulse(0, "bit3 of 0110");
        @(negedge clk); in_wire = 0; @(posedge clk); #1; check_pulse(1, "0110 detected");
        @(negedge clk); in_wire = 0; @(posedge clk); #1; check_pulse(0, "gap after 0110");
        @(negedge clk); in_wire = 1; @(posedge clk); #1; check_pulse(0, "bit2 of 0101");
        @(negedge clk); in_wire = 0; @(posedge clk); #1; check_pulse(0, "bit3 of 0101");
        @(negedge clk); in_wire = 1; @(posedge clk); #1; check_pulse(1, "0101 detected");
        @(negedge clk); in_wire = 0; @(posedge clk); #1; check_pulse(0, "gap after 0101");

        $display("INFO: %0d detections in 400 random bits", detections);
        if (errors == 0) $display("LAB 4-6 PASSED");
        else             $display("LAB 6 FAILED (%0d errors)", errors);
        $finish;
    end

    task check_pulse;
        input exp;
        input [255:0] msg;
        begin
            if (out !== exp) begin
                errors = errors + 1;
                $display("FAIL: %0s (out=%b exp=%b)", msg, out, exp);
            end
          else
            $display("PASS: %0s (out=%b exp=%b)", msg, out, exp);
        end
    endtask
  initial begin
	$dumpfile("dump.vcd"); // waveform file name
	$dumpvars; 
  end
endmodule
