// ============================================================
// Lab 4-3 : Serial Input Majority Voter
// Objective: Design a majority voter.
//   - Samples an input once per clock, takes three samples.
//   - Sets the output to the value presented on the majority of
//     the clocks (majority of the last three samples).
// ============================================================
`timescale 1ns/1ps

module majority_counter(in, clk, out);
    input  in, clk;
    output reg out;

    reg [1:0] samples;   // last two samples

    // last three samples: {oldest, middle, newest}
    wire [2:0] s = {samples, in};
    // majority of three bits
    wire majority = (s[0] & s[1]) | (s[1] & s[2]) | (s[0] & s[2]);

    always @(posedge clk) begin
        samples <= {samples[0], in};   // shift in the new sample
        out     <= majority;           // output = majority of last 3 samples
    end
endmodule
