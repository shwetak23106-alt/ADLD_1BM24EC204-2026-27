alu.v
`timescale 1ns/1ps
//============================================================================
// Module : alu  (N-bit Arithmetic Logic Unit, default N = 8)
// Type   : combinational
// op map : 0000 ADD     0001 SUB      0010 AND      0011 OR
//          0100 XOR     0101 NOT A    0110 NAND     0111 NOR
//          1000 XNOR    1001 SHL A    1010 SHR A    1011 INC A
//          1100 DEC A   1101 PASS A   1110 PASS B   1111 CLEAR
// Flags  : carry (carry-out for ADD/INC, borrow for SUB/DEC, shifted-out bit
//          for SHL/SHR), zero, neg (MSB of result), ovf (signed overflow,
//          ADD and SUB only)
//============================================================================
module alu #(parameter N = 8) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  [3:0]   op,
    output reg [N-1:0] y,
    output reg         carry,
    output             zero,
    output             neg,
    output reg         ovf
);
    reg [N:0] t;
 
    always @(*) begin
        t     = {(N+1){1'b0}};
        y     = {N{1'b0}};
        carry = 1'b0;
        ovf   = 1'b0;
        case (op)
            4'b0000: begin                       // ADD
                t     = {1'b0, a} + {1'b0, b};
                y     = t[N-1:0];
                carry = t[N];
                ovf   = (a[N-1] == b[N-1]) & (y[N-1] != a[N-1]);
            end
            4'b0001: begin                       // SUB  (a - b)
                t     = {1'b0, a} - {1'b0, b};
                y     = t[N-1:0];
                carry = t[N];                    // borrow
                ovf   = (a[N-1] != b[N-1]) & (y[N-1] != a[N-1]);
            end
            4'b0010: y = a & b;                  // AND
            4'b0011: y = a | b;                  // OR
            4'b0100: y = a ^ b;                  // XOR
            4'b0101: y = ~a;                     // NOT A
            4'b0110: y = ~(a & b);               // NAND
            4'b0111: y = ~(a | b);               // NOR
            4'b1000: y = ~(a ^ b);               // XNOR
            4'b1001: begin y = a << 1; carry = a[N-1]; end   // SHL
            4'b1010: begin y = a >> 1; carry = a[0];   end   // SHR
            4'b1011: begin                       // INC A
                t = {1'b0, a} + {{N{1'b0}}, 1'b1};
                y = t[N-1:0]; carry = t[N];
            end
            4'b1100: begin                       // DEC A
                t = {1'b0, a} - {{N{1'b0}}, 1'b1};
                y = t[N-1:0]; carry = t[N];
            end
            4'b1101: y = a;                      // PASS A
            4'b1110: y = b;                      // PASS B
            default: y = {N{1'b0}};              // CLEAR
        endcase
    end
 
    assign zero = (y == {N{1'b0}});
    assign neg  = y[N-1];
endmodule
`timescale 1ns/1ps
module alu_tb;
    reg  [7:0] a, b;
    reg  [3:0] op;
    wire [7:0] y;
    wire carry, zero, neg, ovf;
    integer i;
 
    alu dut (.a(a), .b(b), .op(op), .y(y), .carry(carry), .zero(zero), .neg(neg), .ovf(ovf));
 
    initial begin
        $dumpfile("alu_tb.vcd"); $dumpvars(0, alu_tb);
        $monitor("op=%b a=%h b=%h | y=%h carry=%b zero=%b neg=%b ovf=%b", op, a, b, y, carry, zero, neg, ovf);
 
        // try every operation on the same inputs
        a = 8'hF0; b = 8'h3C;
        for (i = 0; i < 16; i = i + 1) begin
            op = i; #10;
        end
 
        // carry and overflow cases
        a = 8'd200; b = 8'd100; op = 4'b0000; #10;   // ADD with carry
        a = 8'd100; b = 8'd100; op = 4'b0000; #10;   // ADD with overflow
        a = 8'd20;  b = 8'd50;  op = 4'b0001; #10;   // SUB with borrow
        $finish;
    end
endmodule
