module sc_adder_sobol #(parameter integer N=8)(input wire clk,input wire reset,input wire [N-1:0] A,input wire [N-1:0] B,output wire sum_bit);
wire A_bit,B_bit,select_bit;
sobol_sng #(.N(N)) SNG_A(.clk(clk),.reset(reset),.input_value(A),.stochastic_bit(A_bit));
sobol_sng #(.N(N)) SNG_B(.clk(clk),.reset(reset),.input_value(B),.stochastic_bit(B_bit));
select_toggle SELECT(.clk(clk),.reset(reset),.q(select_bit));
assign sum_bit=select_bit?A_bit:B_bit;
endmodule
