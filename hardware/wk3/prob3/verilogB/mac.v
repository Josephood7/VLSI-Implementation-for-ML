// Jing-Hua (Joseph) Chang
// University of California, San Diego
// Computer Engineering
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;
parameter input_size = 4;
parameter add_size = input_size >> 1;
parameter port_size = bw * input_size;

input         [port_size-1:0]       a;  // unsigned activation
input         [port_size-1:0]       b;  // signed weight
input         [psum_bw-1:0]  c;                   // partial sum
output        [psum_bw-1:0]  out;

wire          [psum_bw*input_size-1:0] mul;
wire          [(bw+1)*input_size-1:0]        ua;
wire          [psum_bw-1:0] adder01, adder23;

// Multiplication
genvar i;
generate
    for(i = 0; i < input_size; i = i + 1) begin
        assign ua[i*(bw+1)+(bw+1)-1:i*(bw+1)] = {1'b0, a[i*bw+bw-1:i*bw]}; // unsigned a with 5-bit width
        assign mul[i*psum_bw+psum_bw-1:i*psum_bw] = $signed(ua[i*(bw+1)+(bw+1)-1:i*(bw+1)]) * $signed(b[i*bw+bw-1:i*bw]);
    end
endgenerate

assign adder01 = $signed(mul[psum_bw-1:0]) + $signed(mul[psum_bw+psum_bw-1:psum_bw]);
assign adder23 = $signed(mul[2*psum_bw+psum_bw-1:2*psum_bw]) + $signed(mul[3*psum_bw+psum_bw-1:3*psum_bw]);
assign out = $signed(c) + $signed(adder01) + $signed(adder23);

endmodule
