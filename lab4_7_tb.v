// ============================================================
// Lab 4-7 : Testbench
// Writes a known pattern to all 16 registers, reads them back
// back-to-back (one read per clock) and checks the data.
// ============================================================
`timescale 1ns/1ps
module lab4_7_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer i;

    reg  [7:0] d_in;
    wire [7:0] d_out;
    reg  [3:0] addr_in;
    reg        r_w;
    regfile dut (.d_out(d_out), .d_in(d_in), .addr_in(addr_in), .r_w(r_w), .clk(clk));

    initial begin
        d_in = 0; addr_in = 0; r_w = 0;

        // ---- write a known pattern to every register ----
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            r_w     = 1'b1;
            addr_in = i[3:0];
            d_in    = 8'hA0 + i;
        end

        // ---- read all registers back, one per clock (back-to-back) ----
        @(negedge clk); r_w = 1'b0; addr_in = 4'd0;
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk); addr_in = i[3:0];
            @(posedge clk); #1;
            if (d_out !== (8'hA0 + i)) begin
                errors = errors + 1;
                $display("FAIL: reg[%0d] = %x exp=%x", i, d_out, 8'hA0 + i);
            end
          else
            $display("PASS: reg[%0d] = %x exp=%x", i, d_out, 8'hA0 + i);
        end

        // ---- overwrite a single register and verify the others are intact ----
        @(negedge clk); r_w = 1'b1; addr_in = 4'd5; d_in = 8'hFF;
        @(negedge clk); r_w = 1'b0; addr_in = 4'd5;
        @(posedge clk); #1;
        if (d_out !== 8'hFF) begin
            errors = errors + 1;
            $display("FAIL: reg[5] = %02x exp=ff", d_out);
        end
      else begin $display("PASS: reg[7] = %02x exp=ff", d_out); end
        @(negedge clk); addr_in = 4'd7;
        @(posedge clk); #1;
        if (d_out !== 8'hA7) begin
            errors = errors + 1;
            $display("FAIL: reg[7] = %02x exp=a7", d_out);
        end
      else begin $display("PASS: reg[7] = %02x exp=a7", d_out); end

      if (errors == 0) $display("LAB 4-7 PASSED");
        else             $display("LAB 4-7 FAILED (%0d errors)", errors);
        $finish;
    end
  initial begin
	$dumpfile("dump.vcd"); // waveform file name
	$dumpvars; 
  end
endmodule
