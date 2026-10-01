`timescale 1ns/1ps

module sc_adder_lfsr_parameterized #(
    parameter integer N = 8,
    parameter integer L = 32,
    parameter [7:0] SEED_A = 8'd198,
    parameter [7:0] SEED_B = 8'd86
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
    reg [7:0] select_lfsr;
    reg [7:0] count;

    wire start_accept = start & ~busy;

    wire feedback_sel = select_lfsr[7] ^ select_lfsr[5] ^
                        select_lfsr[4] ^ select_lfsr[1];

    wire [7:0] sel_next = {select_lfsr[6:0], feedback_sel};

    assign stochastic_select = (select_lfsr < 8'd128);

    sc_sng_lfsr_parameterized #(.N(N), .SEED(SEED_A)) SNG_A (
        .clk(clk), .reset(reset), .enable(busy),
        .input_value(A_reg), .stochastic_bit(stochastic_A)
    );

    sc_sng_lfsr_parameterized #(.N(N), .SEED(SEED_B)) SNG_B (
        .clk(clk), .reset(reset), .enable(busy),
        .input_value(B_reg), .stochastic_bit(stochastic_B)
    );

    // Qian-Riedel scaled addition:
    // Y = A*S + B*(1-S), with P(S=1)=0.5.
    // Implemented explicitly as a MUX, not as OR logic.
    assign stochastic_sum = stochastic_select ? stochastic_A : stochastic_B;

    reg [7:0] ones;
    wire [7:0] ones_next = ones + stochastic_sum;

    always @(posedge clk) begin
        if (reset) begin
            A_reg <= 0;
            B_reg <= 0;
            select_lfsr <= 8'd251;
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
                select_lfsr <= 8'd251;
                count <= 0;
                ones <= 0;
                sum <= 0;
                busy <= 1;
            end else if (busy) begin
                ones <= ones_next;
                select_lfsr <= sel_next;

                if (count == L-1) begin
                    // Decode P(Y=1) and undo the factor-of-two scaling.
                    // Numerically this is approximately A+B in the original N-bit scale.
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
