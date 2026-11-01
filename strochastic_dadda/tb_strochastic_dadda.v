// =============================================================================
//  File   : tb_stochastic_dadda_multiplier.v
//  Brief  : Comprehensive self-checking testbench for the simplified
//           8x8 Stochastic Dadda Multiplier (stochastic_dadda_multiplier_8bit).
//           Outputs all intermediate stages, errors, and statistics in decimal.
// =============================================================================
`timescale 1ns / 1ps

module tb_stochastic_dadda_multiplier;

    // -------------------------------------------------------------------------
    // 1. Parameters (Change m = 4, 6, 8, 9, 10, 12, 14, 15 to vary L = 2^m)
    // -------------------------------------------------------------------------
    parameter integer m     = 8;
    localparam integer L    = (1 << m);       // Full stream length = 2^m
    localparam integer SH   = (15 - m);       // Dropped LSB bits from 15-bit rows
    localparam integer SC   = (1 << SH);      // Scale factor = 2^(15 - m)

    // -------------------------------------------------------------------------
    // 2. DUT Signals & Instantiation
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst;
    reg  [7:0]  a;
    reg  [7:0]  b;
    wire [15:0] product;
    wire        done;

    stochastic_dadda_multiplier_8bit #(
        .m(m)
    ) uut (
        .clk     (clk),
        .rst     (rst),
        .a       (a),
        .b       (b),
        .product (product),
        .done    (done)
    );

    // 100 MHz Clock (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // 3. Verification & Statistical Tracking Variables
    // -------------------------------------------------------------------------
    integer test_count;
    integer non_zero_count;
    integer dadda_tree_errors;
    integer cbac_count_errors;
    integer exact_match_count;
    integer max_abs_err;

    real sum_abs_err;
    real sum_sq_err;
    real sum_rel_err;
    real sum_cycles_used;
    real sum_cycles_saved_pct;

    // -------------------------------------------------------------------------
    // 4. Task: Run Single Test Case (Table Row + Optional Detailed Breakdown)
    // -------------------------------------------------------------------------
    task run_vector(
        input [7:0] in_a,
        input [7:0] in_b,
        input       show_detail
    );
        integer exact_prod;
        integer row_a_dec, row_b_dec, dadda_sum;
        integer qa_dec, qb_dec;
        integer exp_ones, act_ones;
        integer quant_sum, est_prod;
        integer quant_err, cbac_err, total_err, abs_err;
        integer cyc_used, cyc_saved;
        real    rel_err_pct, saved_pct;
        begin
            // Apply inputs and pulse reset
            a   = in_a;
            b   = in_b;
            rst = 1'b1;
            @(posedge clk);
            #1;
            rst = 1'b0;

            // Wait for DD-MAX early termination to assert done
            wait (done == 1'b1);
            @(posedge clk);
            #1;

            // Extract decimal values from DUT
            exact_prod = in_a * in_b;
            row_a_dec  = uut.row_a;
            row_b_dec  = uut.row_b;
            dadda_sum  = row_a_dec + row_b_dec;

            qa_dec     = uut.q_a;
            qb_dec     = uut.q_b;
            act_ones   = uut.out_value;
            exp_ones   = (qa_dec / 2) + ((qb_dec + 1) / 2); // floor(qa/2) + ceil(qb/2)

            quant_sum  = (qa_dec + qb_dec) * SC;
            est_prod   = product;

            // Decimal error calculations
            quant_err  = quant_sum - exact_prod;            // Error from dropping (15-m) bits
            cbac_err   = est_prod  - quant_sum;             // Error from CBAC +/-0.5 count
            total_err  = est_prod  - exact_prod;            // Total error (Est - Exact)
            abs_err    = (total_err < 0) ? -total_err : total_err;

            if (exact_prod != 0) begin
                rel_err_pct    = (100.0 * abs_err) / exact_prod;
                non_zero_count = non_zero_count + 1;
                sum_rel_err    = sum_rel_err + rel_err_pct;
            end else begin
                rel_err_pct = 0.0;
            end

            // DD-MAX cycle metrics
            cyc_used  = uut.counter;
            cyc_saved = L - cyc_used;
            saved_pct = (100.0 * cyc_saved) / L;

            // Self-checking assertions
            if (dadda_sum !== exact_prod) begin
                dadda_tree_errors = dadda_tree_errors + 1;
                $display("  [FAIL] Dadda Tree Error for %0d x %0d: RowA(%0d)+RowB(%0d)=%0d != Exact(%0d)",
                         in_a, in_b, row_a_dec, row_b_dec, dadda_sum, exact_prod);
            end
            if (act_ones !== exp_ones) begin
                cbac_count_errors = cbac_count_errors + 1;
                $display("  [FAIL] CBAC Count Error for %0d x %0d: out_value=%0d != Expected=%0d",
                         in_a, in_b, act_ones, exp_ones);
            end

            // Update statistics
            test_count           = test_count + 1;
            sum_abs_err          = sum_abs_err + abs_err;
            sum_sq_err           = sum_sq_err  + (1.0 * total_err * total_err);
            sum_cycles_used      = sum_cycles_used + cyc_used;
            sum_cycles_saved_pct = sum_cycles_saved_pct + saved_pct;
            if (abs_err == 0) exact_match_count = exact_match_count + 1;
            if (abs_err > max_abs_err) max_abs_err = abs_err;

            // Print either step-by-step walkthrough or compact table row
            if (show_detail) begin
                $display("-----------------------------------------------------------------------------------------");
                $display("  STEP-BY-STEP DECIMAL WALKTHROUGH: A = %0d, B = %0d (m = %0d, L = %0d, Scale = 2^%0d = %0d)",
                         in_a, in_b, m, L, SH, SC);
                $display("  1) Exact Product (A * B)         : %0d", exact_prod);
                $display("  2) Dadda Tree 15-bit Rows        : Row_A = %0d, Row_B = %0d (Sum = %0d)",
                         row_a_dec, row_b_dec, dadda_sum);
                $display("  3) Quantized Top-%0d-bit Inputs    : q_a = floor(%0d/%0d) = %0d, q_b = floor(%0d/%0d) = %0d",
                         m, row_a_dec, SC, qa_dec, row_b_dec, SC, qb_dec);
                $display("  4) CBAC 1s Count (out_value)     : floor(%0d/2) + ceil(%0d/2) = %0d + %0d = %0d",
                         qa_dec, qb_dec, (qa_dec/2), ((qb_dec+1)/2), act_ones);
                $display("  5) Final Shifted Output          : 2 * %0d * %0d = %0d",
                         act_ones, SC, est_prod);
                $display("  6) Decimal Error Breakdown       : Quant_Err = %+0d | CBAC_Err = %+0d | Total_Err = %+0d (%0.2f%%)",
                         quant_err, cbac_err, total_err, rel_err_pct);
                $display("  7) DD-MAX Early Termination      : Stopped at cycle %0d / %0d (Saved %0d cycles = %0.1f%%)",
                         cyc_used, L, cyc_saved, saved_pct);
            end else begin
                $display("| %3d x %3d | %5d | %5d + %5d | %4d, %4d | %4d | %5d | %+6d | %+5d | %+6d | %6.2f%% | %4d/%4d (%4.1f%%) |",
                         in_a, in_b, exact_prod, row_a_dec, row_b_dec,
                         qa_dec, qb_dec, act_ones, est_prod,
                         quant_err, cbac_err, total_err, rel_err_pct,
                         cyc_used, L, saved_pct);
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // 5. Main Stimulus & Report Block
    // -------------------------------------------------------------------------
    integer i;
    integer rand_seed;
    reg [7:0] rand_a, rand_b;

    initial begin
        // Generate VCD waveform for GTKWave / Vivado
        $dumpfile("stochastic_dadda_tb.vcd");
        $dumpvars(0, tb_stochastic_dadda_multiplier);

        // Initialize state
        rst                  = 1'b1;
        a                    = 8'd0;
        b                    = 8'd0;
        test_count           = 0;
        non_zero_count       = 0;
        dadda_tree_errors    = 0;
        cbac_count_errors    = 0;
        exact_match_count    = 0;
        max_abs_err          = 0;
        sum_abs_err          = 0.0;
        sum_sq_err           = 0.0;
        sum_rel_err          = 0.0;
        sum_cycles_used      = 0.0;
        sum_cycles_saved_pct = 0.0;
        rand_seed            = 32'h2026_0309;

        repeat (2) @(posedge clk);

        $display("\n=========================================================================================");
        $display("  PART 1: DETAILED DECIMAL WALKTHROUGH OF KEY CASES (m = %0d, L = %0d)", m, L);
        $display("=========================================================================================");
        run_vector(8'd173, 8'd91,  1'b1); // HTML Stochastic Dadda Simulator Default
        run_vector(8'd219, 8'd181, 1'b1); // HTML Dadda 8x8 Textbook Default
        run_vector(8'd13,  8'd11,  1'b1); // Small inputs (high DD-MAX cycle savings)

        // Reset counters before full tabular sweep so Part 1 isn't double-counted
        test_count           = 0;
        non_zero_count       = 0;
        exact_match_count    = 0;
        max_abs_err          = 0;
        sum_abs_err          = 0.0;
        sum_sq_err           = 0.0;
        sum_rel_err          = 0.0;
        sum_cycles_used      = 0.0;
        sum_cycles_saved_pct = 0.0;

        $display("\n=============================================================================================================================");
        $display("  PART 2: FULL DECIMAL ERROR TABLE (m = %0d, L = %0d, Formula: Product = 2 * out_value * 2^(15-%0d))", m, L, m);
        $display("=============================================================================================================================");
        $display("|   Inputs  | Exact |   Dadda Rows  |  Quantized | Out  |  Est  |  Quant |  CBAC |  Total |   Rel   |   DD-MAX Cycles   |");
        $display("|   A x B   |  Prod |  RowA + RowB  |   qa,   qb |  1s  |  Prod |  Error | Error |  Error |  Error  |  Used/Max (Saved) |");
        $display("|-----------|-------|---------------|------------|------|-------|--------|-------|--------|---------|-------------------|");

        // --- A. Corner & Directed Test Cases ---
        run_vector(8'd0,   8'd0,   1'b0); // Zero x Zero
        run_vector(8'd0,   8'd255, 1'b0); // Zero x Max
        run_vector(8'd1,   8'd1,   1'b0); // Min non-zero
        run_vector(8'd13,  8'd11,  1'b0); // 4-bit textbook (143)
        run_vector(8'd50,  8'd25,  1'b0); // Small numbers (1250)
        run_vector(8'd64,  8'd64,  1'b0); // Powers of 2 (4096)
        run_vector(8'd128, 8'd128, 1'b0); // MSB only (16384)
        run_vector(8'd192, 8'd64,  1'b0); // CBAC HTML default (12288)
        run_vector(8'd170, 8'd85,  1'b0); // Alternating bits 10101010 x 01010101 (14450)
        run_vector(8'd173, 8'd91,  1'b0); // Stochastic Dadda HTML default (15743)
        run_vector(8'd219, 8'd181, 1'b0); // Dadda 8x8 preset (39639)
        run_vector(8'd255, 8'd254, 1'b0); // Near max (64770)
        run_vector(8'd255, 8'd255, 1'b0); // Max 8-bit unsigned (65025)

        // --- B. 15 Random Test Cases ---
        for (i = 0; i < 15; i = i + 1) begin
            rand_a = $urandom(rand_seed) & 8'hFF;
            rand_b = $urandom(rand_seed) & 8'hFF;
            run_vector(rand_a, rand_b, 1'b0);
        end

        $display("=============================================================================================================================");
        $display("  PART 3: FINAL TESTBENCH SUMMARY (%0d Total Vectors, m = %0d, L = %0d, Scale = %0d)", test_count, m, L, SC);
        $display("=============================================================================================================================");
        $display("  * Structural Dadda Tree Check : %s (%0d mismatches)",
                 (dadda_tree_errors == 0) ? "PASSED" : "FAILED", dadda_tree_errors);
        $display("  * CBAC Counter Logic Check    : %s (%0d mismatches)",
                 (cbac_count_errors == 0) ? "PASSED" : "FAILED", cbac_count_errors);
        $display("  * Exact Zero-Error Matches    : %0d / %0d vectors", exact_match_count, test_count);
        $display("  * Mean Absolute Error (MAE)   : %0.2f (in decimal product units)", sum_abs_err / test_count);
        $display("  * Root Mean Square Err (RMSE) : %0.2f (in decimal product units)", $sqrt(sum_sq_err / test_count));
        $display("  * Max Absolute Error          : %0d (Worst-case theoretical bound = %0d)", max_abs_err, (3 * SC - 2));
        $display("  * Mean Relative Error (MRE)   : %0.2f%% (across %0d non-zero vectors)",
                 (non_zero_count > 0) ? (sum_rel_err / non_zero_count) : 0.0, non_zero_count);
        $display("  * Average DD-MAX Cycles Used  : %0.1f / %0d cycles (Average Saved = %0.1f%%)",
                 sum_cycles_used / test_count, L, sum_cycles_saved_pct / test_count);
        $display("=============================================================================================================================\n");

        $finish;
    end

endmodule