//==============================================================================
// sc_lfsr8.v
// 8-bit Fibonacci LFSR matching the project convention.
// Current state is used first; then feedback is XORed and shifted in at bit 0.
// POLY_SEL: 0=P1 [7,5,4,3], 1=P2 [7,5,4,1], 2=P3 [7,6,1,0].
//==============================================================================
`timescale 1ns/1ps

module sc_lfsr8 #(
    parameter integer POLY_SEL = 1,
    parameter [7:0] SEED       = 8'd1
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       load_seed,
    input  wire       enable,
    output wire [7:0] state
);
    localparam integer P1 = 0;
    localparam integer P2 = 1;
    localparam integer P3 = 2;

    wire feedback;
    wire [7:0] next_state;
    wire [7:0] d_state;

    assign feedback = (POLY_SEL == P1) ?
                      (state[7] ^ state[5] ^ state[4] ^ state[3]) :
                      (POLY_SEL == P2) ?
                      (state[7] ^ state[5] ^ state[4] ^ state[1]) :
                      (state[7] ^ state[6] ^ state[1] ^ state[0]);

    assign next_state = {state[6:0], feedback};
    assign d_state = load_seed ? SEED : enable ? next_state : state;

    sc_dff ff7 (.clk(clk), .reset(reset), .d(d_state[7]), .q(state[7]));
    sc_dff ff6 (.clk(clk), .reset(reset), .d(d_state[6]), .q(state[6]));
    sc_dff ff5 (.clk(clk), .reset(reset), .d(d_state[5]), .q(state[5]));
    sc_dff ff4 (.clk(clk), .reset(reset), .d(d_state[4]), .q(state[4]));
    sc_dff ff3 (.clk(clk), .reset(reset), .d(d_state[3]), .q(state[3]));
    sc_dff ff2 (.clk(clk), .reset(reset), .d(d_state[2]), .q(state[2]));
    sc_dff ff1 (.clk(clk), .reset(reset), .d(d_state[1]), .q(state[1]));
    sc_dff ff0 (.clk(clk), .reset(reset), .d(d_state[0]), .q(state[0]));
endmodule
