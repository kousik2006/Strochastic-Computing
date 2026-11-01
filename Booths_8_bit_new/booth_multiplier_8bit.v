// =============================================================
//  8x8 signed Booth multiplier (radix-2, sequential)
//  Top level = CONTROL PATH (one-hot FSM) + DATA PATH
//
//  Use:  put operands on multiplicand / multiplier, pulse start = 1.
//        When done = 1, product[15:0] (two's complement) is valid.
//        Release start to return to IDLE.
//  Latency: 1 (load) + 8 iterations x (2 or 3 cycles) + done
// =============================================================
module booth_multiplier_8bit (
    input         clk, rst,
    input         start,
    input  [7:0]  multiplicand,      // signed (two's complement)
    input  [7:0]  multiplier,        // signed (two's complement)
    output [15:0] product,           // signed
    output        done,
    output [6:0]  state              // one-hot state, for debug
);
    // control <-> data path wires
    wire load, acc_en, sub, shift;
    wire q0, qm1, last;

    booth_control_path CU (
        .clk(clk), .rst(rst), .start(start),
        .q0(q0), .qm1(qm1), .last(last),
        .load(load), .acc_en(acc_en), .sub(sub), .shift(shift),
        .done(done), .state(state)
    );

    booth_data_path DP (
        .clk(clk), .rst(rst),
        .load(load), .acc_en(acc_en), .sub(sub), .shift(shift),
        .multiplicand(multiplicand), .multiplier(multiplier),
        .q0(q0), .qm1(qm1), .last(last),
        .product(product)
    );
endmodule
