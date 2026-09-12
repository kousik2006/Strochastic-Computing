//==============================================================================
// sc_sng8.v
// Structural 8-bit LFSR + comparator stochastic number generator.
//==============================================================================
`timescale 1ns/1ps
module sc_sng8 #(
    parameter integer POLY_SEL = 1,
    parameter [7:0] SEED       = 8'd1
) (
    input wire clk, input wire reset, input wire load_seed, input wire enable,
    input wire [7:0] input_value,
    output wire [7:0] lfsr_state,
    output wire stochastic_bit
);
    sc_lfsr8 #(.POLY_SEL(POLY_SEL), .SEED(SEED)) u_lfsr (
        .clk(clk), .reset(reset), .load_seed(load_seed), .enable(enable), .state(lfsr_state)
    );
    sc_comparator8_lt u_compare (
        .a(lfsr_state), .b(input_value), .y(stochastic_bit)
    );
endmodule
