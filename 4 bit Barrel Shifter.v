`timescale 1ns/1ps
//============================================================================
// barrel_shifter_4bit : 2-stage mux-based barrel shifter
//   mode[1:0] : 00 logical shift left   01 logical shift right
//               10 rotate left          11 rotate right
//   sh[1:0]   : shift amount 0..3  (stage 1 shifts by 1, stage 2 by 2)
//============================================================================
module barrel_shifter_4bit (
    input  [3:0] d,
    input  [1:0] sh,
    input  [1:0] mode,
    output [3:0] y
);
    wire right = mode[0];
    wire rot   = mode[1];
 
    // ---- stage 1 : shift/rotate by 1 when sh[0] = 1
    wire [3:0] s1_l = rot ? {d[2:0], d[3]} : {d[2:0], 1'b0};
    wire [3:0] s1_r = rot ? {d[0], d[3:1]} : {1'b0, d[3:1]};
    wire [3:0] s1   = sh[0] ? (right ? s1_r : s1_l) : d;
 
    // ---- stage 2 : shift/rotate by 2 when sh[1] = 1
    wire [3:0] s2_l = rot ? {s1[1:0], s1[3:2]} : {s1[1:0], 2'b00};
    wire [3:0] s2_r = rot ? {s1[1:0], s1[3:2]} : {2'b00, s1[3:2]};
 
    assign y = sh[1] ? (right ? s2_r : s2_l) : s1;
endmodule
`timescale 1ns/1ps
module barrel_shifter_tb;
    reg  [3:0] d;
    reg  [1:0] sh, mode;
    wire [3:0] y;
    integer i, j;
 
    barrel_shifter_4bit dut (.d(d), .sh(sh), .mode(mode), .y(y));
 
    initial begin
        $dumpfile("barrel_shifter_tb.vcd"); $dumpvars(0, barrel_shifter_tb);
        $monitor("mode=%b (00=SLL 01=SRL 10=ROL 11=ROR) shift=%d d=%b | y=%b", mode, sh, d, y);
 
        d = 4'b1011;
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                mode = i; sh = j; #10;
            end
        $finish;
    end
endmodule
