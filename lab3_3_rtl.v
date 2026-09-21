// Lab 3-3 : 3-to-8 decoder with enable
module decoder3to8 (d_in, en, d0, d1, d2, d3, d4, d5, d6, d7);
    input  [2:0] d_in;
    input        en;
    output       d0, d1, d2, d3, d4, d5, d6, d7;
    reg          d0, d1, d2, d3, d4, d5, d6, d7;

    always @(*) begin
        {d7, d6, d5, d4, d3, d2, d1, d0} = 8'b0;
        if (en)
            case (d_in)
                3'd0: d0 = 1'b1;
                3'd1: d1 = 1'b1;
                3'd2: d2 = 1'b1;
                3'd3: d3 = 1'b1;
                3'd4: d4 = 1'b1;
                3'd5: d5 = 1'b1;
                3'd6: d6 = 1'b1;
                3'd7: d7 = 1'b1;
            endcase
    end
endmodule
