module MAC(
	// Input signals
	clk,
	rst_n,
	in_valid,
	in_mode,
	in_act,
	in_wgt,
	// Output signals
	out_act_idx,
	out_wgt_idx,
	out_idx,
    out_valid,
	out_data,
	out_finish
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, in_mode;
input [0:7][3:0] in_act;
input [0:8][3:0] in_wgt;
output logic [3:0] out_act_idx, out_wgt_idx, out_idx;
output logic out_valid, out_finish;
output logic [0:7][11:0] out_data;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
//parameter ACT = ;
//parameter 

logic cs, ns;

logic mode;

//logic [3:0] out_act_idx_nxt, out_wgt_idx_nxt, out_idx_nxt;
logic [3:0] cnt_reg, cnt, cnt_nxt;

logic [0:7][0:7][3:0] in; // before zero padding
logic [0:9][0:9][3:0] act; // after zero padding
logic [0:8][3:0] wgt;

logic [0:7][0:8][3:0] a;
logic [0:8][3:0] w;
logic [0:7][11:0] d;

logic [0:7][11:0] data;
logic [2:0] out_cnt; // out_cnt_nxt;
logic out_valid_nxt;
//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------

//FSM
always @(*) begin
	case (cs)
	0: ns = (in_valid)? 1 : cs;
	1: ns = (out_finish)? 0 : cs;
	endcase
end
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cs <= 0;
	end else begin
		cs <= ns;
	end
end
//---------------------------------------------------------------------
//--access control

//mode
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		mode <= 0;
	end else if (in_valid) begin //update mode
		mode <= in_mode;
	//end else if (out_finish) begin
		//mode <= 0;
	end	else begin //store mode
		mode <= mode;
	end
end

//out_act_idx, out_wgt_idx
//assign out_act_idx[3] = 0;
//assign out_wgt_idx[3] = ~out_act_idx[3];
//assign push_act = (cnt >= 0) && (cnt <= 7);
//assign out_act_idx[2:0] = ((cnt >= 0) && (cnt <= 7))? cnt : 'bx; //only 0-7?
assign out_act_idx = cnt;
//assign out_wgt_idx[2:0] = ((cnt >= 7) && (cnt <= 14))? (cnt - 7) : 0; //mode is "don't care"
assign out_wgt_idx = cnt + 1;
//cnt
always @(*) begin
	if (in_valid) begin
		cnt_nxt = 0;
	end else if (cnt == 15) begin //
		cnt_nxt = 0;
	end else begin
		cnt_nxt = cnt + 1;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt <= 0;
		cnt_reg <= 0;
	end
	//else if (out_finish) //optional
	//	cnt <= 0;
	else begin
		cnt <= cnt_nxt;
		cnt_reg <= cnt;
	end
end

//---------------------------------------------------------------------
//--in act reg 2D array
genvar i;
genvar j;
generate
	for (i = 0; i < 8; i = i + 1) begin //row
		for (j = 0; j < 8; j = j + 1) begin //col
			always @(posedge clk or negedge rst_n) begin
				if (~rst_n) begin
					in[i][j] <= 0;
				end else if (i == out_act_idx) begin //sequential
					in[i][j] <= in_act[j];
				end else begin
					in[i][j] <= in[i][j]; //store
				end
			end
		end
	end
endgenerate

//---------------------------------------------------------------------
//--zero padding : act mapping 

generate
	for(i = 0;i<10; i = i+1)begin
		assign act[0][i] = 0;
		assign act[9][i] = 0;
		assign act[i][0] = 0;
		assign act[i][9] = 0;
	end
	// assign act[0][0] = 0;
	// assign act[9][0] = 0;
	// assign act[0][9] = 0;
	// assign act[9][9] = 0;
	for (i = 1; i < 9; i = i + 1) begin
		for (j = 1; j < 9; j = j + 1) begin
			assign act[i][j] = in[i-1][j-1];//((i == 0) || (i == 9) || (j == 0) || (j == 9))? 0 : in[i - 1][j - 1];
		end
	end
endgenerate


//---------------------------------------------------------------------
//--wgt

generate
	for (i = 0; i < 9; i = i + 1) begin ///???
		always @(posedge clk or negedge rst_n) begin //always push
			if (~rst_n) begin
				wgt[i] <= 0;
			end else begin
				wgt[i] <= in_wgt[i];
			end
		end
	end
endgenerate

//---------------------------------------------------------------------
//--act allocate

//a[n][m] 
always @(*) begin
	if (mode) begin //conv : n is col
		case (cnt - 2) //row
		0:begin //compute r0
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[0][n];
				a[n][1] = act[0][n + 1];
				a[n][2] = act[0][n + 2];
				a[n][3] = act[1][n];
				a[n][4] = act[1][n + 1];
				a[n][5] = act[1][n + 2];
				a[n][6] = act[2][n];
				a[n][7] = act[2][n + 1];
				a[n][8] = act[2][n + 2];
			end
		end
		1:begin //compute r1
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[1][n];
				a[n][1] = act[1][n + 1];
				a[n][2] = act[1][n + 2];
				a[n][3] = act[2][n];
				a[n][4] = act[2][n + 1];
				a[n][5] = act[2][n + 2];
				a[n][6] = act[3][n];
				a[n][7] = act[3][n + 1];
				a[n][8] = act[3][n + 2];
			end
		end
		2:begin //compute r2
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[2][n];
				a[n][1] = act[2][n + 1];
				a[n][2] = act[2][n + 2];
				a[n][3] = act[3][n];
				a[n][4] = act[3][n + 1];
				a[n][5] = act[3][n + 2];
				a[n][6] = act[4][n];
				a[n][7] = act[4][n + 1];
				a[n][8] = act[4][n + 2];
			end
		end
		3:begin //compute r1
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[3][n];
				a[n][1] = act[3][n + 1];
				a[n][2] = act[3][n + 2];
				a[n][3] = act[4][n];
				a[n][4] = act[4][n + 1];
				a[n][5] = act[4][n + 2];
				a[n][6] = act[5][n];
				a[n][7] = act[5][n + 1];
				a[n][8] = act[5][n + 2];
			end
		end
		4:begin //compute r1
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[4][n];
				a[n][1] = act[4][n + 1];
				a[n][2] = act[4][n + 2];
				a[n][3] = act[5][n];
				a[n][4] = act[5][n + 1];
				a[n][5] = act[5][n + 2];
				a[n][6] = act[6][n];
				a[n][7] = act[6][n + 1];
				a[n][8] = act[6][n + 2];
			end
		end
		5:begin //compute r1
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[5][n];
				a[n][1] = act[5][n + 1];
				a[n][2] = act[5][n + 2];
				a[n][3] = act[6][n];
				a[n][4] = act[6][n + 1];
				a[n][5] = act[6][n + 2];
				a[n][6] = act[7][n];
				a[n][7] = act[7][n + 1];
				a[n][8] = act[7][n + 2];
			end
		end
		6:begin //compute r1
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[6][n];
				a[n][1] = act[6][n + 1];
				a[n][2] = act[6][n + 2];
				a[n][3] = act[7][n];
				a[n][4] = act[7][n + 1];
				a[n][5] = act[7][n + 2];
				a[n][6] = act[8][n];
				a[n][7] = act[8][n + 1];
				a[n][8] = act[8][n + 2];
			end
		end
		7:begin //compute r1
			for (integer n = 0; n < 8; n = n + 1) begin
				a[n][0] = act[7][n];
				a[n][1] = act[7][n + 1];
				a[n][2] = act[7][n + 2];
				a[n][3] = act[8][n];
				a[n][4] = act[8][n + 1];
				a[n][5] = act[8][n + 2];
				a[n][6] = act[9][n];
				a[n][7] = act[9][n + 1];
				a[n][8] = act[9][n + 2];
			end
		end
		default:begin //no allocation for conv. mode
			for (integer n = 0; n < 8; n = n + 1) begin
				for (integer m = 0; m < 9; m = m + 1) begin
					a[n][m] = 0;
				end
			end
		end
		endcase
	end else begin //mult : n is row
		for (integer n = 0; n < 8; n = n + 1) begin
			for (integer m = 0; m < 9; m = m + 1) begin
				a[n][m] = act [n + 1][m + 1];
			end
		end
	end
end

generate
	for (i = 0; i < 9; i = i + 1) begin
		always @(*) begin
			w[i] = wgt[i]; // conv
			if (~mode) begin // mult
				if (i == 8) begin
					w[i] = 0;
				end
			end
		end
	end
endgenerate
//---------------------------------------------------------------------
//--process
genvar n;
generate
	for (n = 0; n < 8; n = n + 1) begin //72 PE
		always @(*) begin
			data[n] =  a[n][0]*w[0] + a[n][1]*w[1] + a[n][2]*w[2] + a[n][3]*w[3] + a[n][4]*w[4] + a[n][5]*w[5] + a[n][6]*w[6] + a[n][7]*w[7] + a[n][8]*w[8];
		end
	end
endgenerate

//---------------------------------------------------------------------
//--output

//out data
generate
	for (i = 0; i < 8; i = i + 1) begin
		always @(posedge clk or negedge rst_n) begin
			if (~rst_n) begin //reset
				out_data[i] <= 0;
			end else begin //get output
				out_data[i] <= data[i];
			end
		end
	end
endgenerate

//out_cnt
assign out_cnt = (mode)? (cnt - 2) : (cnt - 8); //conv : mult
/*
always @(*) begin
	if (out_cnt == 7) begin //
		out_cnt_nxt = 0;
	end else if (out_finish) begin
		out_cnt_nxt = 0;
	end else if begin
		out_cnt_nxt = out_cnt + 1;
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		out_cnt <= 0;
	else 
		out_cnt <= out_cnt_nxt;
end
*/

//out valid
//assign out_valid_nxt = (mode)? ((cnt >= 2) && (cnt <= 9)) : ((cnt >= 8) && (cnt <= 15));
always @(*) begin
	out_valid_nxt = 0;
	if (in_valid) begin
		out_valid_nxt = 0;
	end else if (mode && cs) begin //conv mode
		out_valid_nxt = ((cnt >= 2) && (cnt <= 9));
	end else if (~mode && cs) begin //mult mode
		out_valid_nxt = ((cnt >= 8) && (cnt <= 15));
	end
end
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin //reset
		out_valid <= 0;
	end else begin //
		out_valid <= out_valid_nxt;
	end 
end
//assign out_valid_nxt = (mode)? ((cnt >= 2) && (cnt <= 9)) : ((cnt >= 8) && (cnt <= 15));
/*
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin //reset
		out_valid <= 0;
	end else begin //conv 
		out_valid <= (mode)? ((cnt >= 2) && (cnt <= 9)) : ((cnt >= 8) && (cnt <= 15));
	end 
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin //reset
		out_valid <= 0;
	end else if (mode) begin //conv mode
		out_valid <= ((cnt >= 2) && (cnt <= 9));
	end else begin //mult mode
		out_valid <= ((cnt >= 8) && (cnt <= 15));
	end
end
*/

//out_idx
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		out_idx[2:0] <= 0;
	end else begin
		out_idx[2:0] <= out_cnt; //conv : mult
	end
end
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		out_idx[3] <= 0;
	end else begin
		out_idx[3] <= ~mode; //conv : mult
	end
end

//out finish
always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		out_finish <= 0;
	end else begin
		out_finish <= out_valid && (out_cnt == 7); //conv : mult
	end
end
//assign out_finish = (out_cnt == 0);

endmodule
/*
module PE (
	a,
	w,
	d
);
input [3:0]a;
input [3:0]w;
output logic [11:0]d;
endmodule
*/