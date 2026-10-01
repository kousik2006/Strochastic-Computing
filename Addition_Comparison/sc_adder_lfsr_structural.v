module sc_adder_lfsr_structural #(
    parameter integer N = 8,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED_A = 8'b11000110,
    parameter [N-1:0] SEED_B = 8'b01010110,
    parameter [N-1:0] SEED_S = 8'b11111011
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire         sum_bit
);
    wire stochastic_A;
    wire stochastic_B;
    wire select_bit;
    wire [N-1:0] select_random;

    sng_lfsr_structural #(
        .N(N), .TAP_MASK(TAP_MASK), .SEED(SEED_A)
    ) SNG_A (
        .clk(clk), .reset(reset),
        .input_value(A),
        .stochastic_bit(stochastic_A)
    );

    sng_lfsr_structural #(
        .N(N), .TAP_MASK(TAP_MASK), .SEED(SEED_B)
    ) SNG_B (
        .clk(clk), .reset(reset),
        .input_value(B),
        .stochastic_bit(stochastic_B)
    );

    lfsr_structural #(
        .N(N), .TAP_MASK(TAP_MASK), .SEED(SEED_S)
    ) SELECT_LFSR (
        .clk(clk), .reset(reset),
        .q(select_random)
    );

    assign select_bit = select_random[N-1];

    mux2_structural MUX_ADD (
        .d0(stochastic_B),
        .d1(stochastic_A),
        .sel(select_bit),
        .y(sum_bit)
    );
endmodule
