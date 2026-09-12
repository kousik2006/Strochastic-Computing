//==============================================================================
// sc_dff.v
// Single-bit D flip-flop used as the structural storage primitive.
// Active-high synchronous reset.
//==============================================================================
`timescale 1ns/1ps

module sc_dff (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule
