module CPU(
    //INPUT
    clk,
    rst_n,
    in_valid,
    instruction,

    //OUTPUT
    out_valid,
    instruction_fail,
    out_0,
    out_1,
    out_2,
    out_3,
    out_4,
    out_5
);
// INPUT
input clk;
input rst_n;
input in_valid;
input [31:0] instruction;

// OUTPUT
output logic out_valid, instruction_fail;
output logic [15:0] out_0, out_1, out_2, out_3, out_4, out_5;

//================================================================
// DESIGN
//================================================================

//reg addr
parameter ADDR0 = 5'b10001;
parameter ADDR1 = 5'b10010;
parameter ADDR2 = 5'b01000;
parameter ADDR3 = 5'b10111;
parameter ADDR4 = 5'b11111;
parameter ADDR5 = 5'b10000;

//op
parameter F     = 6'b111;
parameter ADDI  = 6'b000;
parameter ADD   = 6'b001;
parameter MULT  = 6'b100;
parameter SHL   = 6'b101;
parameter SHR   = 6'b011;
parameter RLU   = 6'b010;
parameter LKRLU = 6'b110;


//logic in_valid_1, in_valid_2, in_valid_3;

logic [31:0] instruction_0;
logic in_valid_0;

logic signed [15:0] register [0:5];
logic signed [15:0] register_nxt [0:5];

logic [5:0] opcode_0;
//logic [4:0] addrd_0, addrd_1;
logic [4:0] shmt_1;
//logic [5:0] func_0, func_1;
logic signed [15:0] imm_0, imm_1, data_1, data_2, data_3;

logic [2:0] s_0, s_1;// s_2 , s_3;
logic [2:0] t_0, t_1;// t_2, t_3;
logic [2:0] d_0, d_1;
logic [2:0] w_1, w_2, w_3;

logic [3:0] op_0, op_1;// op_2, op_3;
logic f_1, f_2, f_3, f_4;
logic m_1, m_2, m_3;

//add
logic signed [15:0] addend;
logic signed [15:0] sum_1;
//logic signed [15:0] summ;
//lut
//logic [5:0] map[0:3][0:15];
//mult
logic [15:0] a, b;

logic [1:0] a7, a6, a5, a4, a3, a2, a1, a0;
logic [1:0] b7, b6, b5, b4, b3, b2, b1, b0;

logic [3:0] a7b7;
logic [3:0] a7b6, a6b7;
logic [3:0] a7b5, a6b6, a5b7;
logic [3:0] a7b4, a6b5, a5b6, a4b7;
logic [3:0] a7b3, a6b4, a5b5, a4b6, a3b7;
logic [3:0] a7b2, a6b3, a5b4, a4b5, a3b6, a2b7;
logic [3:0] a7b1, a6b2, a5b3, a4b4, a3b5, a2b6, a1b7;
logic [3:0] a7b0, a6b1, a5b2, a4b3, a3b4, a2b5, a1b6, a0b7;
logic [3:0] a6b0, a5b1, a4b2, a3b3, a2b4, a1b5, a0b6;
logic [3:0] a5b0, a4b1, a3b2, a2b3, a1b4, a0b5;
logic [3:0] a4b0, a3b1, a2b2, a1b3, a0b4;
logic [3:0] a3b0, a2b1, a1b2, a0b3;
logic [3:0] a2b0, a1b1, a0b2;
logic [3:0] a1b0, a0b1;
logic [3:0] a0b0;

logic [3:0] a7b7_f;
logic [3:0] a7b6_f, a6b7_f;
logic [3:0] a7b5_f, a6b6_f, a5b7_f;
logic [3:0] a7b4_f, a6b5_f, a5b6_f, a4b7_f;
logic [3:0] a7b3_f, a6b4_f, a5b5_f, a4b6_f, a3b7_f;
logic [3:0] a7b2_f, a6b3_f, a5b4_f, a4b5_f, a3b6_f, a2b7_f;
logic [3:0] a7b1_f, a6b2_f, a5b3_f, a4b4_f, a3b5_f, a2b6_f, a1b7_f;
logic [3:0] a7b0_f, a6b1_f, a5b2_f, a4b3_f, a3b4_f, a2b5_f, a1b6_f, a0b7_f;
logic [3:0] a6b0_f, a5b1_f, a4b2_f, a3b3_f, a2b4_f, a1b5_f, a0b6_f;
logic [3:0] a5b0_f, a4b1_f, a3b2_f, a2b3_f, a1b4_f, a0b5_f;
logic [3:0] a4b0_f, a3b1_f, a2b2_f, a1b3_f, a0b4_f;
logic [3:0] a3b0_f, a2b1_f, a1b2_f, a0b3_f;
logic [3:0] a2b0_f, a1b1_f, a0b2_f;
logic [3:0] a1b0_f, a0b1_f;
logic [3:0] a0b0_f;


// logic [3:0] a7b7_f;
// logic [3:0] a5b7_f;
// logic [3:0] a3b7_f;
// logic [3:0] a1b7_f;
// logic [3:0] a0b6_f;
// logic [3:0] a0b4_f;
// logic [3:0] a0b2_f;
// logic [3:0] a0b0_f;

// logic [4:0] p13a, p12a, p11a, p11b, p10a, p10b, p9a, p9b, p9c, p8a, p8b, p8c;
// logic [4:0] p7a, p7b, p7c, p7d;
// logic [4:0] p1a, p2a, p3a, p3b, p4a, p4b, p5a, p5b, p5c, p6a, p6b, p6c;

// logic [4:0] p13a_f, p12a_f, p11a_f, p11b_f, p10a_f, p10b_f, p9a_f, p9b_f, p9c_f, p8a_f, p8b_f, p8c_f;
// logic [4:0] p7a_f, p7b_f, p7c_f, p7d_f;
// logic [4:0] p1a_f, p2a_f, p3a_f, p3b_f, p4a_f, p4b_f, p5a_f, p5b_f, p5c_f, p6a_f, p6b_f, p6c_f;

logic [3:0] p14;
logic [4:0] p13;
logic [5:0] p12, p11;
logic [6:0] p10, p9, p8, p7, p6, p5, p4;
logic [5:0] p3, p2;
logic [4:0] p1;
logic [3:0] p0;

// logic [3:0] p14_f;
// logic [4:0] p13_f;
// logic [5:0] p12_f, p11_f;
// logic [6:0] p10_f, p9_f, p8_f, p7_f, p6_f, p5_f, p4_f;
// logic [5:0] p3_f, p2_f;
// logic [4:0] p1_f;
// logic [3:0] p0_f;

// logic [3:0] s7;
// logic [6:0] s6;
// logic [7:0] s5;
// logic [8:0] s4, s3, s2;
// logic [7:0] s1;
// logic [6:0] s0;

logic [3:0] s7, s7_ff;
logic [6:0] s6, s6_ff;
logic [7:0] s5, s5_ff;
logic [8:0] s4, s4_ff, s3, s3_ff, s2, s2_ff;
logic [7:0] s1, s1_ff;
logic [6:0] s0, s0_ff;

// logic [8:0] ss3, ss3_ff;
// logic [12:0] ss2, ss2_ff;
// logic [13:0] ss1, ss1_ff;
// logic [12:0] ss0, ss0_ff;

logic [8:0] ss3;
logic [12:0] ss2;
logic [13:0] ss1;
logic [12:0] ss0;

logic [32:0] product_tmp;
logic signed [32:0] product;
//logic signed [31:0] product_1, product_2;
logic signed [15:0] result_2, result_3;
logic sign_bit, sign_bit_f, sign_bit_ff; ////???

//logic signed [15:0] shift_left_1;

//logic signed [31:0] a;
//logic [4:0] b;
//logic signed [15:0] shift_right_2;
logic nonnegative_1; //nonnegative_2, nonnegative_3;
logic signed [15:0] w_data;
logic [1:0] cnt;
//logic out_valid_tmp;



//state

//---------------------------------------------------------------------
// decode

//inst.
/*
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        instruction_0 <= 0;
        in_valid_0 <= 0;
    end else begin
        instruction_0 <= instruction;
        in_valid_0 <= in_valid;
    end
end
*/
always @(*) begin
	opcode_0 = instruction[31:26];
	//addrs_0 =  instruction[25:21];
	//addrt_0 =  instruction[20:16];
	//addrd_0 =   instruction_0[15:11];
	//shmt_0 =  instruction[10:6];
	//func_0 =   instruction[5:0];
	imm_0 = instruction[15:0];
end
//reg.
always @(*) begin
    case (instruction[25:21]) //rs decode
    ADDR0: s_0 = 0;
    ADDR1: s_0 = 1;
    ADDR2: s_0 = 2;
    ADDR3: s_0 = 3;
    ADDR4: s_0 = 4;
    ADDR5: s_0 = 5;
    default: s_0 = 7;
    endcase
end
always @(*) begin
    case (instruction[20:16]) //rt decode
    ADDR0: t_0 = 0;
    ADDR1: t_0 = 1;
    ADDR2: t_0 = 2;
    ADDR3: t_0 = 3;
    ADDR4: t_0 = 4;
    ADDR5: t_0 = 5;
    default: t_0 = 7;
    endcase
end
always @(*) begin
    case (imm_1[15:11]) //rd decode
    ADDR0: d_1 = 0;
    ADDR1: d_1 = 1;
    ADDR2: d_1 = 2;
    ADDR3: d_1 = 3;
    ADDR4: d_1 = 4;
    ADDR5: d_1 = 5;
    default: d_1 = 7;
    endcase
end

always @(*) begin
    op_0 = F;
    if (in_valid) begin
        case (opcode_0)
        6'b000000: begin //R
            case(instruction[5:0])
            6'b100000: op_0 = ADD;
            6'b011000: op_0 = MULT;
            6'b000000: op_0 = SHL;
            6'b000010: op_0 = SHR;
            6'b110001: op_0 = RLU;
            6'b110010: op_0 = LKRLU;
            default:   op_0 = F;
            endcase
        end
        6'b001000: op_0 = ADDI; //I
        default: op_0 = F;
        endcase
    end
end


//---------------------------------------------------------------------
// Pipeline reg. 0 to 1
always @(posedge clk) begin
    // if (~rst_n) begin
    //     op_1 <= 0;
    //     s_1 <= 0;
    //     t_1 <= 0;
    //     imm_1 <= 0;
    // end else begin
        op_1 <= op_0;
        s_1 <= s_0;
        t_1 <= t_0;
        imm_1 <= imm_0;
    //end
end

//---------------------------------------------------------------------
// ALU st1

//instruction f
always @(*) begin
    f_1 = 0;
    if (op_1 == F) begin // op not valid
        f_1 = 1;
    end else if (op_1 == ADDI) begin // I type reg not valid
        f_1 = (s_1 == 7) || (t_1 == 7);
    end else begin // R type reg not valid
        f_1 = (s_1 == 7) || (t_1 == 7) || (d_1 == 7);
    end
end

//Mult.

assign m_1 = (op_1 == MULT) || ((op_1 == LKRLU) && (~nonnegative_1));

always @(posedge clk) begin
    // if (~rst_n) begin
    //     m_2 <= 0;
    //     m_3 <= 0;
    // end else begin
        m_2 <= m_1;
        m_3 <= m_2;
    //end
end

assign sign_bit = register[s_1][15] ^ register[t_1][15];
assign a = (register[s_1][15])? ~(register[s_1] - 1) : register[s_1];
assign b = (register[t_1][15])? ~(register[t_1] - 1) : register[t_1];

always @(*) begin
    a7 = a[15:14];
    a6 = a[13:12];
    a5 = a[11:10];
    a4 = a[9:8];
    a3 = a[7:6];
    a2 = a[5:4];
    a1 = a[3:2];
    a0 = a[1:0];

    b7 = b[15:14];
    b6 = b[13:12];
    b5 = b[11:10];
    b4 = b[9:8];
    b3 = b[7:6];
    b2 = b[5:4];
    b1 = b[3:2];
    b0 = b[1:0];
end

always @(posedge clk) begin
    // if (~rst_n) begin
    //     a7b7_f <= 0;

    //     a7b6_f <= 0;
    //     a6b7_f <= 0;

    //     a7b5_f <= 0;
    //     a6b6_f <= 0;
    //     a5b7_f <= 0;

    //     a7b4_f <= 0;
    //     a6b5_f <= 0;
    //     a5b6_f <= 0;
    //     a4b7_f <= 0;

    //     a7b3_f <= 0;
    //     a6b4_f <= 0;
    //     a5b5_f <= 0;
    //     a4b6_f <= 0;
    //     a3b7_f <= 0;

    //     a7b2_f <= 0;
    //     a6b3_f <= 0;
    //     a5b4_f <= 0;
    //     a4b5_f <= 0;
    //     a3b6_f <= 0;
    //     a2b7_f <= 0;

    //     a7b1_f <= 0;
    //     a6b2_f <= 0;
    //     a5b3_f <= 0;
    //     a4b4_f <= 0;
    //     a3b5_f <= 0;
    //     a2b6_f <= 0;
    //     a1b7_f <= 0;

    //     a7b0_f <= 0;
    //     a6b1_f <= 0;
    //     a5b2_f <= 0;
    //     a4b3_f <= 0;
    //     a3b4_f <= 0;
    //     a2b5_f <= 0;
    //     a1b6_f <= 0;
    //     a0b7_f <= 0;

    //     a6b0_f <= 0;
    //     a5b1_f <= 0;
    //     a4b2_f <= 0;
    //     a3b3_f <= 0;
    //     a2b4_f <= 0;
    //     a1b5_f <= 0;
    //     a0b6_f <= 0;

    //     a5b0_f <= 0;
    //     a4b1_f <= 0;
    //     a3b2_f <= 0;
    //     a2b3_f <= 0;
    //     a1b4_f <= 0;
    //     a0b5_f <= 0;

    //     a4b0_f <= 0;
    //     a3b1_f <= 0;
    //     a2b2_f <= 0;
    //     a1b3_f <= 0;
    //     a0b4_f <= 0;

    //     a3b0_f <= 0;
    //     a2b1_f <= 0;
    //     a1b2_f <= 0;
    //     a0b3_f <= 0;

    //     a2b0_f <= 0;
    //     a1b1_f <= 0;
    //     a0b2_f <= 0;

    //     a1b0_f <= 0;
    //     a0b1_f <= 0;

    //     a0b0_f <= 0;
    // end else begin
        a7b7_f <= a7*b7;

        a7b6_f <= a7*b6;
        a6b7_f <= a6*b7;

        a7b5_f <= a7*b5;
        a6b6_f <= a6*b6;
        a5b7_f <= a5*b7;

        a7b4_f <= a7*b4;
        a6b5_f <= a6*b5;
        a5b6_f <= a5*b6;
        a4b7_f <= a4*b7;

        a7b3_f <= a7*b3;
        a6b4_f <= a6*b4;
        a5b5_f <= a5*b5;
        a4b6_f <= a4*b6;
        a3b7_f <= a3*b7;

        a7b2_f <= a7*b2;
        a6b3_f <= a6*b3;
        a5b4_f <= a5*b4;
        a4b5_f <= a4*b5;
        a3b6_f <= a3*b6;
        a2b7_f <= a2*b7;

        a7b1_f <= a7*b1;
        a6b2_f <= a6*b2;
        a5b3_f <= a5*b3;
        a4b4_f <= a4*b4;
        a3b5_f <= a3*b5;
        a2b6_f <= a2*b6;
        a1b7_f <= a1*b7;

        a7b0_f <= a7*b0;
        a6b1_f <= a6*b1;
        a5b2_f <= a5*b2;
        a4b3_f <= a4*b3;
        a3b4_f <= a3*b4;
        a2b5_f <= a2*b5;
        a1b6_f <= a1*b6;
        a0b7_f <= a0*b7;

        a6b0_f <= a6*b0;
        a5b1_f <= a5*b1;
        a4b2_f <= a4*b2;
        a3b3_f <= a3*b3;
        a2b4_f <= a2*b4;
        a1b5_f <= a1*b5;
        a0b6_f <= a0*b6;

        a5b0_f <= a5*b0;
        a4b1_f <= a4*b1;
        a3b2_f <= a3*b2;
        a2b3_f <= a2*b3;
        a1b4_f <= a1*b4;
        a0b5_f <= a0*b5;

        a4b0_f <= a4*b0;
        a3b1_f <= a3*b1;
        a2b2_f <= a2*b2;
        a1b3_f <= a1*b3;
        a0b4_f <= a0*b4;

        a3b0_f <= a3*b0;
        a2b1_f <= a2*b1;
        a1b2_f <= a1*b2;
        a0b3_f <= a0*b3;

        a2b0_f <= a2*b0;
        a1b1_f <= a1*b1;
        a0b2_f <= a0*b2;

        a1b0_f <= a1*b0;
        a0b1_f <= a0*b1;

        a0b0_f <= a0*b0;
    //end
end 

always @(*) begin
    p14 = a7b7_f;//4
    p13 = a7b6_f + a6b7_f;//5
    p12 = (a7b5_f + a6b6_f) + a5b7_f;//6
    p11 = (a7b4_f + a6b5_f) + (a5b6_f + a4b7_f);//6
    p10 = ((a7b3_f + a6b4_f) + (a5b5_f + a4b6_f)) + a3b7_f;//7
    p9  = ((a7b2_f + a6b3_f) + (a5b4_f + a4b5_f)) + (a3b6_f + a2b7_f);//7
    p8  = ((a7b1_f + a6b2_f) + (a5b3_f + a4b4_f)) + ((a3b5_f + a2b6_f) + a1b7_f);//7
    p7  = ((a7b0_f + a6b1_f) + (a5b2_f + a4b3_f)) + ((a3b4_f + a2b5_f) + (a1b6_f + a0b7_f));//7
    p6  = ((a6b0_f + a5b1_f) + (a4b2_f + a3b3_f)) + ((a2b4_f + a1b5_f) + a0b6_f);//7
    p5  = ((a5b0_f + a4b1_f) + (a3b2_f + a2b3_f)) + (a1b4_f + a0b5_f);//7
    p4  = ((a4b0_f + a3b1_f) + (a2b2_f + a1b3_f)) + a0b4_f;//7
    p3  = (a3b0_f + a2b1_f) + (a1b2_f + a0b3_f);//6
    p2  = (a2b0_f + a1b1_f) + a0b2_f;//6
    p1  = a1b0_f + a0b1_f;//5
    p0  = a0b0_f;//4
end



// always @(*) begin
//     s7 = p14_f;//4
//     s6 = p12_f + (p13_f << 2);//7
//     s5 = p10_f + (p11_f << 2);//8
//     s4 = p8_f  + (p9_f  << 2);//9
//     s3 = p6_f  + (p7_f  << 2);//9
//     s2 = p4_f  + (p5_f  << 2);//9
//     s1 = p2_f  + (p3_f  << 2);//8
//     s0 = p0_f  + (p1_f  << 2);//7
// end

always @(*) begin
    s7 = p14;//4
    s6 = p12 + (p13 << 2);//7
    s5 = p10 + (p11 << 2);//8
    s4 = p8  + (p9  << 2);//9
    s3 = p6  + (p7  << 2);//9
    s2 = p4  + (p5  << 2);//9
    s1 = p2  + (p3  << 2);//8
    s0 = p0  + (p1  << 2);//7
end

always @(posedge clk) begin
    // if (~rst_n) begin
    //     s7_ff <= 0;
    //     s6_ff <= 0;
    //     s5_ff <= 0;
    //     s4_ff <= 0;
    //     s3_ff <= 0;
    //     s2_ff <= 0;
    //     s1_ff <= 0;
    //     s0_ff <= 0;
    // end else begin
        s7_ff <= s7;
        s6_ff <= s6;
        s5_ff <= s5;
        s4_ff <= s4;
        s3_ff <= s3;
        s2_ff <= s2;
        s1_ff <= s1;
        s0_ff <= s0;
    //end
end

always @(*) begin
    ss3 = s6_ff + (s7_ff << 4);//8+1
    ss2 = s4_ff + (s5_ff << 4);//12+1
    ss1 = s2_ff + (s3_ff << 4);//13+1
    ss0 = s0_ff + (s1_ff << 4);//12+1
end

// always @(*) begin
//     ss3 = s6 + (s7 << 4);//8+1
//     ss2 = s4 + (s5 << 4);//12+1
//     ss1 = s2 + (s3 << 4);//13+1
//     ss0 = s0 + (s1 << 4);//12+1
// end

//assign product_tmp = (ss0_ff + (ss1_ff << 8)) + ((ss2_ff + (ss3_ff << 8)) << 16);
assign product_tmp = (ss0 + (ss1 << 8)) + ((ss2 + (ss3 << 8)) << 16);

always @(posedge clk) begin
    // if (~rst_n) begin
    //     sign_bit_f <= 0;
    //     sign_bit_ff <= 0;
    // end else begin
        sign_bit_f <= sign_bit;
        sign_bit_ff <= sign_bit_f;
    //end
end

assign product = (sign_bit_ff)? (~(product_tmp) + 1) : product_tmp; ////sign_bit_n
//assign result_2 = product >>> 15;
assign result_3 = product >>> 15;
//---------------------------------------------------------------------

always @(*) begin /// Latch
    addend = 0;
    if (op_1 == ADD) begin
        addend = register[t_1];
    end else if (op_1 == ADDI) begin
        addend = imm_1;
    end
end

assign sum_1 = register[s_1] + addend;

//---------------------------------------------------------------------

//assign w_1 = (op_1 == ADDI)? t_1 : d_1;
always @(*) begin
    w_1 = d_1; // R type
    if (op_1 == ADDI) w_1 = t_1; // I type
    else if (op_1 == F) w_1 = 7; // f
end

//---------------------------------------------------------------------
// Pipeline reg. 1 to 2
always @(posedge clk) begin
    //if (~rst_n) begin
        //s_2 <= 0;
        //t_2 <= 0; //3
        //imm_2 <= 0; //5
        //op_2 <= 0;
        //f_2 <= 0;
        //w_2 <= 0;
        //nonnegative_2 <= 0;
        //result_2 <= 0;
    //end else begin
        //s_2 <= s_1;
        //t_2 <= t_1;
        //imm_2 <= imm_1;
        //op_2 <= op_1;
        f_2 <= f_1;
        w_2 <= w_1;
        //nonnegative_2 <= nonnegative_1;
        //result_2 <= result_1;
    //end
end

//assign s_2tmp = (~f_2)? s_2 : 0;
//---------------------------------------------------------------------
// ALU st2
/*
always @(*) begin
    case (op_2)
    SHL: data_2 = register[t_2] << shmt_2; //imm[10:6]
    SHR: data_2 = register[t_2] >>> shmt_2;
    RLU: data_2 = (nonnegative_2)? register[t_2] : 0;
    default: data_2 = 0;
    endcase
end
*/
//---------------------------------------------------------------------
// Pipeline reg. 2 to 3
always @(posedge clk) begin
    //if (~rst_n) begin
        //result_3 <= 0;
        //s_3 <= 0;
        //t_3 <= 0;
        //shmt_2 <= 0;
        //op_3 <= 0;
        //t_3 <= 0;
        //f_3 <= 0;
        //w_3 <= 0;
        //imm_3 <= 0;
        ///nonnegative_3 <= 0;
        //data_3 <= 0;
        //sum_3 <= 0;
    //end else begin
        //result_3 <= result_2;
        //s_3 <= s_2;
        //t_3 <= t_2;
        //shmt_2 <= shmt_1;
        //op_3 <= op_2;
        //t_3 <= t_2;
        f_3 <= f_2;
        w_3 <= w_2;
        //imm_3 <= imm_2;
        //nonnegative_3 <= nonnegative_2;
        //data_3 <= data_2;
        //sum_3 <= sum_2;
    //end
end

assign nonnegative_1 = (t_1 <= 5)? (register[t_1] >= 0) : 0;

assign shmt_1 = imm_1[10:6];

// always @(*) begin
//     case (op_3)
//     ADD, ADDI: w_data = sum_3;
//     MULT: w_data = result_3;
//     SHL:  w_data = register[t_3] << shmt_3;
//     SHR:  w_data = register[t_3] >>> shmt_3;
//     RLU: w_data = (nonnegative_3)? register[t_3] : 0;
//     LKRLU: w_data = (nonnegative_3)? register[t_3] : result_3;
//     default: w_data = 0;
//     endcase
// end


always @(*) begin
    case (op_1)
    ADD, ADDI: data_1 = sum_1;
    //MULT: w_data = sum_1;
    SHL:  data_1 = register[t_1] << shmt_1;
    SHR:  data_1 = register[t_1] >>> shmt_1;
    RLU, LKRLU: data_1 = (nonnegative_1)? register[t_1] : 0;
    //LKRLU: w_data = (nonnegative_1)? register[t_1] : result_3;
    default: data_1 = 0;
    endcase
end

always @(posedge clk) begin
    // if (~rst_n) begin
    //     data_2 <= 0;
    //     data_3 <= 0;
    // end else begin
        data_2 <= data_1;
        data_3 <= data_2;
    //end
end

//---------------------------------------------------------------------
//---------------------------------------------------------------------
// register

assign w_data = (m_3)? result_3 : data_3;

genvar i;
generate
    for (i = 0; i < 6; i = i + 1) begin
        always @(*) begin
            register_nxt[i] = 0;
            if (out_valid) begin
                if (i == w_3) begin
                    register_nxt[i] = w_data;
                end else begin
                    register_nxt[i] = register[i];
                end
            end
        end
        always @(posedge clk) begin
            register[i] <= register_nxt[i];
        end
    end
endgenerate
/*
always @(posedge clk) begin
    // if (~rst_n) begin
    //     register[5] <= 0;
    //     register[4] <= 0;
    //     register[3] <= 0;
    //     register[2] <= 0;
    //     register[1] <= 0;
    //     register[0] <= 0;
    // end else begin
        register[5] <= register_nxt[5];
        register[4] <= register_nxt[4];
        register[3] <= register_nxt[3];
        register[2] <= register_nxt[2];
        register[1] <= register_nxt[1];
        register[0] <= register_nxt[0];
    //end
end
*/
//---------------------------------------------------------------------
// output reg

always @(*) begin
    out_5 = 0;
    out_4 = 0;
    out_3 = 0;
    out_2 = 0;
    out_1 = 0;
    out_0 = 0;
    if (out_valid) begin
        out_5 = register[5];
        out_4 = register[4];
        out_3 = register[3];
        out_2 = register[2];
        out_1 = register[1];
        out_0 = register[0];
    end
end

//assign out_valid_tmp = (out_valid)? 1 : 0;

// assign out_5 = (out_valid)? register[5] : 0;
// assign out_4 = (out_valid)? register[4] : 0;
// assign out_3 = (out_valid)? register[3] : 0;
// assign out_2 = (out_valid)? register[2] : 0;
// assign out_1 = (out_valid)? register[1] : 0;
// assign out_0 = (out_valid)? register[0] : 0;

//out valid
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid <= 0;
        cnt <= 0;
    end else begin
        cnt <= (cnt !=0 || in_valid != out_valid)? cnt + 1 : 0;
		out_valid <= (cnt == 3)? out_valid + 1 : out_valid;
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_valid_1 <= 0;
        in_valid_2 <= 0;
        in_valid_3 <= 0;
        out_valid <= 0;
    end else begin
        in_valid_1 <= in_valid;
        in_valid_2 <= in_valid_1;
        in_valid_3 <= in_valid_2;
		out_valid  <= in_valid_3;
    end
end
*/
//instruction f
always @(posedge clk) begin
    //if (~rst_n) begin
        //f_3 <= 0;
        //f_4 <= 0;
    //end else begin
        //f_3 <= f_2;
        f_4 <= f_3;
    //end
end
assign instruction_fail = (out_valid)? f_4 : 0;

endmodule