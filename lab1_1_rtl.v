// Lab 1-1: Full Adder (Behavioral / Dataflow description)
// Build (compile) the full_adder circuit described in Verilog for simulation

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
