// ============================================================
// Lab 4-6 : Sequence Detector
// Objective: Design a detector to detect 0110 or 0101 sequence.
//   - Outputs a one for one clock cycle when either sequence is
//     detected.
//   - The sequences will not overlap.
// ============================================================
`timescale 1ns/1ps

module seq_detect (in_wire, out, clk, reset);
    input  in_wire, clk, reset;
    output reg out;
  wire temp;

    // state = value of the matched prefix of "01.."
    localparam S0 = 3'd0,  // no match / idle
               S1 = 3'd1,  // seen "0"
               S2 = 3'd2,  // seen "01"
               S3 = 3'd3,  // seen "011"  -> 0 completes 0110
               S4 = 3'd4;  // seen "010"  -> 1 completes 0101

    reg [2:0] state;

    always @(posedge clk or posedge reset) begin
      if (reset) begin
            state <= S0;
        out <= 1'b0; end
        else begin
          	out <= temp; 
            case (state)
                S0: state <= in_wire ? S0 : S1;
                S1: state <= in_wire ? S2 : S1;
                S2: state <= in_wire ? S3 : S4;
                // "0110" detected on 0, "0111" is no match; non-overlapping
                S3: state <= S0;
                // "0101" detected on 1; "0100" keeps trailing "0" as new start
                S4: state <= in_wire ? S0 : S1;
                default: state <= S0;
            endcase
        end
    end

    // Mealy output: pulse for exactly one clock cycle on completion
    assign temp = (state == S3 && !in_wire) || (state == S4 && in_wire);
endmodule
