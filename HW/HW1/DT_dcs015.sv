module DT(
    // Input signals
	in_n0,
	in_n1,
	in_n2,
	in_n3,
    // Output signals
    out_n0,
    out_n1,
    out_n2,
    out_n3,
    out_n4,
	ack_n0,
	ack_n1,
	ack_n2,
	ack_n3
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [19:0] in_n0, in_n1, in_n2, in_n3;
output logic [17:0] out_n0, out_n1, out_n2, out_n3, out_n4;
output logic ack_n0, ack_n1, ack_n2, ack_n3;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
//logic in_valid_n0, in_valid_n1, in_valid_n2, in_valid_n3;
//logic [2:0] dest_n0, dest_n1, dest_n2, dest_n3;
//logic [15:0] data_in_n0, data_in_n1, data_in_n2, data_in_n3;
logic [3:0] dist_out_n0, dist_out_n1, dist_out_n2, dist_out_n3, dist_out_n4;
logic [1:0] sum_out0, sum_out1, sum_out2, sum_out3, sum_out4;
logic [4:0] use_n0;  // use_n0[i] = 1 表示 out_n0 用了 in_i

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
//decode
//in_valid_n = in_n[19]
//dest_n = in_n[18:16]
//data_in_n = in_n[15:0]

//condition_n = out_n[17:16]

/*always_comb begin : decode
	in_valid_n0 = in_n0[19];
	in_valid_n0 = in_n0[19];
	in_valid_n0 = in_n0[19];
	in_valid_n0 = in_n0[19];
end
*/

///mapping///
always_comb begin
	//dest = 000
	dist_out_n0 = {
		in_n3[19] & (~in_n3[18]) & (~in_n3[17]) & (~in_n3[16]),
	    in_n2[19] & (~in_n2[18]) & (~in_n2[17]) & (~in_n2[16]),
		in_n1[19] & (~in_n1[18]) & (~in_n1[17]) & (~in_n1[16]),
		in_n0[19] & (~in_n0[18]) & (~in_n0[17]) & (~in_n0[16])
	};
	//dest = 001
	dist_out_n1 = {
		in_n3[19] & (~in_n3[18]) & (~in_n3[17]) & (in_n3[16]),
	    in_n2[19] & (~in_n2[18]) & (~in_n2[17]) & (in_n2[16]),
		in_n1[19] & (~in_n1[18]) & (~in_n1[17]) & (in_n1[16]),
		in_n0[19] & (~in_n0[18]) & (~in_n0[17]) & (in_n0[16])
	};
	//dest = 010
	dist_out_n2 = {
		in_n3[19] & (in_n3[17]) & (~in_n3[16]),
	    in_n2[19] & (in_n2[17]) & (~in_n2[16]),
		in_n1[19] & (in_n1[17]) & (~in_n1[16]),
		in_n0[19] & (in_n0[17]) & (~in_n0[16])
	};
	//dest = 011
	dist_out_n3 = {
		in_n3[19] & (in_n3[17]) & (in_n3[16]),
	    in_n2[19] & (in_n2[17]) & (in_n2[16]),
		in_n1[19] & (in_n1[17]) & (in_n1[16]),
		in_n0[19] & (in_n0[17]) & (in_n0[16])
	};
	//dest = 100
	dist_out_n4 = {
		in_n3[19] & (in_n3[18]),
	    in_n2[19] & (in_n2[18]),
		in_n1[19] & (in_n1[18]),
		in_n0[19] & (in_n0[18])
	};
end

//sum
assign sum_out0 = (dist_out_n0[3] + dist_out_n0[2]) + (dist_out_n0[1] + dist_out_n0[0]);
//assign sum_out0 = {&dist_out_n0, (~dist_out_n0[3])&dist_out_n0[2]&dist_out_n0[0] | dist_out_n0[3]&(~dist_out_n0[1])&dist_out_n0[0] | dist_out_n0[3]&dist_out_n0[2]&(~dist_out_n0[0]) |
					//dist_out_n0[3]&(~dist_out_n0[2])&dist_out_n0[1] | (~dist_out_n0[3])&dist_out_n0[2]&dist_out_n0[1] | (~dist_out_n0[2])&dist_out_n0[1]&dist_out_n0[0], ^dist_out_n0};
assign sum_out1 = (dist_out_n1[3] + dist_out_n1[2]) + (dist_out_n1[1] + dist_out_n1[0]);
//assign sum_out1 = {&dist_out_n1, (~dist_out_n1[3])&dist_out_n1[2]&dist_out_n1[0] | dist_out_n1[3]&(~dist_out_n1[1])&dist_out_n1[0] | dist_out_n1[3]&dist_out_n1[2]&(~dist_out_n1[0]) |
					//dist_out_n1[3]&(~dist_out_n1[2])&dist_out_n1[1] | (~dist_out_n1[3])&dist_out_n1[2]&dist_out_n1[1] | (~dist_out_n1[2])&dist_out_n1[1]&dist_out_n1[0], ^dist_out_n1};
assign sum_out2 = (dist_out_n2[3] + dist_out_n2[2]) + (dist_out_n2[1] + dist_out_n2[0]);
//assign sum_out2 = {&dist_out_n2, (~dist_out_n2[3])&dist_out_n2[2]&dist_out_n2[0] | dist_out_n2[3]&(~dist_out_n2[1])&dist_out_n2[0] | dist_out_n2[3]&dist_out_n2[2]&(~dist_out_n2[0]) |
					//dist_out_n2[3]&(~dist_out_n2[2])&dist_out_n2[1] | (~dist_out_n2[3])&dist_out_n2[2]&dist_out_n2[1] | (~dist_out_n2[2])&dist_out_n2[1]&dist_out_n2[0], ^dist_out_n2};
assign sum_out3 = (dist_out_n3[3] + dist_out_n3[2]) + (dist_out_n3[1] + dist_out_n3[0]);
//assign sum_out3 = {&dist_out_n3, (~dist_out_n3[3])&dist_out_n3[2]&dist_out_n3[0] | dist_out_n3[3]&(~dist_out_n3[1])&dist_out_n3[0] | dist_out_n3[3]&dist_out_n3[2]&(~dist_out_n3[0]) |
					//dist_out_n3[3]&(~dist_out_n3[2])&dist_out_n3[1] | (~dist_out_n3[3])&dist_out_n3[2]&dist_out_n3[1] | (~dist_out_n3[2])&dist_out_n3[1]&dist_out_n3[0], ^dist_out_n3};
assign sum_out4 = (dist_out_n4[3] + dist_out_n4[2]) + (dist_out_n4[1] + dist_out_n4[0]);
//assign sum_out4 = {&dist_out_n4, (~dist_out_n4[3])&dist_out_n4[2]&dist_out_n4[0] | dist_out_n4[3]&(~dist_out_n4[1])&dist_out_n4[0] | dist_out_n4[3]&dist_out_n4[2]&(~dist_out_n4[0]) |
					//dist_out_n4[3]&(~dist_out_n4[2])&dist_out_n4[1] | (~dist_out_n4[3])&dist_out_n4[2]&dist_out_n4[1] | (~dist_out_n4[2])&dist_out_n4[1]&dist_out_n4[0], ^dist_out_n4};

///destination///
//assign out_n0[17:16] = {sum_out0[2]|sum_out0[1], (~sum_out0[1])&sum_out0[0]};
//assign out_n1[17:16] = {sum_out1[2]|sum_out1[1], (~sum_out1[1])&sum_out1[0]};
//assign out_n2[17:16] = {sum_out2[2]|sum_out2[1], (~sum_out2[1])&sum_out2[0]};
//assign out_n3[17:16] = {sum_out3[2]|sum_out3[1], (~sum_out3[1])&sum_out3[0]};
//assign out_n4[17:16] = {sum_out4[2]|sum_out4[1], (~sum_out4[1])&sum_out4[0]};
/*
always_comb begin
	//dest0
	//out_n0[17:16] = 2'b00;
	if (sum_out0 < 2) begin
		out_n0[17:16] = sum_out0;
	end
	else begin
		out_n0[17:16] = 2'b10;
	end
end
always_comb begin
	//dest1
	//out_n1[17:16] = 2'b00;
	if (sum_out1 < 2) begin
		out_n1[17:16] = sum_out1;
	end
	else begin
		out_n1[17:16] = 2'b10;
	end
end

always_comb begin
	//dest2
	//out_n2[17:16] = 2'b00;
	if (sum_out2 < 2) begin
		out_n2[17:16] = sum_out2;
	end
	else begin
		out_n2[17:16] = 2'b10;
	end
end
always_comb begin
	//dest3
	//out_n3[17:16] = 2'b00;
	if (sum_out3 < 2) begin
		out_n3[17:16] = sum_out3;
	end
	else begin
		out_n3[17:16] = 2'b10;
	end
end

always_comb begin
	//dest4
	//out_n4[17:16] = 2'b00;
	if (sum_out4 < 2) begin
		out_n4[17:16] = sum_out4;
	end
	else begin
		out_n4[17:16] = 2'b10;
	end
end
*/
always_comb begin
    // default
    //out_n0[17:16] = 2'b00;
    //out_n1[17:16] = 2'b00;
    //out_n2[17:16] = 2'b00;
    //out_n3[17:16] = 2'b00;
    //out_n4[17:16] = 2'b00;

    // sum_out0 ~ sum_out4
    out_n0[17:16] = ((dist_out_n0[3] + dist_out_n0[2]) + (dist_out_n0[1] + dist_out_n0[0]) < 2) ? sum_out0[1:0] : 2'b10;
    out_n1[17:16] = ((dist_out_n1[3] + dist_out_n1[2]) + (dist_out_n1[1] + dist_out_n1[0]) < 2) ? sum_out1[1:0] : 2'b10;
    out_n2[17:16] = ((dist_out_n2[3] + dist_out_n2[2]) + (dist_out_n2[1] + dist_out_n2[0]) < 2) ? sum_out2[1:0] : 2'b10;
    out_n3[17:16] = ((dist_out_n3[3] + dist_out_n3[2]) + (dist_out_n3[1] + dist_out_n3[0]) < 2) ? sum_out3[1:0] : 2'b10;
    out_n4[17:16] = ((dist_out_n4[3] + dist_out_n4[2]) + (dist_out_n4[1] + dist_out_n4[0]) < 2) ? sum_out4[1:0] : 2'b10;
end

///data out///
always_comb begin
	out_n0[15:0] = 0;
	ack_n0 = 0;
	ack_n1 = 0;
	ack_n2 = 0;
	ack_n3 = 0;
	if (dist_out_n0[0] == 1) begin
		out_n0[15:0] = in_n0[15:0];
		ack_n0 = 1;
	end
	else if (dist_out_n0[1] == 1) begin
		out_n0[15:0] = in_n1[15:0];
		ack_n1 = 1;
	end
	else if (dist_out_n0[2] == 1) begin
		out_n0[15:0] = in_n2[15:0];
		ack_n2 = 1;
	end
	else if (dist_out_n0[3] == 1) begin
		out_n0[15:0] = in_n3[15:0];
		ack_n3 = 1;
	end

	out_n1[15:0] = 0;
	if (dist_out_n1[0] == 1) begin
		out_n1[15:0] = in_n0[15:0];
		ack_n0 = 1;
	end
	else if (dist_out_n1[1] == 1) begin
		out_n1[15:0] = in_n1[15:0];
		ack_n1 = 1;
	end
	else if (dist_out_n1[2] == 1) begin
		out_n1[15:0] = in_n2[15:0];
		ack_n2 = 1;
	end
	else if (dist_out_n1[3] == 1) begin
		out_n1[15:0] = in_n3[15:0];
		ack_n3 = 1;
	end

	out_n2[15:0] = 0;
	if (dist_out_n2[0] == 1) begin
		out_n2[15:0] = in_n0[15:0];
		ack_n0 = 1;
	end
	else if (dist_out_n2[1] == 1) begin
		out_n2[15:0] = in_n1[15:0];
		ack_n1 = 1;
	end
	else if (dist_out_n2[2] == 1) begin
		out_n2[15:0] = in_n2[15:0];
		ack_n2 = 1;
	end
	else if (dist_out_n2[3] == 1) begin
		out_n2[15:0] = in_n3[15:0];
		ack_n3 = 1;
	end

	out_n3[15:0] = 0;
	if (dist_out_n3[0] == 1) begin
		out_n3[15:0] = in_n0[15:0];
		ack_n0 = 1;
	end
	else if (dist_out_n3[1] == 1) begin
		out_n3[15:0] = in_n1[15:0];
		ack_n1 = 1;
	end
	else if (dist_out_n3[2] == 1) begin
		out_n3[15:0] = in_n2[15:0];
		ack_n2 = 1;
	end
	else if (dist_out_n3[3] == 1) begin
		out_n3[15:0] = in_n3[15:0];
		ack_n3 = 1;
	end

	out_n4[15:0] = 0;
	if (dist_out_n4[0] == 1) begin
		out_n4[15:0] = in_n0[15:0];
		ack_n0 = 1;
	end
	else if (dist_out_n4[1] == 1) begin
		out_n4[15:0] = in_n1[15:0];
		ack_n1 = 1;
	end
	else if (dist_out_n4[2] == 1) begin
		out_n4[15:0] = in_n2[15:0];
		ack_n2 = 1;
	end
	else if (dist_out_n4[3] == 1) begin
		out_n4[15:0] = in_n3[15:0];
		ack_n3 = 1;
	end
end

endmodule

