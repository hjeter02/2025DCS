module FIR(
    // Input signals
    clk,
    rst_n,
    in_valid,
    weight_valid,
    x,
    b0,
    b1,
    b2,
    b3,
    // Output signals
    out_valid,
    y
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, weight_valid;
input [15:0] x, b0, b1, b2, b3;

output logic out_valid;
output logic [33:0] y;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic in_valid_1, in_valid_2, in_valid_3, in_valid_4;
logic [15:0] x_f;
logic [15:0] b0_t, b1_t, b2_t, b3_t;
logic [15:0] b0_f, b1_f, b2_f, b3_f;
logic [33:0] s0, s1, s1_f, s2, s2_f, p3, p3_f;
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        x_f <= 0;
    end
    else begin
        x_f <= (in_valid)? x : 0;
    end
end

always @(*) begin
    b0_t = b0_f;
    b1_t = b1_f;
    b2_t = b2_f;
    b3_t = b3_f;
    if (weight_valid) begin
        b0_t = b0;
        b1_t = b1;
        b2_t = b2;
        b3_t = b3;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        b0_f <= 0;
        b1_f <= 0;
        b2_f <= 0;
        b3_f <= 0;
    end
    else begin
        b0_f <= b0_t;
        b1_f <= b1_t;
        b2_f <= b2_t;
        b3_f <= b3_t;
    end
end

assign p3 = x_f * b3_f;
assign s2 = (x_f * b2_f) + p3_f;
assign s1 = (x_f * b1_f) + s2_f;
assign s0 = (x_f * b0_f) + s1_f;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        y <= 0;
        s1_f <= 0;
        s2_f <= 0;
        p3_f <= 0;
    end
    else begin
        y <= (in_valid_4)? s0 : 0;
        s1_f <= s1;
        s2_f <= s2;
        p3_f <= p3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_valid_1 <= 0;
        in_valid_2 <= 0;
        in_valid_3 <= 0;
        in_valid_4 <= 0;
        out_valid <= 0;
    end
    else begin
        in_valid_1 <= in_valid;
        in_valid_2 <= in_valid_1;
        in_valid_3 <= in_valid_2;
        in_valid_4 <= in_valid_3;
        out_valid <= in_valid_4;
    end
end

endmodule