// shift_register : N-bit universal shift register (default 4)
//   mode 00 : hold
//   mode 01 : shift right  (sin_r -> MSB, LSB leaves via sout_r)
//   mode 10 : shift left   (sin_l -> LSB, MSB leaves via sout_l)
//   mode 11 : parallel load from pin
// Covers SISO (shift modes), SIPO (read q), PISO (load, then shift), PIPO.
//============================================================================
module shift_register #(parameter N = 4) (
    input              clk,
    input              rst,
    input  [1:0]       mode,
    input              sin_r,
    input              sin_l,
    input  [N-1:0]     pin,
    output reg [N-1:0] q,
    output             sout_r,
    output             sout_l
);
    assign sout_r = q[0];
    assign sout_l = q[N-1];
 
    always @(posedge clk or posedge rst) begin
        if (rst) q <= {N{1'b0}};
        else begin
            case (mode)
                2'b00:   q <= q;
                2'b01:   q <= {sin_r, q[N-1:1]};
                2'b10:   q <= {q[N-2:0], sin_l};
                2'b11:   q <= pin;
            endcase
        end
module shift_register_tb;
    reg        clk, rst, sin_r, sin_l;
    reg  [1:0] mode;
    reg  [3:0] pin;
    wire [3:0] q;
    wire       sout_r, sout_l;
 
    shift_register #(4) dut (.clk(clk), .rst(rst), .mode(mode), .sin_r(sin_r),
                             .sin_l(sin_l), .pin(pin), .q(q),
                             .sout_r(sout_r), .sout_l(sout_l));
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("shift_register_tb.vcd"); $dumpvars(0, shift_register_tb);
        $monitor("t=%0t mode=%b sin_r=%b sin_l=%b pin=%b | q=%b", $time, mode, sin_r, sin_l, pin, q);
 
        rst = 1; mode = 2'b00; sin_r = 0; sin_l = 0; pin = 4'b0000;
        #12 rst = 0;
 
        mode = 2'b11; pin = 4'b1010;  #10;                 // parallel load 1010
        mode = 2'b00;                 #20;                 // hold
        mode = 2'b01; sin_r = 1;      #40;                 // shift right, feeding 1s
        mode = 2'b11; pin = 4'b0110;  #10;                 // parallel load 0110
        mode = 2'b10; sin_l = 1;      #40;                 // shift left, feeding 1s
        mode = 2'b01; sin_r = 0;      #40;                 // shift right, feeding 0s
        $finish;
    end
endmodule
    end
