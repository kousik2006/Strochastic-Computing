module tb_addition_comparison;

    parameter integer N = 8;
    parameter integer L = 32;

    reg clk;
    reg reset;
    reg [N-1:0] A;
    reg [N-1:0] B;

    wire [N:0] binary_sum;
    wire lfsr_sum_bit;
    wire sobol_sum_bit;

    integer i;
    integer lfsr_ones;
    integer sobol_ones;
    real scale;
    real lfsr_estimate;
    real sobol_estimate;
    real exact_sum;

    binary_adder_parameterized #(.N(N)) DUT_BINARY (
        .A(A),
        .B(B),
        .Sum(binary_sum)
    );

    sc_adder_lfsr_structural #(.N(N)) DUT_LFSR (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .sum_bit(lfsr_sum_bit)
    );

    sc_adder_sobol_structural #(.N(N)) DUT_SOBOL (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .sum_bit(sobol_sum_bit)
    );

    always #5 clk = ~clk;

    task run_case;
        input [N-1:0] a_in;
        input [N-1:0] b_in;
        begin
            A = a_in;
            B = b_in;
            reset = 1'b1;

            @(negedge clk);
            reset = 1'b0;

            lfsr_ones = 0;
            sobol_ones = 0;

            // Unipolar N-bit encoding: P(1) = value / 2^N.
            scale = 1.0;
            for (i = 0; i < N; i = i + 1)
                scale = scale * 2.0;

            $display("");
            $display("============================================================");
            $display("A = %0d (%b), B = %0d (%b)", A, A, B, B);
            $display("Exact binary sum = %0d", binary_sum);
            $display("cycle | LFSR_sum | Sobol_sum");

            for (i = 0; i < L; i = i + 1) begin
                @(negedge clk);
                #1;
                lfsr_ones = lfsr_ones + lfsr_sum_bit;
                sobol_ones = sobol_ones + sobol_sum_bit;

                $display("%5d | %b        | %b", i+1,
                         lfsr_sum_bit, sobol_sum_bit);
            end

            exact_sum = A + B;

            // MUX addition produces (A+B)/2 in stochastic probability.
            lfsr_estimate = (2.0 * lfsr_ones * scale) / L;
            sobol_estimate = (2.0 * sobol_ones * scale) / L;

            $display("------------------------------------------------------------");
            $display("LFSR : ones = %0d/%0d, decoded = %0.3f, error = %0.3f",
                     lfsr_ones, L, lfsr_estimate,
                     lfsr_estimate - exact_sum);
            $display("Sobol: ones = %0d/%0d, decoded = %0.3f, error = %0.3f",
                     sobol_ones, L, sobol_estimate,
                     sobol_estimate - exact_sum);
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        A = 0;
        B = 0;

        #12;

        run_case(20, 30);
        run_case(64, 96);
        run_case(128, 64);
        run_case(200, 40);
        run_case(255, 255);

        #10;
        $finish;
    end
endmodule
