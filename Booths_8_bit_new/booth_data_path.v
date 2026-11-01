// =============================================================
//  BOOTH DATA PATH  (radix-2 Booth, signed 8 x 8 -> 16)
//
//  Registers : M  (8-bit multiplicand)
//              A  (9-bit accumulator, 1 extra sign bit avoids overflow
//                  when M = -128 or A +/- M exceeds 8 bits)
//              Q  (8-bit multiplier, receives product low byte)
//              Q-1 (1-bit)
//              cnt (3-bit shift counter, 8 iterations)
//  Units     : 9-bit adder/subtractor, arithmetic right shifter,
//              counter (half-adder incrementer)
//  Control inputs : load, acc_en, sub, shift      (from control path)
//  Status outputs : q0, qm1, last                 (to control path)
// =============================================================
module booth_data_path (
    input         clk, rst,
    // control signals
    input         load, acc_en, sub, shift,
    // operands
    input  [7:0]  multiplicand,
    input  [7:0]  multiplier,
    // status
    output        q0, qm1, last,
    // result
    output [15:0] product
);
    wire [7:0] M, Q;
    wire [8:0] A, sum;
    wire       Qm1;
    wire [2:0] cnt;

    wire nload, hold_a, hold_q;
    not  n1 (nload, load);
    nor  n2 (hold_a, load, acc_en, shift);   // A keeps its value
    nor  n3 (hold_q, load, shift);           // Q, Q-1 keep their value

    // ------------------------------------------------------------
    // M register : load multiplicand, otherwise hold
    // ------------------------------------------------------------
    wire [7:0] m_d, m_t1, m_t2;
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : m_reg
            and a1 (m_t1[i], load,  multiplicand[i]);
            and a2 (m_t2[i], nload, M[i]);
            or  o1 (m_d[i],  m_t1[i], m_t2[i]);
            dff ff (.clk(clk), .rst(rst), .d(m_d[i]), .q(M[i]));
        end
    endgenerate

    // ------------------------------------------------------------
    // Adder / subtractor : A +/- M   (both sign-extended to 9 bits)
    // ------------------------------------------------------------
    wire [8:0] M_ext;
    assign M_ext = {M[7], M};
    adder_sub_9bit addsub (.a(A), .b(M_ext), .sub(sub), .sum(sum));

    // ------------------------------------------------------------
    // A register : clear(load) / A+-M (acc_en) / arithmetic shift / hold
    // ------------------------------------------------------------
    wire [8:0] a_shr, a_d, a_t1, a_t2, a_t3;
    assign a_shr = {A[8], A[8:1]};           // arithmetic shift right

    generate
        for (i = 0; i < 9; i = i + 1) begin : a_reg
            and a1 (a_t1[i], acc_en, sum[i]);
            and a2 (a_t2[i], shift,  a_shr[i]);
            and a3 (a_t3[i], hold_a, A[i]);
            or  o1 (a_d[i],  a_t1[i], a_t2[i], a_t3[i]);
            dff ff (.clk(clk), .rst(rst), .d(a_d[i]), .q(A[i]));
        end
    endgenerate

    // ------------------------------------------------------------
    // Q register : load multiplier / shift (A[0] enters at the top) / hold
    // ------------------------------------------------------------
    wire [7:0] q_shr, q_d, q_t1, q_t2, q_t3;
    assign q_shr = {A[0], Q[7:1]};

    generate
        for (i = 0; i < 8; i = i + 1) begin : q_reg
            and a1 (q_t1[i], load,   multiplier[i]);
            and a2 (q_t2[i], shift,  q_shr[i]);
            and a3 (q_t3[i], hold_q, Q[i]);
            or  o1 (q_d[i],  q_t1[i], q_t2[i], q_t3[i]);
            dff ff (.clk(clk), .rst(rst), .d(q_d[i]), .q(Q[i]));
        end
    endgenerate

    // ------------------------------------------------------------
    // Q-1 flip-flop : cleared on load, takes Q[0] on shift
    // ------------------------------------------------------------
    wire qm1_t1, qm1_t2, qm1_d;
    and a_qm1_1 (qm1_t1, shift,  Q[0]);
    and a_qm1_2 (qm1_t2, hold_q, Qm1);
    or  o_qm1   (qm1_d,  qm1_t1, qm1_t2);
    dff ff_qm1  (.clk(clk), .rst(rst), .d(qm1_d), .q(Qm1));

    // ------------------------------------------------------------
    // 3-bit counter : counts shifts, cleared on load
    //   cnt + shift  built from a chain of half adders
    // ------------------------------------------------------------
    wire [2:0] cnt_inc, cnt_d;
    wire       cy0, cy1, cy2;
    half_adder cha0 (.a(cnt[0]), .b(shift), .sum(cnt_inc[0]), .carry(cy0));
    half_adder cha1 (.a(cnt[1]), .b(cy0),   .sum(cnt_inc[1]), .carry(cy1));
    half_adder cha2 (.a(cnt[2]), .b(cy1),   .sum(cnt_inc[2]), .carry(cy2));

    generate
        for (i = 0; i < 3; i = i + 1) begin : cnt_reg
            and a1 (cnt_d[i], cnt_inc[i], nload);       // clear on load
            dff ff (.clk(clk), .rst(rst), .d(cnt_d[i]), .q(cnt[i]));
        end
    endgenerate

    and a_last (last, cnt[0], cnt[1], cnt[2]);          // 8th (final) shift

    // ------------------------------------------------------------
    // Status and result
    // ------------------------------------------------------------
    buf b_q0  (q0,  Q[0]);
    buf b_qm1 (qm1, Qm1);
    assign product = {A[7:0], Q};
endmodule
