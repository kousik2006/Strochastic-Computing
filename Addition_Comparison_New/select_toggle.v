module select_toggle (
    input  wire clk,
    input  wire reset,
    output reg  q
);

    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= ~q;
    end

endmodule
