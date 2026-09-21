// ============================================================
// Lab 4-5 : Edge Detector
// Objective: Design an edge detector which counts either positive
// or negative edges or both of an input signal.
//   p_edge = 1 : count positive edges of insig
//   n_edge = 1 : count negative edges of insig
//   both   = 1 : count both edges
// ============================================================
`timescale 1ns/1ps

module edge_detect (insig, p_edge, n_edge, clk, reset, count);
    input        insig, p_edge, n_edge, clk, reset;
    output reg [7:0] count;

    // two-flop synchronizer for the asynchronous input
    reg insig_d, insig_dd;
    wire pos_pulse =  insig_d & ~insig_dd;   // rising edge detected
    wire neg_pulse = ~insig_d &  insig_dd;   // falling edge detected

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            insig_d  <= 1'b0;
            insig_dd <= 1'b0;
            count    <= 8'd0;
        end else begin
            insig_d  <= insig;
            insig_dd <= insig_d;
            if ((p_edge & pos_pulse) | (n_edge & neg_pulse))
                count <= count + 8'd1;
        end
    end
endmodule
