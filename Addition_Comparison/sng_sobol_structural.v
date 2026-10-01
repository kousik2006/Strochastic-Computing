module sng_sobol_structural #(
    parameter integer N = 8
)(
    input  wire         clk,
    input  wire         reset,
    input  wire [N-1:0] input_value,
    output wire         stochastic_bit
);
    wire [N-1:0] sequence_value;

    sobol_structural #(.N(N)) SOBOL (
        .clk(clk),
        .reset(reset),
        .value(sequence_value)
    );

    comparator_structural #(.N(N)) COMPARE (
        .a(sequence_value),
        .b(input_value),
        .a_lt_b(stochastic_bit)
    );
endmodule
