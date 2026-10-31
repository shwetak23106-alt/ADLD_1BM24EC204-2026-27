`timescale 1ns/1ps
//============================================================================
// comparator       : behavioural N-bit magnitude comparator (default N = 4)
// comparator_4bit_gate : gate-level 4-bit version
//   x_i = XNOR(a_i, b_i)
//   EQ  = x3 x2 x1 x0
//   GT  = a3 b3' + x3 a2 b2' + x3 x2 a1 b1' + x3 x2 x1 a0 b0'
//   LT  = a3' b3 + x3 a2' b2 + x3 x2 a1' b1 + x3 x2 x1 a0' b0
//============================================================================
module comparator #(parameter N = 4) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    output         gt,
    output         eq,
    output         lt
);
    assign gt = (a > b);
    assign eq = (a == b);
    assign lt = (a < b);
endmodule
 
module comparator_4bit_gate (
    input  [3:0] a,
    input  [3:0] b,
    output       gt,
    output       eq,
    output       lt
);
    wire [3:0] x;
    assign x = ~(a ^ b);
    assign eq = &x;
    assign gt = (a[3] & ~b[3])
              | (x[3] & a[2] & ~b[2])
              | (x[3] & x[2] & a[1] & ~b[1])
              | (x[3] & x[2] & x[1] & a[0] & ~b[0]);
    assign lt = (~a[3] & b[3])
              | (x[3] & ~a[2] & b[2])
              | (x[3] & x[2] & ~a[1] & b[1])
              | (x[3] & x[2] & x[1] & ~a[0] & b[0]);
  `timescale 1ns/1ps
module comparator_tb;
    reg  [3:0] a, b;
    wire gt, eq, lt;
 
    comparator #(4) dut (.a(a), .b(b), .gt(gt), .eq(eq), .lt(lt));
  initial begin
        $dumpfile("comparator_tb.vcd"); $dumpvars(0, comparator_tb);
        $monitor("a=%d b=%d | gt=%b eq=%b lt=%b", a, b, gt, eq, lt);
 
        a = 4; b = 4;  #10;
        a = 9; b = 5;  #10;
        a = 2; b = 12; #10;
        a = 15; b = 0; #10;
        a = 0; b = 15; #10;
        $finish;
    end
endmodule
