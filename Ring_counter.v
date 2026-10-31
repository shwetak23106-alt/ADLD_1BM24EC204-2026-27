`timescale 1ns/1ps
//============================================================================
// ring_counter : N-bit one-hot ring counter (default 4). Reset -> 0001.
// Sequence (N=4): 0001 -> 0010 -> 0100 -> 1000 -> 0001 ...   (N states)
//============================================================================
module ring_counter #(parameter N = 4) (
    input              clk,
    input              rst,
    output reg [N-1:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst) q <= {{(N-1){1'b0}}, 1'b1};
        else     q <= {q[N-2:0], q[N-1]};
    end
endmodule
`timescale 1ns/1ps
module ring_counter_tb;
    reg        clk, rst;
    wire [3:0] q;
 
    ring_counter #(4) dut (.clk(clk), .rst(rst), .q(q));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("ring_counter_tb.vcd"); $dumpvars(0, ring_counter_tb);
        $monitor("t=%0t rst=%b q=%b", $time, rst, q);
 
        rst = 1;
        #12 rst = 0;
        #120;
        $finish;
    end
endmodule
