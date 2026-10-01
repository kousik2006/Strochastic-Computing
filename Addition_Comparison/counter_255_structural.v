module counter_255_structural #(
    parameter integer N = 8
)(
    input  wire         clk,
    input  wire         reset,
    output wire [N-1:0] q
);
    wire [N:0] carry;
    wire [N-1:0] incremented;
    wire [N-1:0] d;
    wire at_max;

    assign carry[0] = 1'b1;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : INC
            full_adder_structural ADD1 (
                .a(q[i]),
                .b(1'b0),
                .cin(carry[i]),
                .sum(incremented[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    and_reduce_structural #(.N(N)) MAX_DETECT (
        .in(q),
        .out(at_max)
    );

    generate
        for (i = 0; i < N; i = i + 1) begin : NEXT
            mux2_structural NEXT_MUX (
                .d0(incremented[i]),
                .d1((i == 0) ? 1'b1 : 1'b0),
                .sel(at_max),
                .y(d[i])
            );

            dff_structural #(.INIT((i == 0) ? 1'b1 : 1'b0)) COUNT_FF (
                .clk(clk),
                .reset(reset),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate
endmodule
