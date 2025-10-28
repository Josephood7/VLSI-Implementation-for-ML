// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter input_size = 4;
parameter input_num = 20;
parameter data_reg = bw * input_num;
parameter port_size = bw * input_size;

reg clk = 0;

reg  [data_reg-1:0] reg_a;
reg  [data_reg-1:0] reg_b;
reg  [port_size-1:0] a;
reg  [port_size-1:0] b;
reg  [psum_bw-1:0] c;
wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec0, x_dec1, x_dec2, x_dec3;
integer w_dec0, w_dec1, w_dec2, w_dec3;
integer i; 
integer u; 

function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction



function [3:0] x_bin ;
    input integer activate;
    begin
        x_bin = activate & 4'b1111;
    end
endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;
    input  [port_size-1:0] a, b;
    input  [psum_bw-1:0] c;

    begin
        if      (a[bw-1:0] === 4'h3 && b[bw-1:0] === 4'hC && c === 16'h0000) mac_predicted = 16'hFFD0; // -48
	else if (a[bw-1:0] === 4'h4 && b[bw-1:0] === 4'h5 && c === 16'hFFD0) mac_predicted = 16'hFF9E; // -98
	else if (a[bw-1:0] === 4'h2 && b[bw-1:0] === 4'hE && c === 16'hFF9E) mac_predicted = 16'hFF86; // -122
	else if (a[bw-1:0] === 4'hB && b[bw-1:0] === 4'hF && c === 16'hFF86) mac_predicted = 16'hFF59; // -167
	else if (a[bw-1:0] === 4'hA && b[bw-1:0] === 4'h4 && c === 16'hFF59) mac_predicted = 16'hFF7F; // -129
    end

endfunction



mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
); 
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tbB.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<5; i=i+1) begin  // Data length is 10 in the data files

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     w_scan_file = $fscanf(w_file, "%d %d %d %d\n", w_dec0, w_dec1, w_dec2, w_dec3);
     x_scan_file = $fscanf(x_file, "%d %d %d %d\n", x_dec0, x_dec1, x_dec2, x_dec3);

     a = {x_bin(x_dec0), x_bin(x_dec1), x_bin(x_dec2), x_bin(x_dec3)}; // unsigned number
     b = {w_bin(w_dec0), w_bin(w_dec1), w_bin(w_dec2), w_bin(w_dec3)}; // signed number
     c = expected_out;
     
     expected_out = mac_predicted(a, b, c);

  end

  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




