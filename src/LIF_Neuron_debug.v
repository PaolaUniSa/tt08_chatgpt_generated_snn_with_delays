module LIF_Neuron_debug #(
    parameter M = 8,                   // Number of input spikes and weights
    parameter Nbits = 2		      // Nbits weight precision and membrane potential
)(
    input wire clk,                        // Clock signal
    input wire reset,                      // Asynchronous reset, active high
    input wire enable,                     // Enable input for the entire LIF neuron
    input wire [M-1:0] input_spikes,       // M-bit input spikes
    input wire [M*Nbits-1:0] weights,          // M Nbit weights
    input wire [Nbits-1:0] threshold,            // Firing threshold (V_thresh)
    input wire [Nbits-1:0] decay,                // Decay value
    input wire [Nbits-1:0] refractory_period,    // Refractory period in number of clock cycles
    output wire [Nbits-1:0] membrane_potential_out, // add for debug
    output wire spike_out                  // Output spike signal
);
    wire [Nbits-1:0] input_current;         // Nbit input current from InputCurrentCalculator

    // Instantiate the InputCurrentCalculator module
    InputCurrentCalculator #(
        .M(M),
        .Nbits(Nbits)
    ) input_current_calculator_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_spikes(input_spikes),
        .weights(weights),
        .input_current(input_current)
    );

    // Instantiate the LeakyIntegrateFireNeuron module
    LeakyIntegrateFireNeuron_debug #(
    	.Nbits(Nbits)
    ) lif_neuron_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .input_current(input_current),
        .threshold(threshold),
        .decay(decay),
        .refractory_period(refractory_period),
        .membrane_potential_out(membrane_potential_out),
        .spike_out(spike_out)
    );

endmodule
