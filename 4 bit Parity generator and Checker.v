`timescale 1ns/1ps
//============================================================================
// parity_gen_4bit : p = d3^d2^d1^d0 (even parity, ODD=0) or its complement
//                   (odd parity, ODD=1)
// parity_chk_4bit : err = d3^d2^d1^d0^p  (^ ODD). err = 1 -> parity error
//============================================================================
module parity_gen_4bit #(parameter ODD = 0) (
    input  [3:0] d,
    output       p
);
    assign p = (^d) ^ ODD;
endmodule
 
module parity_chk_4bit #(parameter ODD = 0) (
    input  [3:0] d,
    input        p,
    output       err
);
    assign err = (^{d, p}) ^ ODD;
endmodule
`timescale 1ns/1ps
module parity_tb;
    reg  [3:0] d;
    reg        flip;                       // 1 = flip one bit to create an error
    wire       p, err;
    wire [3:0] rx = {d[3:1], d[0] ^ flip}; // data seen by the checker
    integer i;
 
    parity_gen_4bit #(0) gen (.d(d),  .p(p));            // even parity
    parity_chk_4bit #(0) chk (.d(rx), .p(p), .err(err));
 
    initial begin
        $dumpfile("parity_tb.vcd"); $dumpvars(0, parity_tb);
        $monitor("data=%b parity=%b flip=%b received=%b | error=%b", d, p, flip, rx, err);
 
        for (i = 0; i < 16; i = i + 1) begin
            d = i; flip = 0; #5;    // no error    -> err = 0
            flip = 1; #5;           // 1-bit error -> err = 1
        end
        $finish;
    end
endmodule
