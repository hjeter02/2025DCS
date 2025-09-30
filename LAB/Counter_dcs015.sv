module Counter(
    // Input signals
	clk, 
	rst_n, 
	in_valid,  
	in_num,  
    // Output signals
	out_num
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input in_valid; 
input [4:0] in_num;
output logic [4:0] out_num;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] in_num_comb, in_reg, mux_comb;



//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
///0
assign in_num_comb = (in_valid)? in_num : in_reg;
///1
always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
            in_reg <= 0; 
    end
    else begin //clk == 1
            in_reg <= in_num_comb;
    end
end
///2
always_comb begin
	mux_comb = 0;
	if (in_valid) begin
		mux_comb = 0;
	end 
	else if ( out_num < in_reg ) begin
		mux_comb = out_num + 1;
	end
	else begin
		mux_comb = out_num;
	end
end
///3
always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
            out_num <= 0; 
    end
    else begin //clk == 1
            out_num <= mux_comb;
    end
end

endmodule