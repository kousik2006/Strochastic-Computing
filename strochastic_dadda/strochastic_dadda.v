// =============================================================
//  8x8 Stochastic Dadda Multiplier
//  - Partial Products & Dadda Stages 1-4 : Structural (Gate-level)
//  - Final CBAC Stochastic Adder         : Behavioral (Synthesizable)
//  - Scaling Formula                     : 2 * out_value * 2^(15 - m)
// =============================================================
`timescale 1ns / 1ps

// ---------- Half adder (gate level) ----------
module half_adder (
    input  a, b,
    output sum, carry
);
    xor x1 (sum,   a, b);
    and a1 (carry, a, b);
endmodule

// ---------- Full adder (gate level) ----------
module full_adder (
    input  a, b, cin,
    output sum, cout
);
    wire s1, c1, c2;
    half_adder ha1 (.a(a),  .b(b),   .sum(s1),  .carry(c1));
    half_adder ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2));
    or  o1 (cout, c1, c2);
endmodule

// ---------- Top: 8-bit Stochastic Dadda Multiplier ----------
module stochastic_dadda_multiplier_8bit #(
    parameter m = 8              // Counter width (Stream length L = 2^m)
)(
    input             clk,
    input             rst,       // High to reset/load new inputs, Low to run
    input      [7:0]  a,
    input      [7:0]  b,
    output reg [15:0] product,
    output reg        done
);
    // Wires for 64 partial products and 4 Dadda reduction stages
    wire pp0_0, pp0_1, pp0_2, pp0_3, pp0_4, pp0_5, pp0_6, pp0_7;
    wire pp1_0, pp1_1, pp1_2, pp1_3, pp1_4, pp1_5, pp1_6, pp1_7;
    wire pp2_0, pp2_1, pp2_2, pp2_3, pp2_4, pp2_5, pp2_6, pp2_7;
    wire pp3_0, pp3_1, pp3_2, pp3_3, pp3_4, pp3_5, pp3_6, pp3_7;
    wire pp4_0, pp4_1, pp4_2, pp4_3, pp4_4, pp4_5, pp4_6, pp4_7;
    wire pp5_0, pp5_1, pp5_2, pp5_3, pp5_4, pp5_5, pp5_6, pp5_7;
    wire pp6_0, pp6_1, pp6_2, pp6_3, pp6_4, pp6_5, pp6_6, pp6_7;
    wire pp7_0, pp7_1, pp7_2, pp7_3, pp7_4, pp7_5, pp7_6, pp7_7;

    wire s1_c6_0, c1_c6_0, s1_c7_0, c1_c7_0, s1_c7_1, c1_c7_1, s1_c8_0, c1_c8_0;
    wire s1_c8_1, c1_c8_1, s1_c9_0, c1_c9_0, s2_c4_0, c2_c4_0, s2_c5_0, c2_c5_0;
    wire s2_c5_1, c2_c5_1, s2_c6_0, c2_c6_0, s2_c6_1, c2_c6_1, s2_c7_0, c2_c7_0;
    wire s2_c7_1, c2_c7_1, s2_c8_0, c2_c8_0, s2_c8_1, c2_c8_1, s2_c9_0, c2_c9_0;
    wire s2_c9_1, c2_c9_1, s2_c10_0, c2_c10_0, s2_c10_1, c2_c10_1, s2_c11_0, c2_c11_0;
    wire s3_c3_0, c3_c3_0, s3_c4_0, c3_c4_0, s3_c5_0, c3_c5_0, s3_c6_0, c3_c6_0;
    wire s3_c7_0, c3_c7_0, s3_c8_0, c3_c8_0, s3_c9_0, c3_c9_0, s3_c10_0, c3_c10_0;
    wire s3_c11_0, c3_c11_0, s3_c12_0, c3_c12_0, s4_c2_0, c4_c2_0, s4_c3_0, c4_c3_0;
    wire s4_c4_0, c4_c4_0, s4_c5_0, c4_c5_0, s4_c6_0, c4_c6_0, s4_c7_0, c4_c7_0;
    wire s4_c8_0, c4_c8_0, s4_c9_0, c4_c9_0, s4_c10_0, c4_c10_0, s4_c11_0, c4_c11_0;
    wire s4_c12_0, c4_c12_0, s4_c13_0, c4_c13_0;

    // ---------------- Step 1: Partial products (AND gates) ----------------
    and g_pp0_0 (pp0_0, a[0], b[0]); and g_pp0_1 (pp0_1, a[1], b[0]);
    and g_pp0_2 (pp0_2, a[2], b[0]); and g_pp0_3 (pp0_3, a[3], b[0]);
    and g_pp0_4 (pp0_4, a[4], b[0]); and g_pp0_5 (pp0_5, a[5], b[0]);
    and g_pp0_6 (pp0_6, a[6], b[0]); and g_pp0_7 (pp0_7, a[7], b[0]);
    and g_pp1_0 (pp1_0, a[0], b[1]); and g_pp1_1 (pp1_1, a[1], b[1]);
    and g_pp1_2 (pp1_2, a[2], b[1]); and g_pp1_3 (pp1_3, a[3], b[1]);
    and g_pp1_4 (pp1_4, a[4], b[1]); and g_pp1_5 (pp1_5, a[5], b[1]);
    and g_pp1_6 (pp1_6, a[6], b[1]); and g_pp1_7 (pp1_7, a[7], b[1]);
    and g_pp2_0 (pp2_0, a[0], b[2]); and g_pp2_1 (pp2_1, a[1], b[2]);
    and g_pp2_2 (pp2_2, a[2], b[2]); and g_pp2_3 (pp2_3, a[3], b[2]);
    and g_pp2_4 (pp2_4, a[4], b[2]); and g_pp2_5 (pp2_5, a[5], b[2]);
    and g_pp2_6 (pp2_6, a[6], b[2]); and g_pp2_7 (pp2_7, a[7], b[2]);
    and g_pp3_0 (pp3_0, a[0], b[3]); and g_pp3_1 (pp3_1, a[1], b[3]);
    and g_pp3_2 (pp3_2, a[2], b[3]); and g_pp3_3 (pp3_3, a[3], b[3]);
    and g_pp3_4 (pp3_4, a[4], b[3]); and g_pp3_5 (pp3_5, a[5], b[3]);
    and g_pp3_6 (pp3_6, a[6], b[3]); and g_pp3_7 (pp3_7, a[7], b[3]);
    and g_pp4_0 (pp4_0, a[0], b[4]); and g_pp4_1 (pp4_1, a[1], b[4]);
    and g_pp4_2 (pp4_2, a[2], b[4]); and g_pp4_3 (pp4_3, a[3], b[4]);
    and g_pp4_4 (pp4_4, a[4], b[4]); and g_pp4_5 (pp4_5, a[5], b[4]);
    and g_pp4_6 (pp4_6, a[6], b[4]); and g_pp4_7 (pp4_7, a[7], b[4]);
    and g_pp5_0 (pp5_0, a[0], b[5]); and g_pp5_1 (pp5_1, a[1], b[5]);
    and g_pp5_2 (pp5_2, a[2], b[5]); and g_pp5_3 (pp5_3, a[3], b[5]);
    and g_pp5_4 (pp5_4, a[4], b[5]); and g_pp5_5 (pp5_5, a[5], b[5]);
    and g_pp5_6 (pp5_6, a[6], b[5]); and g_pp5_7 (pp5_7, a[7], b[5]);
    and g_pp6_0 (pp6_0, a[0], b[6]); and g_pp6_1 (pp6_1, a[1], b[6]);
    and g_pp6_2 (pp6_2, a[2], b[6]); and g_pp6_3 (pp6_3, a[3], b[6]);
    and g_pp6_4 (pp6_4, a[4], b[6]); and g_pp6_5 (pp6_5, a[5], b[6]);
    and g_pp6_6 (pp6_6, a[6], b[6]); and g_pp6_7 (pp6_7, a[7], b[6]);
    and g_pp7_0 (pp7_0, a[0], b[7]); and g_pp7_1 (pp7_1, a[1], b[7]);
    and g_pp7_2 (pp7_2, a[2], b[7]); and g_pp7_3 (pp7_3, a[3], b[7]);
    and g_pp7_4 (pp7_4, a[4], b[7]); and g_pp7_5 (pp7_5, a[5], b[7]);
    and g_pp7_6 (pp7_6, a[6], b[7]); and g_pp7_7 (pp7_7, a[7], b[7]);

    // ---------------- Dadda Stage 1 (max height -> 6) ----------------
    half_adder ha_s1_c6_0 (.a(pp0_6), .b(pp1_5), .sum(s1_c6_0), .carry(c1_c6_0));
    full_adder fa_s1_c7_0 (.a(pp0_7), .b(pp1_6), .cin(pp2_5), .sum(s1_c7_0), .cout(c1_c7_0));
    half_adder ha_s1_c7_1 (.a(pp3_4), .b(pp4_3), .sum(s1_c7_1), .carry(c1_c7_1));
    full_adder fa_s1_c8_0 (.a(pp1_7), .b(pp2_6), .cin(pp3_5), .sum(s1_c8_0), .cout(c1_c8_0));
    half_adder ha_s1_c8_1 (.a(pp4_4), .b(pp5_3), .sum(s1_c8_1), .carry(c1_c8_1));
    full_adder fa_s1_c9_0 (.a(pp2_7), .b(pp3_6), .cin(pp4_5), .sum(s1_c9_0), .cout(c1_c9_0));

    // ---------------- Dadda Stage 2 (max height -> 4) ----------------
    half_adder ha_s2_c4_0  (.a(pp0_4), .b(pp1_3), .sum(s2_c4_0), .carry(c2_c4_0));
    full_adder fa_s2_c5_0  (.a(pp0_5), .b(pp1_4), .cin(pp2_3), .sum(s2_c5_0), .cout(c2_c5_0));
    half_adder ha_s2_c5_1  (.a(pp3_2), .b(pp4_1), .sum(s2_c5_1), .carry(c2_c5_1));
    full_adder fa_s2_c6_0  (.a(pp2_4), .b(pp3_3), .cin(pp4_2), .sum(s2_c6_0), .cout(c2_c6_0));
    full_adder fa_s2_c6_1  (.a(pp5_1), .b(pp6_0), .cin(s1_c6_0), .sum(s2_c6_1), .cout(c2_c6_1));
    full_adder fa_s2_c7_0  (.a(pp5_2), .b(pp6_1), .cin(pp7_0), .sum(s2_c7_0), .cout(c2_c7_0));
    full_adder fa_s2_c7_1  (.a(c1_c6_0), .b(s1_c7_0), .cin(s1_c7_1), .sum(s2_c7_1), .cout(c2_c7_1));
    full_adder fa_s2_c8_0  (.a(pp6_2), .b(pp7_1), .cin(c1_c7_0), .sum(s2_c8_0), .cout(c2_c8_0));
    full_adder fa_s2_c8_1  (.a(c1_c7_1), .b(s1_c8_0), .cin(s1_c8_1), .sum(s2_c8_1), .cout(c2_c8_1));
    full_adder fa_s2_c9_0  (.a(pp5_4), .b(pp6_3), .cin(pp7_2), .sum(s2_c9_0), .cout(c2_c9_0));
    full_adder fa_s2_c9_1  (.a(c1_c8_0), .b(c1_c8_1), .cin(s1_c9_0), .sum(s2_c9_1), .cout(c2_c9_1));
    full_adder fa_s2_c10_0 (.a(pp3_7), .b(pp4_6), .cin(pp5_5), .sum(s2_c10_0), .cout(c2_c10_0));
    full_adder fa_s2_c10_1 (.a(pp6_4), .b(pp7_3), .cin(c1_c9_0), .sum(s2_c10_1), .cout(c2_c10_1));
    full_adder fa_s2_c11_0 (.a(pp4_7), .b(pp5_6), .cin(pp6_5), .sum(s2_c11_0), .cout(c2_c11_0));

    // ---------------- Dadda Stage 3 (max height -> 3) ----------------
    half_adder ha_s3_c3_0  (.a(pp0_3), .b(pp1_2), .sum(s3_c3_0), .carry(c3_c3_0));
    full_adder fa_s3_c4_0  (.a(pp2_2), .b(pp3_1), .cin(pp4_0), .sum(s3_c4_0), .cout(c3_c4_0));
    full_adder fa_s3_c5_0  (.a(pp5_0), .b(c2_c4_0), .cin(s2_c5_0), .sum(s3_c5_0), .cout(c3_c5_0));
    full_adder fa_s3_c6_0  (.a(c2_c5_0), .b(c2_c5_1), .cin(s2_c6_0), .sum(s3_c6_0), .cout(c3_c6_0));
    full_adder fa_s3_c7_0  (.a(c2_c6_0), .b(c2_c6_1), .cin(s2_c7_0), .sum(s3_c7_0), .cout(c3_c7_0));
    full_adder fa_s3_c8_0  (.a(c2_c7_0), .b(c2_c7_1), .cin(s2_c8_0), .sum(s3_c8_0), .cout(c3_c8_0));
    full_adder fa_s3_c9_0  (.a(c2_c8_0), .b(c2_c8_1), .cin(s2_c9_0), .sum(s3_c9_0), .cout(c3_c9_0));
    full_adder fa_s3_c10_0 (.a(c2_c9_0), .b(c2_c9_1), .cin(s2_c10_0), .sum(s3_c10_0), .cout(c3_c10_0));
    full_adder fa_s3_c11_0 (.a(pp7_4), .b(c2_c10_0), .cin(c2_c10_1), .sum(s3_c11_0), .cout(c3_c11_0));
    full_adder fa_s3_c12_0 (.a(pp5_7), .b(pp6_6), .cin(pp7_5), .sum(s3_c12_0), .cout(c3_c12_0));

    // ---------------- Dadda Stage 4 (max height -> 2) ----------------
    half_adder ha_s4_c2_0  (.a(pp0_2), .b(pp1_1), .sum(s4_c2_0), .carry(c4_c2_0));
    full_adder fa_s4_c3_0  (.a(pp2_1), .b(pp3_0), .cin(s3_c3_0), .sum(s4_c3_0), .cout(c4_c3_0));
    full_adder fa_s4_c4_0  (.a(s2_c4_0), .b(c3_c3_0), .cin(s3_c4_0), .sum(s4_c4_0), .cout(c4_c4_0));
    full_adder fa_s4_c5_0  (.a(s2_c5_1), .b(c3_c4_0), .cin(s3_c5_0), .sum(s4_c5_0), .cout(c4_c5_0));
    full_adder fa_s4_c6_0  (.a(s2_c6_1), .b(c3_c5_0), .cin(s3_c6_0), .sum(s4_c6_0), .cout(c4_c6_0));
    full_adder fa_s4_c7_0  (.a(s2_c7_1), .b(c3_c6_0), .cin(s3_c7_0), .sum(s4_c7_0), .cout(c4_c7_0));
    full_adder fa_s4_c8_0  (.a(s2_c8_1), .b(c3_c7_0), .cin(s3_c8_0), .sum(s4_c8_0), .cout(c4_c8_0));
    full_adder fa_s4_c9_0  (.a(s2_c9_1), .b(c3_c8_0), .cin(s3_c9_0), .sum(s4_c9_0), .cout(c4_c9_0));
    full_adder fa_s4_c10_0 (.a(s2_c10_1), .b(c3_c9_0), .cin(s3_c10_0), .sum(s4_c10_0), .cout(c4_c10_0));
    full_adder fa_s4_c11_0 (.a(s2_c11_0), .b(c3_c10_0), .cin(s3_c11_0), .sum(s4_c11_0), .cout(c4_c11_0));
    full_adder fa_s4_c12_0 (.a(c2_c11_0), .b(c3_c11_0), .cin(s3_c12_0), .sum(s4_c12_0), .cout(c4_c12_0));
    full_adder fa_s4_c13_0 (.a(pp6_7), .b(pp7_6), .cin(c3_c12_0), .sum(s4_c13_0), .cout(c4_c13_0));

    // =============================================================
    //  Final Stage: Synthesizable CBAC Stochastic Adder (Behavioral)
    // =============================================================

    // 1. Group the two remaining 15-bit Dadda rows (columns 14 down to 0)
    wire [14:0] row_a = {
        pp7_7,    c4_c12_0, c4_c11_0, c4_c10_0, c4_c9_0,
        c4_c8_0,  c4_c7_0,  c4_c6_0,  c4_c5_0,  c4_c4_0,
        c4_c3_0,  c4_c2_0,  pp2_0,    pp0_1,    pp0_0
    };

    wire [14:0] row_b = {
        c4_c13_0, s4_c13_0, s4_c12_0, s4_c11_0, s4_c10_0,
        s4_c9_0,  s4_c8_0,  s4_c7_0,  s4_c6_0,  s4_c5_0,
        s4_c4_0,  s4_c3_0,  s4_c2_0,  pp1_0,    1'b0
    };

    // 2. Keep top m bits of each 15-bit row (drops 15 - m LSBs)
    wire [m-1:0] q_a = row_a[14 : 15-m];
    wire [m-1:0] q_b = row_b[14 : 15-m];

    // 3. Shared m-bit counter & output 1s accumulator
    reg [m-1:0] counter;
    reg [m-1:0] out_value;

    // 4. SNG comparators, D1 / D1_bar select, AND-AND-OR, and DD-MAX early stop
    wire x1      = (counter < q_a);
    wire x2      = (counter < q_b);
    wire d1      = counter[0];
    wire d1_bar  = ~counter[0];
    wire out_bit = (x1 & d1) | (x2 & d1_bar);
    wire x_max   = x1 | x2;   // 1 while counter < max(q_a, q_b)

    // 5. Count 1s until x_max == 0, then shift: 2 * out_value * 2^(15 - m)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter   <= 0;
            out_value <= 0;
            product   <= 0;
            done      <= 0;
        end else if (!done) begin
            if (x_max) begin
                out_value <= out_value + out_bit;
                counter   <= counter + 1'b1;
            end else begin
                product   <= (out_value << 1) << (15 - m);
                done      <= 1'b1;
            end
        end
    end

endmodule