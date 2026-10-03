module tb_sobol_sng;
parameter integer N=8; localparam integer CYCLES=(1<<N)-1;
reg clk,reset; reg [N-1:0] input_value;
wire [N-1:0] sobol_value; wire stochastic_bit; integer i,ones;
sobol #(.N(N)) GEN(.clk(clk),.reset(reset),.value(sobol_value));
sobol_sng #(.N(N)) DUT(.clk(clk),.reset(reset),.input_value(input_value),.stochastic_bit(stochastic_bit));
always #5 clk=~clk;
initial begin
 clk=0; reset=1; input_value=8'd64; ones=0; #12; reset=0;
 $display("=== Sobol SNG N=%0d input=%0d ===",N,input_value);
 for(i=0;i<CYCLES;i=i+1) begin
  @(negedge clk); ones=ones+stochastic_bit;
  if(i<8) $display("cycle=%0d sobol=%0d bit=%b",i+1,sobol_value,stochastic_bit);
 end
 $display("ones=%0d/%0d",ones,CYCLES); $finish;
end
endmodule
