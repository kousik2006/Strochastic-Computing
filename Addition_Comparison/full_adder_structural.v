module full_adder_structural (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire axb;
    wire ab;
    wire cin_axb;

    xor (axb, a, b);
    xor (sum, axb, cin);
    and (ab, a, b);
    and (cin_axb, cin, axb);
    or  (cout, ab, cin_axb);
endmodule
