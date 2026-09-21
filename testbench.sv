// ============================================================
// Lab 4-9 : Testbench
// Sends UART commands: write 0x5A to addr 0x10, write 0xC3 to
// addr 0x11, then reads both locations back over the UART TX
// line and checks the returned data.
// ============================================================
`timescale 1ns/1ps
module lab4_9_tb;
    parameter CLKS_PER_BIT = 16;
    localparam BIT = CLKS_PER_BIT * 10;   // 160 ns per UART bit

    reg clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;

    reg  reset, rx_serial;
    wire tx_serial;
    uart_mem_top #(CLKS_PER_BIT) dut (
        .tx_serial(tx_serial), .rx_serial(rx_serial), .clk(clk), .reset(reset));

    task check;
        input condition;
        input [255:0] msg;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("FAIL: %0s (time=%0t)", msg, $time);
            end
        end
    endtask

    // host-side UART transmit: 8N1, LSB first
    task send_byte;
        input [7:0] b;
        integer k;
        begin
            $display("Inside task send_byte at time =%0t)", $time);
            rx_serial = 1'b0;            // start bit
            #(BIT);
            for (k = 0; k < 8; k = k + 1) begin
                rx_serial = b[k];
                $display("rx_serial = b[k] -> b = %0h, k = %0h, rx_serial = %0h at time =%0t)", b, k, rx_serial, $time);
                #(BIT);
            end
            rx_serial = 1'b1;            // stop bit
            #(BIT);
        end
    endtask

    // host-side UART receive
    task recv_byte;
        output [7:0] b;
        integer k;
        begin
            $display("Inside task recv_byte at time =%0t)", $time);
            @(negedge tx_serial);        // wait for start bit
            #(BIT/2);                    // middle of start bit
            for (k = 0; k < 8; k = k + 1) begin
                #(BIT);
                b[k] = tx_serial;
                $display("b[k] = tx_serial -> b = %0h, k = %0h, tx_serial = %0h at time =%0t)", b, k, tx_serial, $time);
            end
            #(BIT);                      // pass stop bit
        end
    endtask

    reg [7:0] got;

    initial begin
        reset = 1; rx_serial = 1'b1; got = 8'b0;
        repeat (5) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // ---- WRITE 0x5A -> address 0x10 ----
        send_byte(8'h01);                // WRITE command
        send_byte(8'h10);                // address
        send_byte(8'h5A);                // data
      repeat (20) @(posedge clk);

        // ---- WRITE 0xC3 -> address 0x11 ----
        send_byte(8'h01);
        send_byte(8'h11);
        send_byte(8'hC3);
        repeat (20) @(posedge clk);
		$display("mem[0x10] = %h, mem[0x11] = %h",
         dut.u_ram.mem[8'h10], dut.u_ram.mem[8'h11]);
        // ---- READ address 0x10, expect 0x5A back ----
        $display("---- READ address 0x10, expect 0x5A back ----");
        $display("READ starts at time =%0t)", $time);
        send_byte(8'h00);                // READ command
      $display("READ command =%h", 8'h00);
        send_byte(8'h10);                // address
      $display("READ address =%h and time = %0t", 8'h10, $time);
        recv_byte(got);
      $display("READ received =%h", got);
        check(got === 8'h5A, "read back 0x5A from address 0x10");

        // ---- READ address 0x11, expect 0xC3 back ----
        $display("---- READ address 0x10, expect 0xC3 back ----");
        $display("READ starts at time =%0t)", $time);
        send_byte(8'h00);
      $display("READ command =%h", 8'h00);
        send_byte(8'h11);
      $display("READ address =%h and time = %0t", 8'h11, $time);
        recv_byte(got);
      $display("READ received =%h", got);
        check(got === 8'hC3, "read back 0xC3 from address 0x11");

        // ---- READ back-to-back ----
        $display("---- READ back-to-back ----");
        $display("READ starts at time =%0t)", $time);
      send_byte(8'h00); $display("READ command =%h", 8'h00); send_byte(8'h10); $display("READ address =%h and time = %0t", 8'h10, $time);
      recv_byte(got);
      check(got === 8'h5A, "back-to-back read 0x10 = 0x5A");
      $display("READ received =%h", got);
      send_byte(8'h00); $display("READ command =%h", 8'h00); send_byte(8'h11); $display("READ address =%h and time = %0t", 8'h11, $time);
      recv_byte(got);
      $display("READ received =%h", got);
        check(got === 8'hC3, "back-to-back read 0x11 = 0xC3");
        
        if (errors == 0) $display("LAB 4-9 PASSED");
        else             $display("LAB 4-9 FAILED (%0d errors)", errors);
        $finish;
    end

    // watchdog
    initial begin
        #5_000_000;
        $display("LAB 4-9 FAILED: timeout");
        $finish;
    end
  initial begin
	$dumpfile("dump.vcd"); // waveform file name
	$dumpvars; 
  end
endmodule
