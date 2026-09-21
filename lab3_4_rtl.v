// Lab 3-4 : Count number of 1's in an 8-bit vector and
//           find position (index) of the first '1' (scanning from bit 0 upward).
//           Outputs are registered: valid one clock cycle after val is applied.
//           pos = 8 when there are no ones in val.
module count_ones (clk, reset, val, Num, pos);
    input        clk, reset;
    input  [7:0] val;
    output [3:0] Num;
    output [3:0] pos;

    reg [3:0] Num;
    reg [3:0] pos;
    integer i;
    reg [3:0] cnt;
    reg [3:0] first;
    reg       found;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Num <= 4'd0;
            pos <= 4'd0;
        end else begin
            cnt   = 4'd0;
            first = 4'd8;   // default: no ones found
            found = 1'b0;
            for (i = 0; i < 8; i = i + 1) begin
                if (val[i]) begin
                    cnt = cnt + 1'b1;
                    if (!found) begin
                        first = i[3:0];
                        found = 1'b1;
                    end
                end
            end
            Num <= cnt;
            pos <= first;
        end
    end
endmodule
