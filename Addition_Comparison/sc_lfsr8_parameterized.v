`timescale 1ns/1ps

module sc_lfsr8_parameterized #(
    parameter [7:0] SEED = 8'h1
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [7:0] state
);
    wire feedback;
    assign feedback = state[7] ^ state[5] ^ state[4] ^ state[1];

    always @(posedge clk) begin
        if (reset)
            state <= SEED;
        else if (enable)
            state <= {state[6:0], feedback};
    end
endmodule
