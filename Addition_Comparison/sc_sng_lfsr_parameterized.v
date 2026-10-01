module sc_sng_lfsr_parameterized #(
    parameter integer N = 8,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED = 1
)(
    input wire clk,
    input wire reset,
    input wire load_seed,
    input wire enable,
    input wire [N-1:0] input_value,
    output wire stochastic_bit,
    output wire [N-1:0] random_value
);
    sc_lfsr_parameterized #(
        .N(N),
        .TAP_MASK(TAP_MASK),
        .SEED(SEED)
    ) LFSR (
        .clk(clk),
        .reset(reset),
        .load_seed(load_seed),
        .enable(enable),
        .state(random_value)
    );

    assign stochastic_bit = (random_value < input_value);
endmodule
