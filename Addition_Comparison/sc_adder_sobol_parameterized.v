`timescale 1ns/1ps

module sc_adder_sobol_parameterized #(
    parameter integer N = 8,
    parameter integer L = 32
)(
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output reg          busy,
    output reg          done,
    output reg  [N:0]   sum,
    output wire         stochastic_A,
    output wire         stochastic_B,
    output wire         stochastic_select,
    output wire         stochastic_sum
);
    reg [N-1:0] A_reg, B_reg;
    reg [7:0] count;
    reg [7:0] ones;

    wire start_accept = start & ~busy;

    wire [7:0] seq_A, seq_B, seq_S;
    reg  [7:0] dummy_seed;

    sc_sng_sobol_parameterized #(.N(N)) SNG_A (
        .clk(clk), .reset(reset), .enable(busy),
        .input_value(A_reg), .stochastic_bit(stochastic_A),
        .sequence_value(seq_A)
    );

    sc_sng_sobol_parameterized #(.N(N)) SNG_B (
        .clk(clk), .reset(reset), .enable(busy),
        .input_value(B_reg), .stochastic_bit(stochastic_B),
        .sequence_value(seq_B)
    );

    // Independent deterministic phase for the select sequence.
    sc_sobol8_parameterized SNG_SELECT (
        .clk(clk), .reset(reset), .enable(busy),
        .value(seq_S)
    );

    assign stochastic_select = seq_S < 8'd128;
    assign stochastic_sum = stochastic_select ? stochastic_A : stochastic_B;

    wire [7:0] ones_next = ones + stochastic_sum;

    always @(posedge clk) begin
        if (reset) begin
            A_reg <= 0;
            B_reg <= 0;
            count <= 0;
            ones <= 0;
            sum <= 0;
            busy <= 0;
            done <= 0;
        end else begin
            done <= 0;

            if (start_accept) begin
                A_reg <= A;
                B_reg <= B;
                count <= 0;
                ones <= 0;
                sum <= 0;
                busy <= 1;
            end else if (busy) begin
                ones <= ones_next;

                if (count == L-1) begin
                    sum <= ((ones_next * (2*(2**N-1))) + (L/2)) / L;
                    busy <= 0;
                    done <= 1;
                    count <= 0;
                end else begin
                    count <= count + 1'b1;
                end
            end
        end
    end
endmodule
