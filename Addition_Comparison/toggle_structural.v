module toggle_structural (
    input  wire clk,
    input  wire reset,
    output wire q
);
    wire d;

    not (d, q);

    dff_structural #(.INIT(1'b0)) FF (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );
endmodule
