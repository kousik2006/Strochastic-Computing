`timescale 1ns/1ps
module booth_dff(
    input clk,
    input reset,
    input d,
    output reg q
);
    always @(posedge clk) begin
        if(reset) q <= 1'b0;
        else      q <= d;
    end
endmodule
