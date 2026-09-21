// Lab 3-2 : 8-bit comparator with EQ, GT, LT outputs
module comparator_rel (a, b, EQ, GT, LT);
    input  [7:0] a, b;
    output       EQ, GT, LT;

    assign EQ = (a == b);
    assign GT = (a >  b);
    assign LT = (a <  b);
endmodule
