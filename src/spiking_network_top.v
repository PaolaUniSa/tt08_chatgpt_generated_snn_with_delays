module spiking_network_top #(
    parameter Nbits = 4 )               // Number of bits for the weights and membrane potential
 (
    input wire system_clock,
    input wire reset,
    input wire SCLK,
    input wire MOSI,
    input wire SS,
    output wire MISO,
    output wire [8-1:0] debug_output,//[7:0]
    output wire [1:0] output_spikes
);
    // Internal signals
    wire clk_div_ready_reg_out;
    wire input_spike_ready_reg_out;
    wire debug_config_ready_reg_out;
    wire clk_div_ready_sync;
    wire input_spike_ready_sync;   
    wire debug_config_ready_sync;
    wire [(24*8+8*2)*4+(24*8+8*2)*Nbits+4*Nbits+3*8+8-1+8:0] all_data_out; //3*8 +8+8+8+ 208*8 +8=208*8+56=1664+56 =1720  -- 215 bytes
    wire [23:0] input_spikes;   //[23:0] input_spikes;
    wire [Nbits-1:0] decay;
    wire [Nbits-1:0] refractory_period;
    wire [Nbits-1:0] threshold;
    wire [7:0] div_value;
    wire [(24*8+8*2)*Nbits-1:0] weights;
    wire [(24*8+8*2)*4-1:0] delays;
    wire [7:0] debug_config_in;
    wire [(8+2)*Nbits-1:0] membrane_potentials; //79
    wire [8-1:0] output_spikes_layer1;
    wire delay_clk;
    
    wire MOSI_sync; // Synchronized MOSI signal

    // Instantiations
    spi_interface spi_inst (
        .SCLK(SCLK),
        .MOSI(MOSI_sync),
        .SS(SS),
        .RESET(reset),
        .MISO(MISO),
        .clk_div_ready_reg_out(clk_div_ready_reg_out),
        .input_spike_ready_reg_out(input_spike_ready_reg_out),
        .debug_config_ready_reg_out(debug_config_ready_reg_out),
        .all_data_out(all_data_out)
    );

    clock_divider clk_div_inst (
        .clk(system_clock),
        .reset(reset),
        .enable(clk_div_ready_sync),
        .div_value(div_value),
        .clk_out(delay_clk)
    );

    debug_module #(.Nbits(Nbits)) debug_inst  (
        .clk(system_clock),
        .rst(reset),
        .en(debug_config_ready_sync),
        .debug_config_in(debug_config_in),
        .membrane_potentials(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .debug_select(debug_output)
    );

    SNNwithDelays_top #(.Nbits(Nbits)) snn_inst (
        .clk(system_clock),
        .reset(reset),
        .enable(input_spike_ready_sync),
        .delay_clk(delay_clk),
        .input_spikes(input_spikes),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .delays(delays),
        .membrane_potential_out(membrane_potentials),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes(output_spikes)
    );

    // Synchronizers
    synchronizer clk_div_sync (
        .clk(system_clock),
        .reset(reset),
        .async_signal(clk_div_ready_reg_out),
        .sync_signal(clk_div_ready_sync)
    );

    synchronizer input_spike_sync (
        .clk(system_clock),
        .reset(reset),
        .async_signal(input_spike_ready_reg_out),
        .sync_signal(input_spike_ready_sync)
    );

    synchronizer debug_config_sync (
        .clk(system_clock),
        .reset(reset),
        .async_signal(debug_config_ready_reg_out),
        .sync_signal(debug_config_ready_sync)
    );

    // MOSI Synchronizer
    synchronizer mosi_sync (
        .clk(SCLK),
        .reset(reset),
        .async_signal(MOSI),
        .sync_signal(MOSI_sync)
    );

    // Corrected Assignments
    // 3*8  +8 +8+8+ 208*8+8=208*8 +56=1664+56=   1720
	assign input_spikes = all_data_out      [3*8-1                          :                      0];   // 3 bytes
    assign decay = all_data_out             [Nbits+3*8-1                    :                    3*8];   // 0:1 bits in the 4° byte
    assign refractory_period = all_data_out [2*Nbits+3*8-1                  :              Nbits+3*8];   // 2:3 bits in the 4° byte
    assign threshold = all_data_out         [3*Nbits+3*8-1     :                 2*Nbits+3*8];          // 4:5 bits in the 4° byte
    assign div_value = all_data_out         [4*Nbits+3*8+8-1:4*Nbits+3*8];                              // 5° byte
    assign weights = all_data_out           [(24*8+8*2)*Nbits+4*Nbits+3*8+8-1:4*Nbits+3*8+8];           //Nbits=2 is 416 bits -> 52 bytes (6:57)         
    assign delays = all_data_out            [(24*8+8*2)*4+(24*8+8*2)*Nbits+4*Nbits+3*8+8-1 :(24*8+8*2)*Nbits+4*Nbits+3*8+8]; // 832 bits (104 bytes)
    assign debug_config_in = all_data_out   [(24*8+8*2)*4+(24*8+8*2)*Nbits+4*Nbits+3*8+8-1+8:(24*8+8*2)*4+(24*8+8*2)*Nbits+4*Nbits+3*8+8]; 

//(24*8+8*2)*4+(24*8+8*2)*Nbits+4*Nbits+3*8+8+8   with Nbits=2 = 1296   ---> 162 bytes
endmodule   

