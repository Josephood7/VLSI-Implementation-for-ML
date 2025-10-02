// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, A, B, format, acc, clk, reset);

parameter bw = 8;
parameter psum_bw = 16;

input clk;
input acc;
input reset;
input format;

input signed [bw-1:0] A;
input signed [bw-1:0] B;

output signed [psum_bw-1:0] out;

reg signed [psum_bw-1:0] psum_q;
reg signed [bw-1:0] a_q;
reg signed [bw-1:0] b_q;

wire signed [psum_bw-1:0] psum_q_acc;
wire signed [psum_bw-1:0] mac_op;
wire signed [psum_bw-1:0] mul_sm;
wire signed [psum_bw-3:0] mul_sm_tmp;
wire signed [psum_bw-1:0] sign_mag;
wire signed [psum_bw-1:0] sign_mag_sub;

assign out = psum_q;
assign psum_q_acc = (acc)? (mac_op):(psum_q);
assign mac_op = (format)? (sign_mag):(psum_q + (a_q * b_q));

assign mul_sm_tmp = (a_q[bw-2:0] * b_q[bw-2:0]);
assign mul_sm = {(a_q[bw-1] ^ b_q[bw-1]), 1'b0, mul_sm_tmp};
assign sign_mag_sub = (psum_q[psum_bw-2:0] > mul_sm[psum_bw-2:0])? ({psum_q[psum_bw-1], (psum_q[psum_bw-2:0] - mul_sm[psum_bw-2:0])}):({mul_sm[psum_bw-1], (mul_sm[psum_bw-2:0] - psum_q[psum_bw-2:0])});
assign sign_mag = (psum_q[psum_bw-1] ^ mul_sm[psum_bw-1])? (sign_mag_sub):({psum_q[psum_bw-1], (psum_q[psum_bw-2:0] + mul_sm[psum_bw-2:0])});

// Your code goes here

always @(posedge clk) begin
	if(reset) psum_q <= 0;
	else psum_q <= psum_q_acc;
end

always @(posedge clk) begin
	if(reset) begin
		a_q <= 0;
		b_q <= 0;
	end else begin
		a_q <= A;
		b_q <= B;
	end
end

endmodule
