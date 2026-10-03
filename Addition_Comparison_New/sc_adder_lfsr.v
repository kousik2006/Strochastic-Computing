module sc_adder_lfsr #(
    parameter integer N = 32,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED_A   = 8'b11000110,
    parameter [N-1:0] SEED_B   = 8'b01010110
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire         sum_bit
);

    wire A_bit;
    wire B_bit;
    wire select_bit;

    lfsr_sng #(
        .N(N),
        .TAP_MASK(TAP_MASK),
        .SEED(SEED_A)
    ) SNG_A (
        .clk(clk),
        .reset(reset),
        .input_value(A),
        .stochastic_bit(A_bit)
    );

    lfsr_sng #(
        .N(N),
        .TAP_MASK(TAP_MASK),
        .SEED(SEED_B)
    ) SNG_B (
        .clk(clk),
        .reset(reset),
        .input_value(B),
        .stochastic_bit(B_bit)
    );

    select_toggle SELECT (
        .clk(clk),
        .reset(reset),
        .q(select_bit)
    );

    mux2 MUX_ADD (
        .d0(B_bit),
        .d1(A_bit),
        .sel(select_bit),
        .y(sum_bit)
    );

endmodule
