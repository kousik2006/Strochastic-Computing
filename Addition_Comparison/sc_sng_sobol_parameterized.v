module sc_sng_sobol_parameterized #(
    parameter integer N = 8,
    parameter [N-1:0] SEED = 0
)(
    input wire clk,
    input wire reset,
    input wire load_seed,
    input wire enable,
    input wire [N-1:0] input_value,
    output wire stochastic_bit,
    output wire [N-1:0] sequence_value
);
    sc_sobol_parameterized #(
        .N(N),
        .SEED(SEED)
    ) SOBOL (
        .clk(clk),
        .reset(reset),
        .load_seed(load_seed),
        .enable(enable),
        .value(sequence_value)
    );

    assign stochastic_bit = (sequence_value < input_value);
endmodule
