`timescale 1ns/1ps
module booth_reg1(
    input clk, reset, load,
    input d,
    output q
);
    wire nl,w0,w1,di;
    not(nl,load);
    and(w0,q,nl);
    and(w1,d,load);
    or(di,w0,w1);
    booth_dff ff(.clk(clk),.reset(reset),.d(di),.q(q));
endmodule
