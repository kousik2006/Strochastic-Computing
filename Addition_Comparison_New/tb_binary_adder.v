module tb_binary_adder;
parameter integer N=8;
reg [N-1:0] A,B; wire [N:0] Sum; integer errors;
binary_adder #(.N(N)) DUT(.A(A),.B(B),.Sum(Sum));
task check; input [N-1:0] a_in,b_in; reg [N:0] expected; begin
 A=a_in; B=b_in; #1; expected={1'b0,A}+{1'b0,B};
 if(Sum!==expected) begin errors=errors+1; $display("FAIL A=%0d B=%0d Sum=%0d Expected=%0d",A,B,Sum,expected); end
 else $display("PASS A=%0d B=%0d Sum=%0d",A,B,Sum);
end endtask
initial begin
 errors=0; $display("=== Binary Adder N=%0d ===",N);
 check(0,0); check(1,2); check(20,30); check(64,96); check(127,129);
 check({N{1'b1}},{N{1'b1}});
 if(errors==0) $display("RESULT: PASS"); else $display("RESULT: FAIL (%0d errors)",errors);
 $finish;
end
endmodule
