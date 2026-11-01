`timescale 1ns/1ps
module booth_multiplier_8bit_tb;
    reg         clk, rst, start;
    reg  [7:0]  multiplicand, multiplier;
    wire [15:0] product;
    wire        done;
    wire [6:0]  state;

    reg  signed [15:0] expected;
    integer i, j, errors, cycles, min_cycles, max_cycles, total_tests;

    booth_multiplier_8bit dut (
        .clk(clk), .rst(rst), .start(start),
        .multiplicand(multiplicand), .multiplier(multiplier),
        .product(product), .done(done), .state(state)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Run one multiplication and check the result
    task run_mult(input [7:0] x, input [7:0] y);
        begin
            multiplicand = x;
            multiplier   = y;
            @(negedge clk);
            start  = 1;
            cycles = 0;
            @(negedge clk);
            while (!done && cycles < 100) begin
                @(negedge clk);
                cycles = cycles + 1;
            end

            expected = $signed(x) * $signed(y);
            total_tests = total_tests + 1;
            if (cycles < min_cycles) min_cycles = cycles;
            if (cycles > max_cycles) max_cycles = cycles;

            if (!done || product !== expected) begin
                errors = errors + 1;
                $display("ERROR: %0d * %0d = %0d, expected %0d (done=%b)",
                         $signed(x), $signed(y), $signed(product), expected, done);
            end

            @(negedge clk);
            start = 0;                 // leave DONE, go back to IDLE
            @(negedge clk);
            @(negedge clk);
        end
    endtask

    // directed test with printout
    task show(input [7:0] x, input [7:0] y);
        begin
            run_mult(x, y);
            $display("%4d * %4d = %6d   (expected %6d)  cycles=%0d",
                     $signed(x), $signed(y), $signed(product), expected, cycles);
        end
    endtask

    initial begin
        $dumpfile("booth_tb.vcd");
        $dumpvars(0, booth_multiplier_8bit_tb);

        errors = 0; total_tests = 0; min_cycles = 1000; max_cycles = 0;
        rst = 1; start = 0; multiplicand = 0; multiplier = 0;
        #22 rst = 0;
        @(negedge clk);

        // ---- directed cases (these are recorded in the VCD) ----
        show( 8'd3,    8'd4);
        show(-8'sd3,   8'd4);
        show( 8'd7,   -8'sd5);
        show(-8'sd7,  -8'sd5);
        show( 8'd127,  8'd127);
        show(-8'sd128, 8'd127);
        show(-8'sd128,-8'sd128);   // 16384, tests the 9-bit accumulator
        show( 8'd0,    8'd55);
        show(-8'sd1,  -8'sd1);

        // ---- exhaustive test: all 65536 signed combinations ----
        $dumpoff;                                   // keep the VCD small
        for (i = -128; i <= 127; i = i + 1)
            for (j = -128; j <= 127; j = j + 1)
                run_mult(i[7:0], j[7:0]);

        $display("--------------------------------------------------");
        $display("Tests run: %0d   latency: %0d..%0d cycles after start",
                 total_tests, min_cycles, max_cycles);
        if (errors == 0) $display("PASS: all signed 8x8 combinations correct.");
        else             $display("FAIL: %0d errors.", errors);
        $finish;
    end
endmodule
