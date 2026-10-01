`timescale 1ns/1ps

module binary_adder_parameterized #(
    parameter integer N = 8
)(
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    input  wire         Cin,
    output wire [N:0]   Sum
);
    assign Sum = A + B + Cin;
endmodule
