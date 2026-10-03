module stochastic_counter #(
    parameter integer L  = 32,
    parameter integer CW = $clog2(L + 1)
)(
    input  wire          clk,
    input  wire          reset,
    input  wire          stochastic_bit,
    output reg  [CW-1:0] count
);

    always @(posedge clk) begin
        if (reset)
            count <= {CW{1'b0}};
        else if (stochastic_bit)
            count <= count + 1'b1;
    end

endmodule
