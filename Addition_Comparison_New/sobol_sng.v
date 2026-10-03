module sobol_sng #(parameter integer N=8)(input wire clk,input wire reset,input wire [N-1:0] input_value,output wire stochastic_bit);
wire [N-1:0] sobol_value;
sobol #(.N(N)) GEN(.clk(clk),.reset(reset),.value(sobol_value));
assign stochastic_bit=(sobol_value<=input_value);
endmodule
