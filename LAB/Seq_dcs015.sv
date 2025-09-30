module Seq(
	// Input signals
	clk,
	rst_n,
	in_valid,
	card,
	// Output signals
	win,
	lose,
	sum
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] card;
output logic win, lose;
output logic [4:0] sum;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
logic [3:0] in;
logic win_comb, lose_comb;
logic [4:0] sum_comb;
//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------

/*always_comb begin
	if (in_valid) begin
		card_comb = card;
	end else begin
		card_comb = 0;
	end
end*/

/*always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        in <= 0;
    end
    else if(in_valid) begin //clk == 1
        in <= card;
    end
	else begin
		in <= 0;
	end
end*/

assign in = ((in_valid)&&(card <= 10))? card :
			((in_valid)&&(card > 10)) ? 10:
			0;
always_comb begin
	in = 0;
	if ((in_valid)&&(card <= 10)) begin
		in = card;
	end
	else if ((in_valid)&&(card > 10)) begin
		in = 10;
	end
end
always_comb begin
	sum_comb = 0;
	//win_comb = 0;
	//lose_comb = 0;
	//in = (in <= 10)? in : 10;

	if (sum <= 16) begin
		sum_comb = in + sum;
	end
	else if (((win | lose) == 1)||(sum > 16)) begin
		sum_comb = 0;
	end
	/*else if ((sum > 16) && (sum <= 21)) begin
		win_comb = 1;
	end
	else if (sum > 21) begin
		lose_comb = 1;
	end*/
end

always_comb begin
	win_comb = 0;
	if (((win|lose) != 1) && (sum_comb > 16) && (sum_comb <= 21)) begin
		win_comb = 1;
	end
	else if (win == 1) begin
		win_comb = 0;
	end
end

always_comb begin
	lose_comb = 0;
	if (((win|lose) != 1) && (sum_comb > 21)) begin
		lose_comb = 1;
	end
	else if (lose == 1) begin
		lose_comb = 0;
	end
end

///DFF sum
always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
            sum <= 0; 
    end
    else begin //clk == 1
            sum <= sum_comb;
    end
end
///DFF win
always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
            win <= 0; 
    end
    else begin //clk == 1
            win <= win_comb;
    end
end
///DFF lose
always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
            lose <= 0; 
    end
    else begin //clk == 1
            lose <= lose_comb;
    end
end

endmodule
