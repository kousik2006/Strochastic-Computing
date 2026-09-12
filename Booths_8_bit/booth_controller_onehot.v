`timescale 1ns/1ps
module booth_controller_onehot(
    input clk,
    input reset,
    input start,
    input [1:0] booth_pair,
    input last_count,
    output load_operands,
    output do_add,
    output do_sub,
    output do_shift,
    output busy,
    output done
);
    // One-hot states:
    // IDLE  = 00001
    // LOAD  = 00010
    // ADD   = 00100
    // SUB   = 01000
    // SHIFT = 10000
    reg [4:0] state;
    wire [4:0] next;

    localparam IDLE  = 5'b00001;
    localparam LOAD  = 5'b00010;
    localparam ADD_S = 5'b00100;
    localparam SUB_S = 5'b01000;
    localparam SHIFT = 5'b10000;

    wire p01,p10,p00_11;
    assign p01 = (~booth_pair[1]) & booth_pair[0];
    assign p10 = booth_pair[1] & (~booth_pair[0]);
    assign p00_11 = ~(p01 | p10);

    assign load_operands = state[1];
    assign do_add = state[2];
    assign do_sub = state[3];
    assign do_shift = state[4];
    assign busy = ~state[0];
    assign done = state[4] & last_count;

    assign next[0] = state[4] & last_count;
    assign next[1] = state[0] & start;
    assign next[2] = state[1] & p01;
    assign next[3] = state[1] & p10;
    assign next[4] = (state[1] & p00_11) |
                     state[2] | state[3] |
                     (state[4] & ~last_count);

    always @(posedge clk) begin
        if(reset) state <= IDLE;
        else      state <= next;
    end
endmodule
