module lfsr #(
    parameter integer N = 32,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED     = 8'b00000001
)(
    input  wire         clk,
    input  wire         reset,
    output reg  [N-1:0] q
);

    wire feedback;

    assign feedback = ^(q & TAP_MASK);

    always @(posedge clk) begin
        if (reset)
            q <= SEED;
        else
            q <= {q[N-2:0], feedback};
    end

endmodule
