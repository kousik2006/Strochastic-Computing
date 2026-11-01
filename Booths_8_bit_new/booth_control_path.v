// =============================================================
//  BOOTH CONTROL PATH  -  one-hot FSM (7 flip-flops)
//
//  state[0] IDLE   waiting for start
//  state[1] LOAD   load operands, clear A, Q-1, counter
//  state[2] CHECK  look at (Q0, Q-1)
//  state[3] ADD    Q0,Q-1 = 01  ->  A = A + M
//  state[4] SUB    Q0,Q-1 = 10  ->  A = A - M
//  state[5] SHIFT  arithmetic shift right {A,Q,Q-1}, counter++
//  state[6] DONE   product ready (stays until start is released)
//
//  Moore outputs: load, acc_en, sub, shift, done
// =============================================================
module booth_control_path (
    input        clk, rst,
    input        start,
    // status from the data path
    input        q0, qm1, last,
    // control to the data path
    output       load, acc_en, sub, shift,
    output       done,
    output [6:0] state          // one-hot state (for debug / waveforms)
);
    // ---- one-hot state bits ----
    wire s_idle, s_load, s_check, s_add, s_sub, s_shift, s_done;
    // ---- next-state bits ----
    wire n_idle, n_load, n_check, n_add, n_sub, n_shift, n_done;

    // ---- inverted inputs ----
    wire nstart, nq0, nqm1, nlast;
    not i1 (nstart, start);
    not i2 (nq0,    q0);
    not i3 (nqm1,   qm1);
    not i4 (nlast,  last);

    // ---- next-state logic (gates) ----
    // IDLE  <= (IDLE | DONE) & ~start
    wire t_idle;
    or  g_idle1 (t_idle, s_idle, s_done);
    and g_idle2 (n_idle, t_idle, nstart);

    // LOAD  <= IDLE & start
    and g_load  (n_load, s_idle, start);

    // CHECK <= LOAD | (SHIFT & ~last)
    wire t_chk;
    and g_chk1 (t_chk, s_shift, nlast);
    or  g_chk2 (n_check, s_load, t_chk);

    // ADD   <= CHECK & ~Q0 &  Q-1     (01)
    and g_add  (n_add, s_check, nq0, qm1);

    // SUB   <= CHECK &  Q0 & ~Q-1     (10)
    and g_sub  (n_sub, s_check, q0, nqm1);

    // SHIFT <= (CHECK & (Q0 == Q-1))  |  ADD  |  SUB     (00 or 11 skip the add)
    wire eq, t_sh;
    xnor g_eq  (eq, q0, qm1);
    and  g_sh1 (t_sh, s_check, eq);
    or   g_sh2 (n_shift, t_sh, s_add, s_sub);

    // DONE  <= (SHIFT & last) | (DONE & start)
    wire t_d1, t_d2;
    and g_d1 (t_d1, s_shift, last);
    and g_d2 (t_d2, s_done,  start);
    or  g_d3 (n_done, t_d1, t_d2);

    // ---- state register: IDLE resets to 1, all others to 0 (one-hot) ----
    dff #(.RESET_VAL(1'b1)) ff_idle  (.clk(clk), .rst(rst), .d(n_idle),  .q(s_idle));
    dff #(.RESET_VAL(1'b0)) ff_load  (.clk(clk), .rst(rst), .d(n_load),  .q(s_load));
    dff #(.RESET_VAL(1'b0)) ff_check (.clk(clk), .rst(rst), .d(n_check), .q(s_check));
    dff #(.RESET_VAL(1'b0)) ff_add   (.clk(clk), .rst(rst), .d(n_add),   .q(s_add));
    dff #(.RESET_VAL(1'b0)) ff_sub   (.clk(clk), .rst(rst), .d(n_sub),   .q(s_sub));
    dff #(.RESET_VAL(1'b0)) ff_shift (.clk(clk), .rst(rst), .d(n_shift), .q(s_shift));
    dff #(.RESET_VAL(1'b0)) ff_done  (.clk(clk), .rst(rst), .d(n_done),  .q(s_done));

    // ---- outputs ----
    buf o1 (load,  s_load);
    or  o2 (acc_en, s_add, s_sub);
    buf o3 (sub,   s_sub);
    buf o4 (shift, s_shift);
    buf o5 (done,  s_done);

    assign state = {s_done, s_shift, s_sub, s_add, s_check, s_load, s_idle};
endmodule
