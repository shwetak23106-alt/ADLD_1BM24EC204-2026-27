`timescale 1ns/1ps
//============================================================================
// timer : programmable one-shot down-counter timer
//   start  : pulse high (while idle) to load 'load' and begin counting
//   busy   : high for exactly 'load' clock cycles
//   done   : one-cycle pulse when the programmed time has elapsed
//   load=0 is ignored.  rst is asynchronous and aborts any running count.
//============================================================================
module timer #(parameter W = 8) (
    input              clk,
    input              rst,
    input              start,
    input  [W-1:0]     load,
    output reg         busy,
    output reg         done
);
    reg [W-1:0] cnt;
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt  <= {W{1'b0}};
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;                          // default: pulse only
            if (!busy) begin
                if (start && (load != {W{1'b0}})) begin
                    cnt  <= load;
                    busy <= 1'b1;
                end
            end else begin
                if (cnt == {{(W-1){1'b0}}, 1'b1}) begin   // cnt == 1
                    busy <= 1'b0;
                    done <= 1'b1;
                    cnt  <= {W{1'b0}};
                end else
                    cnt <= cnt - 1'b1;
            end
        end
    end
  `timescale 1ns/1ps
module timer_tb;
    reg        clk, rst, start;
    reg  [7:0] load;
    wire       busy, done;
 
    timer dut (.clk(clk), .rst(rst), .start(start), .load(load), .busy(busy), .done(done));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("timer_tb.vcd"); $dumpvars(0, timer_tb);
        $monitor("t=%0t start=%b load=%d | busy=%b done=%b", $time, start, load, busy, done);
      rst = 1; start = 0; load = 0;
        #12 rst = 0;
 
        // run a 5-clock timer
        #10 load = 5; start = 1;
        #10 start = 0;
        #100;
 
        // run a 3-clock timer
        load = 3; start = 1;
        #10 start = 0;
        #60;
        $finish;
    end
endmodule
  
      


endmodule
