// ============================================================
// Lab 4-4 : Serial 8-bit to 1-bit (Serializer)
// Objective: Design a serializer that takes in an 8-bit input
// every 8 clock cycles and supplies a single bit out every
// clock cycle (MSB first).
// ============================================================
`timescale 1ns/1ps

module serial (bit_out, byte_in, clk, reset);
    input  [7:0] byte_in;
    input        clk, reset;
    output       bit_out;

    reg [7:0] shift;
    reg [2:0] cnt;      // 0..7 : bit position being sent

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift <= 8'd0;
            cnt   <= 3'd0;
        end else begin
          if (cnt == 3'd0) begin
                shift <= byte_in;   // load a new byte every 8 clocks
            	cnt   <= cnt + 3'd1;
            end 
          else if (cnt < 3'd7) begin
            	shift <= {shift[6:0], 1'b0};  // shift left, MSB first
                cnt   <= cnt + 3'd1;
            end 
          else begin
            	shift <= {shift[6:0], 1'b0};
                cnt   <= 3'd0;
            end
        end
    end

    assign bit_out = shift[7];
endmodule
