module SPMV(
    clk, 
	rst_n, 
	// input 
	in_valid, 
	weight_valid, 
	in_row, 
	in_col, 
	in_data, 
	// output
	out_valid, 
	out_row, 
	out_data, 
	out_finish
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n; 
// input
input in_valid, weight_valid; 
input [4:0] in_row, in_col; 
input [7:0] in_data; 
// output 
output logic out_valid; 
output logic [4:0] out_row; 
output logic [20:0] out_data; 
output logic out_finish; 

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
parameter IDLE = 2'b00;
parameter INV = 2'b01;
parameter INM = 2'b11;
parameter OUTV = 2'b10;

logic [1:0] cur_state;
logic [1:0] next_state;

logic [7:0] vector_next [0:31];
logic [7:0] vector [0:31];
logic [7:0] v_reg;

logic [4:0] in_row_reg;
logic [4:0] in_row_reg_2;
logic [4:0] in_row_tmp;
//logic [4:0] in_col_reg;
logic [7:0] in_data_reg;

logic acc_rst;
logic [17:0] acc;
logic [17:0] sum;
logic [17:0] sum_reg;

logic [17:0] data [0:31];
logic [17:0] data_reg [0:31];

logic [31:0] row_valid;
logic [31:0] row_valid_f;

//logic [4:0] row [0:31];
//logic [4:0] row_reg [0:31];

// logic [4:0] cnt;
// logic [4:0] cnt_w;
// logic [4:0] cnt_r;
//logic [4:0] cnt_next;
//logic [7:0] p_cnt;

//logic out_valid_next; 
//logic [4:0] out_row_next; 
//logic [20:0] out_data_next; 
//logic out_finish_next;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
//FSM
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        cur_state <= IDLE;
    else 
        cur_state <= next_state;
end
always_comb begin
	case (cur_state)
	IDLE: next_state = (in_valid) ? INV : IDLE;
	INV: next_state = (weight_valid) ? INM : cur_state;
	INM: next_state = (!weight_valid) ? OUTV : cur_state;
	OUTV: next_state = (out_finish) ? IDLE : cur_state;
	endcase
end
//---------------------------------------------------------------------
//vector input
//*/main
genvar i;
generate
	for (i = 0; i < 32; i = i + 1) begin
		always_comb begin
		//for (integer i = 0; i < 32; i = i + 1) //default vector
			vector_next[i] = vector[i];
			if (in_valid) begin //update one element of vector
		//for (integer i = 0; i < 32; i = i + 1) begin
				if ((i == in_row))
					vector_next[i] = in_data;
			end
		end
	end
endgenerate

//*/
//vector reg.
generate
	for (i = 0; i < 32; i = i + 1) begin
		always_ff @(posedge clk, negedge rst_n) begin
			if (!rst_n) begin
			//for (integer i = 0; i < 32; i = i + 1) //initial rst
				vector[i] <= 0;
			end
			else if (in_valid) begin 
			//for (integer i = 0; i < 32; i = i + 1) //update
				vector[i] <= vector_next[i];
			end
			else if (out_finish) begin
			//for (integer i = 0; i < 32; i = i + 1) //rst
				vector[i] <= 0;
			end
		end
	end
endgenerate


//---------------------------------------------------------------------
//matrix input & process

assign in_row_tmp = (weight_valid)? in_row : 0; ///?
//assign sum_valid = ((cur_state == INM) && (in_row_tmp != in_row_reg))? 1 : 0;
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		acc_rst <= 0;
	else if ((cur_state[1]) && (in_row_tmp != in_row_reg)) //acc rst
		acc_rst <= 1;
	else
		acc_rst <= 0;
end	

assign acc = ((acc_rst))? 0 : sum_reg;
assign sum = acc + (v_reg * in_data_reg); //((state == INM))?
//assign product = vector[in_col_reg] * in_data_reg;

always_ff @(posedge clk) begin
    in_row_reg <= in_row_tmp;
	in_row_reg_2 <= in_row_reg;
end
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
        in_data_reg <= 0;
    else if (weight_valid || (cur_state == INM)) //optional
        in_data_reg <= in_data;
	else if (out_finish)
		in_data_reg <= 0;
end
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
        v_reg <= 0;
    else if (weight_valid || (cur_state == INM)) //optional
        v_reg <= vector[in_col];
	else if (out_finish)
		v_reg <= 0;
end

//sum to sum_reg
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) //optional
        sum_reg <= 0;
    else if (weight_valid || (cur_state == INM)) //INM compute sum ///?
        sum_reg <= sum;
	else if (out_finish)
		sum_reg <= 0;
end
//data & row shift reg
generate
	for (i = 0; i < 32; i = i + 1) begin
		always_comb begin
			//for (integer i = 0; i < 32; i = i + 1) begin //store
			data[i] = data_reg[i];
			if ((acc_rst) && (sum_reg != 0) && (i == in_row_reg_2)) begin //write
				data[i] = sum_reg;
			end
		end
	end
endgenerate
/*
always_comb begin
	for (integer i = 0; i < 32; i = i + 1) begin //store
		data[i] = data_reg[i];
	end
	// if ((acc_rst) && (sum_reg != 0)) begin //write
	// 	data[in_row_reg_2] = sum_reg;
	// end
    for (integer i = 0; i < 32; i = i + 1) begin
        if ((acc_rst) && (sum_reg != 0)) begin
            if (i == in_row_reg_2)
                data[i] = sum_reg;
        end
    end
end
*/
generate
    for (i = 0; i < 32; i = i + 1) begin
        always @(posedge clk) begin //ok
	//for (integer i = 0; i < 32; i = i + 1) begin
            data_reg[i] <= data[i];
	    end 
end
endgenerate
/*
always @(posedge clk) begin //ok
	for (integer i = 0; i < 32; i = i + 1) begin
        data_reg[i] <= data[i];
	end 
end
*/
/*
always_ff @(posedge clk, negedge rst_n) begin //ok
	if (!rst_n) begin
		for (integer i = 0; i < 32; i = i + 1) begin
        	data_reg[i] <= 0;
		end
	end
	else if (out_finish) begin
		for (integer i = 0; i < 32; i = i + 1) begin
			data_reg[i] <= 0;
		end
	end
    else begin
		for (integer i = 0; i < 32; i = i + 1) begin
        	data_reg[i] <= data[i];
		end
	end 
end
*/
//row_valid
always_comb begin
    for (integer i = 0; i < 32; i = i + 1) begin
        row_valid[i] = row_valid_f[i];
    end
    if ((acc_rst) && ((sum_reg != 0))) //write
        row_valid[in_row_reg_2] = 1;
	if (cur_state == OUTV) //read
		row_valid[out_row] = 0;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin //initial reset
        for (integer i = 0; i < 32; i = i + 1) begin
            row_valid_f[i] <= 0;
        end
    end
    else if (out_finish) begin //reset
        for (integer i = 0; i < 32; i = i + 1) begin
            row_valid_f[i] <= 0;
        end
    end
    else if (cur_state[1] == 1)
        for (integer i = 0; i < 32; i = i + 1) begin
            row_valid_f[i] <= row_valid[i];
        end
end
//counter

// assign cnt_w = (acc_rst && (sum_reg != 0))? cnt + 1 : cnt;
// assign cnt_r = (next_state == OUTV)? cnt_w - 1 : cnt_w;

// always_ff @(posedge clk, negedge rst_n) begin
// 	if (!rst_n)
//         cnt <= 0;
//     else
//         cnt <= cnt_r; //
// end
/*
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
        p_cnt <= 0;
    else if (out_finish)
        p_cnt <= p_cnt + 1; //
end
*/
//*/
//---------------------------------------------------------------------
//output
/*
always_comb begin
	if ((next_state == OUTV)) begin
		out_data_next = data_reg[cnt];
		out_row_next = row_reg[cnt];
	end
	else begin
		out_data_next = out_data;
		out_row_next = out_row;
	end
end
*/
always_comb begin
    casez (row_valid_f)
        32'b???????????????????????????????1: begin
            out_data = data_reg[0];
            out_row = 0;
        end
        32'b??????????????????????????????10: begin
            out_data = data_reg[1];
            out_row = 1;
        end
        32'b?????????????????????????????100: begin
        out_data = data_reg[2];
        out_row = 2;
        end
        32'b????????????????????????????1000: begin
        out_data = data_reg[3];
        out_row = 3;
        end
        32'b???????????????????????????10000: begin
            out_data = data_reg[4];
            out_row = 4;
        end
        32'b??????????????????????????100000: begin
            out_data = data_reg[5];
            out_row = 5;
        end
        32'b?????????????????????????1000000: begin
            out_data = data_reg[6];
            out_row = 6;
        end
        32'b????????????????????????10000000: begin
            out_data = data_reg[7];
            out_row = 7;
        end
        32'b???????????????????????100000000: begin
            out_data = data_reg[8];
            out_row = 8;
        end
        32'b??????????????????????1000000000: begin 
            out_data = data_reg[9];
            out_row = 9;
        end
        32'b?????????????????????10000000000: begin 
            out_data = data_reg[10];
            out_row = 10;
        end
        32'b????????????????????100000000000: begin 
            out_data = data_reg[11];
            out_row = 11;
        end
        32'b???????????????????1000000000000: begin
            out_data = data_reg[12];
            out_row = 12;
        end
        32'b??????????????????10000000000000: begin
            out_data = data_reg[13];
            out_row = 13;
        end
        32'b?????????????????100000000000000: begin
            out_data = data_reg[14];
            out_row = 14;
        end
        32'b????????????????1000000000000000: begin 
            out_data = data_reg[15];
            out_row = 15;
        end
        32'b???????????????10000000000000000: begin 
            out_data = data_reg[16];
            out_row = 16;
        end
        32'b??????????????100000000000000000: begin 
            out_data = data_reg[17];
            out_row = 17;
        end
        32'b?????????????1000000000000000000: begin 
            out_data = data_reg[18];
            out_row = 18;
        end
        32'b????????????10000000000000000000: begin 
            out_data = data_reg[19];
            out_row = 19;
        end
        32'b???????????100000000000000000000: begin
            out_data = data_reg[20];
            out_row = 20;
        end
        32'b??????????1000000000000000000000: begin
            out_data = data_reg[21];
            out_row = 21;
        end
        32'b?????????10000000000000000000000: begin
            out_data = data_reg[22];
            out_row = 22;
        end
        32'b????????100000000000000000000000: begin 
            out_data = data_reg[23];
            out_row = 23;
        end
        32'b???????1000000000000000000000000: begin 
            out_data = data_reg[24];
            out_row = 24;
        end
        32'b??????10000000000000000000000000: begin 
            out_data = data_reg[25];
            out_row = 25;
        end
        32'b?????100000000000000000000000000: begin 
            out_data = data_reg[26];
            out_row = 26;
        end
        32'b????1000000000000000000000000000: begin 
            out_data = data_reg[27];
            out_row = 27;
        end
        32'b???10000000000000000000000000000: begin 
            out_data = data_reg[28];
            out_row = 28;
        end
        32'b??100000000000000000000000000000: begin
            out_data = data_reg[29];
            out_row = 29;
        end
        32'b?1000000000000000000000000000000: begin
            out_data = data_reg[30];
            out_row = 30;
        end
        32'b10000000000000000000000000000000: begin
            out_data = data_reg[31];
            out_row = 31;
        end
        32'b00000000000000000000000000000000: begin
            out_data = 0;
            out_row = 0;
        end
    endcase
end
assign out_finish = (cur_state == OUTV)? ~(|row_valid) : 0;
//assign out_data = (out_valid)? data_reg[cnt] : 0;
//assign out_row = (out_valid)? row_reg[cnt] : 0;
//assign out_finish = ((cnt == 0) && (cur_state == OUTV))? 1 : 0; //ok
assign out_valid = (cur_state == OUTV); //ok
/*
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        out_data <= 0;
    else 
        out_data <= out_data_next;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        out_valid <= 0;
    else 
        out_valid <= out_valid_next;
end
*/
endmodule
