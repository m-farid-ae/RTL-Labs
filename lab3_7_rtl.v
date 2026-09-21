// Lab 3-7 : 32-bit ALU
// Operations (4-bit opcode):
//   4'h0 : ADD            (A + B)
//   4'h1 : SUBTRACT       (A - B)
//   4'h2 : AND            (A & B)
//   4'h3 : OR             (A | B)
//   4'h4 : XOR            (A ^ B)
//   4'h5 : SHIFT RIGHT    (A >> B[4:0]), logical
//   4'h6 : SHIFT LEFT     (A << B[4:0])
//   4'h7 : BARREL SHIFT LEFT  (rotate A left  by B[4:0])
//   4'h8 : BARREL SHIFT RIGHT (rotate A right by B[4:0])
// Outputs (registered, active-high async reset):
//   Dout     : 32-bit result
//   Zero     : 1 when Dout == 0
//   CarryOut : carry-out of add/sub (for sub, carry of A + ~B + 1)
//   Overflow : signed overflow of add/sub
module alu (A, B, Opcode, Reset, clock, Dout, Zero, CarryOut, Overflow);
    input  [31:0] A, B;
    input  [3:0]  Opcode;
    input         Reset, clock;
    output [31:0] Dout;
    output        Zero, CarryOut, Overflow;

    reg [31:0] Dout;
    reg        Zero, CarryOut, Overflow;

    reg [32:0] arith;         // 33-bit for carry detection
    reg [31:0] shift_tmp;
    reg [4:0]  shamt;
    integer k;

    wire [32:0] add_res = {1'b0, A} + {1'b0, B};
    wire [32:0] sub_res = {1'b0, A} + {1'b0, ~B} + 33'd1;

    always @(posedge clock or posedge Reset) begin
        if (Reset) begin
            Dout     <= 32'd0;
            Zero     <= 1'b0;
            CarryOut <= 1'b0;
            Overflow <= 1'b0;
        end else begin
            shamt = B[4:0];
            case (Opcode)
                4'h0: begin                                     // ADD
                    arith = add_res;
                    Dout     <= arith[31:0];
                    CarryOut <= arith[32];
                    Overflow <= (~A[31] & ~B[31] &  arith[31]) |
                                ( A[31] &  B[31] & ~arith[31]);
                    Zero     <= (arith[31:0] == 32'd0);
                end
                4'h1: begin                                     // SUBTRACT
                    arith = sub_res;
                    Dout     <= arith[31:0];
                    CarryOut <= arith[32];
                    Overflow <= (~A[31] &  B[31] &  arith[31]) |
                                ( A[31] & ~B[31] & ~arith[31]);
                    Zero     <= (arith[31:0] == 32'd0);
                end
                4'h2: begin Dout <= A & B; CarryOut <= 1'b0;
                            Overflow <= 1'b0; Zero <= ((A & B) == 32'd0); end
                4'h3: begin Dout <= A | B; CarryOut <= 1'b0;
                            Overflow <= 1'b0; Zero <= ((A | B) == 32'd0); end
                4'h4: begin Dout <= A ^ B; CarryOut <= 1'b0;
                            Overflow <= 1'b0; Zero <= ((A ^ B) == 32'd0); end
                4'h5: begin                                     // SHIFT RIGHT logical
                    Dout <= A >> shamt; CarryOut <= 1'b0;
                    Overflow <= 1'b0; Zero <= ((A >> shamt) == 32'd0);
                end
                4'h6: begin                                     // SHIFT LEFT
                    Dout <= A << shamt; CarryOut <= 1'b0;
                    Overflow <= 1'b0; Zero <= ((A << shamt) == 32'd0);
                end
                4'h7: begin                                     // BARREL / rotate LEFT
                    shift_tmp = A;
                    for (k = 0; k < shamt; k = k + 1)
                        shift_tmp = {shift_tmp[30:0], shift_tmp[31]};
                    Dout <= shift_tmp; CarryOut <= 1'b0;
                    Overflow <= 1'b0; Zero <= (shift_tmp == 32'd0);
                end
                4'h8: begin                                     // BARREL / rotate RIGHT
                    shift_tmp = A;
                    for (k = 0; k < shamt; k = k + 1)
                        shift_tmp = {shift_tmp[0], shift_tmp[31:1]};
                    Dout <= shift_tmp; CarryOut <= 1'b0;
                    Overflow <= 1'b0; Zero <= (shift_tmp == 32'd0);
                end
                default: begin
                    Dout <= 32'd0; Zero <= 1'b1;
                    CarryOut <= 1'b0; Overflow <= 1'b0;
                end
            endcase
        end
    end
endmodule
