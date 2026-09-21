// ============================================================
// Lab 4-1 : Testbench
// ============================================================
`timescale 1ns/1ps
module lab4_1_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    task check;
        input condition;
        input [255:0] msg;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("FAIL: %0s (time=%0t)", msg, $time);
            end
          else begin
            $display("PASS: %0s (time=%0t)", msg, $time);
          end
        end
    endtask

    // ---- DUT 1: sync_sc_ff ----
    reg  ffs, ffc;
    wire ffout;
    sync_sc_ff u_ff (.out(ffout), .set(ffs), .clear(ffc), .clk(clk));

    // ---- DUT 2: counter8 ----
    reg        set, clear, en;
    wire [7:0] count;
    counter8 u_cnt (.count(count), .set(set), .clear(clear), .en(en), .clk(clk));

    initial begin
        ffs = 0; ffc = 0; set = 0; clear = 0; en = 0;

        // -- test synchronous set on the raw flip-flop --
        @(negedge clk); ffs = 1;
        @(negedge clk); ffs = 0; #1;
        check(ffout === 1'b1, "sync_sc_ff set to 1");

        // -- test synchronous clear --
        @(negedge clk); ffc = 1;
        @(negedge clk); ffc = 0; #1;
        check(ffout === 1'b0, "sync_sc_ff cleared to 0");

        // -- counter: clear to zero --
        @(negedge clk); clear = 1;
        @(negedge clk); clear = 0; #1;
        check(count === 8'd0, "counter cleared to 0");

        // -- counter: set to 16 --
        @(negedge clk); set = 1;
        @(negedge clk); set = 0; #1;
        check(count === 8'd16, "counter set to 16");

        // -- counter: count down when enabled --
        @(negedge clk); en = 1;
        @(negedge clk); #1; check(count === 8'd15, "count down to 15");
        @(negedge clk); #1; check(count === 8'd14, "count down to 14");
        @(negedge clk); #1; check(count === 8'd13, "count down to 13");
      @(negedge clk); #1; check(count === 8'd12, "count down to 12");
      @(negedge clk); #1; check(count === 8'd11, "count down to 11");
      @(negedge clk); #1; check(count === 8'd10, "count down to 10");
      @(negedge clk); #1; check(count === 8'd09, "count down to 9");
      @(negedge clk); #1; check(count === 8'd08, "count down to 8");
      @(negedge clk); #1; check(count === 8'd07, "count down to 7");
      @(negedge clk); #1; check(count === 8'd06, "count down to 6");
      @(negedge clk); #1; check(count === 8'd05, "count down to 5");
      @(negedge clk); #1; check(count === 8'd04, "count down to 4");
      @(negedge clk); #1; check(count === 8'd03, "count down to 3");
      @(negedge clk); #1; check(count === 8'd02, "count down to 2");
      @(negedge clk); #1; check(count === 8'd01, "count down to 1");
      @(negedge clk); #1; check(count === 8'd00, "count down to 0");
      @(negedge clk); #1; check(count === 8'd255, "count down to 255");
      @(negedge clk); #1; check(count === 8'd254, "count down to 254");
      @(negedge clk); #1; check(count === 8'd253, "count down to 253");
      @(negedge clk); #1; check(count === 8'd252, "count down to 252");
      @(negedge clk); #1; check(count === 8'd251, "count down to 251");
      @(negedge clk); #1; check(count === 8'd250, "count down to 250");
         en = 0;

        // -- counter: hold when disabled --
      @(negedge clk); #1; check(count === 8'd250, "counter holds when en=0");

        // -- clear has priority over set/en --
        @(negedge clk); clear = 1; set = 1; en = 1;
        @(negedge clk); clear = 0; set = 0; en = 0; #1;
        check(count === 8'd0, "clear has priority");
      
      @(negedge clk); clear = 0; set = 1; en = 0; #1;
      @(negedge clk); #1; check(count === 8'd16, "counter set to 16");

        if (errors == 0) $display("LAB 4-1 PASSED");
        else             $display("LAB 4-1 FAILED (%0d errors)", errors);
        $finish;
    end
endmodule
