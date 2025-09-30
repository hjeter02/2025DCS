module FSM(
	// Input signals
	clk,
	rst_n,
	in_valid,
	op,
    A,
    B,
	// Output signals
    pred_taken,
    state
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [1:0] op;
input [3:0] A, B;
output logic pred_taken;
output logic [1:0] state;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------
logic pred_taken_next;
logic p;
logic [1:0] next_state;
//parameter P_NTAKEN1;00
//parameter P_NTAKEN2;01
//parameter P_TAKEN1;00
//parameter P_TAKEN2;01

//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) pred_taken <= 0;
    else pred_taken <= pred_taken_next;
end
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) state <= 0;
    else state <= next_state;
end
always_comb begin
	case (state)
	//nk1
	0 :
		if (in_valid && p) next_state = 1;
		else next_state = state;
	//nk2
	1 :
		if (in_valid && p) next_state = 3;
		else if (in_valid && !p) next_state = 0;
		else next_state = state;
	//k1
	2 :
		if (in_valid && p) next_state = 3;
		else if (in_valid && !p) next_state = 0;
		else next_state = state;
	//k2
	3 :
		if (in_valid && p) next_state = 3;
		else if (in_valid && !p) next_state = 2;
		else next_state = state;
	default : next_state = state;
	endcase
end

always_comb begin
	if ((next_state ==2) || (next_state ==3)) pred_taken_next = 1;
	else pred_taken_next = 0;
end


always_comb begin
	if (in_valid) begin
		case (op)
		//==
		0:
			p = (A == B) ? 1 : 0;
		//!=
		1:
			p = (A != B) ? 1 : 0;
		//<
		2:
			p = (A < B) ? 1 : 0;
		//>=
		3:
			p = (A >= B) ? 1 : 0;
		default:
			p = 0;
		endcase
	end	
	else p = 0;
end

endmodule
