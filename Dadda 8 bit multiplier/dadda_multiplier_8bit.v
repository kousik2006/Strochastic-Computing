// =============================================================
//  8x8 Dadda Multiplier  (fully structural)
//  Inputs : a[7:0], b[7:0]   (unsigned)
//  Output : product[15:0]
//  Height sequence 8 -> 6 -> 4 -> 3 -> 2 -> final adder
//  Uses 48 full adders and 8 half adders (reduction + final ripple adder)
// =============================================================

// ---------- Half adder (gate level) ----------
module half_adder (
    input  a, b,
    output sum, carry
);
    xor x1 (sum,   a, b);
    and a1 (carry, a, b);
endmodule

// ---------- Full adder (gate level, built from 2 half adders + OR) ----------
module full_adder (
    input  a, b, cin,
    output sum, cout
);
    wire s1, c1, c2;
    half_adder ha1 (.a(a),  .b(b),   .sum(s1),  .carry(c1));
    half_adder ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2));
    or  o1 (cout, c1, c2);
endmodule

// ---------- Top: 8-bit Dadda multiplier ----------
module dadda_multiplier_8bit (
    input  [7:0]  a,
    input  [7:0]  b,
    output [15:0] product
);
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
    wire s4_c12_0, c4_c12_0, s4_c13_0, c4_c13_0, fc1, fc2, fc3, fc4;
    wire fc5, fc6, fc7, fc8, fc9, fc10, fc11, fc12;
    wire fc13, fc14;

    // ---------------- Step 1: partial products (AND gates) ----------------
    and g_pp0_0 (pp0_0, a[0], b[0]);
    and g_pp0_1 (pp0_1, a[1], b[0]);
    and g_pp0_2 (pp0_2, a[2], b[0]);
    and g_pp0_3 (pp0_3, a[3], b[0]);
    and g_pp0_4 (pp0_4, a[4], b[0]);
    and g_pp0_5 (pp0_5, a[5], b[0]);
    and g_pp0_6 (pp0_6, a[6], b[0]);
    and g_pp0_7 (pp0_7, a[7], b[0]);
    and g_pp1_0 (pp1_0, a[0], b[1]);
    and g_pp1_1 (pp1_1, a[1], b[1]);
    and g_pp1_2 (pp1_2, a[2], b[1]);
    and g_pp1_3 (pp1_3, a[3], b[1]);
    and g_pp1_4 (pp1_4, a[4], b[1]);
    and g_pp1_5 (pp1_5, a[5], b[1]);
    and g_pp1_6 (pp1_6, a[6], b[1]);
    and g_pp1_7 (pp1_7, a[7], b[1]);
    and g_pp2_0 (pp2_0, a[0], b[2]);
    and g_pp2_1 (pp2_1, a[1], b[2]);
    and g_pp2_2 (pp2_2, a[2], b[2]);
    and g_pp2_3 (pp2_3, a[3], b[2]);
    and g_pp2_4 (pp2_4, a[4], b[2]);
    and g_pp2_5 (pp2_5, a[5], b[2]);
    and g_pp2_6 (pp2_6, a[6], b[2]);
    and g_pp2_7 (pp2_7, a[7], b[2]);
    and g_pp3_0 (pp3_0, a[0], b[3]);
    and g_pp3_1 (pp3_1, a[1], b[3]);
    and g_pp3_2 (pp3_2, a[2], b[3]);
    and g_pp3_3 (pp3_3, a[3], b[3]);
    and g_pp3_4 (pp3_4, a[4], b[3]);
    and g_pp3_5 (pp3_5, a[5], b[3]);
    and g_pp3_6 (pp3_6, a[6], b[3]);
    and g_pp3_7 (pp3_7, a[7], b[3]);
    and g_pp4_0 (pp4_0, a[0], b[4]);
    and g_pp4_1 (pp4_1, a[1], b[4]);
    and g_pp4_2 (pp4_2, a[2], b[4]);
    and g_pp4_3 (pp4_3, a[3], b[4]);
    and g_pp4_4 (pp4_4, a[4], b[4]);
    and g_pp4_5 (pp4_5, a[5], b[4]);
    and g_pp4_6 (pp4_6, a[6], b[4]);
    and g_pp4_7 (pp4_7, a[7], b[4]);
    and g_pp5_0 (pp5_0, a[0], b[5]);
    and g_pp5_1 (pp5_1, a[1], b[5]);
    and g_pp5_2 (pp5_2, a[2], b[5]);
    and g_pp5_3 (pp5_3, a[3], b[5]);
    and g_pp5_4 (pp5_4, a[4], b[5]);
    and g_pp5_5 (pp5_5, a[5], b[5]);
    and g_pp5_6 (pp5_6, a[6], b[5]);
    and g_pp5_7 (pp5_7, a[7], b[5]);
    and g_pp6_0 (pp6_0, a[0], b[6]);
    and g_pp6_1 (pp6_1, a[1], b[6]);
    and g_pp6_2 (pp6_2, a[2], b[6]);
    and g_pp6_3 (pp6_3, a[3], b[6]);
    and g_pp6_4 (pp6_4, a[4], b[6]);
    and g_pp6_5 (pp6_5, a[5], b[6]);
    and g_pp6_6 (pp6_6, a[6], b[6]);
    and g_pp6_7 (pp6_7, a[7], b[6]);
    and g_pp7_0 (pp7_0, a[0], b[7]);
    and g_pp7_1 (pp7_1, a[1], b[7]);
    and g_pp7_2 (pp7_2, a[2], b[7]);
    and g_pp7_3 (pp7_3, a[3], b[7]);
    and g_pp7_4 (pp7_4, a[4], b[7]);
    and g_pp7_5 (pp7_5, a[5], b[7]);
    and g_pp7_6 (pp7_6, a[6], b[7]);
    and g_pp7_7 (pp7_7, a[7], b[7]);

    // ---------------- Dadda stage 1: reduce max column height to 6 (heights before: [1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 0]) ----------------
    half_adder ha_s1_c6_0 (.a(pp0_6), .b(pp1_5), .sum(s1_c6_0), .carry(c1_c6_0));
    full_adder fa_s1_c7_0 (.a(pp0_7), .b(pp1_6), .cin(pp2_5), .sum(s1_c7_0), .cout(c1_c7_0));
    half_adder ha_s1_c7_1 (.a(pp3_4), .b(pp4_3), .sum(s1_c7_1), .carry(c1_c7_1));
    full_adder fa_s1_c8_0 (.a(pp1_7), .b(pp2_6), .cin(pp3_5), .sum(s1_c8_0), .cout(c1_c8_0));
    half_adder ha_s1_c8_1 (.a(pp4_4), .b(pp5_3), .sum(s1_c8_1), .carry(c1_c8_1));
    full_adder fa_s1_c9_0 (.a(pp2_7), .b(pp3_6), .cin(pp4_5), .sum(s1_c9_0), .cout(c1_c9_0));

    // ---------------- Dadda stage 2: reduce max column height to 4 (heights before: [1, 2, 3, 4, 5, 6, 6, 6, 6, 6, 6, 4, 3, 2, 1, 0]) ----------------
    half_adder ha_s2_c4_0 (.a(pp0_4), .b(pp1_3), .sum(s2_c4_0), .carry(c2_c4_0));
    full_adder fa_s2_c5_0 (.a(pp0_5), .b(pp1_4), .cin(pp2_3), .sum(s2_c5_0), .cout(c2_c5_0));
    half_adder ha_s2_c5_1 (.a(pp3_2), .b(pp4_1), .sum(s2_c5_1), .carry(c2_c5_1));
    full_adder fa_s2_c6_0 (.a(pp2_4), .b(pp3_3), .cin(pp4_2), .sum(s2_c6_0), .cout(c2_c6_0));
    full_adder fa_s2_c6_1 (.a(pp5_1), .b(pp6_0), .cin(s1_c6_0), .sum(s2_c6_1), .cout(c2_c6_1));
    full_adder fa_s2_c7_0 (.a(pp5_2), .b(pp6_1), .cin(pp7_0), .sum(s2_c7_0), .cout(c2_c7_0));
    full_adder fa_s2_c7_1 (.a(c1_c6_0), .b(s1_c7_0), .cin(s1_c7_1), .sum(s2_c7_1), .cout(c2_c7_1));
    full_adder fa_s2_c8_0 (.a(pp6_2), .b(pp7_1), .cin(c1_c7_0), .sum(s2_c8_0), .cout(c2_c8_0));
    full_adder fa_s2_c8_1 (.a(c1_c7_1), .b(s1_c8_0), .cin(s1_c8_1), .sum(s2_c8_1), .cout(c2_c8_1));
    full_adder fa_s2_c9_0 (.a(pp5_4), .b(pp6_3), .cin(pp7_2), .sum(s2_c9_0), .cout(c2_c9_0));
    full_adder fa_s2_c9_1 (.a(c1_c8_0), .b(c1_c8_1), .cin(s1_c9_0), .sum(s2_c9_1), .cout(c2_c9_1));
    full_adder fa_s2_c10_0 (.a(pp3_7), .b(pp4_6), .cin(pp5_5), .sum(s2_c10_0), .cout(c2_c10_0));
    full_adder fa_s2_c10_1 (.a(pp6_4), .b(pp7_3), .cin(c1_c9_0), .sum(s2_c10_1), .cout(c2_c10_1));
    full_adder fa_s2_c11_0 (.a(pp4_7), .b(pp5_6), .cin(pp6_5), .sum(s2_c11_0), .cout(c2_c11_0));

    // ---------------- Dadda stage 3: reduce max column height to 3 (heights before: [1, 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 1, 0]) ----------------
    half_adder ha_s3_c3_0 (.a(pp0_3), .b(pp1_2), .sum(s3_c3_0), .carry(c3_c3_0));
    full_adder fa_s3_c4_0 (.a(pp2_2), .b(pp3_1), .cin(pp4_0), .sum(s3_c4_0), .cout(c3_c4_0));
    full_adder fa_s3_c5_0 (.a(pp5_0), .b(c2_c4_0), .cin(s2_c5_0), .sum(s3_c5_0), .cout(c3_c5_0));
    full_adder fa_s3_c6_0 (.a(c2_c5_0), .b(c2_c5_1), .cin(s2_c6_0), .sum(s3_c6_0), .cout(c3_c6_0));
    full_adder fa_s3_c7_0 (.a(c2_c6_0), .b(c2_c6_1), .cin(s2_c7_0), .sum(s3_c7_0), .cout(c3_c7_0));
    full_adder fa_s3_c8_0 (.a(c2_c7_0), .b(c2_c7_1), .cin(s2_c8_0), .sum(s3_c8_0), .cout(c3_c8_0));
    full_adder fa_s3_c9_0 (.a(c2_c8_0), .b(c2_c8_1), .cin(s2_c9_0), .sum(s3_c9_0), .cout(c3_c9_0));
    full_adder fa_s3_c10_0 (.a(c2_c9_0), .b(c2_c9_1), .cin(s2_c10_0), .sum(s3_c10_0), .cout(c3_c10_0));
    full_adder fa_s3_c11_0 (.a(pp7_4), .b(c2_c10_0), .cin(c2_c10_1), .sum(s3_c11_0), .cout(c3_c11_0));
    full_adder fa_s3_c12_0 (.a(pp5_7), .b(pp6_6), .cin(pp7_5), .sum(s3_c12_0), .cout(c3_c12_0));

    // ---------------- Dadda stage 4: reduce max column height to 2 (heights before: [1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 0]) ----------------
    half_adder ha_s4_c2_0 (.a(pp0_2), .b(pp1_1), .sum(s4_c2_0), .carry(c4_c2_0));
    full_adder fa_s4_c3_0 (.a(pp2_1), .b(pp3_0), .cin(s3_c3_0), .sum(s4_c3_0), .cout(c4_c3_0));
    full_adder fa_s4_c4_0 (.a(s2_c4_0), .b(c3_c3_0), .cin(s3_c4_0), .sum(s4_c4_0), .cout(c4_c4_0));
    full_adder fa_s4_c5_0 (.a(s2_c5_1), .b(c3_c4_0), .cin(s3_c5_0), .sum(s4_c5_0), .cout(c4_c5_0));
    full_adder fa_s4_c6_0 (.a(s2_c6_1), .b(c3_c5_0), .cin(s3_c6_0), .sum(s4_c6_0), .cout(c4_c6_0));
    full_adder fa_s4_c7_0 (.a(s2_c7_1), .b(c3_c6_0), .cin(s3_c7_0), .sum(s4_c7_0), .cout(c4_c7_0));
    full_adder fa_s4_c8_0 (.a(s2_c8_1), .b(c3_c7_0), .cin(s3_c8_0), .sum(s4_c8_0), .cout(c4_c8_0));
    full_adder fa_s4_c9_0 (.a(s2_c9_1), .b(c3_c8_0), .cin(s3_c9_0), .sum(s4_c9_0), .cout(c4_c9_0));
    full_adder fa_s4_c10_0 (.a(s2_c10_1), .b(c3_c9_0), .cin(s3_c10_0), .sum(s4_c10_0), .cout(c4_c10_0));
    full_adder fa_s4_c11_0 (.a(s2_c11_0), .b(c3_c10_0), .cin(s3_c11_0), .sum(s4_c11_0), .cout(c4_c11_0));
    full_adder fa_s4_c12_0 (.a(c2_c11_0), .b(c3_c11_0), .cin(s3_c12_0), .sum(s4_c12_0), .cout(c4_c12_0));
    full_adder fa_s4_c13_0 (.a(pp6_7), .b(pp7_6), .cin(c3_c12_0), .sum(s4_c13_0), .cout(c4_c13_0));

    // ---------------- Final stage: ripple-carry adder on the two remaining rows ----------------
    assign product[0] = pp0_0;
    half_adder ha_final_1 (.a(pp0_1), .b(pp1_0), .sum(product[1]), .carry(fc1));
    full_adder fa_final_2 (.a(pp2_0), .b(s4_c2_0), .cin(fc1), .sum(product[2]), .cout(fc2));
    full_adder fa_final_3 (.a(c4_c2_0), .b(s4_c3_0), .cin(fc2), .sum(product[3]), .cout(fc3));
    full_adder fa_final_4 (.a(c4_c3_0), .b(s4_c4_0), .cin(fc3), .sum(product[4]), .cout(fc4));
    full_adder fa_final_5 (.a(c4_c4_0), .b(s4_c5_0), .cin(fc4), .sum(product[5]), .cout(fc5));
    full_adder fa_final_6 (.a(c4_c5_0), .b(s4_c6_0), .cin(fc5), .sum(product[6]), .cout(fc6));
    full_adder fa_final_7 (.a(c4_c6_0), .b(s4_c7_0), .cin(fc6), .sum(product[7]), .cout(fc7));
    full_adder fa_final_8 (.a(c4_c7_0), .b(s4_c8_0), .cin(fc7), .sum(product[8]), .cout(fc8));
    full_adder fa_final_9 (.a(c4_c8_0), .b(s4_c9_0), .cin(fc8), .sum(product[9]), .cout(fc9));
    full_adder fa_final_10 (.a(c4_c9_0), .b(s4_c10_0), .cin(fc9), .sum(product[10]), .cout(fc10));
    full_adder fa_final_11 (.a(c4_c10_0), .b(s4_c11_0), .cin(fc10), .sum(product[11]), .cout(fc11));
    full_adder fa_final_12 (.a(c4_c11_0), .b(s4_c12_0), .cin(fc11), .sum(product[12]), .cout(fc12));
    full_adder fa_final_13 (.a(c4_c12_0), .b(s4_c13_0), .cin(fc12), .sum(product[13]), .cout(fc13));
    full_adder fa_final_14 (.a(pp7_7), .b(c4_c13_0), .cin(fc13), .sum(product[14]), .cout(fc14));
    assign product[15] = fc14;
endmodule
