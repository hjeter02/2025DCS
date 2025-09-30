module TA(
    clk, 
	rst_n, 
	// input 
	i_valid, 
	i_length,
	m_ready,
	// virtual memory
	m_data,
	m_read,
	m_addr,
	// output 
	o_valid, 
	o_data 
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n; 
// input
input i_valid; 
input [1:0] i_length;
input m_ready;
// virtual memory
input [31:0] m_data; 
output logic m_read;
output logic  [5:0] m_addr; 
// output 
output logic o_valid; 
output logic [40:0] o_data; 


logic [5:0] cs, ns;
logic [4:0] cnt, cnt_nxt, ccnt;
logic [4:0] cntt, cntt_nxt;

parameter IDLE = 0;//3'b000;
parameter I_TOKEN = 1;//3'b001;
//parameter WAIT1 = 2;
//parameter WAIT2 = 3;
parameter WQ = 2;//3'b010;//3'b011;
//parameter WAIT3 = 5;
parameter WK = 3;//3'b011;//3'b111;
//parameter WAIT4 = 7;
//parameter WV = 8;
//parameter WAIT5 = 9;
parameter QKT = 4;//3'b100;//3'b101;
//parameter WAIT6 = 11;
//parameter MM = 12;
//parameter WAIT7 = 13;
parameter V = 5;//3'b101;//3'b100;

logic [1:0] length, length_nxt;
logic m_ready_f;
logic m_read_nxt;
logic [3:0] in_data [0:7];

logic [3:0] token [0:31][0:7];
logic [3:0] token_nxt [0:31][0:7];
logic [9:0] q [0:31][0:7];
logic [9:0] q_nxt [0:31][0:7];
logic [10:0] k [0:31][0:7];
logic [10:0] k_nxt [0:31][0:7];
logic [10:0] v [0:31][0:7];
logic [10:0] v_nxt [0:31][0:7];

logic [21:0] score [0:31][0:31]; ///////!!!
logic [21:0] score_nxt [0:31][0:31];

//MM2
logic [21:0] c [0:31];
logic [10:0] d [0:31];
logic [35:0] result0, result1, result2, result3;
logic [35:0] result_nxt, result;

logic o_valid_nxt;
//logic [40:0] vector [0:7];
//logic [40:0] vector_nxt [0:7];
//logic [40:0] o_data_nxt;

logic [35:0] o_token [0:6];
logic [35:0] o_token_nxt [0:6];
//logic i_valid_f;

//logic [7:0] pcnt, pcnt_nxt;

//p cnt
// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         pcnt <= 0;
//     else 
//         pcnt <= pcnt_nxt;
// end
// always @(*) begin
//     pcnt_nxt = pcnt;
//     if (i_valid) begin
//         pcnt_nxt = pcnt + 1;
//     end
// end


//FSM1
//---------------------------------------------------------------------
always @(*) begin
	case (cs)
	IDLE: ns = (m_ready_f)? I_TOKEN : cs;
	I_TOKEN: begin //1
		case (length)
		0: ns = (cnt == 3)? WQ : cs; //l + 3
		1: ns = (cnt == 7)? WQ : cs;
		2: ns = (cnt == 15)? WQ : cs;
		3: ns = (cnt == 31)? WQ : cs;
		endcase
	end
	//WAIT1: ns = WAIT2; //2
	//WAIT2: ns = WQ; //3
	//W: ns = (cnt == 25)? QKT : cs; //23 + 2
	WQ: ns = (cnt == 8)? WK : cs; //4
	//WAIT3: ns = WK;
	WK: ns = (cnt == 8)? QKT : cs; //6
	//WAIT4: ns = WV;
	//WV: ns = (cnt == 8)? WAIT5 : cs; //8
	//WAIT5: ns = QKT;
	QKT: begin //10
		case (length)
		0: ns = (cnt == 3)? V : cs;
		1: ns = (cnt == 7)? V : cs;
		2: ns = (cnt == 15)? V : cs;
		3: ns = (cnt == 31)? V : cs;
		endcase
	end
	//WAIT6: ns = V;
	//MM: begin //12
		//ns = (cnt == 7)? WAIT7 : cs;
		// case (length)
		// 0: ns = (cnt == 4)? V : cs;
		// 1: ns = (cnt == 8)? V : cs;
		// 2: ns = (cnt == 16)? V : cs;
		// 3: ns = (cnt == 32)? V : cs;
		// endcase
	//end
	//WAIT7: ns = V;
	V: ns = (cnt == 16)? IDLE : cs; //14
	default: ns = cs;
	endcase
end

//cnt
always @(*) begin
	if (ns != cs) begin
		cnt_nxt = 0;
	end else begin
		cnt_nxt = cnt + 1;
	end
end

always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		cs <= 0;
		cnt <= 0;
		//i_valid_f <= 0;
		//cntt <= 0;
	end else begin
		cs <= ns;
		cnt <= cnt_nxt;
		//i_valid_f <= i_valid;
		//cntt <= cntt_nxt;
	end
end

always @(*) begin
	case (length)
	0: ccnt = (3 - cnt);
	1: ccnt = (7 - cnt);
	2: ccnt = (15 - cnt);
	3: ccnt = (31 - cnt);
	endcase
end

//length
//---------------------------------------------------------------------

assign length_nxt = (i_valid)? i_length : length; /////
always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		length <= 0;
	end else begin
		length <= length_nxt;
	end
end

//m_read, m_addr , m_data
//---------------------------------------------------------------------

always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		m_ready_f <= 0;
	end
	else if (m_ready) begin
		m_ready_f <= m_ready;
	end
	else if (cs == V) begin
		m_ready_f <= 0;
	end
end

always @(*) begin
	m_read = 0;
	if (cs == I_TOKEN) begin
		m_read = 1;
	end
	else if (((cs == WQ) || (cs == WK) || (cs == V)) && (cnt <=7)) begin
		m_read = 1;
	end
end
always @(*) begin
	m_addr = 0;
	if (cs == I_TOKEN) begin
		//m_addr = cnt;
		case (length)
		0: m_addr = 3 - cnt;
		1: m_addr = 7 - cnt;
		2: m_addr = 15 - cnt;
		3: m_addr = 31 - cnt;
		endcase
	end
	else if (cs == WQ) begin
		case (length)
		0: m_addr = 11 - cnt;//7 - cnt + 4;
		1: m_addr = 15 - cnt;//7 - cnt + 8;
		2: m_addr = 23 - cnt;//7 - cnt + 16;
		3: m_addr = 39 - cnt;//7 - cnt + 32;
		endcase
	end
	else if (cs == WK) begin
		case (length)
		0: m_addr = 19 - cnt;//7 - cnt + 12;
		1: m_addr = 23 - cnt;//7 - cnt + 16;
		2: m_addr = 31 - cnt;//7 - cnt + 24;
		3: m_addr = 47 - cnt;//7 - cnt + 40;
		endcase
	end
	else if (cs == V) begin
		case (length)
		0: m_addr = 20 + cnt;//27 - cnt;//7 - cnt + 20;
		1: m_addr = 24 + cnt;//31 - cnt;//7 - cnt + 24;
		2: m_addr = 32 + cnt;//39 - cnt;//7 - cnt + 32;
		3: m_addr = 48 + cnt;//55 - cnt;//7 - cnt + 48;
		endcase
	end
end
always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		in_data[7] <= 0;
		in_data[6] <= 0;
		in_data[5] <= 0;
		in_data[4] <= 0;
		in_data[3] <= 0;
		in_data[2] <= 0;
		in_data[1] <= 0;
		in_data[0] <= 0;
	end
	else begin
		in_data[7] <= m_data[3:0];
		in_data[6] <= m_data[7:4];
		in_data[5] <= m_data[11:8];
		in_data[4] <= m_data[15:12];
		in_data[3] <= m_data[19:16];
		in_data[2] <= m_data[23:20];
		in_data[1] <= m_data[27:24];
		in_data[0] <= m_data[31:28];
	end
end




//MM
//---------------------------------------------------------------------

logic [10:0] a [0:31][0:7];
logic [10:0] b [0:7];
logic [21:0] product_tmp [0:31];
logic [21:0] product [0:31];

genvar i, j;

generate
for (i = 0; i < 32; i = i + 1) begin
	for (j = 0; j < 8; j = j + 1) begin
		always @(*) begin //input logic
			a[i][j] = 0;
			if ((cs == WQ) || (cs == WK) || (cs == V)) begin
				a[i][j] = token[i][j];
			end
			if ((cs == QKT)) begin
				a[i][j] = q[i][j];
			end
		end
	end
end
endgenerate
generate
for (i = 0; i < 8; i = i + 1) begin
	always @(*) begin
		b[i] = 0;
		if ((cs == WQ) || (cs == WK) || (cs == V)) begin
			b[i] = in_data[i];
		end
		else if ((cs == QKT)) begin
			b[i] = k[ccnt][i];
		end
	end
end
endgenerate
generate
for (i = 0; i < 32; i = i + 1) begin	
	always @(*) begin
		product_tmp[i] = ((a[i][0] * b[0] + a[i][1] * b[1]) + (a[i][2] * b[2] + a[i][3] * b[3])) + ((a[i][4] * b[4] + a[i][5] * b[5]) + (a[i][6] * b[6] + a[i][7] * b[7]));
	end
	always @(posedge clk) begin
	//for (integer i = 0; i < 32; i = i + 1) begin
	// if (~rst_n) begin
	// 	for (integer i = 0; i < 32; i = i + 1) begin
	// 		product[i] <= 0;
	// 	end
	// end else begin
		//for (integer i = 0; i < 32; i = i + 1) begin
			product[i] <= product_tmp[i];
		//end
	//end
	end	
end
endgenerate



//MM2//
//---------------------------------------------------------------------
generate
for (i = 0; i < 32; i = i + 1) begin	
	always @(*) begin
		case (length)
		0: c[i] = score[3][i];
		1: c[i] = score[7][i];
		2: c[i] = score[15][i];
		3: c[i] = score[31][i];
		endcase
	end
	always @(*) begin
	//for (integer i = 0; i < 32; i = i + 1) begin
		d[i] = product[i];//v[i][cnt];
	end
end
endgenerate
always @(*) begin
	result0 = ((c[0] * d[0] + c[1] * d[1]) + (c[2] * d[2] + c[3] * d[3])) + ((c[4] * d[4] + c[5] * d[5]) + (c[6] * d[6] + c[7] * d[7]));
	result1 = ((c[8] * d[8] + c[9] * d[9]) + (c[10] * d[10] + c[11] * d[11])) + ((c[12] * d[12] + c[13] * d[13]) + (c[14] * d[14] + c[15] * d[15]));
	result2 = ((c[16] * d[16] + c[17] * d[17]) + (c[18] * d[18] + c[19] * d[19])) + ((c[20] * d[20] + c[21] * d[21]) + (c[22] * d[22] + c[23] * d[23]));
	result3 = ((c[24] * d[24] + c[25] * d[25]) + (c[26] * d[26] + c[27] * d[27])) + ((c[28] * d[28] + c[29] * d[29]) + (c[30] * d[30] + c[31] * d[31]));
	result_nxt =  result0 + result1 + result2 + result3;
end

//AT
//---------------------------------------------------------------------

logic [21:0] at_in [0:31];
logic [21:0] at_in_nxt [0:31];
logic [25:0] acc0 [0:7];
logic [25:0] acc1 [0:1];
logic [26:0] sum;
logic [21:0] mean;
logic [21:0] at_out [0:31];

generate
for (i = 0; i < 32; i = i + 1) begin	
	always @(*) begin //at_in logic
		at_in[i] = 0;
		if ((cs == I_TOKEN) || ((cs == WQ) && (cnt == 0))) begin
			if (i <= 7)
				at_in[i] = in_data[i];
			else 
				at_in[i] = 0;
		end
		else if ((cs == QKT) || ((cs == V) && (cnt == 0))) begin
			at_in[i] = product[i];
		end
	end
end
endgenerate

generate
for (i = 0; i < 8; i = i + 1) begin	
	always @(*) begin
		acc0[i] = (at_in[4*i] + at_in[(4*i) + 1]) + (at_in[(4*i) + 2] + at_in[(4*i) + 3]);
	end
end
endgenerate
always @(*) begin
	acc1[0] = (acc0[0] + acc0[1]) + (acc0[2] + acc0[3]);
	acc1[1] = (acc0[4] + acc0[5]) + (acc0[6] + acc0[7]);
	sum = acc1[0] + acc1[1];
end

always @(*) begin //mean logic
	if ((cs == I_TOKEN) || ((cs == WQ) && (cnt == 0))) begin
		//size = 8; //>>3;
		mean = sum >> 3;
	end
	else begin
		case (length)
		0: mean = sum >> 2;//size = 4; //>>2;
		1: mean = sum >> 3;//size = 8; //>>3;
		2: mean = sum >> 4;//size = 16;//>>4;
		3: mean = sum >> 5;//size = 32;//>>5;
		endcase
	end
end
generate
for (i = 0; i < 32; i = i + 1) begin	
	always @(*) begin
        at_out[i] = (at_in[i] >= mean)? at_in[i] : 0; //at_in_ff
    end   
end 
endgenerate
//token//
//---------------------------------------------------------------------
generate
for (i = 0; i < 32; i = i + 1) begin /////
	for (j = 0; j < 8; j = j + 1) begin
		always @(*) begin
			token_nxt[i][j] = token[i][j];
			if (((cs == I_TOKEN) && (cnt != 0)) || ((cs == WQ) && (cnt == 0))) begin
				if (i == 0)
					token_nxt[i][j] = at_out[j]; //left: 0th col -> row, right: 1 row!!!!!!////////
				else
					token_nxt[i][j] = token[i-1][j];
			end
			else if (i_valid) begin
				token_nxt[i][j] = 0;
			end
		end
		always @(posedge clk) begin
				token[i][j] <= token_nxt[i][j];
		end
	end
end
endgenerate
//q//
//---------------------------------------------------------------------
generate
for (i = 0; i < 32; i = i + 1) begin /////
	for (j = 0; j < 8; j = j + 1) begin
		always @(*) begin
			q_nxt[i][j] = q[i][j];
			if ((cs == WQ)) begin
				if (j == 0)
					q_nxt[i][j] = product_tmp[i]; //left: 0th col -> row, right: 1 row!!!!!!////////
				else
					q_nxt[i][j] = q[i][j-1];
			end
			else if (i_valid) begin
				q_nxt[i][j] = 0;
			end
		end
		always @(posedge clk) begin
			q[i][j] <= q_nxt[i][j];
		end
	end
end
endgenerate
//k//
//---------------------------------------------------------------------
generate
for (i = 0; i < 32; i = i + 1) begin /////
	for (j = 0; j < 8; j = j + 1) begin
		always @(*) begin
			k_nxt[i][j] = k[i][j];
			if ((cs == WK)) begin
				if (j == 0)
					k_nxt[i][j] = product_tmp[i]; //left: 0th col -> row, right: 1 row!!!!!!////////
				else
					k_nxt[i][j] = k[i][j-1];
			end
			else if (i_valid) begin
				k_nxt[i][j] = 0;
			end
		end
		always @(posedge clk) begin
				k[i][j] <= k_nxt[i][j];
		end
	end
end
endgenerate
//score//
//---------------------------------------------------------------------
generate
for (i = 0; i < 32; i = i + 1) begin /////
	for (j = 0; j < 32; j = j + 1) begin
		always @(*) begin
			if (((cs == QKT) && (cnt != 0)) ||((cs == V) && (cnt == 0))) begin
				if (j == 0)
					score_nxt[i][j] = at_out[i];
				else
					score_nxt[i][j] = score[i][j-1];
			end
			else if (i_valid) begin
				score_nxt[i][j] = 0;
			end
			else begin
				score_nxt[i][j] = score[i][j];
			end
		end
		always @(posedge clk) begin
				score[i][j] <= score_nxt[i][j];
		end
	end
end
endgenerate

//output logic//
//---------------------------------------------------------------------

always @(*) begin
	for (integer i = 0; i < 7; i = i + 1) begin
		o_token_nxt[i] = 0;
	end
	if ((cs == V) && (cnt >= 2)) begin
			o_token_nxt[0] = result_nxt;
			o_token_nxt[1] = o_token[0];
			o_token_nxt[2] = o_token[1];
			o_token_nxt[3] = o_token[2];
			o_token_nxt[4] = o_token[3];
			o_token_nxt[5] = o_token[4];
			o_token_nxt[6] = o_token[5];
	end
end
always @(posedge clk) begin
		for (integer i = 0; i < 7; i = i + 1) begin
			o_token[i] <= o_token_nxt[i];
		end
	//end
end

assign o_valid = ((cs == V) && (cnt >= 9)); ////

assign o_data = (o_valid)? o_token[6] : 0;

endmodule
