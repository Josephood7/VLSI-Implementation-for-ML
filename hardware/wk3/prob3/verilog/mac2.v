// Jing-Hua (Joseph) Chang
// University of California, San Diego
// Computer Engineering
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;
input         [bw-1:0]   a; // unsigned activation
input         [bw-1:0]   b; // signed weight
input         [psum_bw-1:0]  c; // partial sum
output        [psum_bw-1:0] out;

wire          [psum_bw-1:0] mul;
wire          [psum_bw-1:0] nn;
wire          [psum_bw-1:0] mulN_cP, mulP_cN;

wire          [bw*2-1:0] mul_bN;
wire          [bw-1:0] bN_2cP;
wire          [psum_bw-1:0] mulLc_mulN, mulSc_mulN, mulLc_cN, mulSc_cN;
wire          [psum_bw-1:0] mulN_2cP, cN_2cP;

// Multiplication
assign bN_2cP = {1'b0, (~b[bw-2:0])} + 1;    // when b is negative, b's two's compliment positive value
assign mul_bN = a * bN_2cP;                       // multiplication when b is negtive
assign mul = (b[bw-1])? ~(mul_bN-1):(a * b);

// Summation
assign nn = {1'b1, (mul[psum_bw-2:0] + c[psum_bw-2:0])}; // mul & c are both negative
assign mulN_2cP = {1'b0, (~mul[psum_bw-2:0])} + 1;       // mul two's compliment positive value
assign cN_2cP = {1'b0, (~c[psum_bw-2:0])} + 1;           // c two's compiment positive value

    // contrary sign
assign mulLc_mulN = {mul[psum_bw-1], (mulN_2cP - c[psum_bw-2:0])}; // mul > c (mul is negative)
assign mulSc_mulN = {c[psum_bw-1], (c[psum_bw-2:0] - mulN_2cP)};   // mul < c (mul is negative)
assign mulLc_cN = {mul[psum_bw-1], (mul[psum_bw-2:0] - cN_2cP)};   // mul > c (c is negative)
assign mulSc_cN = {c[psum_bw-1], (cN_2cP - mul[psum_bw-2:0])};     // mul < c (c is negative)

assign mulN_cP = (mulN_2cP > c[psum_bw-2:0])? (~mulLc_mulN + 1):(mulSc_mulN); // mul is negative, c is positive
assign mulP_cN = (mul[psum_bw-2:0] > cN_2cP)? (mulLc_cN):(~mulSc_cN + 1);     // mul is positive, c is negative

assign out = (mul[psum_bw-1])? ((c[psum_bw-1])? (nn):(mulN_cP)):((c[psum_bw-1])? (mulP_cN):(mul + c));

endmodule
