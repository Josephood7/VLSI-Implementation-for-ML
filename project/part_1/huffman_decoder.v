module huffman_decoder(
    input         clk,
    input         reset,
    input  [31:0] encoded_data,
    input         data_valid,

    output        data_ready,
    output [31:0] decoded_data,
    output        output_valid
);

    reg [63:0] buffer;
    reg [6:0]  cnt;

    always @(*) begin
        case()
    end

endmodule