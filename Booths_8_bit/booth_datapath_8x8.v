`timescale 1ns/1ps
module booth_datapath_8x8(
    input clk,
    input reset,
    input load_operands,
    input do_add,
    input do_sub,
    input do_shift,
    input [7:0] multiplicand,
    input [7:0] multiplier,
    output [1:0] booth_pair,
    output [15:0] product
);
    wire [15:0] M_ext;
    wire [15:0] A;
    wire [7:0] Q;
    wire Qm1;

    wire [15:0] add_y, sub_y;
    wire [15:0] selected_A;
    wire [15:0] A_shift;
    wire [7:0] Q_shift;
    wire Qm1_shift;

    // Zero extension is sufficient for unsigned 8x8.
    assign M_ext = {8'b0,multiplicand};

    booth_adder16 ADD(
        .a(A), .b(M_ext), .subtract(1'b0),
        .sum(add_y), .cout()
    );

    booth_adder16 SUB(
        .a(A), .b(M_ext), .subtract(1'b1),
        .sum(sub_y), .cout()
    );

    // Structural operation selection: ADD, SUB, or HOLD.
    genvar i;
    generate
        for(i=0;i<16;i=i+1) begin: SEL
            wire nops,add_w,sub_w,hold_w;
            wire add_or_sub;
            or(add_or_sub,do_add,do_sub);
            not(nops,add_or_sub);
            and(add_w,add_y[i],do_add);
            and(sub_w,sub_y[i],do_sub);
            and(hold_w,A[i],nops);
            or(selected_A[i],add_w,sub_w,hold_w);
        end
    endgenerate

    // Arithmetic right shift of combined {A,Q,Qm1}.
    assign A_shift = {selected_A[15],selected_A[15:1]};
    assign Q_shift = {selected_A[0],Q[7:1]};
    assign Qm1_shift = Q[0];

    booth_reg16 AREG(
        .clk(clk),.reset(reset),
        .load(load_operands | do_shift),
        .d(load_operands ? 16'b0 : A_shift),
        .q(A)
    );

    booth_reg8 QREG(
        .clk(clk),.reset(reset),
        .load(load_operands | do_shift),
        .d(load_operands ? multiplier : Q_shift),
        .q(Q)
    );

    booth_reg1 QM1REG(
        .clk(clk),.reset(reset),
        .load(load_operands | do_shift),
        .d(load_operands ? 1'b0 : Qm1_shift),
        .q(Qm1)
    );

    assign booth_pair = {Q[0],Qm1};

    // Final 16-bit unsigned product.
    assign product = {A[7:0],Q};
endmodule
