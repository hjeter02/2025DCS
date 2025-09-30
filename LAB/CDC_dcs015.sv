
`include "Handshake_syn.v"

module CDC(
	// Input signals
	clk_1,
	clk_2,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[3:0]in_data;

output logic out_valid;
output logic [4:0]out_data; 			

// ---------------------------------------------------------------------
// logic declaration                 
// ---------------------------------------------------------------------	
logic ready2sync, ready2sync_f;

logic [3:0] cs1, ns1, cs2, ns2;

logic flag;

logic [3:0] data2sync, a, b, a_syn, b_syn ,data, a_syn_reg, data2design;
logic busy_out;

logic sidle_in;

logic valid, valid_reg;

logic change, change_reg;

logic out_valid_nxt;
logic [4:0] out_data_nxt;
// ---------------------------------------------------------------------
// design              
// ---------------------------------------------------------------------
parameter S_WAIT_INPUT1 = 3'b000;
parameter S_WAIT_INPUT2 = 3'b001;
parameter S_SEND_DATA = 3'b011;
parameter S_WAIT_1CT = 3'b100;

parameter S_IDLE = 3'b010;
parameter S_GET_DOUT = 3'b110;
parameter S_OUT = 3'b111;

assign change = (valid) && (~valid_reg);

always @(posedge clk_2 or negedge rst_n) begin
	if (~rst_n) begin
		change_reg <= 0;
	end else begin /////
		change_reg <= change;
	end
end

always @(posedge clk_2 or negedge rst_n) begin
	if (~rst_n) begin
		a_syn_reg <= 0;
	end else if ((cs2 == S_GET_DOUT) && (change_reg)) begin /////
		a_syn_reg <= a_syn;
	end
end

always @(posedge clk_1 or negedge rst_n) begin
	if (~rst_n) begin
		ready2sync_f <= 0;
	end else if (ready2sync) begin
		ready2sync_f <= ready2sync;
	end else if (cs1 == 0) begin
		ready2sync_f <= 0;
	end
end

// always @(posedge clk_1 or negedge rst_n) begin
// 	if (~rst_n) begin
// 		cnt <= 0;
// 	end else if (((cs1 == S_SEND_DATA) || (cs1 == S_WAIT_INPUT2)) && ready2sync) begin /////
// 		cnt <= cnt + 1;
// 	end else if (cs1 == S_WAIT_INPUT1) begin
// 		cnt <= 0;
// 	end
// end

always @(posedge clk_1 or negedge rst_n) begin
	if (~rst_n) begin
		cs1 <= 0;
	end else begin
		cs1 <= ns1;
	end
end

always @(posedge clk_2 or negedge rst_n) begin
	if (~rst_n) begin
		cs2 <= 2;
	end else begin
		cs2 <= ns2;
	end
end

assign flag = ready2sync_f && ready2sync;
//assign flag = ;

always @(*) begin
	case (cs1)
	S_WAIT_INPUT1:begin
		ns1 = (in_valid)? S_WAIT_INPUT2 : cs1;
		ready2sync = 0;
		data2sync = 0;
		busy_out = 0;
	end
	S_WAIT_INPUT2:begin
		ns1 = S_SEND_DATA;
		ready2sync = 0;
		data2sync = 0;
		busy_out = 0;
	end
	
	S_SEND_DATA:begin
		ns1 = (flag)? S_WAIT_1CT : cs1;
		ready2sync = (sidle_in);
		if (ready2sync && sidle_in) begin
			data2sync = (flag)? a : b;
		end else begin
			data2sync = 0;
		end
		busy_out = 0;
	end
	S_WAIT_1CT:begin
		ns1 = S_WAIT_INPUT1;
		ready2sync = 0;
		data2sync = 0;
		busy_out = 0;
	end
	default:begin
		ns1 = cs1;
		ready2sync = 0;
		data2sync = 0;
		busy_out = 0;
	end
	endcase
end

always @(posedge clk_1 or negedge rst_n) begin
	if (~rst_n) begin
		a <= 0;
		b <= 0;
	end else if (in_valid) begin
		a <= in_data;
		b <= a;
	end else begin
		a <= a;
		b <= b;
	end
end

always @(posedge clk_2 or negedge rst_n) begin
	if (~rst_n) begin
		valid_reg <= 0;
	end else begin
		valid_reg <= valid;
	end
end

always @(*) begin
	case (cs2)
	S_IDLE:begin
		ns2 = (change)? S_GET_DOUT : cs2;
		a_syn = 0;
		b_syn = 0;
		out_valid_nxt = 0;
		out_data_nxt = 0;
	end
	S_GET_DOUT:begin
		ns2 = (change)? S_OUT : cs2; ////
		a_syn = (valid)? data2design : 0;
		b_syn = 0;
		out_valid_nxt = 0;
		out_data_nxt = 0;
	end
	S_OUT:begin
		ns2 = S_IDLE;
		a_syn = a_syn_reg;
		b_syn = (valid)? data2design : 0;
		out_valid_nxt = 1;
		out_data_nxt = a_syn_reg + b_syn;
	end
	default:begin
		ns2 = cs2;
		a_syn = 0;
		b_syn = 0;
		out_valid_nxt = 0;
		out_data_nxt = 0;
	end
	endcase
end

always @(posedge clk_2 or negedge rst_n) begin
	if (~rst_n) begin
		out_valid <= 0;
		out_data <= 0;
	end else begin
		out_valid <= out_valid_nxt;
		out_data <= out_data_nxt;
	end
end

//assign sum = a + b;
//assign ready2sync = ?;
//assign data2sync = (ready2sync && sidle_in)? b : 0;
//assign busy_out = 0;

Handshake_syn sync(
					.sclk(clk_1), 
					.dclk(clk_2), 
					.rst_n(rst_n),
					.sready(ready2sync), //out to sync
					.din(data2sync),  //out to sync
					.sidle(sidle_in), //to design
					.dbusy(busy_out), //to sync
					.dvalid(valid),   //to design
					.dout(data2design) //to design
);

//assign data = (valid)? data2design : 0;


		
endmodule