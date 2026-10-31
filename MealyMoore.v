//============================================================================
module mealy_1011 (
    input      clk,
    input      rst,
    input      din,
    output reg dout
);
    localparam S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
    reg [1:0] state, next;
 
    always @(posedge clk or posedge rst) begin      // state register
        if (rst) state <= S0;
        else     state <= next;
    end
 
    always @(*) begin                               // next-state + output
        next = S0;
        dout = 1'b0;
        case (state)
            S0: next = din ? S1 : S0;
            S1: next = din ? S1 : S2;
            S2: next = din ? S3 : S0;
            S3: begin
                if (din) begin next = S1; dout = 1'b1; end
                else           next = S2;
            end
            default: next = S0;
        endcase
    end
`timescale 1ns/1ps
//============================================================================
// moore_1011 : Moore FSM, overlapping "1011" sequence detector
//   Output depends on state ONLY -> asserted one cycle after the last '1'.
//
//   State  Meaning         din=0   din=1   Output
//   S0     no progress     S0      S1      0
//   S1     seen "1"        S2      S1      0
//   S2     seen "10"       S0      S3      0
//   S3     seen "101"      S2      S4      0
//   S4     seen "1011"     S2      S1      1
//============================================================================
module moore_1011 (
    input  clk,
    input  rst,
    input  din,
    output dout
);
    localparam S0 = 3'd0, S1 = 3'd1, S2 = 3'd2, S3 = 3'd3, S4 = 3'd4;
    reg [2:0] state, next;
 
    always @(posedge clk or posedge rst) begin      // state register
        if (rst) state <= S0;
        else     state <= next;
    end
 
    always @(*) begin                               // next-state logic
        case (state)
            S0: next = din ? S1 : S0;
            S1: next = din ? S1 : S2;
            S2: next = din ? S3 : S0;
            S3: next = din ? S4 : S2;
            S4: next = din ? S1 : S2;
            default: next = S0;
        endcase
    end
 
    assign dout = (state == S4);                    // output logic (Moore)
endmodule
`timescale 1ns/1ps
module fsm_tb;
    reg  clk, rst, din;
    wire mealy_out, moore_out;
    reg  [15:0] stream;
    integer i;
 
    mealy_1011 u_mealy (.clk(clk), .rst(rst), .din(din), .dout(mealy_out));
    moore_1011 u_moore (.clk(clk), .rst(rst), .din(din), .dout(moore_out));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("fsm_tb.vcd"); $dumpvars(0, fsm_tb);
        $monitor("t=%0t din=%b | mealy=%b moore=%b", $time, din, mealy_out, moore_out);
 
        stream = 16'b1011_0110_1011_1011;     // contains several 1011 patterns
        rst = 1; din = 0;
        #12 rst = 0;
 
        for (i = 15; i >= 0; i = i - 1) begin
            @(negedge clk);
            din = stream[i];
        end
        @(negedge clk); din = 0;
        #20;
        $finish;
    end
endmodule
