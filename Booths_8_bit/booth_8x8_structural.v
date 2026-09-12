`timescale 1ns/1ps
module booth_8x8_structural(
    input clk,
    input reset,
    input start,
    input [7:0] multiplicand,
    input [7:0] multiplier,
    output [15:0] product,
    output busy,
    output done
);
    wire [1:0] booth_pair;
    wire [7:0] count_onehot;
    wire last_count;

    wire load_operands, do_add, do_sub, do_shift;
    wire ctrl_busy, ctrl_done;

    // Accept a new operation only while idle.
    wire start_accept;
    assign start_accept = start & ~ctrl_busy;

    booth_datapath_8x8 DP(
        .clk(clk),
        .reset(reset),
        .load_operands(load_operands),
        .do_add(do_add),
        .do_sub(do_sub),
        .do_shift(do_shift),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .booth_pair(booth_pair),
        .product(product)
    );

    booth_counter_onehot8 COUNT(
        .clk(clk),
        .reset(reset),
        .enable(ctrl_busy),
        .count_onehot(count_onehot),
        .last(last_count)
    );

    booth_controller_onehot CTRL(
        .clk(clk),
        .reset(reset),
        .start(start_accept),
        .booth_pair(booth_pair),
        .last_count(last_count),
        .load_operands(load_operands),
        .do_add(do_add),
        .do_sub(do_sub),
        .do_shift(do_shift),
        .busy(ctrl_busy),
        .done(ctrl_done)
    );

    assign busy = ctrl_busy;
    assign done = ctrl_done;
endmodule
