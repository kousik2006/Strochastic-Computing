`timescale 1ns/1ps

// Hardware-friendly 8-bit digital Sobol / low-discrepancy generator.
// The recurrence uses XOR with a direction vector selected by the
// least-significant set bit of the iteration counter.
// This is intended as a compact, deterministic RTL sequence source.
module sc_sobol8_parameterized (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [7:0] value
);
    reg [7:0] index;
    reg [7:0] x;
    reg [7:0] direction [0:7];

    integer i;

    always @(posedge clk) begin
        if (reset) begin
            index <= 0;
            x <= 0;
            value <= 0;
            direction[0] <= 8'h80;
            direction[1] <= 8'h40;
            direction[2] <= 8'h20;
            direction[3] <= 8'h10;
            direction[4] <= 8'h08;
            direction[5] <= 8'h04;
            direction[6] <= 8'h02;
            direction[7] <= 8'h01;
        end else if (enable) begin
            // Gray-code/Sobol update: xor direction vector associated
            // with the changed bit position of the counter.
            if (index[0] == 1'b0) x <= x ^ direction[0];
            else if (index[1] == 1'b0) x <= x ^ direction[1];
            else if (index[2] == 1'b0) x <= x ^ direction[2];
            else if (index[3] == 1'b0) x <= x ^ direction[3];
            else if (index[4] == 1'b0) x <= x ^ direction[4];
            else if (index[5] == 1'b0) x <= x ^ direction[5];
            else if (index[6] == 1'b0) x <= x ^ direction[6];
            else x <= x ^ direction[7];

            index <= index + 1'b1;
            value <= x;
        end
    end
endmodule
