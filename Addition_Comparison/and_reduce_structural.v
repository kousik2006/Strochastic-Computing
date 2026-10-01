module and_reduce_structural #(
    parameter integer N = 8
)(
    input  wire [N-1:0] in,
    output wire         out
);
    wire [N-1:0] a;

    assign a[0] = in[0];

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : AND_TREE
            and (a[i], a[i-1], in[i]);
        end
    endgenerate

    assign out = a[N-1];
endmodule
