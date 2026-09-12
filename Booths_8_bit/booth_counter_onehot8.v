`timescale 1ns/1ps
module booth_counter_onehot8(
    input clk,
    input reset,
    input enable,
    output [7:0] count_onehot,
    output last
);
    reg [7:0] q;

    always @(posedge clk) begin
        if(reset)
            q <= 8'b0;
        else if(!enable)
            q <= 8'b0;
        else if(q == 8'b0)
            q <= 8'b00000001;
        else if(q[7])
            q <= 8'b0;
        else
            q <= {q[6:0],1'b0};
    end

    assign count_onehot = q;
    assign last = q[7];
endmodule
