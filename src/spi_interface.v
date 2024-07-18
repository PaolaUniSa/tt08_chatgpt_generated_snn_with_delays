module spi_interface 
(
    input wire SCLK, MOSI, SS, RESET,
    output wire MISO,
    output wire clk_div_ready_reg_out,
    output wire input_spike_ready_reg_out,
    output wire debug_config_ready_reg_out,
    output wire [(24*8+8*2)*4+(24*8+8*2)*2+4*2+3*8+8-1+8:0] all_data_out //3*8+8+8+8+208*8+8=208*8+56=1664+56=1720 //[320*8-1:0] all_data_out //output wire [M*N-1:0] all_data_out //224
);
    // Internal signals
    wire [7:0] received_data;
    wire data_valid;
    wire [7:0] SPI_instruction_reg_in;
    wire [7:0] SPI_instruction_reg_out;
    wire [7:0] SPI_address_MSB_reg_out;
    wire [7:0] SPI_address_LSB_reg_out;
    wire clk_div_ready_reg_in;
    wire input_spike_ready_reg_in;
    wire debug_config_ready_reg_in;
    wire write_memory_enable;
    
    // Register declarations
    reg [7:0] MSB_Address_reg;
    reg [7:0] LSB_Address_reg;
    reg [7:0] SPI_instruction_reg;
    reg clk_div_ready_reg;
    reg input_spike_ready_reg;
    reg debug_config_ready_reg;

    // Enable signals
    wire SPI_instruction_reg_en;
    wire clk_div_ready_reg_en;
    wire input_spike_ready_reg_en;
    wire debug_config_ready_reg_en;
    wire SPI_address_MSB_reg_en;
    wire SPI_address_LSB_reg_en;

    wire [7:0] data_to_send;
    
    // Instantiate the spi_slave module
    spi_slave spi_slave_inst (
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(SS),
        .RESET(RESET),
        .MISO(MISO),
        .data_to_send(data_to_send),
        .received_data(received_data),
        .data_valid(data_valid)
    );

    // Instantiate the spi_control_unit module
    spi_control_unit spi_control_unit_inst (
        .clk(SCLK),
        .reset(RESET),
        .cs(SS),
        .data_valid(data_valid),
        .SPI_instruction_reg_in(SPI_instruction_reg_in),
        .SPI_instruction_reg_out(SPI_instruction_reg_out),
        .SPI_address_MSB_reg_en(SPI_address_MSB_reg_en),
        .SPI_address_LSB_reg_en(SPI_address_LSB_reg_en),
        .SPI_instruction_reg_en(SPI_instruction_reg_en),
        .clk_div_ready(clk_div_ready_reg_in),
        .clk_div_ready_en(clk_div_ready_reg_en),
        .input_spike_ready(input_spike_ready_reg_in),
        .input_spike_ready_en(input_spike_ready_reg_en),
        .debug_config_ready(debug_config_ready_reg_in),
        .debug_config_ready_en(debug_config_ready_reg_en),
        .write_memory_enable(write_memory_enable)
    );

    // Instantiate the memory module
    memory memory_inst ( //215
        .data_in(received_data),
        .addr(SPI_address_LSB_reg_out[6:0]), //.addr({SPI_address_MSB_reg_out[0], SPI_address_LSB_reg_out}),
        .write_enable(write_memory_enable),
        .clk(SCLK),
        .reset(RESET),
        .data_out(data_to_send),
        .all_data_out(all_data_out)
    );

    // Register assignments
    always @(posedge SCLK or posedge RESET) begin
        if (RESET) begin
            MSB_Address_reg <= 8'd0;
            LSB_Address_reg <= 8'd0;
            SPI_instruction_reg <= 8'd0;
            clk_div_ready_reg <= 1'b0;
            input_spike_ready_reg <= 1'b0;
            debug_config_ready_reg <= 1'b0;
        end else begin
            if (SPI_address_MSB_reg_en) MSB_Address_reg <= received_data;
            if (SPI_address_LSB_reg_en) LSB_Address_reg <= received_data;
            if (SPI_instruction_reg_en) SPI_instruction_reg <= received_data;
            if (clk_div_ready_reg_en) clk_div_ready_reg <= clk_div_ready_reg_in;
            if (input_spike_ready_reg_en) input_spike_ready_reg <= input_spike_ready_reg_in;
            if (debug_config_ready_reg_en) debug_config_ready_reg <= debug_config_ready_reg_in;
        end
    end

   assign SPI_address_LSB_reg_out= LSB_Address_reg;
   assign SPI_address_MSB_reg_out= MSB_Address_reg;

    // Output assignments
    assign clk_div_ready_reg_out = clk_div_ready_reg;
    assign input_spike_ready_reg_out = input_spike_ready_reg;
    assign debug_config_ready_reg_out = debug_config_ready_reg;
    assign SPI_instruction_reg_in = received_data;
    assign SPI_instruction_reg_out = SPI_instruction_reg;

endmodule
