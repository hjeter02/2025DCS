module Comb(
  // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
  // Output signals
	out_num0,
	out_num1
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [6:0] in_num0, in_num1, in_num2, in_num3;
output logic [7:0] out_num0, out_num1;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [6:0] xnor_num, or_num, and_num, xor_num, large_num1, small_num1, large_num2, small_num2;
logic [7:0] sum2;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
assign xnor_num = in_num0 ~^ in_num1;
assign or_num = in_num1 | in_num3;
assign and_num = in_num0 & in_num2;
assign xor_num = in_num2 ^ in_num3;

assign flag1 = xnor_num >= or_num;
assign flag2 = and_num >= xor_num;

assign large_num1 = (flag1)? xnor_num : or_num;
assign small_num1 = (flag1)? or_num : xnor_num;

assign large_num2 = (flag2)? and_num : xor_num;
assign small_num2 = (flag2)? xor_num : and_num;

assign out_num0 = large_num1 + large_num2;
assign sum2 = small_num1 + small_num2;

assign out_num1 = {
	sum2[7],
	sum2[6]^sum2[7],
	sum2[5]^sum2[6],
	sum2[4]^sum2[5],
	sum2[3]^sum2[4],
	sum2[2]^sum2[3],
	sum2[1]^sum2[2],
	sum2[0]^sum2[1]
	};


endmodule