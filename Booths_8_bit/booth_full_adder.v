`timescale 1ns/1ps
module booth_full_adder(input a,b,cin, output sum,cout);
    wire x1,c1,c2;
    xor(x1,a,b);
    xor(sum,x1,cin);
    and(c1,a,b);
    and(c2,x1,cin);
    or(cout,c1,c2);
endmodule
