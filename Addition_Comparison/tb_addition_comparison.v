`timescale 1ns/1ps

module tb_addition_comparison;

    parameter integer N = 8;
    parameter integer L = 32;

    reg clk, reset, start;
    reg [N-1:0] A, B;

    wire [N:0] binary_sum;

    wire lfsr_busy, lfsr_done;
    wire [N:0] lfsr_sum;
    wire lfsr_A, lfsr_B, lfsr_select, lfsr_stochastic_sum;

    wire sobol_busy, sobol_done;
    wire [N:0] sobol_sum;
    wire sobol_A, sobol_B, sobol_select, sobol_stochastic_sum;

    binary_adder_parameterized #(.N(N)) DUT_BINARY (
        .A(A), .B(B), .Cin(1'b0), .Sum(binary_sum)
    );

    sc_adder_lfsr_parameterized #(.N(N), .L(L)) DUT_LFSR (
        .clk(clk), .reset(reset), .start(start),
        .A(A), .B(B),
        .busy(lfsr_busy), .done(lfsr_done), .sum(lfsr_sum),
        .stochastic_A(lfsr_A), .stochastic_B(lfsr_B),
        .stochastic_select(lfsr_select),
        .stochastic_sum(lfsr_stochastic_sum)
    );

    sc_adder_sobol_parameterized #(.N(N), .L(L)) DUT_SOBOL (
        .clk(clk), .reset(reset), .start(start),
        .A(A), .B(B),
        .busy(sobol_busy), .done(sobol_done), .sum(sobol_sum),
        .stochastic_A(sobol_A), .stochastic_B(sobol_B),
        .stochastic_select(sobol_select),
        .stochastic_sum(sobol_stochastic_sum)
    );

    always #5 clk = ~clk;

    task run_case;
        input [N-1:0] a_in;
        input [N-1:0] b_in;
        begin
            @(negedge clk);
            A = a_in;
            B = b_in;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            wait(lfsr_done);
            wait(sobol_done);
            #1;

            $display("A=%0d B=%0d | Binary=%0d | LFSR-SC=%0d | Sobol-SC=%0d",
                     A, B, binary_sum, lfsr_sum, sobol_sum);

            if (binary_sum !== (A+B))
                $display("ERROR: binary adder mismatch");

            $display("  LFSR stochastic stream last bits: A=%b B=%b S=%b Y=%b",
                     lfsr_A, lfsr_B, lfsr_select, lfsr_stochastic_sum);
            $display("  Sobol stochastic stream last bits: A=%b B=%b S=%b Y=%b",
                     sobol_A, sobol_B, sobol_select, sobol_stochastic_sum);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        A = 0;
        B = 0;

        #20;
        reset = 0;

        run_case(8'd20,  8'd30);
        run_case(8'd64,  8'd96);
        run_case(8'd128, 8'd64);
        run_case(8'd200, 8'd40);
        run_case(8'd255, 8'd255);

        #20;
        $finish;
    end
endmodule
