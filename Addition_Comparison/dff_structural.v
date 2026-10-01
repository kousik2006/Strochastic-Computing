module dff_structural #(
    parameter INIT = 1'b1
)(
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        if (reset)
            q <= INIT;
        else
            q <= d;
    end
endmodule
