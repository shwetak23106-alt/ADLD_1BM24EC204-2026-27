`timescale 1ns/1ps
//============================================================================
// lfsr_4bit : 4-bit Fibonacci LFSR, polynomial x^4 + x^3 + 1
//   feedback = q[3] ^ q[2]; shifts left each clock; seed (reset) = 0001
//   Maximal length: cycles through all 15 non-zero states.
//   'rbit' is the serial pseudo-random bit stream (q[3]).
//============================================================================
module lfsr_4bit (
    input            clk,
    input            rst,
    output reg [3:0] q,
    output           rbit
);
    wire fb = q[3] ^ q[2];
    assign rbit = q[3];
 
    always @(posedge clk or posedge rst) begin
        if (rst) q <= 4'b0001;
        else     q <= {q[2:0], fb};
    end
endmodule
`timescale 1ns/1ps
module lfsr_tb;
    reg        clk, rst;
    wire [3:0] q;
    wire       rbit;
 
    lfsr_4bit dut (.clk(clk), .rst(rst), .q(q), .rbit(rbit));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("lfsr_tb.vcd"); $dumpvars(0, lfsr_tb);
        $monitor("t=%0t q=%b (%d) rbit=%b", $time, q, q, rbit);
 
        rst = 1;
        #12 rst = 0;
        #180;                  // a bit more than 15 clocks, so you can see it repeat
        $finish;
    end
endmodule
