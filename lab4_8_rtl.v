// ============================================================
// Lab 4-8 : FIFO
// Objective: Using the RAM structure, construct a FIFO with
// 128 entries, each 8 bits wide.
//   d_in_valid : push d_in into the FIFO (ignored when full)
//   d_out_req  : pop the oldest entry to d_out (ignored when empty)
//   full/empty : status flags
// ============================================================
`timescale 1ns/1ps

module fifo(d_in, d_in_valid, d_out, d_out_req, clk, full, empty);
    input  [7:0] d_in;
    input        d_in_valid, d_out_req, clk;
    output reg [7:0] d_out;
    output       full, empty;

    reg [7:0] mem [0:127];   // 128 entries x 8 bits
    reg [6:0] wr_ptr, rd_ptr;
    reg [7:0] count;         // 0..128

    integer i;
    initial begin
        wr_ptr = 7'd0; rd_ptr = 7'd0; count = 8'd0; d_out = 8'd0;
        for (i = 0; i < 128; i = i + 1) mem[i] = 8'd0;
    end

    assign full  = (count == 8'd128);
    assign empty = (count == 8'd0);

    wire do_push = d_in_valid & ~full;
    wire do_pop  = d_out_req  & ~empty;

    always @(posedge clk) begin
        if (do_push) begin
            mem[wr_ptr] <= d_in;
            wr_ptr      <= wr_ptr + 7'd1;
        end
        if (do_pop) begin
            d_out  <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 7'd1;
        end
        case ({do_push, do_pop})
            2'b10:   count <= count + 8'd1;
            2'b01:   count <= count - 8'd1;
            default: count <= count;
        endcase
    end
endmodule
