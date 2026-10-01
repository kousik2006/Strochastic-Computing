module mux2_structural (
    input  wire d0,
    input  wire d1,
    input  wire sel,
    output wire y
);
    wire nsel;
    wire w0;
    wire w1;

    not (nsel, sel);
    and (w0, d0, nsel);
    and (w1, d1, sel);
    or  (y, w0, w1);
endmodule
