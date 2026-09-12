`timescale 1ns/1ps
module tb_booth_8x8_structural;
    reg clk, reset, start;
    reg [7:0] multiplicand, multiplier;
    wire [15:0] product;
    wire busy, done;

    integer i,j,expected,errors;

    booth_8x8_structural DUT(
        .clk(clk), .reset(reset), .start(start),
        .multiplicand(multiplicand), .multiplier(multiplier),
        .product(product), .busy(busy), .done(done)
    );

    initial begin
        clk=0;
        forever #5 clk=~clk;
    end

    task run_test;
        input [7:0] a;
        input [7:0] b;
        begin
            @(negedge clk);
            while(busy) @(negedge clk);

            multiplicand=a;
            multiplier=b;
            start=1'b1;

            @(negedge clk);
            start=1'b0;

            wait(done==1'b1);
            #1;

            expected=a*b;

            if(product !== expected[15:0]) begin
                $display("FAIL: %0d x %0d -> DUT=%0d EXPECTED=%0d",
                         a,b,product,expected);
                errors=errors+1;
            end
            else begin
                $display("PASS: %0d x %0d = %0d",a,b,product);
            end
        end
    endtask

    initial begin
        reset=1;
        start=0;
        multiplicand=0;
        multiplier=0;
        errors=0;

        repeat(3) @(negedge clk);
        reset=0;

        $display("==============================================");
        $display(" 8x8 UNSIGNED STRUCTURAL BOOTH MULTIPLIER");
        $display("==============================================");

        run_test(0,0);
        run_test(1,1);
        run_test(5,7);
        run_test(15,15);
        run_test(25,12);
        run_test(100,50);
        run_test(127,127);
        run_test(128,2);
        run_test(128,128);
        run_test(200,100);
        run_test(255,2);
        run_test(255,255);

        $display("");
        $display("Starting exhaustive 256 x 256 verification...");

        for(i=0;i<256;i=i+1)
            for(j=0;j<256;j=j+1)
                run_test(i[7:0],j[7:0]);

        $display("");
        $display("==============================================");
        if(errors==0) begin
            $display("ALL TESTS PASSED");
            $display("65536 combinations verified.");
        end
        else begin
            $display("TEST FAILED: %0d errors",errors);
        end
        $display("==============================================");

        $finish;
    end
endmodule
