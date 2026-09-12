`timescale 1ns/1ps

// Standalone L=16 verification bench. Do NOT use this as a synthesis source.
module tb_sc_multiplier_16;
    reg clk, reset, start;
    reg [7:0] A, B;
    wire busy, done;
    wire [15:0] product;
    wire stochastic_A, stochastic_B, stochastic_product;
    wire [7:0] lfsr_A_state, lfsr_B_state;
    wire [5:0] ones_A, ones_B, ones_product;

    integer expected, err;
    real probability, decoded;

    sc_multiplier_16 dut (
        .clk(clk), .reset(reset), .start(start), .A(A), .B(B),
        .busy(busy), .done(done), .product(product),
        .stochastic_A(stochastic_A), .stochastic_B(stochastic_B),
        .stochastic_product(stochastic_product),
        .lfsr_A_state(lfsr_A_state), .lfsr_B_state(lfsr_B_state),
        .ones_A(ones_A), .ones_B(ones_B), .ones_product(ones_product)
    );

    always #5 clk = ~clk;

    task run_case;
        input [7:0] a_in, b_in;
        begin
            @(negedge clk); A=a_in; B=b_in; start=1'b1;
            @(negedge clk); start=1'b0;
            wait(done == 1'b1); #1;
            expected = a_in*b_in;
            err = (product >= expected) ? product-expected : expected-product;
            probability = ones_product/16.0;
            decoded = probability*65025.0;
            $display("L=16 | A=%3d B=%3d | ones A/B/P=%2d/%2d/%2d | SC=%5d exact=%5d err=%5d | pP=%0.4f",
                     a_in,b_in,ones_A,ones_B,ones_product,product,expected,err,probability);
            @(negedge clk);
        end
    endtask

    initial begin
        clk=0; reset=1; start=0; A=0; B=0;
        repeat(2) @(posedge clk); reset=0;
        $display("============================================================");
        $display("L=16 STOCHASTIC MULTIPLIER");
        $display("Fixed SNG pair: P3-174 x P3-121 | stream length = 16");
        $display("============================================================");
        run_case(0,0); run_case(1,255); run_case(10,20);
        run_case(64,64); run_case(100,150); run_case(128,128);
        run_case(200,100); run_case(200,200); run_case(255,255);
        $display("******** L=16 TEST COMPLETE ********");
        $finish;
    end
endmodule
