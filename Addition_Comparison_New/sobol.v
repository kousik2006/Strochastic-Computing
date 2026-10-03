module sobol #(
    parameter integer N = 8
)(
    input  wire         clk,
    input  wire         reset,
    output reg  [N-1:0] value
);

    reg [N-1:0] index;
    reg [N-1:0] gray;
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            index <= 'd1;
            value <= 'd1;
        end
        else begin
            gray = index ^ (index >> 1);

            for (i = 0; i < N; i = i + 1)
                value[i] <= gray[N-1-i];

            index <= index + 1'b1;
        end
    end

endmodule
