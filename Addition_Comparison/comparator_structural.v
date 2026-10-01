module comparator_structural #(
    parameter integer N = 8
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire         a_lt_b
);
    wire [N:0] equal;
    wire [N:0] less;
    wire [N-1:0] a_not;
    wire [N-1:0] xnor_bit;
    wire [N-1:0] less_bit;
    wire [N-1:0] less_here;

    assign equal[N] = 1'b1;
    assign less[N]  = 1'b0;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : CMP
            localparam integer K = N-1-i;
            not  (a_not[K], a[K]);
            xnor (xnor_bit[K], a[K], b[K]);
            and  (less_bit[K], a_not[K], b[K]);
            and  (less_here[K], equal[K+1], less_bit[K]);
            or   (less[K], less_here[K], less[K+1]);
            and  (equal[K], equal[K+1], xnor_bit[K]);
        end
    endgenerate

    assign a_lt_b = less[0];
endmodule
