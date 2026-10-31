//============================================================================
// div_by_n : divide-by-N counter / clock divider, 50 % duty cycle, N >= 2
//   count   : mod-N counter (0 .. N-1) clocked on the rising edge
//   clk_out : clk / N
//   Even N : clk_out = (count < N/2)
//   Odd  N : a rising-edge pulse (count < (N+1)/2) is ANDed with a copy of
//            itself delayed by half a clock (falling-edge register) which
//            trims the high time to exactly N/2 clock periods.
//============================================================================
module div_by_n #(parameter N = 5, parameter W = 8) (
    input          clk,
    input          rst,
    output         clk_out,
    output reg [W-1:0] count
);
    localparam HIGH = (N + 1) / 2;       // = N/2 for even N
 
    reg  clk_n;
    wire clk_p = (count < HIGH);
 
    // mod-N counter on rising edge
    always @(posedge clk or posedge rst) begin
        if (rst)                  count <= {W{1'b0}};
        else if (count == N - 1)  count <= {W{1'b0}};
        else                      count <= count + 1'b1;
    end
 
    // half-cycle delayed copy (falling edge)
    always @(negedge clk or posedge rst) begin
        if (rst) clk_n <= 1'b0;
        else     clk_n <= clk_p;
    end
 
    assign clk_out = (N % 2) ? (clk_p & clk_n) : clk_p;
endmodule
`timescale 1ns/1ps
module div_by_n_tb;
    reg  clk, rst;
    wire out4, out5;          // divide by 4 (even) and divide by 5 (odd)
    wire [7:0] cnt4, cnt5;
 
    div_by_n #(4) d4 (.clk(clk), .rst(rst), .clk_out(out4), .count(cnt4));
    div_by_n #(5) d5 (.clk(clk), .rst(rst), .clk_out(out5), .count(cnt5));
 
    initial clk = 0;
    always #5 clk = ~clk;     // 10 ns clock
 
    initial begin
        $dumpfile("div_by_n_tb.vcd"); $dumpvars(0, div_by_n_tb);
        $monitor("t=%0t out_div4=%b out_div5=%b", $time, out4, out5);
 
        rst = 1;
        #12 rst = 0;
        #300;
        $fin
endmodule
