module core  (
	input clk,
    input reset,
	input [35:0] inst,
	output ofifo_valid,
    input [bw*row-1 : 0 ]  D_xmem, 
    output [psum_bw*col-1 : 0 ] sfp_out,
    output data_ready_huff
); 
    parameter bw  = 4;
    parameter col = 8;
    parameter psum_bw = 16;
    parameter row = 8;

wire [31:0] Q_xmem;
wire l0_or_ififo;
sram_32b_w2048 #(
    .num(2048)
) input_mem(
    .CLK(clk),
    .WEN(inst[18]),
    .CEN(inst[19]),
    .D(D_xmem),
    .A(inst[17:7]),
    .Q(Q_xmem)
);

wire [31:0] decoded_data;
wire        symbol_valid;
huffman_decoder compression(
    .clk(clk),
    .reset(reset),
    .data_in(Q_xmem),
    .data_valid(inst[35]),
    .data_ready(data_ready_huff),
    .symbol_out(decoded_data),
    .symbol_valid(symbol_valid)
);

wire [127:0] D_pmem, Q_pmem;
genvar i;
generate
    for(i = 0; i < 4; i = i + 1) begin : sram_n
        sram_32b_w2048 #(
        .num(2048)
        ) partial_mem(
            .CLK(clk),
            .WEN(inst[31]),
            .CEN(inst[32]),
            .D(D_pmem[(i+1) * 32 - 1: i*32]),
            .A(inst[30:20]),
            .Q(Q_pmem[(i+1) * 32 - 1: i*32])
        );
    end
endgenerate


corelet #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
) corelet_inst(
    .clk(clk),
    .reset(reset),
    .inst(inst[1:0]), // 1st bit : execute  0th: Load Kernel
    .l0_or_ififo(inst[17]),
    .l0_rd(inst[3]),
    .l0_wr(symbol_valid),
    .in_data(decoded_data), // Q_xmem
    .psum_accum_in(Q_pmem),
    .accum(inst[33]), 
    .ofifo_rd(inst[6]),
    .ofifo_valid(ofifo_valid),
    .psum_out(D_pmem),
    .out_data(sfp_out),
    .relu_valid(inst[34])

);


endmodule