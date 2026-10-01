module sng_lfsr_structural #(
    parameter integer N = 8,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED = 8'b00000001
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [N-1:0] input_value,
    output wire         stochastic_bit
);
    wire [N-1:0] random_value;

    lfsr_structural #(
        .N(N),
        .TAP_MASK(TAP_MASK),
        .SEED(SEED)
    ) LFSR (
        .clk(clk),
        .reset(reset),
        .q(random_value)
    );

    comparator_structural #(.N(N)) COMPARE (
        .a(random_value),
        .b(input_value),
        .a_lt_b(stochastic_bit)
    );
endmodule
