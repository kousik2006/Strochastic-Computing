//==============================================================================
// Generic structural stochastic multiplier core.
// Stream lengths used by this project are 16 and 32.
//==============================================================================
`timescale 1ns/1ps
module sc_stochastic_multiplier #(
    parameter integer STREAM_LEN = 32,
    parameter integer POLY_A = 1,
    parameter [7:0] SEED_A = 8'd198,
    parameter integer POLY_B = 1,
    parameter [7:0] SEED_B = 8'd86
) (
    input wire clk, input wire reset, input wire start,
    input wire [7:0] A, input wire [7:0] B,
    output wire busy, output reg done, output reg [15:0] product,
    output wire stochastic_A, output wire stochastic_B,
    output wire stochastic_product,
    output wire [7:0] lfsr_A_state, output wire [7:0] lfsr_B_state,
    output reg [5:0] ones_A, output reg [5:0] ones_B,
    output reg [5:0] ones_product
);
    reg [7:0] A_reg, B_reg;
    reg busy_reg;
    reg [5:0] cycle_count;
    assign busy = busy_reg;
    wire start_accept = start & ~busy_reg;
    wire sng_seed_load = start_accept;
    wire sng_enable = busy_reg;

    sc_sng8 #(.POLY_SEL(POLY_A), .SEED(SEED_A)) u_sng_A (
        .clk(clk), .reset(reset), .load_seed(sng_seed_load), .enable(sng_enable),
        .input_value(A_reg), .lfsr_state(lfsr_A_state), .stochastic_bit(stochastic_A)
    );
    sc_sng8 #(.POLY_SEL(POLY_B), .SEED(SEED_B)) u_sng_B (
        .clk(clk), .reset(reset), .load_seed(sng_seed_load), .enable(sng_enable),
        .input_value(B_reg), .lfsr_state(lfsr_B_state), .stochastic_bit(stochastic_B)
    );

    assign stochastic_product = stochastic_A & stochastic_B;

    wire [5:0] final_ones_product = ones_product + stochastic_product;
    wire [20:0] scaled_product_full = final_ones_product * 21'd65025;
    wire [15:0] decoded_product = (STREAM_LEN == 16) ?
                                   (scaled_product_full >> 4) :
                                   (STREAM_LEN == 32) ?
                                   (scaled_product_full >> 5) : 16'd0;

    always @(posedge clk) begin
        if (reset) begin
            A_reg <= 0; B_reg <= 0; busy_reg <= 0; done <= 0;
            product <= 0; cycle_count <= 0;
            ones_A <= 0; ones_B <= 0; ones_product <= 0;
        end else begin
            done <= 0;
            if (start_accept) begin
                A_reg <= A; B_reg <= B; busy_reg <= 1;
                cycle_count <= 0; ones_A <= 0; ones_B <= 0; ones_product <= 0;
            end else if (busy_reg) begin
                ones_A <= ones_A + stochastic_A;
                ones_B <= ones_B + stochastic_B;
                ones_product <= final_ones_product;
                if (cycle_count == STREAM_LEN-1) begin
                    busy_reg <= 0; done <= 1; product <= decoded_product; cycle_count <= 0;
                end else begin
                    cycle_count <= cycle_count + 1'b1;
                end
            end
        end
    end
endmodule
