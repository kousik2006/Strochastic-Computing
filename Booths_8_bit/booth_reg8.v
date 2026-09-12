`timescale 1ns/1ps
module booth_reg8(
    input clk, reset, load,
    input [7:0] d,
    output [7:0] q
);
    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin: R
            wire nl,w0,w1,di;
            not(nl,load);
            and(w0,q[i],nl);
            and(w1,d[i],load);
            or(di,w0,w1);
            booth_dff ff(.clk(clk),.reset(reset),.d(di),.q(q[i]));
        end
    endgenerate
endmodule
