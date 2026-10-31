`timescale 1ns/1ps
//============================================================================
// sync_counter_4bit  : synchronous up/down counter (all FFs share clk)
//                      en=1 counts, up=1 counts up, up=0 counts down
// t_ff               : negative-edge triggered T flip-flop (toggle each edge)
// async_counter_4bit : 4-bit ripple (asynchronous) UP counter built from
//                      t_ff cells; clock of stage i+1 is Q of stage i
//============================================================================
module sync_counter_4bit (
    input            clk,
    input            rst,
    input            en,
    input            up,
    output reg [3:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)     q <= 4'd0;
        else if (en) q <= up ? (q + 4'd1) : (q - 4'd1);
    end
endmodule
 
module t_ff (
    input      clk,
    input      rst,
    output reg q
);
    always @(negedge clk or posedge rst) begin
        if (rst) q <= 1'b0;
        else     q <= ~q;
    end
endmodule
 
module async_counter_4bit (
    input        clk,
    input        rst,
    output [3:0] q
);
    t_ff ff0 (.clk(clk),  .rst(rst), .q(q[0]));
    t_ff ff1 (.clk(q[0]), .rst(rst), .q(q[1]));
    t_ff ff2 (.clk(q[1]), .rst(rst), .q(q[2]));
    t_ff ff3 (.clk(q[2]), .rst(rst), .q(q[3]));
endmodule
`timescale 1ns/1ps
module counters_tb;
    reg        clk, rst, en, up;
    wire [3:0] sq, aq;
 
    sync_counter_4bit  dut_sync  (.clk(clk), .rst(rst), .en(en), .up(up), .q(sq));
    async_counter_4bit dut_async (.clk(clk), .rst(rst), .q(aq));

    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("counters_tb.vcd"); $dumpvars(0, counters_tb);
        $monitor("t=%0t en=%b up=%b | sync=%d async=%d", $time, en, up, sq, aq);
 
        rst = 1; en = 0; up = 1;
        #12 rst = 0;
 
        en = 1; up = 1;        #200;    // count up
        en = 0;                #30;     // hold (sync only; async always counts)
        en = 1; up = 0;        #100;    // sync counts down
        $finish;
    end
endmodule
