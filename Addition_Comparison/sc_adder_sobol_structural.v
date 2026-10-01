module sc_adder_sobol_structural #(
    parameter integer N = 8
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
    wire [N-1:0] select_sequence;

    sng_sobol_structural #(.N(N)) SNG_A (
        .clk(clk), .reset(reset),
        .input_value(A),
        .stochastic_bit(stochastic_A)
    );

    sng_sobol_structural #(.N(N)) SNG_B (
        .clk(clk), .reset(reset),
        .input_value(B),
        .stochastic_bit(stochastic_B)
    );

    sobol_structural #(.N(N)) SELECT_SOBOL (
        .clk(clk), .reset(reset),
        .value(select_sequence)
    );

    assign select_bit = select_sequence[N-1];

    mux2_structural MUX_ADD (
        .d0(stochastic_B),
        .d1(stochastic_A),
        .sel(select_bit),
        .y(sum_bit)
    );
endmodule
