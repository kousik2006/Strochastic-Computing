// =============================================================
//  Basic cells shared by the Booth multiplier
//  (flip-flop, half adder, full adder, 9-bit add/subtract unit)
// =============================================================

// ---------- D flip-flop with async reset (RESET_VAL = value after reset) ----------
module dff #(parameter RESET_VAL = 1'b0) (
    input      clk, rst, d,
    output reg q
);
    always @(posedge clk or posedge rst)
        if (rst) q <= RESET_VAL;
        else     q <= d;
endmodule

// ---------- Half adder (gate level) ----------
module half_adder (
    input  a, b,
    output sum, carry
);
    xor x1 (sum,   a, b);
    and a1 (carry, a, b);
endmodule

// ---------- Full adder (gate level: 2 half adders + OR) ----------
module full_adder (
    input  a, b, cin,
    output sum, cout
);
    wire s1, c1, c2;
    half_adder ha1 (.a(a),  .b(b),   .sum(s1),  .carry(c1));
    half_adder ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2));
    or  o1 (cout, c1, c2);
endmodule

// ---------- 9-bit ripple adder / subtractor ----------
//   sub = 0 : sum = a + b
//   sub = 1 : sum = a - b   (b is inverted and carry-in = 1)
module adder_sub_9bit (
    input  [8:0] a,
    input  [8:0] b,
    input        sub,
    output [8:0] sum
);
    wire [8:0] b_x;      // b XOR sub
    wire [9:0] c;        // carry chain

    buf bc (c[0], sub);  // +1 for two's complement subtraction

    genvar i;
    generate
        for (i = 0; i < 9; i = i + 1) begin : bit_slice
            xor xb (b_x[i], b[i], sub);
            full_adder fa (.a(a[i]), .b(b_x[i]), .cin(c[i]),
                           .sum(sum[i]), .cout(c[i+1]));
        end
    endgenerate
endmodule
