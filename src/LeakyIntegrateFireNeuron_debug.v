module LeakyIntegrateFireNeuron_debug (
    input wire clk,                          // Clock signal
    input wire reset,                        // Asynchronous reset, active high
    input wire enable,                       // Enable input for updating the neuron
    input wire [2-1:0] input_current,    // Input current (I_ext)
    input wire [2-1:0] threshold,        // Firing threshold (V_thresh)
    input wire [2-1:0] decay,            // Decay value adjusted based on membrane potential sign
    input wire [2-1:0] refractory_period, // Refractory period in number of clock cycles
    output wire [2-1:0] membrane_potential_out, // add for debug
    output reg spike_out                // Output spike signal, renamed from 'fired'
);

    reg [2-1:0] membrane_potential = 2'b0;  // Membrane potential (V_m), initialized to 0
    reg [2-1:0] refractory_counter = 2'b0;  // Counter to handle the refractory period, initialized to 0
    wire signed [2+1:0] potential_update;   // Use a wire for immediate calculation, now Nbits + 2    3:0


    assign membrane_potential_out = membrane_potential;
   
    // Correctly perform sign extension when computing potential_update
    assign potential_update = $signed({membrane_potential[2-1], membrane_potential[2-1], membrane_potential}) +
                              $signed({input_current[2-1], input_current[2-1], input_current}) +
                              (membrane_potential[2-1] ? $signed({decay[2-1], decay[2-1], decay}) : -$signed({decay[2-1], decay[2-1], decay}));

    always @(posedge clk or posedge reset) begin
        // Initialize spike_out at the beginning of the block
        spike_out <= 1'b0;

        if (reset) begin
            // Reset all states immediately when reset is high, regardless of clock
            membrane_potential <= 2'b0;
            refractory_counter <= 2'b0;
        end else if (enable) begin  // Only update if enabled
            if (refractory_counter > 0) begin
                // Decrement refractory counter if in refractory period
                refractory_counter <= refractory_counter - 1;
            end else begin
                // Use the calculated potential_update to set the new membrane potential
                if (potential_update[2+1] && potential_update < -8)  // Negative overflow (checks if negative and exceeds 8-bit lower bound)
                    membrane_potential <= 2'b10; // Set to -7
                else if (potential_update > 7)  // Positive overflow (checks if exceeds 8-bit upper bound)
                    membrane_potential <= 2'b01; // Set to 7
                else  // No overflow or underflow
                    membrane_potential <= potential_update[2-1:0];

                if ($signed(membrane_potential) >= $signed(threshold)) begin
                    // Neuron fires
                    spike_out <= 1'b1;
                    membrane_potential <= $signed(membrane_potential) - $signed(threshold); // Subtracting reset
                    refractory_counter <= refractory_period; // Enter refractory period
                end
            end
        end
    end
endmodule
