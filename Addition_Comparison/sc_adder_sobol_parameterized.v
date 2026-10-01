module sc_adder_sobol_parameterized #(
    parameter integer N = 8,
    parameter integer L = 32,
    parameter [N-1:0] SEED_A = 0,
    parameter [N-1:0] SEED_B = 8'd1,
    parameter [N-1:0] SEED_S = 8'd170
)(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire busy,
    output wire done,
    output wire stochastic_A,
    output wire stochastic_B,
    output wire stochastic_select,
    output wire stochastic_sum
);
    reg [N-1:0] A_reg, B_reg;
    reg busy_reg, done_reg;

    localparam [N-1:0] HALF_SCALE = {1'b1,{(N-1){1'b0}}};
    localparam integer COUNT_W = (L <= 1) ? 1 : $clog2(L+1);

    reg [COUNT_W-1:0] count;
    wire start_accept = start & ~busy_reg;

    wire [N-1:0] seq_A, seq_B, seq_S;

    sc_sng_sobol_parameterized #(.N(N), .SEED(SEED_A)) SNG_A (
        .clk(clk),
        .reset(reset),
        .load_seed(start_accept),
        .enable(busy_reg),
        .input_value(A_reg),
        .stochastic_bit(stochastic_A),
        .sequence_value(seq_A)
    );

    sc_sng_sobol_parameterized #(.N(N), .SEED(SEED_B)) SNG_B (
        .clk(clk),
        .reset(reset),
        .load_seed(start_accept),
        .enable(busy_reg),
        .input_value(B_reg),
        .stochastic_bit(stochastic_B),
        .sequence_value(seq_B)
    );

    sc_sobol_parameterized #(.N(N), .SEED(SEED_S)) SNG_SELECT (
        .clk(clk),
        .reset(reset),
        .load_seed(start_accept),
        .enable(busy_reg),
        .value(seq_S)
    );

    assign stochastic_select = (seq_S < HALF_SCALE);

    // MUX-based scaled addition, same arithmetic as the LFSR version.
    assign stochastic_sum = stochastic_select ? stochastic_A : stochastic_B;

    always @(posedge clk) begin
        if (reset) begin
            A_reg <= 0;
            B_reg <= 0;
            busy_reg <= 0;
            done_reg <= 0;
            count <= 0;
        end else begin
            done_reg <= 0;

            if (start_accept) begin
                A_reg <= A;
                B_reg <= B;
                busy_reg <= 1;
                count <= 0;
            end else if (busy_reg) begin
                if (count == L-1) begin
                    busy_reg <= 0;
                    done_reg <= 1;
                    count <= 0;
                end else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

    assign busy = busy_reg;
    assign done = done_reg;
endmodule
