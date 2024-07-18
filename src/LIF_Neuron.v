module LIF_Neuron #(
    parameter M = 8                   // Number of input spikes and weights
)(
    input wire clk,                        // Clock signal
    input wire reset,                      // Asynchronous reset, active high
    input wire enable,                     // Enable input for the entire LIF neuron
    input wire [M-1:0] input_spikes,       // M-bit input spikes
    input wire [M*8-1:0] weights,          // M 8-bit weights
    input wire [7:0] threshold,            // Firing threshold (V_thresh)
    input wire [7:0] decay,                // Decay value
    input wire [7:0] refractory_period,    // Refractory period in number of clock cycles
    output wire spike_out                  // Output spike signal
);
    wire [7:0] input_current;         // 8-bit input current from InputCurrentCalculator

    // Instantiate the InputCurrentCalculator module
    InputCurrentCalculator #(
        .M(M)
    ) input_current_calculator_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_spikes(input_spikes),
        .weights(weights),
        .input_current(input_current)
    );

    // Instantiate the LeakyIntegrateFireNeuron module
    LeakyIntegrateFireNeuron lif_neuron_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_current(input_current),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .spike_out(spike_out)
    );

endmodule
