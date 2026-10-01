module xor_reduce_structural #(
    parameter integer N = 8
)(
    input  wire [N-1:0] in,
    output wire         out
);
    wire [N-1:0] x;

    assign x[0] = in[0];

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : XOR_TREE
            xor (x[i], x[i-1], in[i]);
        end
    endgenerate

    assign out = x[N-1];
endmodule
