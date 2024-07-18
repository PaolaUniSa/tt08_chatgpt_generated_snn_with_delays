module NeuronWithDelays #(
    parameter M = 2                // Number of input spikes and weights
)(
    input wire clk,                      // Clock signal
    input wire reset,                    // Asynchronous reset, active high
    input wire enable,                   // Enable input for the entire neuron
    input wire delay_clk,                // Delay Clock signal
    input wire [M-1:0] input_spikes,     // M-bit input spikes
    input wire [M*8-1:0] weights,        // M 8-bit weights
    input wire [7:0] threshold,          // Firing threshold (V_thresh)
    input wire [7:0] decay,              // Decay value
    input wire [7:0] refractory_period,  // Refractory period in number of clock cycles
    input wire [M*3-1:0] delay_values,   // Flattened array of 3-bit delay values
    input wire [M-1:0] delays,           // Array of delay enables for each input
    output wire spike_out                // Output spike signal
);
    wire [M-1:0] delayed_spikes;     // Delayed input spikes

    // Generate neuron_delay instances for each input spike
    genvar i;
    generate
        for (i = 0; i < M; i = i + 1) begin: neuron_delay_gen
            neuron_delay neuron_delay_inst (
                .sys_clk(clk),
                .reset(reset),
                .enable(enable),
                .delay_clk(delay_clk), // Assuming delay clock is same as system clock
                .delay_value(delay_values[i*3 +: 3]),
                .delay(delays[i]),
                .din(input_spikes[i]),
                .dout(delayed_spikes[i])
            );
        end
    endgenerate

    // Instantiate the LIF_Neuron module
    LIF_Neuron #(
        .M(M)
    ) lif_neuron_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_spikes(delayed_spikes),
        .weights(weights),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .spike_out(spike_out)
    );

endmodule
