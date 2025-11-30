module huffman_decoder (
    input wire clk,
    input wire reset,
    
    // Input Interface (From D_xmem / SRAM)
    input wire [31:0] data_in,      // Compressed data chunk
    input wire data_valid,          // "I have sent you 32 bits"
    output reg data_ready,          // "I can accept 32 more bits"

    // Output Interface (To L0 / Computation)
    output reg [31:0] symbol_out,    // Decoded 4-bit weight
    output reg symbol_valid         // "This weight is valid now"
);

    // --- Internal State ---
    reg [63:0] buffer;       // 64-bit Sliding Window
    reg [6:0] count;         // Valid bits in buffer (0-64)
    
    // --- Combinational Logic Signals ---
    reg [3:0] next_symbol;   
    reg [4:0] bits_consumed; 
    reg match_found;         

    // --- Helper: Bit Reversal ---
    // Text file is "First Bit -> Last Bit". 
    // We want "First Bit" at index 0 of our buffer.
    integer i;
    reg [31:0] data_in_reversed;
    always @(*) begin
        for (i=0; i<32; i=i+1) begin
            data_in_reversed[i] = data_in[31-i];
        end
    end

    // --- 1. DECODING LOGIC (Combinational) ---
    always @(*) begin
        // Defaults to prevent Latches
        next_symbol = 0;
        bits_consumed = 0;
        match_found = 0;

        // Note for ModelSim: The "parallel_case" comment is ignored by ModelSim,
        // which is fine! Huffman codes don't overlap, so priority logic works too.
        case (1'b1) // synopsys parallel_case
            
            // ---------------------------------------------------------
            // PASTE PYTHON OUTPUT HERE
            // IMPORTANT: If your code is "10" (First 1, then 0), 
            // you must match buffer[0]=1 and buffer[1]=0.
            // This means the Verilog Literal must be reversed: 2'b01
            // ---------------------------------------------------------

            buffer[1:0] == 2'b00: begin
                symbol_out = 4'b0000; // Original: 0000, Code: 00
                bits_consumed = 2;
                //valid = 1;
            end
            buffer[2:0] == 3'b011: begin
                symbol_out = 4'b0001; // Original: 0001, Code: 110
                bits_consumed = 3;
                //valid = 1;
            end
            buffer[2:0] == 3'b010: begin
                symbol_out = 4'b1110; // Original: 1110, Code: 010
                bits_consumed = 3;
                //valid = 1;
            end
            buffer[2:0] == 3'b101: begin
                symbol_out = 4'b1111; // Original: 1111, Code: 101
                bits_consumed = 3;
                //valid = 1;
            end
            buffer[3:0] == 4'b0111: begin
                symbol_out = 4'b0010; // Original: 0010, Code: 1110
                bits_consumed = 4;
                //valid = 1;
            end
            buffer[3:0] == 4'b0001: begin
                symbol_out = 4'b0111; // Original: 0111, Code: 1000
                bits_consumed = 4;
                //valid = 1;
            end
            buffer[3:0] == 4'b1110: begin
                symbol_out = 4'b1101; // Original: 1101, Code: 0111
                bits_consumed = 4;
                //valid = 1;
            end
            buffer[4:0] == 5'b01001: begin
                symbol_out = 4'b0011; // Original: 0011, Code: 10010
                bits_consumed = 5;
                //valid = 1;
            end
            buffer[4:0] == 5'b00110: begin
                symbol_out = 4'b0100; // Original: 0100, Code: 01100
                bits_consumed = 5;
                //valid = 1;
            end
            buffer[4:0] == 5'b11111: begin
                symbol_out = 4'b1001; // Original: 1001, Code: 11111
                bits_consumed = 5;
                //valid = 1;
            end
            buffer[4:0] == 5'b11001: begin
                symbol_out = 4'b1100; // Original: 1100, Code: 10011
                bits_consumed = 5;
                //valid = 1;
            end
            buffer[5:0] == 6'b001111: begin
                symbol_out = 4'b0101; // Original: 0101, Code: 111100
                bits_consumed = 6;
                //valid = 1;
            end
            buffer[5:0] == 6'b010110: begin
                symbol_out = 4'b0110; // Original: 0110, Code: 011010
                bits_consumed = 6;
                //valid = 1;
            end
            buffer[5:0] == 6'b110110: begin
                symbol_out = 4'b1010; // Original: 1010, Code: 011011
                bits_consumed = 6;
                //valid = 1;
            end
            buffer[5:0] == 6'b101111: begin
                symbol_out = 4'b1011; // Original: 1011, Code: 111101
                bits_consumed = 6;
                //valid = 1;
            end

        endcase
    end

    // --- 2. MAIN SEQUENTIAL LOOP ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer <= 0;
            count <= 0;
            symbol_out <= 0;
            symbol_valid <= 0;
            data_ready <= 1;
        end else begin
            symbol_valid <= 0; // Pulse valid for 1 cycle
            
            // A. Decode Success
            if (count > 0 && match_found) begin
                symbol_out[31:28] <= next_symbol;
                symbol_out <= symbol_out >> 4;
            end

            // B. Shift Buffer & Load New Data
            if ((count > 0 && match_found) && (data_valid)) begin
                // Shift out used bits, Shift in new 32 bits
                buffer <= (buffer >> bits_consumed) | ({32'b0, data_in_reversed} << (count - bits_consumed));
                count <= (count - bits_consumed) + 32;
                data_ready <= 0; 
            end
            else if (count > 0 && match_found) begin
                // Just shift out used bits
                buffer <= buffer >> bits_consumed;
                count <= count - bits_consumed;
            end
            else if (data_valid) begin
                // Just load new data
                buffer <= buffer | ({32'b0, data_in_reversed} << count);
                count <= count + 32;
                data_ready <= 0;
            end
            
            // C. Flow Control
            // If we have empty space for a full 32-bit word, ask for more.
            if (count == 32) begin
                data_ready <= 1;
                symbol_valid <= 1;
            end else begin 
                data_ready <= 0;
                symbol_valid <= 0;
            end
        end
    end

endmodule