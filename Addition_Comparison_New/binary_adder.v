module binary_adder #(
    parameter integer N = 8
)(
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    output wire [N:0]   Sum
);

    assign Sum = {1'b0, A} + {1'b0, B};

endmodule
