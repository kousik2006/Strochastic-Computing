module tb_sc_adder_sobol_L32;
parameter integer N=8; localparam integer L=32;
reg clk,reset; reg [N-1:0] A,B; wire sum_bit; integer i,ones; real estimate,exact_sum;
sc_adder_sobol #(.N(N)) DUT(.clk(clk),.reset(reset),.A(A),.B(B),.sum_bit(sum_bit));
always #5 clk=~clk;
task run_case; input [N-1:0] a_in,b_in; begin
 A=a_in; B=b_in; ones=0; reset=1; @(negedge clk); reset=0;
 for(i=0;i<L;i=i+1) begin @(negedge clk); ones=ones+sum_bit; end
 exact_sum=(A+B)/2.0;
 estimate=(2.0*ones*((1<<N)-1))/L;
 $display("A=%0d B=%0d | ones=%0d/%0d | exact=%0.3f | estimate=%0.3f",A,B,ones,L,exact_sum,estimate);
end endtask
initial begin clk=0; reset=1; A=0; B=0; $display("=== Sobol SC Adder N=%0d L=%0d ===",N,L); #12;
 run_case(20,30); run_case(64,96); run_case(128,64); run_case(200,40); run_case(255,255); $finish; end
endmodule
