`timescale 1ns/1ps
//============================================================================
// johnson_counter : N-bit twisted-ring (Johnson) counter. Reset -> 0000.
// Sequence (N=4): 0000 0001 0011 0111 1111 1110 1100 1000 (2N states)
//============================================================================
module johnson_counter #(parameter N = 4) (
    input              clk,
    input              rst,
    output reg [N-1:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst) q <= {N{1'b0}};
        else     q <= {q[N-2:0], ~q[N-1]};
       end
endmodule
`timescale 1ns/1ps
module johnson_counter_tb;
    reg        clk, rst;
    wire [3:0] q;
 
    johnson_counter #(4) dut (.clk(clk), .rst(rst), .q(q));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("johnson_counter_tb.vcd"); $dumpvars(0, johnson_counter_tb);
        $monitor("t=%0t rst=%b q=%b", $time, rst, q);
 
        rst = 1;
        #12 rst = 0;
        #170;
        $finish;
    end
  
