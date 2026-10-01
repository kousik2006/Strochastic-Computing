module sc_sobol_parameterized #(
    parameter integer N = 8,
    parameter [N-1:0] SEED = 0
)(
    input wire clk,
    input wire reset,
    input wire load_seed,
    input wire enable,
    output reg [N-1:0] value
);
    reg [N-1:0] x;
    reg [N-1:0] index;

    function integer ctz;
        input [N-1:0] v;
        integer k;
        reg found;
        begin
            ctz = 0;
            found = 0;
            for (k = 0; k < N; k = k + 1) begin
                if (!found && v[k]) begin
                    ctz = k;
                    found = 1;
                end
            end
        end
    endfunction

    function [N-1:0] direction_number;
        input integer k;
        reg [N-1:0] temp;
        begin
            temp = {N{1'b0}};
            temp[N-1-k] = 1'b1;
            direction_number = temp;
        end
    endfunction

    wire [N-1:0] index_next;
    wire [N-1:0] x_next;

    assign index_next = index + 1'b1;
    assign x_next = x ^ direction_number(ctz(index_next));

    always @(posedge clk) begin
        if (reset) begin
            x <= 0;
            index <= 0;
            value <= SEED;
        end else if (load_seed) begin
            x <= 0;
            index <= 0;
            value <= SEED;
        end else if (enable) begin
            x <= x_next;
            index <= index_next;
            value <= x_next ^ SEED;
        end
    end
endmodule
