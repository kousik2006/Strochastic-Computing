module binary_adder_parameterized #(
    parameter integer N = 32
)(
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire [N:0]   Sum
);
    wire [N:0] carry;

    assign carry[0] = 1'b0;
    assign Sum[N] = carry[N];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : ADD
            full_adder_structural FA (
                .a(A[i]),
                .b(B[i]),
                .cin(carry[i]),
                .sum(Sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
endmodule
