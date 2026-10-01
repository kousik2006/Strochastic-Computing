`timescale 1ns/1ps

module sc_sng_lfsr_parameterized #(
    parameter integer N = 8,
    parameter [7:0]   SEED = 8'h1
)(
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,
    input  wire [N-1:0] input_value,
    output wire         stochastic_bit
);
    wire [7:0] random_value;

    sc_lfsr8_parameterized #(.SEED(SEED)) LFSR (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .state(random_value)
    );

    assign stochastic_bit = random_value < input_value;
endmodule
