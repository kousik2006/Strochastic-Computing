module sobol_structural #(
    parameter integer N = 8
)(
    input  wire         clk,
    input  wire         reset,
    output wire [N-1:0] value
);
    wire [N-1:0] index;
    wire [N-1:0] gray;

    counter_structural #(.N(N)) INDEX_COUNTER (
        .clk(clk),
        .reset(reset),
        .q(index)
    );

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : SOBOL_XOR
            if (i == N-1) begin : MSB
                assign gray[i] = index[i];
            end else begin : OTHER
                xor (gray[i], index[i], index[i+1]);
            end
        end

        // Reverse the Gray-code bits to form the 1-D base-2 Sobol integer.
        for (i = 0; i < N; i = i + 1) begin : BIT_REVERSE
            assign value[i] = gray[N-1-i];
        end
    endgenerate
endmodule
