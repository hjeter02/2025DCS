module INF(
	// input signal
	clk,
	rst_n,
	in_valid,
	in_mode,
	in_addr,
	in_data,
	// input axi 
	ar_ready,
	r_data,
	r_valid,
	aw_ready,
	w_ready,
	// output signals
	out_valid,
	out_data,
	// output axi
	ar_addr,
	ar_valid,
	r_ready,
	aw_addr,
	aw_valid,
	w_data,
	w_valid
);
//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid, in_mode;
input [3:0] in_addr;
input [7:0] in_data, r_data; 
input ar_ready, r_valid, aw_ready, w_ready;
output logic out_valid;
output logic [7:0] out_data, w_data;
output logic [3:0] ar_addr, aw_addr;
output logic ar_valid, r_ready, aw_valid, w_valid;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [1:0] cnt, cnt_nxt;
logic [3:0] in_addr_reg;
logic [2:0] cs, ns;
logic mode;

parameter S_IDLE = 3'b000;
parameter S_AR = 3'b001;
parameter S_R = 3'b011;
parameter S_AW = 3'b010;
parameter S_W = 3'b110;
parameter S_OUTPUT = 3'b111;

logic [3:0][7:0]r;
logic [3:0][7:0]w;

logic [7:0] out_data_nxt;
logic [1:0] out_cnt, out_cnt_nxt, out_cnt_reg;

//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------
//FSM
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cs <= 0;
    end else begin
        cs <= ns;
    end
end

always @(*) begin
    case (cs)
    S_IDLE:
        if (in_valid) begin
            ns = (in_mode)? S_AW : S_AR; //w : r
        end else begin
            ns = cs;
        end
    S_AR:
        ns = (ar_valid && ar_ready)? S_R : cs;
    S_R:
        ns = (r_valid && r_ready && (cnt == 3))? S_OUTPUT : cs;
    S_AW:
        ns = (aw_valid && aw_ready)? S_W : cs;
    S_W:
        ns = (w_valid && w_ready && (cnt == 3))? S_OUTPUT : cs;
    S_OUTPUT:
        ns = (out_cnt == 3)? S_IDLE : cs;
    default: ns = cs;
    endcase
end

//input reg
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_addr_reg <= 0;
    end else if (in_valid) begin
        in_addr_reg <= in_addr;
    end else begin
        in_addr_reg <= in_addr_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mode <= 0;
    end else begin
        mode <= (in_valid)? in_mode : mode;
    end
end

//---------------------------------------------------------------------
//--cnt

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt <= 0;
    end else begin
        cnt <= cnt_nxt;
    end
end

always @(*) begin
    if (r_valid || w_ready) begin
        cnt_nxt = cnt + 1;
    end else begin
        cnt_nxt = cnt; //0;
    end
end

//---------------------------------------------------------------------
//--read

//read addr
//assign ar_valid_nxt = ((cs == S_AR));
always @(posedge clk or negedge rst_n) begin //olk//
    if (~rst_n) begin
        ar_valid <= 0;
        ar_addr <= 0;
    end else if (cs == S_AR && (~in_valid) && (~ar_ready)) begin
        ar_valid <= 1;
        ar_addr <= (~ar_ready)? in_addr_reg : 0;
	end else if (ar_ready) begin //finish rst
		ar_valid <= 0;
        ar_addr <= 0;
	end
end

//read data
assign r_ready = (cs == S_R); //ok//

//shift reg.
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        r[0] <= 0;
        r[1] <= 0;
        r[2] <= 0;
        r[3] <= 0;
    end else if (r_valid) begin ///
        r[3] <= r_data;
        r[2] <= r[3];
        r[1] <= r[2];
        r[0] <= r[1];
	end else begin
		r[3] <= r[3];
        r[2] <= r[2];
        r[1] <= r[1];
        r[0] <= r[0];
	end
end

//---------------------------------------------------------------------
//--write

always @(posedge clk or negedge rst_n) begin //ok//
    if (~rst_n) begin
        aw_valid <= 0;
        aw_addr <= 0;
    end else if (cs == S_AW && (~in_valid) && (~aw_ready)) begin
        aw_valid <= 1;
        aw_addr <= (~aw_ready)? in_addr_reg : 0;
    end else if (aw_ready) begin //finish rst
		aw_valid <= 0;
        aw_addr <= 0;
	end
end
//write data
assign w_valid = (cs == S_W); //ok//

//shift reg. for write
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        w[0] <= 0;
        w[1] <= 0;
        w[2] <= 0;
        w[3] <= 0;
    end else if (in_valid && in_mode) begin
        w[3] <= in_data;
        w[2] <= w[3];
        w[1] <= w[2];
        w[0] <= w[1];
    end
end
assign w_data = (cs == S_W)? w[cnt] : 0;

//---------------------------------------------------------------------
//--output

//out data
always @(*) begin
    if (cs == S_OUTPUT) begin
        out_data = (~mode)? r[out_cnt] : 0; /////
    end else begin
        out_data = 0;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_data <= 0;
    end else begin
        out_data <= out_data_nxt;
    end
end
*/
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_cnt <= 0;
        out_cnt_reg <= 0;
		//out_cnt_reg_r <= 0;
    end else begin
        out_cnt <= (cs == S_OUTPUT)? out_cnt + 1 : 0;
        out_cnt_reg <= out_cnt;
		//out_cnt_reg_r <= out_cnt_reg;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_cnt <= 0;
        out_cnt_reg <= 0;
    end else begin
        out_cnt <= (cs == S_OUTPUT)? out_cnt ;
        out_cnt_reg <= out_cnt;
    end
end
*/
assign out_valid = (cs == S_OUTPUT)? (out_cnt_reg >= 0) || (out_cnt_reg <= 3) : 0;



endmodule
