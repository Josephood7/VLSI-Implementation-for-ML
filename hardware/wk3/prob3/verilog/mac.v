// Jing-Hua (Joseph) Chang
// University of California, San Diego
// Computer Engineering
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

input         [bw-1:0]   a;     // unsigned activation
input         [bw-1:0]   b;     // signed weight
input         [psum_bw-1:0]  c; // partial sum
output        [psum_bw-1:0] out;

wire          [psum_bw-1:0] mul;
wire          [bw:0] ua;

// Multiplication
assign ua = {1'b0, a[bw-1:0]};         // unsigned a with 5-bit width
assign mul = $signed(ua) * $signed(b);
assign out = $signed(c) + $signed(mul);

endmodule
