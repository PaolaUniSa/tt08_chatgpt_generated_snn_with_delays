module memory (
    input wire [8-1:0] data_in,
    input wire [$clog2(162)-1:0] addr,
    input wire write_enable,
    input wire clk,
    input wire reset,
    output reg [8-1:0] data_out,
    output reg [162*8-1:0] all_data_out
);

    // Declare the memory array
    reg [8-1:0] mem [0:162-1];
    integer i,j;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Asynchronous reset: clear all memory contents
            //for (i = 0; i < 162; i = i + 1) begin
               // mem[i] <= 0; 
            //end
             mem[0] <= 0; 
        end else if (write_enable) begin
            mem[addr] <= data_in;  // Write data to memory
        end
    end

    always @(*) begin
        // Output the data at the current address
        data_out = mem[addr];

        // Concatenate all memory data into all_data_out
        for (j = 0; j < 162; j = j + 1) begin
            all_data_out[j*8 +: 8] = mem[j];
        end
    end

endmodule














