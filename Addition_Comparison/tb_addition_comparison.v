module tb_addition_comparison;

    parameter integer N = 8;
    parameter integer L = 32;

    reg clk;
    reg reset;
    reg start;
    reg [N-1:0] A;
    reg [N-1:0] B;

    wire [N:0] binary_sum;

    wire lfsr_busy, lfsr_done;
    wire lfsr_A, lfsr_B, lfsr_select, lfsr_sum_bit;

    wire sobol_busy, sobol_done;
    wire sobol_A, sobol_B, sobol_select, sobol_sum_bit;

    integer i;
    integer lfsr_ones;
    integer sobol_ones;
    real max_value;
    real exact_sum;
    real lfsr_estimate;
    real sobol_estimate;
    real lfsr_error;
    real sobol_error;

    binary_adder_parameterized #(.N(N)) DUT_BINARY (
        .A(A),
        .B(B),
        .Cin(1'b0),
        .Sum(binary_sum)
    );

    sc_adder_lfsr_parameterized #(.N(N), .L(L)) DUT_LFSR (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .busy(lfsr_busy),
        .done(lfsr_done),
        .stochastic_A(lfsr_A),
        .stochastic_B(lfsr_B),
        .stochastic_select(lfsr_select),
        .stochastic_sum(lfsr_sum_bit)
    );

    sc_adder_sobol_parameterized #(.N(N), .L(L)) DUT_SOBOL (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .busy(sobol_busy),
        .done(sobol_done),
        .stochastic_A(sobol_A),
        .stochastic_B(sobol_B),
        .stochastic_select(sobol_select),
        .stochastic_sum(sobol_sum_bit)
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

            wait(lfsr_busy && sobol_busy);

            lfsr_ones = 0;
            sobol_ones = 0;

            max_value = 1.0;
            for (i = 0; i < N; i = i + 1)
                max_value = max_value * 2.0;
            max_value = max_value - 1.0;

            $display("");
            $display("============================================================");
            $display("A = %0d (%b), B = %0d (%b)", A, A, B, B);
            $display("Exact binary sum = %0d", binary_sum);
            $display("cycle | LFSR_sum | Sobol_sum | LFSR_sel | Sobol_sel");

            for (i = 0; i < L; i = i + 1) begin
                @(negedge clk);
                #1;
                lfsr_ones = lfsr_ones + lfsr_sum_bit;
                sobol_ones = sobol_ones + sobol_sum_bit;

                $display("%5d | %b        | %b         | %b        | %b",
                         i+1, lfsr_sum_bit, sobol_sum_bit,
                         lfsr_select, sobol_select);
            end

            wait(lfsr_done && sobol_done);

            exact_sum = A + B;

            lfsr_estimate = (2.0 * lfsr_ones * max_value) / L;
            sobol_estimate = (2.0 * sobol_ones * max_value) / L;

            lfsr_error = lfsr_estimate - exact_sum;
            sobol_error = sobol_estimate - exact_sum;

            $display("------------------------------------------------------------");
            $display("LFSR : ones = %0d/%0d, decoded = %0.3f, error = %0.3f",
                     lfsr_ones, L, lfsr_estimate, lfsr_error);
            $display("Sobol: ones = %0d/%0d, decoded = %0.3f, error = %0.3f",
                     sobol_ones, L, sobol_estimate, sobol_error);
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

        // Unsized literals make these tests automatically adapt to N.
        run_case(20, 30);
        run_case(64, 96);
        run_case(128, 64);
        run_case(200, 40);
        run_case(255, 255);

        #20;
        $finish;
    end

endmodule
