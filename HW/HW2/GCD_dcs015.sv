module GCD(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_data,
    // Output signals
    out_valid,
    out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] in_data;

output logic out_valid;
output logic [4:0] out_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] data [1:0];
logic [3:0] cnt;
logic [3:0] num;
logic [3:0] add1;
logic [3:0] add0;
logic [3:0] tmp, tmp_reg;
logic [4:0] sum;
logic [4:0] sum2_reg;
logic [4:0] sum1_reg;
logic [4:0] sum0_reg;

logic [2:0] pwr [1:0];//3bit max=4
logic [4:0] a;
logic [4:0] b;
logic [3:0] a1, a2;
logic [3:0] b1, b2;
logic [2:0] common_pwr;
logic [3:0] out;
logic [4:0] result;
logic [4:0] gcd, gcd_reg;

logic [4:0] out_num [2:0];
logic [4:0] out_num_next [2:0];
logic [4:0] out_data_next;


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
//counter--------------------------------------------------------------
always_ff@(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end
    else if (in_valid || ((cnt > 0) && (cnt <= 10))) begin
        cnt <= cnt + 1;
    end
    //else if ((cnt == 1) || cnt <= 11) cnt <= cnt +1;
    else cnt <= 0;
end
//---------------------------------------------------------------------
//input logic----------------------------------------------------------
always_ff@(posedge clk) begin
    if (in_valid) begin //(cnt == 6)
        data[1] <= in_data;
        data[0] <= data[1];
    end
    else begin
        data[0] <= data[0];
        data[1] <= data[1];
    end
end
//---------------------------------------------------------------------
//---allocate & add----------------------------------------------------
always_comb begin // comparing lsb
    num = (cnt == 2) ? data[0] : tmp_reg;
    if (in_data[0] == data[1][0]) begin
        add0 = in_data;
        add1 = data[1];
        tmp = num;
    end
    else if (in_data[0] == num[0]) begin
        add0 = in_data;
        add1 = num;
        tmp = data[1];
    end
    else begin
        add0 = data[1];
        add1 = num;
        tmp = in_data;
    end
    sum = add0 + add1; // add
end
//sum_reg--------------------------------------------------------------
//---------------------------------------------------------------------
always_ff@(posedge clk) begin
    if ((cnt == 2)) begin
        sum2_reg <= sum;
    end
    else sum2_reg <= sum2_reg;
end
always_ff@(posedge clk) begin
    if ((cnt == 4)) begin
        sum1_reg <= sum;
    end
    else sum1_reg <= sum1_reg;
end
always_ff@(posedge clk) begin
    if ((cnt == 6)) begin
        sum0_reg <= sum;
    end
    else sum0_reg <= sum0_reg;
end

always_ff@(posedge clk) begin
    if ((cnt == 2) || (cnt == 4) || (cnt == 6)) begin ///???
        tmp_reg <= tmp;
    end
    else tmp_reg <= tmp_reg;
end
//---------------------------------------------------------------------
//---gcd---------------------------------------------------------------
//mux
always_comb begin
    a = (cnt == 4) ? sum2_reg : gcd_reg;
    b = sum;
    gcd = result;
end
//gcd blk
always_comb begin
    result = 'bx;
    //pwr1
    if (!a[3:1]) pwr[1] = 4;
    else if (!a[2:1]) pwr[1] = 3;
    else if (!a[1]) pwr[1] = 2;
    else pwr[1] = 1;
    //pwr0
    if (!b[3:1]) pwr[0] = 4;
    else if (!b[2:1]) pwr[0] = 3;
    else if (!b[1]) pwr[0] = 2;
    else pwr[0] = 1;
    //shift
    a1 = a >> pwr[1];
    b1 = b >> pwr[0];
    //swap
    a2 = (a1 > b1) ? a1 : b1;
    b2 = (a1 > b1) ? b1 : a1;
    //find min. pwr
    common_pwr = ((pwr[1]) > (pwr[0]))? (pwr[0]) : (pwr[1]);
    //gcd
    if ((a2 == b2)) out = b2;
    else if ((a2 ==15) && ((b2 == 5) || (b2 == 3))) out = b2;
    else if ((a2 == 9) && (b2 == 3)) out = b2;
    else if ((a2 == 15) && (b2 == 9)) out = 3;
    else out = 1;
    //shift back
    result = out << common_pwr;
end
//gcd dff
always_ff@(posedge clk) begin
    if ((cnt == 4) || (cnt == 6)) begin ///???
        gcd_reg <= gcd;
        //cp_reg <= cp;
    end
    else begin
        gcd_reg <= gcd_reg;
        //cp_reg <= cp_reg;
    end
end
//---------------------------------------------------------------------
//output logic---------------------------------------------------------
/*
always_comb begin
    case(cnt)
    7: out_data_next = sum0_reg;
    8: out_data_next = sum1_reg;
    9: out_data_next = sum2_reg;
    10: out_data_next = gcd_reg;
    default: out_data_next = 0;
    endcase
end
*/
always_comb begin
    if (cnt == 7) begin
    out_num_next[2] = gcd_reg;
    out_num_next[1] = sum2_reg;
    out_num_next[0] = sum1_reg;
    out_data_next = sum0_reg;
    end
    else begin
    out_num_next[2] = gcd_reg;
    out_num_next[1] = out_num[2];
    out_num_next[0] = out_num[1];
    out_data_next = out_num[0];
    end
end

always_ff@(posedge clk) begin
    // if ((cnt >= 7) && (cnt <= 10))
    out_num[2] <= out_num_next[2];
    out_num[1] <= out_num_next[1];
    out_num[0] <= out_num_next[0];
        //out_data <= out_data_next;
        //out_valid <= 1;
end

always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_data <= 0;
    end
    else begin //if ((cnt >= 7) && (cnt <= 10)) begin
        out_data <= out_data_next;
    end
end

always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
    end
    else if ((cnt >= 7) && (cnt <= 10)) begin
        out_valid <= 1;
    end
    else out_valid <= 0;
end

endmodule
