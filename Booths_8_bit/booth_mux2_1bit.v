`timescale 1ns/1ps
module booth_mux2_1bit(input d0,d1,sel,output y);
    wire ns,w0,w1;
    not(ns,sel);
    and(w0,d0,ns);
    and(w1,d1,sel);
    or(y,w0,w1);
endmodule
