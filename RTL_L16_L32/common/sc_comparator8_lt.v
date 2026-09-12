//==============================================================================
// sc_comparator8_lt.v
// Structural unsigned 8-bit magnitude comparator: y=1 when a<b.
//==============================================================================
`timescale 1ns/1ps
module sc_comparator8_lt (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire y
);
    wire e7,e6,e5,e4,e3,e2,e1,e0;
    wire l7,l6,l5,l4,l3,l2,l1,l0;

    assign e7 = ~(a[7] ^ b[7]); assign e6 = ~(a[6] ^ b[6]);
    assign e5 = ~(a[5] ^ b[5]); assign e4 = ~(a[4] ^ b[4]);
    assign e3 = ~(a[3] ^ b[3]); assign e2 = ~(a[2] ^ b[2]);
    assign e1 = ~(a[1] ^ b[1]); assign e0 = ~(a[0] ^ b[0]);

    assign l7 = (~a[7]) & b[7];
    assign l6 = e7 & (~a[6]) & b[6];
    assign l5 = e7 & e6 & (~a[5]) & b[5];
    assign l4 = e7 & e6 & e5 & (~a[4]) & b[4];
    assign l3 = e7 & e6 & e5 & e4 & (~a[3]) & b[3];
    assign l2 = e7 & e6 & e5 & e4 & e3 & (~a[2]) & b[2];
    assign l1 = e7 & e6 & e5 & e4 & e3 & e2 & (~a[1]) & b[1];
    assign l0 = e7 & e6 & e5 & e4 & e3 & e2 & e1 & (~a[0]) & b[0];
    assign y = l7 | l6 | l5 | l4 | l3 | l2 | l1 | l0;
endmodule
