module lfsr_sng #(
    parameter integer N = 32,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED     = 8'b00000001
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [N-1:0] input_value,
    output wire         stochastic_bit
);

    wire [N-1:0] random_value;

    lfsr #(
        .N(N),
        .TAP_MASK(TAP_MASK),
        .SEED(SEED)
    ) RNG (
        .clk(clk),
        .reset(reset),
        .q(random_value)
    );

    assign stochastic_bit = (random_value <= input_value);

endmodule
