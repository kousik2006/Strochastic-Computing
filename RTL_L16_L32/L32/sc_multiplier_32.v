//==============================================================================
// L=32 dedicated top-level wrapper.
// Fixed best investigated pair: P2-198 x P2-86.
//==============================================================================
`timescale 1ns/1ps
module sc_multiplier_32 (
    input wire clk, input wire reset, input wire start,
    input wire [7:0] A, input wire [7:0] B,
    output wire busy, output wire done, output wire [15:0] product,
    output wire stochastic_A, output wire stochastic_B,
    output wire stochastic_product,
    output wire [7:0] lfsr_A_state, output wire [7:0] lfsr_B_state,
    output wire [5:0] ones_A, output wire [5:0] ones_B,
    output wire [5:0] ones_product
);
    sc_stochastic_multiplier #(
        .STREAM_LEN(32),
        .POLY_A(1), .SEED_A(8'd198),
        .POLY_B(1), .SEED_B(8'd86)
    ) u_core (
        .clk(clk), .reset(reset), .start(start), .A(A), .B(B),
        .busy(busy), .done(done), .product(product),
        .stochastic_A(stochastic_A), .stochastic_B(stochastic_B),
        .stochastic_product(stochastic_product),
        .lfsr_A_state(lfsr_A_state), .lfsr_B_state(lfsr_B_state),
        .ones_A(ones_A), .ones_B(ones_B), .ones_product(ones_product)
    );
endmodule
