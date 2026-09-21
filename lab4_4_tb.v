// ============================================================
// Lab 4-4 : Testbench
// ============================================================
`timescale 1ns/1ps
module lab4_4_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer i;

    reg  [7:0] byte_in;
    reg        reset;
    wire       bit_out;
    serial dut (.bit_out(bit_out), .byte_in(byte_in), .clk(clk), .reset(reset));

    reg [7:0] got;

    // capture 8 serialized bits starting from a freshly loaded byte
    task capture;
        output [7:0] g;
        begin
            g = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                g = {g[6:0], bit_out};   // MSB first
              @(posedge clk); #1;
            end
        end
    endtask

    initial begin
        byte_in = 8'hA5; reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // first byte: 8 clocks after reset release the first byte is loaded
      repeat (8) @(posedge clk); #1;
        capture(got);
        if (got !== 8'hA5) begin
            errors = errors + 1;
            $display("FAIL: byte 1 got=%02x exp=a5", got);
        end
      	else 
          $display("PASS: byte 1 got=%02x exp=a5", got);

        // second byte (same byte_in, loaded again 8 clocks later)
        capture(got);
        if (got !== 8'hA5) begin
            errors = errors + 1;
            $display("FAIL: byte 2 got=%02x exp=a5", got);
        end
      else 
          $display("PASS: byte 1 got=%02x exp=a5", got);

        // change the byte between loads
        byte_in = 8'h3C;
        capture(got);          // captures the 3C load that happened mid-capture
        capture(got);
        if (got !== 8'h3C) begin
            errors = errors + 1;
            $display("FAIL: byte 4 got=%02x exp=3c", got);
        end
      else 
        $display("PASS: byte 1 got=%02x exp=3c", got);

        if (errors == 0) $display("LAB 4-4 PASSED");
        else             $display("LAB 4-4 FAILED (%0d errors)", errors);
        $finish;
    end
  initial begin
	$dumpfile("dump.vcd"); // waveform file name
	$dumpvars; 
  end
endmodule
