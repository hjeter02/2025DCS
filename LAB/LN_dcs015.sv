module LN(
    //OUTPUT 
    clk,
    rst_n,
    in_valid,
    in_data,

    //INPUT
    out_valid,
	out_data
);

// INPUT
input clk;
input rst_n;
input in_valid;
input signed [7:0] in_data;

// OUTPUT
output logic out_valid;
output logic signed [7:0] out_data;

//================================================================
// DESIGN
//================================================================
logic signed [7:0] data [0:7];
logic signed [7:0] data_nxt [0:7];

logic [2:0] cnt, cnt_nxt;

logic signed [11: 0] sum, sum_reg, acc, acc2;
logic signed [7:0] mean, mean_reg, xi, xi_reg; // xi2, xi2_reg; // xi_mean, abs;
logic signed [8:0] xi_mean, abs, xi2, xi2_reg; /////////

logic signed [11: 0] sum2, sum2_reg;
logic signed [7:0] vrc, vrc_reg;

logic signed [8:0] data2 [0:7];
logic signed [8:0] data2_nxt [0:7];

logic signed [7:0] out_data_nxt;
logic out_valid_nxt;

//logic flag, flag_reg, flag2_reg, flag3_reg, flag4_reg, flag5_reg;
//logic out_finish;

//logic [32:0] pcnt, pcnt_nxt;

logic valid [17:0];


//valid
// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n) begin
//         for (integer i = 0; i < 18; i = i + 1) begin
//             valid[i] <= 0;
//         end
//     end
//     else begin
//         valid[0] <= (in_valid)? in_valid : 0;
//         for (integer i = 1; i < 18; i = i + 1) begin
//             valid[i] <= valid[i - 1];
//         end
//     end
// end


always @(posedge clk) begin
    // if (!rst_n) begin
    //     for (integer i = 0; i < 18; i = i + 1) begin
    //         valid[i] <= 0;
    //     end
    // end
    // else begin
        valid[0] <= (in_valid)? in_valid : 0;
        for (integer i = 1; i < 18; i = i + 1) begin
            valid[i] <= valid[i - 1];
        end
    // end
end

//p cnt
// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         pcnt <= 0;
//     else 
//         pcnt <= pcnt_nxt;
// end
// always @(*) begin
//     pcnt_nxt = 0;
//     if (in_valid) begin
//         pcnt_nxt = (cnt == 0)? pcnt + 1 : pcnt;
//     end
// end

//FSM
// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         cs <= IDLE;
//     else 
//         cs <= ns;
// end
// always @(*) begin
//     case (cs)
//     IDLE: ns = (in_valid)? IN : IDLE;
//     IN: ns = (cnt == 8)? COMP : cs;

//     endcase
// end

//counter
always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        cnt <= 0;
    else 
        cnt <= cnt_nxt;
end
always @(*) begin
    cnt_nxt = 0;
    if (in_valid || out_valid) begin ////////
        cnt_nxt = (cnt == 7)? 0 : cnt + 1;
    end
end


//data reg

// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n) begin
//         data[0] <= 0;
//         data[1] <= 0;
//         data[2] <= 0;
//         data[3] <= 0;
//         data[4] <= 0;
//         data[5] <= 0;
//         data[6] <= 0;
//         data[7] <= 0;
//     end
//     else begin
//         data[0] <= data_nxt[0];
//         data[1] <= data_nxt[1];
//         data[2] <= data_nxt[2];
//         data[3] <= data_nxt[3];
//         data[4] <= data_nxt[4];
//         data[5] <= data_nxt[5];
//         data[6] <= data_nxt[6];
//         data[7] <= data_nxt[7];
//     end
// end

always @(posedge clk) begin
    // if (!rst_n) begin
    //     data[0] <= 0;
    //     data[1] <= 0;
    //     data[2] <= 0;
    //     data[3] <= 0;
    //     data[4] <= 0;
    //     data[5] <= 0;
    //     data[6] <= 0;
    //     data[7] <= 0;
    // end
    // else begin
        data[0] <= data_nxt[0];
        data[1] <= data_nxt[1];
        data[2] <= data_nxt[2];
        data[3] <= data_nxt[3];
        data[4] <= data_nxt[4];
        data[5] <= data_nxt[5];
        data[6] <= data_nxt[6];
        data[7] <= data_nxt[7];
    // end
end

always @(*) begin
    for (integer i = 0; i < 8; i = i + 1) begin
        data_nxt[i] = data[i];
    end
    if (in_valid || out_valid) begin
        data_nxt[0] = in_data;
        for (integer i = 1; i < 8; i = i + 1) begin
        data_nxt[i] = data[i-1];
        end
    end
end

//mean

assign acc = (cnt == 0)? 0 : sum_reg;
always @(*) begin
    sum = (in_valid)? acc + in_data : 0;
    mean = sum_reg / 8; ////////
end

// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         mean_reg <= 0;
//     else if (cnt == 8)
//         mean_reg <= mean;
// end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        mean_reg <= 0;
    else if (cnt == 0)
        mean_reg <= mean;
end

// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         sum_reg <= 0;
//     // else if (out_finish)
//     //     sum_reg <= 0;
//     else 
//         //sum_reg <= (cnt == 8)? sum : 0;
//         sum_reg <= sum;
// end

always @(posedge clk) begin
    // if (!rst_n)
    //     sum_reg <= 0;
    // else if (out_finish)
    //     sum_reg <= 0;
    // else 
        //sum_reg <= (cnt == 8)? sum : 0;
        sum_reg <= sum;
end

//xi - mean

always @(*) begin
    xi = data[7];
    xi_mean = xi_reg - mean_reg;
    //xi_mean = (tmp >= 0)? tmp : -tmp;
end

// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         xi_reg <= 0;
//     else 
//         xi_reg <= xi;
// end

always @(posedge clk) begin
    // if (!rst_n)
    //     xi_reg <= 0;
    // else 
        xi_reg <= xi;
end
//data2 reg
// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n) begin
//         data2[0] <= 0;
//         data2[1] <= 0;
//         data2[2] <= 0;
//         data2[3] <= 0;
//         data2[4] <= 0;
//         data2[5] <= 0;
//         data2[6] <= 0;
//         data2[7] <= 0;
//     end
//     else begin
//         data2[0] <= data2_nxt[0];
//         data2[1] <= data2_nxt[1];
//         data2[2] <= data2_nxt[2];
//         data2[3] <= data2_nxt[3];
//         data2[4] <= data2_nxt[4];
//         data2[5] <= data2_nxt[5];
//         data2[6] <= data2_nxt[6];
//         data2[7] <= data2_nxt[7];
//     end
// end

always @(posedge clk) begin
    // if (!rst_n) begin
    //     data2[0] <= 0;
    //     data2[1] <= 0;
    //     data2[2] <= 0;
    //     data2[3] <= 0;
    //     data2[4] <= 0;
    //     data2[5] <= 0;
    //     data2[6] <= 0;
    //     data2[7] <= 0;
    // end
    // else begin
        data2[0] <= data2_nxt[0];
        data2[1] <= data2_nxt[1];
        data2[2] <= data2_nxt[2];
        data2[3] <= data2_nxt[3];
        data2[4] <= data2_nxt[4];
        data2[5] <= data2_nxt[5];
        data2[6] <= data2_nxt[6];
        data2[7] <= data2_nxt[7];
    // end
end

always @(*) begin
    for (integer i = 0; i < 8; i = i + 1) begin
        data2_nxt[i] = data2[i];
    end
    if (in_valid || out_valid) begin //////////
        data2_nxt[0] = xi_mean;
        for (integer i = 1; i < 8; i = i + 1) begin
            data2_nxt[i] = data2[i-1];
        end
    end
end

//vrc

always @(*) begin
    //abs = 0;
    abs = (xi_mean[8])? ~(xi_mean - 1) : xi_mean;
end

assign acc2 = (cnt == 1)? 0 : sum2_reg;

//assign acc2 

always @(*) begin
    sum2 = acc2 + abs;
    //vrc = sum2_reg >>> 3;
    vrc = sum2_reg / 8;
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        vrc_reg <= 0;
    else if (cnt == 1)
        vrc_reg <= vrc;
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        sum2_reg <= 0;
    // else if (out_finish)
    //     sum2_reg <= 0;
    else 
        //sum2_reg <= (cnt == 8)? sum2 : 0;
        sum2_reg <= sum2;
end

// always @(posedge clk) begin
    // if (!rst_n)
    //     sum2_reg <= 0;
    // else if (out_finish)
    //     sum2_reg <= 0;
    // else 
        //sum2_reg <= (cnt == 8)? sum2 : 0;
        // sum2_reg <= sum2;
// end

//out
// assign flag = (cnt == 0);
// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n) begin
//         flag_reg <= 0;
//         flag2_reg <= 0;
//         flag3_reg <= 0;
//         flag4_reg <= 0;
//         flag5_reg <= 0;
//     end
//     else begin
//         flag_reg <= (flag)? flag : flag_reg;
//         flag2_reg <= (flag_reg && flag)? flag_reg : flag2_reg;
//         flag3_reg <= (flag2_reg && flag)? flag2_reg : flag3_reg;
//         flag4_reg <= (flag3_reg && flag)? flag3_reg : flag4_reg;
//         flag5_reg <= flag4_reg;
//     end
// end

always @(*) begin
    out_valid_nxt = valid[17];
end

always @(*) begin
    xi2 = data2[7];
    out_data_nxt = xi2_reg / vrc_reg;
end

// always @(posedge clk, negedge rst_n) begin
//     if (!rst_n)
//         xi2_reg <= 0;
//     else 
//         xi2_reg <= xi2;
// end

always @(posedge clk) begin
    // if (!rst_n)
    //     xi2_reg <= 0;
    // else 
        xi2_reg <= xi2;
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        out_data <= 0;
    else 
        out_data <= (out_valid_nxt)? out_data_nxt : 0;
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        out_valid <= 0;
    else 
        out_valid <= out_valid_nxt;
        //out_valid <= 0;
end

//assign out_finish = out_valid && flag;

endmodule







