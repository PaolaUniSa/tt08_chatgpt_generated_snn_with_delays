/*
 * Copyright (c) 2024 Paola Vitolo
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_chatgpt_snn_with_delays_paolaunisa (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);



    // Internal signals for the SNNwithDelays_top instance
    wire [23:0] input_spikes;
    wire [(24*8+8*2)*2-1:0] weights;
    wire [2-1:0] threshold;
    wire [2-1:0] decay;
    wire [2-1:0] refractory_period;
    wire [(8*24+8*2)*4-1:0] delays;
    wire [(8+2)*2-1:0] membrane_potential_out;
    wire [7:0] output_spikes_layer1;
    wire [1:0] output_spikes;

    // Map ui_in to input_spikes and other inputs
    assign input_spikes = {3{ui_in[7:0]}}; // Assuming ui_in carries the input spikes
    assign weights = {52{ui_in[7:0]}};
    
    assign threshold= ui_in[1:0];
    assign decay = ui_in[1:0];
    assign refractory_period = ui_in[1:0];
    
    assign delays = {52{ui_in[7:0]}};
    // Map other ui_in signals to the appropriate internal signals
    // Similarly, assign values for weights, threshold, decay, refractory_period, and delays
    // according to your design requirements

    // Output mappings
    assign uo_out[7:0] = output_spikes_layer1[7:0];
    assign uio_out[1:0] = output_spikes[1:0];
    assign uio_out[7:2] = 6'b000000;
    assign uio_oe = 8'b11111111; // Enable all uio_out signals


// List all unused inputs to prevent warnings
  wire _unused = &{ena,uio_in, 1'b0};


    // Instantiate the SNNwithDelays_top module
    SNNwithDelays_top #(
        .Nbits(2)
    ) snn_with_delays (
        .clk(clk),
        .reset(~rst_n),                    // Convert active low reset to active high
        .enable(ena),
        .delay_clk(clk),                   // Assuming delay_clk is the same as clk
        .input_spikes(input_spikes),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .delays(delays),
        .membrane_potential_out(membrane_potential_out),
        .output_spikes_layer1(output_spikes_layer1),
        .output_spikes(output_spikes)
    );

endmodule
