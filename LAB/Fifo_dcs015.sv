module Fifo(
    // Input signals
	clk, 
	rst_n, 
	write_valid, 
	write_data, 
	read_valid, 
    // Output signals
	write_full, 
	write_success, 
	read_empty, 	
	read_success, 
	read_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input write_valid, read_valid; 
input [7:0] write_data;
output logic write_full, write_success, read_empty, read_success;
output logic [7:0] read_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] ptr, ptr_next;
logic [7:0] head;
logic [7:0] data [9:0];
logic [7:0] data_next [9:0];
logic empty_next;
logic full_next;
logic write_success_next;
logic read_success_next;
logic [7:0] read_data_next;


//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
//write condition DFF///
always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) begin
        write_full <= 0;
        write_success <= 0;
    end
    else if (write_valid) begin
        write_full <= full_next;
        write_success <= write_success_next;
    end
    else begin
        write_full <= 0;
        write_success <= 0;
    end
end
//read condition DFF///
always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) begin
        read_empty <= 0;
        read_success <= 0;
        read_data <= 0;
    end
    else if (read_valid) begin//read
        read_empty <= empty_next;
        read_success <= read_success_next;
        read_data <= read_data_next;
    end
    else begin//invalid
        read_empty <= 0;
        read_success <= 0;
        read_data <= 0;
    end
end
//pointer DFF///
always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) ptr <= 0;
    else ptr <= ptr_next;
end
// data DFF///
always_ff @( posedge clk, negedge rst_n ) begin
    if(!rst_n) begin
        data[0] <= 0;
        data[1] <= 0;
        data[2] <= 0;
        data[3] <= 0;
        data[4] <= 0;
        data[5] <= 0;
        data[6] <= 0;
        data[7] <= 0;
        data[8] <= 0;
        data[9] <= 0;
    end
    else if (write_success_next) begin//write write_valid & (!full_next) 
        data[0] <= data[1];
        data[1] <= data[2];
        data[2] <= data[3];
        data[3] <= data[4];
        data[4] <= data[5];
        data[5] <= data[6];
        data[6] <= data[7];
        data[7] <= data[8];
        data[8] <= data[9];
        data[9] <= write_data;
    end//read
    else begin
        data[0] <= data_next[0];
        data[1] <= data_next[1];
        data[2] <= data_next[2];
        data[3] <= data_next[3];
        data[4] <= data_next[4];
        data[5] <= data_next[5];
        data[6] <= data_next[6];
        data[7] <= data_next[7];
        data[8] <= data_next[8];
        data[9] <= data_next[9];
    end
end
//ptr comb//??
always_comb begin
    if ((ptr < 10) && (write_success_next & (~read_success_next))) begin //write
		ptr_next = ptr + 1;
	end
	//else if (empty_next = 1) begin
		//ptr_next = ptr
	//end
    else if ((0 < ptr) && (read_success_next && (~write_success_next))) begin //read
		ptr_next = ptr - 1;
	end
    else ptr_next = ptr;
end
/*always_comb begin
    if ((0 < ptr < 10) && (write_success_next & (~read_success_next))) begin 
		ptr_next = ptr + 1;
	end
    else if ((0 < ptr < 10) && (read_success_next & (~write_success_next))) begin
		ptr_next = ptr - 1;
	end
    else ptr_next = ptr;
end*/


assign empty_next = read_valid && (ptr == 0);///
assign full_next = write_valid && (~read_valid) && (ptr == 10);///????
//success
//assign write_success_next = write_valid && (ptr_next < 10);
//assign read_success_next = read_valid && (ptr_next != 0);
assign write_success_next = write_valid && (~full_next);///??????
assign read_success_next = read_valid && ((ptr > 0));///??

//read
always_comb begin///
    data_next[0] = data[0];
    data_next[1] = data[1];
    data_next[2] = data[2];
    data_next[3] = data[3];
    data_next[4] = data[4];
    data_next[5] = data[5];
    data_next[6] = data[6];
    data_next[7] = data[7];
    data_next[8] = data[8];
    data_next[9] = data[9];
    //if (read_valid & (~read_empty)) data_next[10-ptr] = 0;//read
    //data_next[10-ptr] = (read_valid & (~read_empty)) ? 0 : data[10-ptr];///
    data_next[10-ptr] = (read_success_next) ? 0 : data[10-ptr];///???
end
//assign write_done = (write_valid & (!write_full)) ? 1 : 0; 
//ptr & success
//head
assign head = data_next[10-ptr];///
assign read_data_next = (read_success_next) ? data[10-ptr]:0;///


endmodule