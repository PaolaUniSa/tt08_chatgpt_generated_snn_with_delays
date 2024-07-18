module spi_control_unit (
    input wire clk,
    input wire reset,
    input wire cs,                       // Chip Select signal
    input wire data_valid,               // Data valid signal
    input wire [7:0] SPI_instruction_reg_in,   // Instruction register input
    input wire [7:0] SPI_instruction_reg_out,  // Instruction register output
    output reg SPI_address_MSB_reg_en,   // Enable signal for Address MSB register
    output reg SPI_address_LSB_reg_en,   // Enable signal for Address LSB register
    output reg SPI_instruction_reg_en,   // Enable signal for Instruction register
    output reg clk_div_ready,
    output reg clk_div_ready_en,
    output reg input_spike_ready,
    output reg input_spike_ready_en,
    output reg debug_config_ready,
    output reg debug_config_ready_en,
    output reg write_memory_enable
);

    // State encoding
    parameter IDLE = 3'b000,
              WAIT_DATA_VALID_MSB = 3'b001,
              WAIT_DATA_VALID_LSB = 3'b010,
              WAIT_DATA_VALID_INSTR = 3'b011,
              WAIT_DATA_VALID_FINAL = 3'b100,
              SYSCLK_DOMAIN_EN = 3'b101;

    reg [2:0] current_state, next_state;

    // State transition on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (!cs)
                    next_state = WAIT_DATA_VALID_MSB;
            end
            WAIT_DATA_VALID_MSB: begin
                if (data_valid)
                    next_state = WAIT_DATA_VALID_LSB;
            end
            WAIT_DATA_VALID_LSB: begin
                if (data_valid)
                    next_state = WAIT_DATA_VALID_INSTR;
            end
            WAIT_DATA_VALID_INSTR: begin
                if (data_valid) begin
                    next_state = WAIT_DATA_VALID_FINAL;
                end
            end
            WAIT_DATA_VALID_FINAL: begin
                if (data_valid) begin
                    case (SPI_instruction_reg_out)
                        8'h05, 8'h07, 8'h09: next_state = SYSCLK_DOMAIN_EN;
                        default: next_state = IDLE;
                    endcase
                end
            end
            SYSCLK_DOMAIN_EN: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic on clock edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            SPI_address_MSB_reg_en <= 0;
            SPI_address_LSB_reg_en <= 0;
            SPI_instruction_reg_en <= 0;
            clk_div_ready <= 0;
            clk_div_ready_en <= 0;
            input_spike_ready <= 0;
            input_spike_ready_en <= 0;
            debug_config_ready <= 0;
            debug_config_ready_en <= 0;
            write_memory_enable <= 0;
        end else begin
            SPI_address_MSB_reg_en <= 0;
            SPI_address_LSB_reg_en <= 0;
            SPI_instruction_reg_en <= 0;
            clk_div_ready <= 0;
            clk_div_ready_en <= 0;
            input_spike_ready <= 0;
            input_spike_ready_en <= 0;
            debug_config_ready <= 0;
            debug_config_ready_en <= 0;
            write_memory_enable <= 0;
            
            case (current_state)
                WAIT_DATA_VALID_MSB: begin
                    if (data_valid)
                        SPI_address_MSB_reg_en <= 1;
                end
                WAIT_DATA_VALID_LSB: begin
                    if (data_valid)
                        SPI_address_LSB_reg_en <= 1;
                end
                WAIT_DATA_VALID_INSTR: begin
                    if (data_valid) begin
                        SPI_instruction_reg_en <= 1;
                        case (SPI_instruction_reg_in)
                            8'h05: clk_div_ready_en <= 1;
                            8'h07: input_spike_ready_en <= 1;
                            8'h09: debug_config_ready_en <= 1;
                        default: ;
                        endcase
                    end
                end
                WAIT_DATA_VALID_FINAL: begin
                    if (data_valid) begin
                        case (SPI_instruction_reg_out)
                            8'h01, 8'h05, 8'h07, 8'h09: write_memory_enable <= 1;
                        default: ;
                        endcase
                    end
                end
                SYSCLK_DOMAIN_EN: begin
                    case (SPI_instruction_reg_out)
                        8'h05: begin
                            clk_div_ready <= 1;
                            clk_div_ready_en <= 1;
                        end
                        8'h07: begin
                            input_spike_ready <= 1;
                            input_spike_ready_en <= 1;
                        end
                        8'h09: begin
                            debug_config_ready <= 1;
                            debug_config_ready_en <= 1;
                        end
                        default: ;
                    endcase
                end
                default: ;
            endcase
        end
    end
endmodule
