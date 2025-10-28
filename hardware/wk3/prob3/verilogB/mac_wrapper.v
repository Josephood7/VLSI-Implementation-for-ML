// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_wrapper (clk, out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;
parameter input_size = 4;
parameter add_size = input_size >> 1;
parameter port_size = bw * input_size;


input         [port_size-1:0]       a;  // unsigned activation
input         [port_size-1:0]       b;  // signed weight

output [psum_bw-1:0] out;
input  [psum_bw-1:0] c;
input  clk;

reg    [port_size-1:0] a_q;
reg    [port_size-1:0] b_q;
reg    [psum_bw-1:0] c_q;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(out)
); 

always @ (posedge clk) begin
        b_q  <= b;
        a_q  <= a;
        c_q  <= c;
end

endmodule

