`timescale 1ns/1ps
module booth_adder16(
    input [15:0] a,
    input [15:0] b,
    input subtract,
    output [15:0] sum,
    output cout
);
    wire [15:0] bx;
    wire [16:0] c;
    assign c[0]=subtract;
    genvar i;
    generate
        for(i=0;i<16;i=i+1) begin: FA
            xor(bx[i],b[i],subtract);
            booth_full_adder u(.a(a[i]),.b(bx[i]),.cin(c[i]),
                               .sum(sum[i]),.cout(c[i+1]));
        end
    endgenerate
    assign cout=c[16];
endmodule
