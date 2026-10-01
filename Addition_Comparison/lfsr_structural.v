module lfsr_structural #(
    parameter integer N = 8,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED = 8'b00000001
)(
    input  wire         clk,
    input  wire         reset,
    output wire [N-1:0] q
);
    wire feedback;
    wire [N-1:0] d;

    xor_reduce_structural #(.N(N)) FEEDBACK_XOR (
        .in(q & TAP_MASK),
        .out(feedback)
    );

    assign d[0] = feedback;

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : SHIFT
            assign d[i] = q[i-1];
        end

        for (i = 0; i < N; i = i + 1) begin : FF
            dff_structural #(.INIT(SEED[i])) LFSR_FF (
                .clk(clk),
                .reset(reset),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate
endmodule
