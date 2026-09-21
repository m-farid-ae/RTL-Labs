`timescale 1ns/1ps

// Synchronous set/clear flip-flop (holds value otherwise)
module sync_sc_ff(out, set, clear, clk);
    input  set, clear, clk;
    output reg out;
    always @(posedge clk) begin
        if (clear)
            out <= 1'b0;        // synchronous clear (has priority)
        else if (set)
            out <= 1'b1;        // synchronous set
        else
          out <= out;  
    end
endmodule

module counter8(count, set, clear, en, clk);
    input  set, clear, en, clk;
    output [7:0] count;

    wire [7:0] val16 = 8'd16;                 // set value
    wire       counting = en & ~set & ~clear; // en only counts when no set/clear
    wire [7:0] nxt = count - 8'd1;            // next value when counting down

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : G_BIT
            wire bit_set, bit_clear;
            // global clear forces every bit to 0 (wins via FF priority)
            assign bit_clear = clear | (counting &  count[i] & ~nxt[i]);
            // global set forces 16; while counting, set bits that go 0->1
            assign bit_set   = ~clear &
                               (set   ? val16[i] :
                                        (counting & ~count[i] &  nxt[i]));
            sync_sc_ff u_ff (
                .out  (count[i]),
                .set  (bit_set),
                .clear(bit_clear),
                .clk  (clk)
            );
        end
    endgenerate
endmodule