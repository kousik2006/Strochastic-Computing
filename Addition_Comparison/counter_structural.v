module counter_structural #(
    parameter integer N = 8
)(
    input  wire         clk,
    input  wire         reset,
    output wire [N-1:0] q
);
    wire [N:0] carry;
    wire [N-1:0] d;

    assign carry[0] = 1'b1;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : COUNT
            full_adder_structural ADD1 (
                .a(q[i]),
                .b(1'b0),
                .cin(carry[i]),
                .sum(d[i]),
                .cout(carry[i+1])
            );

            dff_structural #(.INIT(1'b0)) COUNT_FF (
                .clk(clk),
                .reset(reset),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate
endmodule
