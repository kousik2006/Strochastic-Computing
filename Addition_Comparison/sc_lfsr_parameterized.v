// Parameterized Fibonacci LFSR.
// Default N=8 TAP_MASK 10110010 gives feedback
// state[7] ^ state[5] ^ state[4] ^ state[1].
//
// For another N, provide a suitable TAP_MASK and non-zero SEED.

module sc_lfsr_parameterized #(
    parameter integer N = 8,
    parameter [N-1:0] TAP_MASK = 8'b10110010,
    parameter [N-1:0] SEED = 1
)(
    input wire clk,
    input wire reset,
    input wire load_seed,
    input wire enable,
    output reg [N-1:0] state
);
    wire feedback;

    assign feedback = ^(state & TAP_MASK);

    always @(posedge clk) begin
        if (reset)
            state <= SEED;
        else if (load_seed)
            state <= SEED;
        else if (enable)
            state <= {state[N-2:0], feedback};
    end
endmodule
