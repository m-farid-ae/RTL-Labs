// Lab 2-8: 8-to-1 multiplexer using the ternary (conditional) operator
module mux_8to1 (
    input  wire [7:0] d0, d1, d2, d3, d4, d5, d6, d7,
    input  wire [2:0] sel,
    output wire [7:0] out
);

assign out = (sel == 3'd0) ? d0 :
             (sel == 3'd1) ? d1 :
             (sel == 3'd2) ? d2 :
             (sel == 3'd3) ? d3 :
             (sel == 3'd4) ? d4 :
             (sel == 3'd5) ? d5 :
             (sel == 3'd6) ? d6 : d7;

endmodule
