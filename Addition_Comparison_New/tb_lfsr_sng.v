module tb_lfsr_sng;

    parameter integer N = 8;
    localparam integer CYCLES = (1 << N) - 1;

    reg          clk;
    reg          reset;
    reg  [N-1:0] input_value;

    wire [N-1:0] random_value;
    wire         stochastic_bit;

    integer i;
    integer ones;

    lfsr #(
        .N(N)
    ) RNG (
        .clk(clk),
        .reset(reset),
        .q(random_value)
    );

    lfsr_sng #(
        .N(N)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .input_value(input_value),
        .stochastic_bit(stochastic_bit)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        input_value = 64;
        ones = 0;

        #12;
        reset = 1'b0;

        $display("==============================================");
        $display("LFSR SNG N=%0d input=%0d", N, input_value);
        $display("==============================================");

        for (i = 0; i < CYCLES; i = i + 1) begin
            @(negedge clk);

            ones = ones + stochastic_bit;

            if (i < 8)
                $display(
                    "cycle=%0d random=%0d bit=%b",
                    i + 1, random_value, stochastic_bit
                );
        end

        $display("ones=%0d/%0d", ones, CYCLES);

        $finish;
    end

endmodule
