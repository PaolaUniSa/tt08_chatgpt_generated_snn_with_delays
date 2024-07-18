module NeuronLayerWithDelays #(
    parameter M = 2,                // Number of input spikes and weights
    parameter N = 4                 // Number of neurons in the layer
)(
    input wire clk,                      // Clock signal
    input wire reset,                    // Asynchronous reset, active high
    input wire enable,                   // Enable input for the entire layer
    input wire delay_clk,                // Delay Clock signal
    input wire [M-1:0] input_spikes,     // M-bit input spikes
    input wire [N*M*8-1:0] weights,      // N * M 8-bit weights
    input wire [7:0] threshold,          // Firing threshold (V_thresh)
    input wire [7:0] decay,              // Decay value
    input wire [7:0] refractory_period,  // Refractory period in number of clock cycles
    input wire [N*M*3-1:0] delay_values, // Flattened array of 3-bit delay values
    input wire [N*M-1:0] delays,         // Array of delay enables for each input
    output wire [N-1:0] output_spikes    // Output spike signals for each neuron
);

    // Generate NeuronWithDelays instances for each neuron
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: neuron_gen
            NeuronWithDelays #(
                .M(M)
            ) neuron_inst (
                .clk(clk),
                .reset(reset),
                .enable(enable),
                .delay_clk(delay_clk),
                .input_spikes(input_spikes),
                .weights(weights[i*M*8 +: M*8]),
                .threshold(threshold),
                .decay(decay),
                .refractory_period(refractory_period),
                .delay_values(delay_values[i*M*3 +: M*3]),
                .delays(delays[i*M +: M]),
                .spike_out(output_spikes[i])
            );
        end
    endgenerate

endmodule
