// Lab 1-3: 2:1 Multiplexer using continuous assignment (assign statement)
// Objective: Using the assign statement write a 2:1 mux

module mux21 (in1, in2, sel, out);
    input  in1;
    input  in2;
    input  sel;
    output out;

    assign out = sel ? in1 : in2;

endmodule
