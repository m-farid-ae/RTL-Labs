// ============================================================
// Lab 4-8 : Testbench
// push/pop checks, full flag, empty flag, and simultaneous
// push+pop while full.
// ============================================================
`timescale 1ns/1ps
module lab4_8_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer i;

    reg  [7:0] d_in;
    reg        d_in_valid, d_out_req;
    wire [7:0] d_out;
    wire       full, empty;
    fifo dut (.d_in(d_in), .d_in_valid(d_in_valid), .d_out(d_out),
              .d_out_req(d_out_req), .clk(clk), .full(full), .empty(empty));

    task check;
        input condition;
      input [2255:0] msg;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("FAIL: %0s (time=%0t)", msg, $time);
            end
          else $display("PASS: %0s (time=%0t)", msg, $time);
        end
    endtask

    task push;
        input [7:0] v;
        begin
            d_in = v; d_in_valid = 1'b1;
            @(posedge clk); #1;
            d_in_valid = 1'b0;
        end
    endtask

    task pop_check;
        input [7:0] exp;
        input [255:0] msg;
        begin
            d_out_req = 1'b1;
            @(posedge clk); #1;
            d_out_req = 1'b0;
            check(d_out === exp, msg);
        end
    endtask

    initial begin
        d_in = 0; d_in_valid = 0; d_out_req = 0;

        // ---- empty at start ----
        #1; check(empty === 1'b1, "FIFO empty after reset");

        // ---- basic push / pop (FIFO order) ----
        push(8'h11); push(8'h22); push(8'h33);
        check(empty === 1'b0, "not empty after pushes");
        pop_check(8'h11, "pop 1st = 0x11");
        pop_check(8'h22, "pop 2nd = 0x22");
        pop_check(8'h33, "pop 3rd = 0x33");
        check(empty === 1'b1, "empty after draining");

        // ---- fill completely ----
        for (i = 0; i < 128; i = i + 1) push(i[7:0]);
        check(full === 1'b1, "full after 128 pushes");
        push(8'hEE);   // must be ignored
        check(full === 1'b1, "push ignored while full");

        // ---- simultaneous push + pop while full ----
        d_in = 8'hAA; d_in_valid = 1'b1; d_out_req = 1'b1;
        @(posedge clk); #1;
        d_in_valid = 1'b0; d_out_req = 1'b0;
        check(d_out === 8'd0,  "simultaneous pop returns oldest entry 0");
      check(full !== 1'b1,   "should not be full after simultaneous push+pop because push was ignored due to fifo full at that time and popped successful because it was not empty ");
      @(posedge clk); #1;
      @(posedge clk); #1;
      pop_check(8'd1, "pushed value comes out after the old entries");
        pop_check(8'd2,  "order preserved after simultaneous access");
      

        // ---- drain everything ----
        for (i = 3; i < 128; i = i + 1) begin
            d_out_req = 1'b1;
            @(posedge clk); #1;
            d_out_req = 1'b0;
            if (d_out !== (i[7:0])) begin
                errors = errors + 1;
                $display("FAIL: drain[%0d] = %02x exp=%02x", i, d_out, i[7:0]);
            end
          	else $display("PASS: drain[%0d] = %02x exp=%02x", i, d_out, i[7:0]);
        end
        check(empty === 1'b1, "empty after full drain");

        if (errors == 0) $display("LAB 4-8 PASSED");
        else             $display("LAB 4-8 FAILED (%0d errors)", errors);
        $finish;
    end
  initial begin
  	$dumpfile("dump.vcd"); // waveform file name
	$dumpvars; 
  end
endmodule
