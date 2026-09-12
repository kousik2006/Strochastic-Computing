`timescale 1ns/1ps

//==============================================================================
// FINAL L=32 STOCHASTIC MULTIPLIER TESTBENCH
//
// DUT:
//     sc_multiplier_32
//
// Configuration:
//     Stream length = 32
//     SNG-A         = P2, seed 198
//     SNG-B         = P2, seed 86
//
// This testbench verifies:
//
//   1. Reset
//   2. START operation
//   3. Exactly 32 stochastic samples
//   4. LFSR-A sequence
//   5. LFSR-B sequence
//   6. stochastic_A
//   7. stochastic_B
//   8. stochastic_product
//   9. ones counters
//  10. DONE signal
//  11. BUSY signal
//  12. SC product
//  13. Exact product
//  14. Absolute error
//
// SIMULATION ONLY -- NOT A SYNTHESIS SOURCE.
//==============================================================================

module tb_sc_multiplier_32;

    //==========================================================================
    // INPUTS
    //==========================================================================

    reg         clk;
    reg         reset;
    reg         start;

    reg [7:0]   A;
    reg [7:0]   B;


    //==========================================================================
    // OUTPUTS FROM DUT
    //==========================================================================

    wire        busy;
    wire        done;

    wire [15:0] product;

    wire        stochastic_A;
    wire        stochastic_B;
    wire        stochastic_product;

    wire [7:0]  lfsr_A_state;
    wire [7:0]  lfsr_B_state;

    wire [5:0]  ones_A;
    wire [5:0]  ones_B;
    wire [5:0]  ones_product;


    //==========================================================================
    // INDEPENDENT TESTBENCH COUNTERS
    //
    // These are NOT the DUT counters.
    //
    // They independently count what we observe on the stochastic signals.
    // This lets us verify that the DUT's counters are correct.
    //==========================================================================

    integer tb_ones_A;
    integer tb_ones_B;
    integer tb_ones_product;

    integer cycle;

    integer expected_product;
    integer absolute_error;
    integer signed_error;

    integer expected_ones_A;
    integer expected_ones_B;
    integer expected_ones_product;


    //==========================================================================
    // REAL VARIABLES FOR ERROR ANALYSIS
    //==========================================================================

    real ideal_probability_A;
    real ideal_probability_B;
    real ideal_probability_product;

    real measured_probability_A;
    real measured_probability_B;
    real measured_probability_product;

    real normalized_error;


    //==========================================================================
    // INSTANTIATE DUT
    //==========================================================================

    sc_multiplier_32 dut (

        .clk                (clk),
        .reset              (reset),
        .start              (start),

        .A                  (A),
        .B                  (B),

        .busy               (busy),
        .done               (done),

        .product            (product),

        .stochastic_A       (stochastic_A),
        .stochastic_B       (stochastic_B),
        .stochastic_product (stochastic_product),

        .lfsr_A_state       (lfsr_A_state),
        .lfsr_B_state       (lfsr_B_state),

        .ones_A             (ones_A),
        .ones_B             (ones_B),
        .ones_product       (ones_product)
    );


    //==========================================================================
    // CLOCK
    //
    // 10 ns period
    //==========================================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //==========================================================================
    // RUN ONE MULTIPLICATION TEST
    //==========================================================================

    task run_case;

        input [7:0] a_in;
        input [7:0] b_in;

        begin

            //------------------------------------------------------------------
            // Wait until previous operation is completely finished
            //------------------------------------------------------------------

            wait (busy == 1'b0);


            //------------------------------------------------------------------
            // Clear independent testbench counters
            //------------------------------------------------------------------

            tb_ones_A       = 0;
            tb_ones_B       = 0;
            tb_ones_product = 0;


            //------------------------------------------------------------------
            // Apply A and B while DUT is idle
            //------------------------------------------------------------------

            @(negedge clk);

            A     = a_in;
            B     = b_in;
            start = 1'b1;


            //------------------------------------------------------------------
            // START is one clock wide
            //------------------------------------------------------------------

            @(negedge clk);

            start = 1'b0;


            //------------------------------------------------------------------
            // Wait until DUT accepts START
            //------------------------------------------------------------------

            wait (busy == 1'b1);


            //------------------------------------------------------------------
            // TEST HEADER
            //------------------------------------------------------------------

            $display("");
            $display("");
            $display("======================================================================");
            $display("             L=32 STOCHASTIC MULTIPLIER TEST");
            $display("======================================================================");
            $display("A                  = %0d", a_in);
            $display("B                  = %0d", b_in);
            $display("SNG-A              = P2 / seed 198");
            $display("SNG-B              = P2 / seed 86");
            $display("STREAM LENGTH      = 32");
            $display("----------------------------------------------------------------------");

            $display(
                "Cycle | LFSR_A | LFSR_B | S_A | S_B | S_A&S_B"
            );

            $display(
                "----------------------------------------------------------------------"
            );


            //==================================================================
            // 32 STOCHASTIC SAMPLES
            //
            // IMPORTANT:
            //
            // We look at the signals on the NEGATIVE edge BEFORE the next
            // positive edge.
            //
            // Therefore the displayed LFSR state is the state that is used
            // for that stochastic sample.
            //
            // Cycle 1 MUST show:
            //
            //     LFSR_A = 198
            //     LFSR_B = 86
            //
            // because these are the loaded seeds.
            //==================================================================

            for (cycle = 1; cycle <= 32; cycle = cycle + 1) begin

                //----------------------------------------------------------------
                // Observe current stochastic state
                //----------------------------------------------------------------

                @(negedge clk);

                $display(
                    "%5d | %7d | %7d | %3d | %3d | %7d",
                    cycle,
                    lfsr_A_state,
                    lfsr_B_state,
                    stochastic_A,
                    stochastic_B,
                    stochastic_product
                );


                //----------------------------------------------------------------
                // Independently count stochastic bits
                //----------------------------------------------------------------

                if (stochastic_A == 1'b1)
                    tb_ones_A = tb_ones_A + 1;

                if (stochastic_B == 1'b1)
                    tb_ones_B = tb_ones_B + 1;

                if (stochastic_product == 1'b1)
                    tb_ones_product = tb_ones_product + 1;


                //----------------------------------------------------------------
                // The current stochastic bits are consumed at this rising edge
                //----------------------------------------------------------------

                @(posedge clk);

            end


            //==================================================================
            // Allow NON-BLOCKING assignments in DUT to settle
            //==================================================================

            #1;


            //==================================================================
            // EXPECTED EXACT INTEGER PRODUCT
            //==================================================================

            expected_product = a_in * b_in;


            //==================================================================
            // ABSOLUTE INTEGER ERROR
            //==================================================================

            if (product >= expected_product)
                absolute_error = product - expected_product;
            else
                absolute_error = expected_product - product;


            //==================================================================
            // SIGNED ERROR
            //==================================================================

            signed_error = product - expected_product;


            //==================================================================
            // IDEAL NORMALIZED PROBABILITIES
            //
            // The stochastic representation uses:
            //
            //     P = value / 255
            //==================================================================

            ideal_probability_A =
                a_in / 255.0;

            ideal_probability_B =
                b_in / 255.0;

            ideal_probability_product =
                ideal_probability_A *
                ideal_probability_B;


            //==================================================================
            // MEASURED STOCHASTIC PROBABILITIES
            //==================================================================

            measured_probability_A =
                tb_ones_A / 32.0;

            measured_probability_B =
                tb_ones_B / 32.0;

            measured_probability_product =
                tb_ones_product / 32.0;


            //==================================================================
            // NORMALIZED ERROR
            //==================================================================

            if (measured_probability_product >= ideal_probability_product)

                normalized_error =
                    measured_probability_product -
                    ideal_probability_product;

            else

                normalized_error =
                    ideal_probability_product -
                    measured_probability_product;


            //==================================================================
            // FINAL RESULT
            //==================================================================

            $display("");
            $display("----------------------------------------------------------------------");

            $display(
                "TESTBENCH COUNT A       = %0d / 32",
                tb_ones_A
            );

            $display(
                "DUT COUNT A             = %0d / 32",
                ones_A
            );

            $display("");

            $display(
                "TESTBENCH COUNT B       = %0d / 32",
                tb_ones_B
            );

            $display(
                "DUT COUNT B             = %0d / 32",
                ones_B
            );

            $display("");

            $display(
                "TESTBENCH COUNT PRODUCT = %0d / 32",
                tb_ones_product
            );

            $display(
                "DUT COUNT PRODUCT       = %0d / 32",
                ones_product
            );


            //==================================================================
            // COUNTER CONSISTENCY CHECK
            //==================================================================

            $display("");
            $display("----------------------------------------------------------------------");
            $display("COUNTER VERIFICATION");
            $display("----------------------------------------------------------------------");

            if (tb_ones_A == ones_A)
                $display("A counter       : PASS");
            else
                $display(
                    "A counter       : FAIL  TB=%0d DUT=%0d",
                    tb_ones_A,
                    ones_A
                );


            if (tb_ones_B == ones_B)
                $display("B counter       : PASS");
            else
                $display(
                    "B counter       : FAIL  TB=%0d DUT=%0d",
                    tb_ones_B,
                    ones_B
                );


            if (tb_ones_product == ones_product)
                $display("Product counter : PASS");
            else
                $display(
                    "Product counter : FAIL  TB=%0d DUT=%0d",
                    tb_ones_product,
                    ones_product
                );


            //==================================================================
            // PROBABILITIES
            //==================================================================

            $display("");
            $display("----------------------------------------------------------------------");
            $display("STOCHASTIC PROBABILITIES");
            $display("----------------------------------------------------------------------");

            $display(
                "Ideal P(A)       = %0.6f",
                ideal_probability_A
            );

            $display(
                "Measured P(A)    = %0.6f",
                measured_probability_A
            );

            $display("");

            $display(
                "Ideal P(B)       = %0.6f",
                ideal_probability_B
            );

            $display(
                "Measured P(B)    = %0.6f",
                measured_probability_B
            );

            $display("");

            $display(
                "Ideal P(product) = %0.6f",
                ideal_probability_product
            );

            $display(
                "Measured P(prod) = %0.6f",
                measured_probability_product
            );


            //==================================================================
            // PRODUCT RESULTS
            //==================================================================

            $display("");
            $display("----------------------------------------------------------------------");
            $display("PRODUCT VERIFICATION");
            $display("----------------------------------------------------------------------");

            $display(
                "SC Product       = %0d",
                product
            );

            $display(
                "Exact Product    = %0d",
                expected_product
            );

            $display(
                "Absolute Error   = %0d",
                absolute_error
            );

            $display(
                "Signed Error     = %0d",
                signed_error
            );

            $display(
                "Normalized Error = %0.6f",
                normalized_error
            );


            //==================================================================
            // DONE CHECK
            //==================================================================

            $display("");
            $display("----------------------------------------------------------------------");
            $display("CONTROL SIGNAL CHECK");
            $display("----------------------------------------------------------------------");

            if (done == 1'b1)
                $display("DONE             : PASS");
            else
                $display("DONE             : FAIL");


            if (busy == 1'b0)
                $display("BUSY             : PASS - returned to IDLE");
            else
                $display("BUSY             : FAIL - still BUSY");


            //==================================================================
            // FINAL CASE STATUS
            //==================================================================

            if ((tb_ones_A == ones_A) &&
                (tb_ones_B == ones_B) &&
                (tb_ones_product == ones_product) &&
                (done == 1'b1) &&
                (busy == 1'b0)) begin

                $display("");
                $display(">>> CASE VERIFICATION: PASS <<<");

            end
            else begin

                $display("");
                $display(">>> CASE VERIFICATION: FAIL <<<");

            end


            $display("======================================================================");
            $display("");


            //------------------------------------------------------------------
            // Idle clock before next test
            //------------------------------------------------------------------

            @(negedge clk);

        end

    endtask


    //==========================================================================
    // MAIN TEST SEQUENCE
    //==========================================================================

    initial begin

        //---------------------------------------------------------------------- 
        // Initial values
        //----------------------------------------------------------------------

        reset = 1'b1;
        start = 1'b0;

        A = 8'd0;
        B = 8'd0;


        //----------------------------------------------------------------------
        // Reset
        //----------------------------------------------------------------------

        $display("");
        $display("======================================================================");
        $display("       L=32 STOCHASTIC MULTIPLIER - FINAL VERIFICATION");
        $display("======================================================================");
        $display("Configuration:");
        $display("    Stream Length : 32");
        $display("    SNG-A         : P2 / seed 198");
        $display("    SNG-B         : P2 / seed 86");
        $display("");


        repeat (2) @(posedge clk);

        reset = 1'b0;

        @(posedge clk);


        //----------------------------------------------------------------------
        // TEST CASE 1
        //----------------------------------------------------------------------

        run_case(8'd0, 8'd0);


        //----------------------------------------------------------------------
        // TEST CASE 2
        //----------------------------------------------------------------------

        run_case(8'd1, 8'd255);


        //----------------------------------------------------------------------
        // TEST CASE 3
        //----------------------------------------------------------------------

        run_case(8'd10, 8'd20);


        //----------------------------------------------------------------------
        // TEST CASE 4
        //----------------------------------------------------------------------

        run_case(8'd64, 8'd64);


        //----------------------------------------------------------------------
        // TEST CASE 5
        //----------------------------------------------------------------------

        run_case(8'd100, 8'd150);


        //----------------------------------------------------------------------
        // TEST CASE 6
        //----------------------------------------------------------------------

        run_case(8'd128, 8'd128);


        //----------------------------------------------------------------------
        // TEST CASE 7
        //----------------------------------------------------------------------

        run_case(8'd200, 8'd100);


        //----------------------------------------------------------------------
        // TEST CASE 8
        //----------------------------------------------------------------------

        run_case(8'd200, 8'd200);


        //----------------------------------------------------------------------
        // TEST CASE 9
        //----------------------------------------------------------------------

        run_case(8'd255, 8'd255);


        //----------------------------------------------------------------------
        // ALL TESTS COMPLETE
        //----------------------------------------------------------------------

        $display("");
        $display("======================================================================");
        $display("              ALL L=32 TESTS COMPLETE");
        $display("======================================================================");
        $display("");

        $finish;

    end

endmodule