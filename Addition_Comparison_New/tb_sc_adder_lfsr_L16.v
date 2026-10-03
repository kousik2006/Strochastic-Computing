module tb_sc_adder_lfsr_L16;

    parameter integer N = 8;
    localparam integer L = 16;

    reg clk;
    reg reset;
    reg [N-1:0] A;
    reg [N-1:0] B;

    wire sum_bit;

    integer i;
    integer ones;

    real estimate;
    real exact_sum;
    real abs_error;

    sc_adder_lfsr #(.N(N)) DUT (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .sum_bit(sum_bit)
    );

    always #5 clk = ~clk;

    task run_case;
        input [N-1:0] a_in;
        input [N-1:0] b_in;

        begin
            A = a_in;
            B = b_in;
            ones = 0;

            reset = 1'b1;
            @(negedge clk);
            reset = 1'b0;

            for (i = 0; i < L; i = i + 1) begin
                @(negedge clk);
                ones = ones + sum_bit;
            end

            exact_sum = A + B;
            estimate = (2.0 * ones * ((1 << N) - 1)) / L;

            abs_error = estimate - exact_sum;
            if (abs_error < 0.0)
                abs_error = -abs_error;

            $display("A=%0d B=%0d | ones=%0d/%0d | exact=%0.3f | estimate=%0.3f | abs_err=%0.3f",
                     A, B, ones, L, exact_sum, estimate, abs_error);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        A = 0;
        B = 0;

        $display("==============================================");
        $display("sc_adder_lfsr : N=%0d L=%0d", N, L);
        $display("==============================================");

        #12;

        run_case(20, 30);
        run_case(64, 96);
        run_case(128, 64);
        run_case(200, 40);
        run_case(255, 255);

        $display("==============================================");
        $finish;
    end

endmodule
