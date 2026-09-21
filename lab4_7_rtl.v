// ============================================================
// Lab 4-7 : Register File (16 x 8-bit)
// Objective: Design a synthesizable 16x8 bit register file using
// the single-bit D-FF.
//   addr_in : register address (4 bits)
//   r_w     : 1 = write d_in to register addr_in
//             0 = read register addr_in onto d_out
//   All accesses take one clock cycle; back-to-back accesses OK.
// ============================================================
`timescale 1ns/1ps

// single-bit D flip-flop (defined earlier in the course)
module d_ff(q, d, clk);
    input  d, clk;
    output reg q;
    always @(posedge clk)
        q <= d;
endmodule

module regfile (d_out, d_in, addr_in, r_w, clk);
    output reg [7:0] d_out;
    input      [7:0] d_in;
    input      [3:0] addr_in;
    input            clk, r_w;

    wire [7:0] q [0:15];       // 16 registers, each 8 bits wide
    wire [7:0] d_next [0:15];  // next value for each register

    // 16 registers x 8 bits = 128 single-bit d_ff instances
    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin : G_REG
            // per-register next-value logic (vector assignment, 8 bits):
            // load d_in only when writing AND this register is addressed,
            // otherwise recirculate (hold)
            assign d_next[i] = (r_w && (addr_in == i)) ? d_in : q[i];
            for (j = 0; j < 8; j = j + 1) begin : G_BIT
                d_ff u_ff (.q(q[i][j]), .d(d_next[i][j]), .clk(clk));
            end
        end
    endgenerate

    // synchronous read: one clock cycle per access, back-to-back OK
    always @(posedge clk) begin
        if (!r_w)
            d_out <= q[addr_in];
    end
endmodule