`timescale 1ns/1ps

module sc_sng_sobol_parameterized #(
    parameter integer N = 8
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire [N-1:0] input_value,
    output wire         stochastic_bit,
    output wire [7:0]   sequence_value
);
    sc_sobol8_parameterized SOBOL (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .value(sequence_value)
    );

    assign stochastic_bit = sequence_value < input_value;
endmodule
