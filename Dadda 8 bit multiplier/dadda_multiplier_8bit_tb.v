`timescale 1ns/1ps
module dadda_multiplier_8bit_tb;
    reg  [7:0]  a, b;
    wire [15:0] product;
    reg  [15:0] expected;
    integer i, j, errors;

    // Device under test
    dadda_multiplier_8bit dut (.a(a), .b(b), .product(product));

    // Apply inputs, update expected together with them, then check after settling
    task apply_and_check(input [7:0] ta, input [7:0] tb);
        begin
            a = ta;
            b = tb;
            expected = ta * tb;     // updated at the same time as the inputs
            #1;                     // let the gates settle
            if (product !== expected) begin
                errors = errors + 1;
                $display("ERROR: a=%0d b=%0d product=%0d expected=%0d",
                         a, b, product, expected);
            end
        end
    endtask

    initial begin
        errors = 0;

        // ---- directed corner cases ----
        apply_and_check(8'd0,   8'd0);
        apply_and_check(8'd1,   8'd1);
        apply_and_check(8'd255, 8'd255);   // max: 65025
        apply_and_check(8'd255, 8'd1);
        apply_and_check(8'd170, 8'd85);    // 0xAA * 0x55
        apply_and_check(8'd13,  8'd11);

        // ---- exhaustive test: all 65536 input combinations ----
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                apply_and_check(i, j);

        if (errors == 0) $display("PASS: all 65536 combinations correct.");
        else             $display("FAIL: %0d errors.", errors);
        $finish;
    end

    // Waveform dump for GTKWave
    initial begin
        $dumpfile("dadda_tb.vcd");
        $dumpvars(0, dadda_multiplier_8bit_tb);
    end
endmodule
