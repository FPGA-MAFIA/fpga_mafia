
`include "macros.vh"

module accel_core_cr_mem 
import accel_core_pkg::*;
(
    input  logic       Clk,
    input  logic       Rst,
    // Core interface
    input  logic [31:0] data,
    input  logic [31:0] address,
    input  logic        wren,
    input  logic        rden,
    output logic [31:0] q,
    // Fabric interface
    //input  logic [31:0] address_b,
    //input  logic [31:0] data_b,
    //input  logic        wren_b,
    //output logic [31:0] q_b,
    // XOR example
    input  logic [7:0] xor_result,
    output logic [7:0] xor_inp1,
    output logic [7:0] xor_inp2,
    // MUL ACCEL
    input accel_outputs_t mul_outputs,
    output accel_inputs_t mul_inputs
);

t_cr cr;
t_cr next_cr;

assign xor_inp1 = cr.xor_inp1;
assign xor_inp2 = cr.xor_inp2;
assign mul_inputs.input_vec = cr.neuron_in;
assign mul_inputs.w1 = cr.w1;
assign mul_inputs.w2 = cr.w2;
assign mul_inputs.w3 = cr.w3;


// Data-Path signals
logic [31:0] pre_q;
//logic [31:0] pre_q_b;



`MAFIA_DFF(cr, next_cr, Clk)
//==============================
// Memory Access
//------------------------------
// 1. Access CR_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    if(Rst) begin 
        next_cr = 0;
    end else begin
        next_cr = cr;
        next_cr.xor_result = xor_result;
        // MUL ACCEL
        if(mul_outputs.done_layer) begin
            next_cr.neuron_out = mul_outputs.output_vec;
            next_cr.neuron_in.meta_data = '0;
            next_cr.neuron_in.data = mul_outputs.output_vec.data;
        end
        if(mul_outputs.release_w1)
            next_cr.w1.meta_data.in_use = 0;
        if(mul_outputs.release_w2)
            next_cr.w2.meta_data.in_use = 0;
        if(mul_outputs.release_w3)
            next_cr.w3.meta_data.in_use = 0;
            // WHAT ABOUT MOV_OUT_TO_IN?
    end
    if(wren) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_XOR_IN_1       : next_cr.xor_inp1       = data[7:0];//xor inp 1
            CR_XOR_IN_2       : next_cr.xor_inp2       = data[7:0];// xor inp 2
            // MUL ACCEL INPUT
                CR_MUL_IN_META    : begin 
                    next_cr.neuron_in.meta_data.matrix_col_num  = data[7:0]; //in metadata. NOT TRANSPOSED!
                    next_cr.neuron_in.meta_data.matrix_row_num  = data[15:8];
                    next_cr.neuron_in.meta_data.in_use_by_accel = data[16];
                    next_cr.neuron_in.meta_data.mov_out_to_in   = data[17];
                    next_cr.neuron_in.meta_data.output_ready    = data[18];
                end 
                CR_MUL_IN_0       : begin 
                    next_cr.neuron_in.data[0]   = data[7:0];
                    next_cr.neuron_in.data[1]   = data[15:8];
                    next_cr.neuron_in.data[2]   = data[23:16];
                    next_cr.neuron_in.data[3]   = data[31:24]; 
                end
                CR_MUL_IN_1       : begin 
                    next_cr.neuron_in.data[4]   = data[7:0];
                    next_cr.neuron_in.data[5]   = data[15:8];
                    next_cr.neuron_in.data[6]   = data[23:16];
                    next_cr.neuron_in.data[7]   = data[31:24]; 
                end
                CR_MUL_IN_2       : begin 
                    next_cr.neuron_in.data[8]   = data[7:0];
                    next_cr.neuron_in.data[9]   = data[15:8];
                    next_cr.neuron_in.data[10]  = data[23:16];
                    next_cr.neuron_in.data[11]  = data[31:24]; 
                end
                CR_MUL_IN_3       : begin 
                    next_cr.neuron_in.data[12]  = data[7:0];
                    next_cr.neuron_in.data[13]  = data[15:8];
                    next_cr.neuron_in.data[14]  = data[23:16];
                    next_cr.neuron_in.data[15]  = data[31:24]; 
                end
                CR_MUL_IN_4       : begin 
                    next_cr.neuron_in.data[16]  = data[7:0];
                    next_cr.neuron_in.data[17]  = data[15:8];
                    next_cr.neuron_in.data[18]  = data[23:16];
                    next_cr.neuron_in.data[19]  = data[31:24]; 
                end
                CR_MUL_IN_5       : begin 
                    next_cr.neuron_in.data[20]  = data[7:0];
                    next_cr.neuron_in.data[21]  = data[15:8];
                    next_cr.neuron_in.data[22]  = data[23:16];
                    next_cr.neuron_in.data[23]  = data[31:24]; 
                end
                CR_MUL_IN_6       : begin 
                    next_cr.neuron_in.data[24]  = data[7:0];
                    next_cr.neuron_in.data[25]  = data[15:8];
                    next_cr.neuron_in.data[26]  = data[23:16];
                    next_cr.neuron_in.data[27]  = data[31:24]; 
                end
                CR_MUL_IN_7       : begin 
                    next_cr.neuron_in.data[28]  = data[7:0];
                    next_cr.neuron_in.data[29]  = data[15:8];
                    next_cr.neuron_in.data[30]  = data[23:16];
                    next_cr.neuron_in.data[31]  = data[31:24]; 
                end
                CR_MUL_IN_8       : begin 
                    next_cr.neuron_in.data[32]  = data[7:0];
                    next_cr.neuron_in.data[33]  = data[15:8];
                    next_cr.neuron_in.data[34]  = data[23:16];
                    next_cr.neuron_in.data[35]  = data[31:24]; 
                end
                CR_MUL_IN_9       : begin 
                    next_cr.neuron_in.data[36]  = data[7:0];
                    next_cr.neuron_in.data[37]  = data[15:8];
                    next_cr.neuron_in.data[38]  = data[23:16];
                    next_cr.neuron_in.data[39]  = data[31:24]; 
                end
                CR_MUL_IN_10      : begin 
                    next_cr.neuron_in.data[40]  = data[7:0];
                    next_cr.neuron_in.data[41]  = data[15:8];
                    next_cr.neuron_in.data[42]  = data[23:16];
                    next_cr.neuron_in.data[43]  = data[31:24]; 
                end
                CR_MUL_IN_11      : begin 
                    next_cr.neuron_in.data[44]  = data[7:0];
                    next_cr.neuron_in.data[45]  = data[15:8];
                    next_cr.neuron_in.data[46]  = data[23:16];
                    next_cr.neuron_in.data[47]  = data[31:24]; 
                end
                CR_MUL_IN_12      : begin 
                    next_cr.neuron_in.data[48]  = data[7:0];
                    next_cr.neuron_in.data[49]  = data[15:8];
                    next_cr.neuron_in.data[50]  = data[23:16];
                    next_cr.neuron_in.data[51]  = data[31:24]; 
                end
                CR_MUL_IN_13      : begin 
                    next_cr.neuron_in.data[52]  = data[7:0];
                    next_cr.neuron_in.data[53]  = data[15:8];
                    next_cr.neuron_in.data[54]  = data[23:16];
                    next_cr.neuron_in.data[55]  = data[31:24]; 
                end
                CR_MUL_IN_14      : begin 
                    next_cr.neuron_in.data[56]  = data[7:0];
                    next_cr.neuron_in.data[57]  = data[15:8];
                    next_cr.neuron_in.data[58]  = data[23:16];
                    next_cr.neuron_in.data[59]  = data[31:24]; 
                end
                CR_MUL_IN_15      : begin 
                    next_cr.neuron_in.data[60]  = data[7:0];
                    next_cr.neuron_in.data[61]  = data[15:8];
                    next_cr.neuron_in.data[62]  = data[23:16];
                    next_cr.neuron_in.data[63]  = data[31:24]; 
                end
                CR_MUL_IN_16      : begin 
                    next_cr.neuron_in.data[64]  = data[7:0];
                    next_cr.neuron_in.data[65]  = data[15:8];
                    next_cr.neuron_in.data[66]  = data[23:16];
                    next_cr.neuron_in.data[67]  = data[31:24]; 
                end
                CR_MUL_IN_17      : begin 
                    next_cr.neuron_in.data[68]  = data[7:0];
                    next_cr.neuron_in.data[69]  = data[15:8];
                    next_cr.neuron_in.data[70]  = data[23:16];
                    next_cr.neuron_in.data[71]  = data[31:24]; 
                end
                CR_MUL_IN_18      : begin 
                    next_cr.neuron_in.data[72]  = data[7:0];
                    next_cr.neuron_in.data[73]  = data[15:8];
                    next_cr.neuron_in.data[74]  = data[23:16];
                    next_cr.neuron_in.data[75]  = data[31:24]; 
                end
                CR_MUL_IN_19      : begin 
                    next_cr.neuron_in.data[76]  = data[7:0];
                    next_cr.neuron_in.data[77]  = data[15:8];
                    next_cr.neuron_in.data[78]  = data[23:16];
                    next_cr.neuron_in.data[79]  = data[31:24]; 
                end
                CR_MUL_IN_20      : begin 
                    next_cr.neuron_in.data[80]  = data[7:0];
                    next_cr.neuron_in.data[81]  = data[15:8];
                    next_cr.neuron_in.data[82]  = data[23:16];
                    next_cr.neuron_in.data[83]  = data[31:24]; 
                end
                CR_MUL_IN_21      : begin 
                    next_cr.neuron_in.data[84]  = data[7:0];
                    next_cr.neuron_in.data[85]  = data[15:8];
                    next_cr.neuron_in.data[86]  = data[23:16];
                    next_cr.neuron_in.data[87]  = data[31:24]; 
                end
                CR_MUL_IN_22      : begin 
                    next_cr.neuron_in.data[88]  = data[7:0];
                    next_cr.neuron_in.data[89]  = data[15:8];
                    next_cr.neuron_in.data[90]  = data[23:16];
                    next_cr.neuron_in.data[91]  = data[31:24]; 
                end
                CR_MUL_IN_23      : begin 
                    next_cr.neuron_in.data[92]  = data[7:0];
                    next_cr.neuron_in.data[93]  = data[15:8];
                    next_cr.neuron_in.data[94]  = data[23:16];
                    next_cr.neuron_in.data[95]  = data[31:24]; 
                end
                CR_MUL_IN_24      : begin 
                    next_cr.neuron_in.data[96]  = data[7:0];
                    next_cr.neuron_in.data[97]  = data[15:8];
                    next_cr.neuron_in.data[98]  = data[23:16];
                    next_cr.neuron_in.data[99]  = data[31:24]; 
                end
                CR_MUL_IN_25      : begin 
                    next_cr.neuron_in.data[100] = data[7:0];
                    next_cr.neuron_in.data[101] = data[15:8];
                    next_cr.neuron_in.data[102] = data[23:16];
                    next_cr.neuron_in.data[103] = data[31:24]; 
                end
                CR_MUL_IN_26      : begin 
                    next_cr.neuron_in.data[104] = data[7:0];
                    next_cr.neuron_in.data[105] = data[15:8];
                    next_cr.neuron_in.data[106] = data[23:16];
                    next_cr.neuron_in.data[107] = data[31:24]; 
                end
                CR_MUL_IN_27      : begin 
                    next_cr.neuron_in.data[108] = data[7:0];
                    next_cr.neuron_in.data[109] = data[15:8];
                    next_cr.neuron_in.data[110] = data[23:16];
                    next_cr.neuron_in.data[111] = data[31:24]; 
                end
                CR_MUL_IN_28      : begin 
                    next_cr.neuron_in.data[112] = data[7:0];
                    next_cr.neuron_in.data[113] = data[15:8];
                    next_cr.neuron_in.data[114] = data[23:16];
                    next_cr.neuron_in.data[115] = data[31:24]; 
                end
                CR_MUL_IN_29      : begin 
                    next_cr.neuron_in.data[116] = data[7:0];
                    next_cr.neuron_in.data[117] = data[15:8];
                    next_cr.neuron_in.data[118] = data[23:16];
                    next_cr.neuron_in.data[119] = data[31:24]; 
                end
                CR_MUL_IN_30      : begin 
                    next_cr.neuron_in.data[120] = data[7:0];
                    next_cr.neuron_in.data[121] = data[15:8];
                    next_cr.neuron_in.data[122] = data[23:16];
                    next_cr.neuron_in.data[123] = data[31:24]; 
                end
                CR_MUL_IN_31      : begin 
                    next_cr.neuron_in.data[124] = data[7:0];
                    next_cr.neuron_in.data[125] = data[15:8];
                    next_cr.neuron_in.data[126] = data[23:16];
                    next_cr.neuron_in.data[127] = data[31:24]; 
                end
                CR_MUL_IN_32      : begin 
                    next_cr.neuron_in.data[128] = data[7:0];
                    next_cr.neuron_in.data[129] = data[15:8];
                    next_cr.neuron_in.data[130] = data[23:16];
                    next_cr.neuron_in.data[131] = data[31:24]; 
                end
                CR_MUL_IN_33      : begin 
                    next_cr.neuron_in.data[132] = data[7:0];
                    next_cr.neuron_in.data[133] = data[15:8];
                    next_cr.neuron_in.data[134] = data[23:16];
                    next_cr.neuron_in.data[135] = data[31:24]; 
                end
                CR_MUL_IN_34      : begin 
                    next_cr.neuron_in.data[136] = data[7:0];
                    next_cr.neuron_in.data[137] = data[15:8];
                    next_cr.neuron_in.data[138] = data[23:16];
                    next_cr.neuron_in.data[139] = data[31:24]; 
                end
                CR_MUL_IN_35      : begin 
                    next_cr.neuron_in.data[140] = data[7:0];
                    next_cr.neuron_in.data[141] = data[15:8];
                    next_cr.neuron_in.data[142] = data[23:16];
                    next_cr.neuron_in.data[143] = data[31:24]; 
                end
                CR_MUL_IN_36      : begin 
                    next_cr.neuron_in.data[144] = data[7:0];
                    next_cr.neuron_in.data[145] = data[15:8];
                    next_cr.neuron_in.data[146] = data[23:16];
                    next_cr.neuron_in.data[147] = data[31:24]; 
                end
                CR_MUL_IN_37      : begin 
                    next_cr.neuron_in.data[148] = data[7:0];
                    next_cr.neuron_in.data[149] = data[15:8];
                    next_cr.neuron_in.data[150] = data[23:16];
                    next_cr.neuron_in.data[151] = data[31:24]; 
                end
                CR_MUL_IN_38      : begin 
                    next_cr.neuron_in.data[152] = data[7:0];
                    next_cr.neuron_in.data[153] = data[15:8];
                    next_cr.neuron_in.data[154] = data[23:16];
                    next_cr.neuron_in.data[155] = data[31:24]; 
                end
                CR_MUL_IN_39      : begin 
                    next_cr.neuron_in.data[156] = data[7:0];
                    next_cr.neuron_in.data[157] = data[15:8];
                    next_cr.neuron_in.data[158] = data[23:16];
                    next_cr.neuron_in.data[159] = data[31:24]; 
                end
                CR_MUL_IN_40      : begin 
                    next_cr.neuron_in.data[160] = data[7:0];
                    next_cr.neuron_in.data[161] = data[15:8];
                    next_cr.neuron_in.data[162] = data[23:16];
                    next_cr.neuron_in.data[163] = data[31:24]; 
                end
                CR_MUL_IN_41      : begin 
                    next_cr.neuron_in.data[164] = data[7:0];
                    next_cr.neuron_in.data[165] = data[15:8];
                    next_cr.neuron_in.data[166] = data[23:16];
                    next_cr.neuron_in.data[167] = data[31:24]; 
                end
                CR_MUL_IN_42      : begin 
                    next_cr.neuron_in.data[168] = data[7:0];
                    next_cr.neuron_in.data[169] = data[15:8];
                    next_cr.neuron_in.data[170] = data[23:16];
                    next_cr.neuron_in.data[171] = data[31:24]; 
                end
                CR_MUL_IN_43      : begin 
                    next_cr.neuron_in.data[172] = data[7:0];
                    next_cr.neuron_in.data[173] = data[15:8];
                    next_cr.neuron_in.data[174] = data[23:16];
                    next_cr.neuron_in.data[175] = data[31:24]; 
                end
                CR_MUL_IN_44      : begin 
                    next_cr.neuron_in.data[176] = data[7:0];
                    next_cr.neuron_in.data[177] = data[15:8];
                    next_cr.neuron_in.data[178] = data[23:16];
                    next_cr.neuron_in.data[179] = data[31:24]; 
                end
                CR_MUL_IN_45      : begin 
                    next_cr.neuron_in.data[180] = data[7:0];
                    next_cr.neuron_in.data[181] = data[15:8];
                    next_cr.neuron_in.data[182] = data[23:16];
                    next_cr.neuron_in.data[183] = data[31:24]; 
                end
                CR_MUL_IN_46      : begin 
                    next_cr.neuron_in.data[184] = data[7:0];
                    next_cr.neuron_in.data[185] = data[15:8];
                    next_cr.neuron_in.data[186] = data[23:16];
                    next_cr.neuron_in.data[187] = data[31:24]; 
                end
                CR_MUL_IN_47      : begin 
                    next_cr.neuron_in.data[188] = data[7:0];
                    next_cr.neuron_in.data[189] = data[15:8];
                    next_cr.neuron_in.data[190] = data[23:16];
                    next_cr.neuron_in.data[191] = data[31:24]; 
                end
                CR_MUL_IN_48      : begin 
                    next_cr.neuron_in.data[192] = data[7:0];
                    next_cr.neuron_in.data[193] = data[15:8];
                    next_cr.neuron_in.data[194] = data[23:16];
                    next_cr.neuron_in.data[195] = data[31:24]; 
                end
                CR_MUL_IN_49      : begin 
                    next_cr.neuron_in.data[196] = data[7:0];
                    next_cr.neuron_in.data[197] = data[15:8];
                    next_cr.neuron_in.data[198] = data[23:16];
                    next_cr.neuron_in.data[199] = data[31:24]; 
                end
                CR_MUL_IN_50      : begin 
                    next_cr.neuron_in.data[200] = data[7:0];
                    next_cr.neuron_in.data[201] = data[15:8];
                    next_cr.neuron_in.data[202] = data[23:16];
                    next_cr.neuron_in.data[203] = data[31:24]; 
                end
                CR_MUL_IN_51      : begin 
                    next_cr.neuron_in.data[204] = data[7:0];
                    next_cr.neuron_in.data[205] = data[15:8];
                    next_cr.neuron_in.data[206] = data[23:16];
                    next_cr.neuron_in.data[207] = data[31:24]; 
                end
                CR_MUL_IN_52      : begin 
                    next_cr.neuron_in.data[208] = data[7:0];
                    next_cr.neuron_in.data[209] = data[15:8];
                    next_cr.neuron_in.data[210] = data[23:16];
                    next_cr.neuron_in.data[211] = data[31:24]; 
                end
                CR_MUL_IN_53      : begin 
                    next_cr.neuron_in.data[212] = data[7:0];
                    next_cr.neuron_in.data[213] = data[15:8];
                    next_cr.neuron_in.data[214] = data[23:16];
                    next_cr.neuron_in.data[215] = data[31:24]; 
                end
                CR_MUL_IN_54      : begin 
                    next_cr.neuron_in.data[216] = data[7:0];
                    next_cr.neuron_in.data[217] = data[15:8];
                    next_cr.neuron_in.data[218] = data[23:16];
                    next_cr.neuron_in.data[219] = data[31:24]; 
                end
                CR_MUL_IN_55      : begin 
                    next_cr.neuron_in.data[220] = data[7:0];
                    next_cr.neuron_in.data[221] = data[15:8];
                    next_cr.neuron_in.data[222] = data[23:16];
                    next_cr.neuron_in.data[223] = data[31:24]; 
                end
                CR_MUL_IN_56      : begin 
                    next_cr.neuron_in.data[224] = data[7:0];
                    next_cr.neuron_in.data[225] = data[15:8];
                    next_cr.neuron_in.data[226] = data[23:16];
                    next_cr.neuron_in.data[227] = data[31:24]; 
                end
                CR_MUL_IN_57      : begin 
                    next_cr.neuron_in.data[228] = data[7:0];
                    next_cr.neuron_in.data[229] = data[15:8];
                    next_cr.neuron_in.data[230] = data[23:16];
                    next_cr.neuron_in.data[231] = data[31:24]; 
                end
                CR_MUL_IN_58      : begin 
                    next_cr.neuron_in.data[232] = data[7:0];
                    next_cr.neuron_in.data[233] = data[15:8];
                    next_cr.neuron_in.data[234] = data[23:16];
                    next_cr.neuron_in.data[235] = data[31:24]; 
                end
                CR_MUL_IN_59      : begin 
                    next_cr.neuron_in.data[236] = data[7:0];
                    next_cr.neuron_in.data[237] = data[15:8];
                    next_cr.neuron_in.data[238] = data[23:16];
                    next_cr.neuron_in.data[239] = data[31:24]; 
                end
                CR_MUL_IN_60      : begin 
                    next_cr.neuron_in.data[240] = data[7:0];
                    next_cr.neuron_in.data[241] = data[15:8];
                    next_cr.neuron_in.data[242] = data[23:16];
                    next_cr.neuron_in.data[243] = data[31:24]; 
                end
                CR_MUL_IN_61      : begin 
                    next_cr.neuron_in.data[244] = data[7:0];
                    next_cr.neuron_in.data[245] = data[15:8];
                    next_cr.neuron_in.data[246] = data[23:16];
                    next_cr.neuron_in.data[247] = data[31:24]; 
                end
                CR_MUL_IN_62      : begin 
                    next_cr.neuron_in.data[248] = data[7:0];
                    next_cr.neuron_in.data[249] = data[15:8];
                    next_cr.neuron_in.data[250] = data[23:16];
                    next_cr.neuron_in.data[251] = data[31:24]; 
                end

            // W1
                CR_MUL_W1_META    : begin
                    next_cr.w1.meta_data.neuron_idx = data[7:0]; //in metadata
                    next_cr.w1.meta_data.data_len   = data[15:8];
                    next_cr.w1.meta_data.in_use     = data[16];
                end
                CR_MUL_W1_0       : begin 
                    next_cr.w1.data[0]   = data[7:0];
                    next_cr.w1.data[1]   = data[15:8];
                    next_cr.w1.data[2]   = data[23:16];
                    next_cr.w1.data[3]   = data[31:24]; 
                end
                CR_MUL_W1_1       : begin 
                    next_cr.w1.data[4]   = data[7:0];
                    next_cr.w1.data[5]   = data[15:8];
                    next_cr.w1.data[6]   = data[23:16];
                    next_cr.w1.data[7]   = data[31:24]; 
                end
                CR_MUL_W1_2       : begin 
                    next_cr.w1.data[8]   = data[7:0];
                    next_cr.w1.data[9]   = data[15:8];
                    next_cr.w1.data[10]  = data[23:16];
                    next_cr.w1.data[11]  = data[31:24]; 
                end
                CR_MUL_W1_3       : begin 
                    next_cr.w1.data[12]  = data[7:0];
                    next_cr.w1.data[13]  = data[15:8];
                    next_cr.w1.data[14]  = data[23:16];
                    next_cr.w1.data[15]  = data[31:24]; 
                end
                CR_MUL_W1_4       : begin 
                    next_cr.w1.data[16]  = data[7:0];
                    next_cr.w1.data[17]  = data[15:8];
                    next_cr.w1.data[18]  = data[23:16];
                    next_cr.w1.data[19]  = data[31:24]; 
                end
                CR_MUL_W1_5       : begin 
                    next_cr.w1.data[20]  = data[7:0];
                    next_cr.w1.data[21]  = data[15:8];
                    next_cr.w1.data[22]  = data[23:16];
                    next_cr.w1.data[23]  = data[31:24]; 
                end
                CR_MUL_W1_6       : begin 
                    next_cr.w1.data[24]  = data[7:0];
                    next_cr.w1.data[25]  = data[15:8];
                    next_cr.w1.data[26]  = data[23:16];
                    next_cr.w1.data[27]  = data[31:24]; 
                end
                CR_MUL_W1_7       : begin 
                    next_cr.w1.data[28]  = data[7:0];
                    next_cr.w1.data[29]  = data[15:8];
                    next_cr.w1.data[30]  = data[23:16];
                    next_cr.w1.data[31]  = data[31:24]; 
                end
                CR_MUL_W1_8       : begin 
                    next_cr.w1.data[32]  = data[7:0];
                    next_cr.w1.data[33]  = data[15:8];
                    next_cr.w1.data[34]  = data[23:16];
                    next_cr.w1.data[35]  = data[31:24]; 
                end
                CR_MUL_W1_9       : begin 
                    next_cr.w1.data[36]  = data[7:0];
                    next_cr.w1.data[37]  = data[15:8];
                    next_cr.w1.data[38]  = data[23:16];
                    next_cr.w1.data[39]  = data[31:24]; 
                end
                CR_MUL_W1_10      : begin 
                    next_cr.w1.data[40]  = data[7:0];
                    next_cr.w1.data[41]  = data[15:8];
                    next_cr.w1.data[42]  = data[23:16];
                    next_cr.w1.data[43]  = data[31:24]; 
                end
                CR_MUL_W1_11      : begin 
                    next_cr.w1.data[44]  = data[7:0];
                    next_cr.w1.data[45]  = data[15:8];
                    next_cr.w1.data[46]  = data[23:16];
                    next_cr.w1.data[47]  = data[31:24]; 
                end
                CR_MUL_W1_12      : begin 
                    next_cr.w1.data[48]  = data[7:0];
                    next_cr.w1.data[49]  = data[15:8];
                    next_cr.w1.data[50]  = data[23:16];
                    next_cr.w1.data[51]  = data[31:24]; 
                end
                CR_MUL_W1_13      : begin 
                    next_cr.w1.data[52]  = data[7:0];
                    next_cr.w1.data[53]  = data[15:8];
                    next_cr.w1.data[54]  = data[23:16];
                    next_cr.w1.data[55]  = data[31:24]; 
                end
                CR_MUL_W1_14      : begin 
                    next_cr.w1.data[56]  = data[7:0];
                    next_cr.w1.data[57]  = data[15:8];
                    next_cr.w1.data[58]  = data[23:16];
                    next_cr.w1.data[59]  = data[31:24]; 
                end
                CR_MUL_W1_15      : begin 
                    next_cr.w1.data[60]  = data[7:0];
                    next_cr.w1.data[61]  = data[15:8];
                    next_cr.w1.data[62]  = data[23:16];
                    next_cr.w1.data[63]  = data[31:24]; 
                end
                CR_MUL_W1_16      : begin 
                    next_cr.w1.data[64]  = data[7:0];
                    next_cr.w1.data[65]  = data[15:8];
                    next_cr.w1.data[66]  = data[23:16];
                    next_cr.w1.data[67]  = data[31:24]; 
                end
                CR_MUL_W1_17      : begin 
                    next_cr.w1.data[68]  = data[7:0];
                    next_cr.w1.data[69]  = data[15:8];
                    next_cr.w1.data[70]  = data[23:16];
                    next_cr.w1.data[71]  = data[31:24]; 
                end
                CR_MUL_W1_18      : begin 
                    next_cr.w1.data[72]  = data[7:0];
                    next_cr.w1.data[73]  = data[15:8];
                    next_cr.w1.data[74]  = data[23:16];
                    next_cr.w1.data[75]  = data[31:24]; 
                end
                CR_MUL_W1_19      : begin 
                    next_cr.w1.data[76]  = data[7:0];
                    next_cr.w1.data[77]  = data[15:8];
                    next_cr.w1.data[78]  = data[23:16];
                    next_cr.w1.data[79]  = data[31:24]; 
                end
                CR_MUL_W1_20      : begin 
                    next_cr.w1.data[80]  = data[7:0];
                    next_cr.w1.data[81]  = data[15:8];
                    next_cr.w1.data[82]  = data[23:16];
                    next_cr.w1.data[83]  = data[31:24]; 
                end
                CR_MUL_W1_21      : begin 
                    next_cr.w1.data[84]  = data[7:0];
                    next_cr.w1.data[85]  = data[15:8];
                    next_cr.w1.data[86]  = data[23:16];
                    next_cr.w1.data[87]  = data[31:24]; 
                end
                CR_MUL_W1_22      : begin 
                    next_cr.w1.data[88]  = data[7:0];
                    next_cr.w1.data[89]  = data[15:8];
                    next_cr.w1.data[90]  = data[23:16];
                    next_cr.w1.data[91]  = data[31:24]; 
                end
                CR_MUL_W1_23      : begin 
                    next_cr.w1.data[92]  = data[7:0];
                    next_cr.w1.data[93]  = data[15:8];
                    next_cr.w1.data[94]  = data[23:16];
                    next_cr.w1.data[95]  = data[31:24]; 
                end
                CR_MUL_W1_24      : begin 
                    next_cr.w1.data[96]  = data[7:0];
                    next_cr.w1.data[97]  = data[15:8];
                    next_cr.w1.data[98]  = data[23:16];
                    next_cr.w1.data[99]  = data[31:24]; 
                end
                CR_MUL_W1_25      : begin 
                    next_cr.w1.data[100] = data[7:0];
                    next_cr.w1.data[101] = data[15:8];
                    next_cr.w1.data[102] = data[23:16];
                    next_cr.w1.data[103] = data[31:24]; 
                end
                CR_MUL_W1_26      : begin 
                    next_cr.w1.data[104] = data[7:0];
                    next_cr.w1.data[105] = data[15:8];
                    next_cr.w1.data[106] = data[23:16];
                    next_cr.w1.data[107] = data[31:24]; 
                end
                CR_MUL_W1_27      : begin 
                    next_cr.w1.data[108] = data[7:0];
                    next_cr.w1.data[109] = data[15:8];
                    next_cr.w1.data[110] = data[23:16];
                    next_cr.w1.data[111] = data[31:24]; 
                end
                CR_MUL_W1_28      : begin 
                    next_cr.w1.data[112] = data[7:0];
                    next_cr.w1.data[113] = data[15:8];
                    next_cr.w1.data[114] = data[23:16];
                    next_cr.w1.data[115] = data[31:24]; 
                end
                CR_MUL_W1_29      : begin 
                    next_cr.w1.data[116] = data[7:0];
                    next_cr.w1.data[117] = data[15:8];
                    next_cr.w1.data[118] = data[23:16];
                    next_cr.w1.data[119] = data[31:24]; 
                end
                CR_MUL_W1_30      : begin 
                    next_cr.w1.data[120] = data[7:0];
                    next_cr.w1.data[121] = data[15:8];
                    next_cr.w1.data[122] = data[23:16];
                    next_cr.w1.data[123] = data[31:24]; 
                end
                CR_MUL_W1_31      : begin 
                    next_cr.w1.data[124] = data[7:0];
                    next_cr.w1.data[125] = data[15:8];
                    next_cr.w1.data[126] = data[23:16];
                    next_cr.w1.data[127] = data[31:24]; 
                end
                CR_MUL_W1_32      : begin 
                    next_cr.w1.data[128] = data[7:0];
                    next_cr.w1.data[129] = data[15:8];
                    next_cr.w1.data[130] = data[23:16];
                    next_cr.w1.data[131] = data[31:24]; 
                end
                CR_MUL_W1_33      : begin 
                    next_cr.w1.data[132] = data[7:0];
                    next_cr.w1.data[133] = data[15:8];
                    next_cr.w1.data[134] = data[23:16];
                    next_cr.w1.data[135] = data[31:24]; 
                end
                CR_MUL_W1_34      : begin 
                    next_cr.w1.data[136] = data[7:0];
                    next_cr.w1.data[137] = data[15:8];
                    next_cr.w1.data[138] = data[23:16];
                    next_cr.w1.data[139] = data[31:24]; 
                end
                CR_MUL_W1_35      : begin 
                    next_cr.w1.data[140] = data[7:0];
                    next_cr.w1.data[141] = data[15:8];
                    next_cr.w1.data[142] = data[23:16];
                    next_cr.w1.data[143] = data[31:24]; 
                end
                CR_MUL_W1_36      : begin 
                    next_cr.w1.data[144] = data[7:0];
                    next_cr.w1.data[145] = data[15:8];
                    next_cr.w1.data[146] = data[23:16];
                    next_cr.w1.data[147] = data[31:24]; 
                end
                CR_MUL_W1_37      : begin 
                    next_cr.w1.data[148] = data[7:0];
                    next_cr.w1.data[149] = data[15:8];
                    next_cr.w1.data[150] = data[23:16];
                    next_cr.w1.data[151] = data[31:24]; 
                end
                CR_MUL_W1_38      : begin 
                    next_cr.w1.data[152] = data[7:0];
                    next_cr.w1.data[153] = data[15:8];
                    next_cr.w1.data[154] = data[23:16];
                    next_cr.w1.data[155] = data[31:24]; 
                end
                CR_MUL_W1_39      : begin 
                    next_cr.w1.data[156] = data[7:0];
                    next_cr.w1.data[157] = data[15:8];
                    next_cr.w1.data[158] = data[23:16];
                    next_cr.w1.data[159] = data[31:24]; 
                end
                CR_MUL_W1_40      : begin 
                    next_cr.w1.data[160] = data[7:0];
                    next_cr.w1.data[161] = data[15:8];
                    next_cr.w1.data[162] = data[23:16];
                    next_cr.w1.data[163] = data[31:24]; 
                end
                CR_MUL_W1_41      : begin 
                    next_cr.w1.data[164] = data[7:0];
                    next_cr.w1.data[165] = data[15:8];
                    next_cr.w1.data[166] = data[23:16];
                    next_cr.w1.data[167] = data[31:24]; 
                end
                CR_MUL_W1_42      : begin 
                    next_cr.w1.data[168] = data[7:0];
                    next_cr.w1.data[169] = data[15:8];
                    next_cr.w1.data[170] = data[23:16];
                    next_cr.w1.data[171] = data[31:24]; 
                end
                CR_MUL_W1_43      : begin 
                    next_cr.w1.data[172] = data[7:0];
                    next_cr.w1.data[173] = data[15:8];
                    next_cr.w1.data[174] = data[23:16];
                    next_cr.w1.data[175] = data[31:24]; 
                end
                CR_MUL_W1_44      : begin 
                    next_cr.w1.data[176] = data[7:0];
                    next_cr.w1.data[177] = data[15:8];
                    next_cr.w1.data[178] = data[23:16];
                    next_cr.w1.data[179] = data[31:24]; 
                end
                CR_MUL_W1_45      : begin 
                    next_cr.w1.data[180] = data[7:0];
                    next_cr.w1.data[181] = data[15:8];
                    next_cr.w1.data[182] = data[23:16];
                    next_cr.w1.data[183] = data[31:24]; 
                end
                CR_MUL_W1_46      : begin 
                    next_cr.w1.data[184] = data[7:0];
                    next_cr.w1.data[185] = data[15:8];
                    next_cr.w1.data[186] = data[23:16];
                    next_cr.w1.data[187] = data[31:24]; 
                end
                CR_MUL_W1_47      : begin 
                    next_cr.w1.data[188] = data[7:0];
                    next_cr.w1.data[189] = data[15:8];
                    next_cr.w1.data[190] = data[23:16];
                    next_cr.w1.data[191] = data[31:24]; 
                end
                CR_MUL_W1_48      : begin 
                    next_cr.w1.data[192] = data[7:0];
                    next_cr.w1.data[193] = data[15:8];
                    next_cr.w1.data[194] = data[23:16];
                    next_cr.w1.data[195] = data[31:24]; 
                end
                CR_MUL_W1_49      : begin 
                    next_cr.w1.data[196] = data[7:0];
                    next_cr.w1.data[197] = data[15:8];
                    next_cr.w1.data[198] = data[23:16];
                    next_cr.w1.data[199] = data[31:24]; 
                end
                CR_MUL_W1_50      : begin 
                    next_cr.w1.data[200] = data[7:0];
                    next_cr.w1.data[201] = data[15:8];
                    next_cr.w1.data[202] = data[23:16];
                    next_cr.w1.data[203] = data[31:24]; 
                end
                CR_MUL_W1_51      : begin 
                    next_cr.w1.data[204] = data[7:0];
                    next_cr.w1.data[205] = data[15:8];
                    next_cr.w1.data[206] = data[23:16];
                    next_cr.w1.data[207] = data[31:24]; 
                end
                CR_MUL_W1_52      : begin 
                    next_cr.w1.data[208] = data[7:0];
                    next_cr.w1.data[209] = data[15:8];
                    next_cr.w1.data[210] = data[23:16];
                    next_cr.w1.data[211] = data[31:24]; 
                end
                CR_MUL_W1_53      : begin 
                    next_cr.w1.data[212] = data[7:0];
                    next_cr.w1.data[213] = data[15:8];
                    next_cr.w1.data[214] = data[23:16];
                    next_cr.w1.data[215] = data[31:24]; 
                end
                CR_MUL_W1_54      : begin 
                    next_cr.w1.data[216] = data[7:0];
                    next_cr.w1.data[217] = data[15:8];
                    next_cr.w1.data[218] = data[23:16];
                    next_cr.w1.data[219] = data[31:24]; 
                end
                CR_MUL_W1_55      : begin 
                    next_cr.w1.data[220] = data[7:0];
                    next_cr.w1.data[221] = data[15:8];
                    next_cr.w1.data[222] = data[23:16];
                    next_cr.w1.data[223] = data[31:24]; 
                end
                CR_MUL_W1_56      : begin 
                    next_cr.w1.data[224] = data[7:0];
                    next_cr.w1.data[225] = data[15:8];
                    next_cr.w1.data[226] = data[23:16];
                    next_cr.w1.data[227] = data[31:24]; 
                end
                CR_MUL_W1_57      : begin 
                    next_cr.w1.data[228] = data[7:0];
                    next_cr.w1.data[229] = data[15:8];
                    next_cr.w1.data[230] = data[23:16];
                    next_cr.w1.data[231] = data[31:24]; 
                end
                CR_MUL_W1_58      : begin 
                    next_cr.w1.data[232] = data[7:0];
                    next_cr.w1.data[233] = data[15:8];
                    next_cr.w1.data[234] = data[23:16];
                    next_cr.w1.data[235] = data[31:24]; 
                end
                CR_MUL_W1_59      : begin 
                    next_cr.w1.data[236] = data[7:0];
                    next_cr.w1.data[237] = data[15:8];
                    next_cr.w1.data[238] = data[23:16];
                    next_cr.w1.data[239] = data[31:24]; 
                end
                CR_MUL_W1_60      : begin 
                    next_cr.w1.data[240] = data[7:0];
                    next_cr.w1.data[241] = data[15:8];
                    next_cr.w1.data[242] = data[23:16];
                    next_cr.w1.data[243] = data[31:24]; 
                end
                CR_MUL_W1_61      : begin 
                    next_cr.w1.data[244] = data[7:0];
                    next_cr.w1.data[245] = data[15:8];
                    next_cr.w1.data[246] = data[23:16];
                    next_cr.w1.data[247] = data[31:24]; 
                end
                CR_MUL_W1_62      : begin 
                    next_cr.w1.data[248] = data[7:0];
                    next_cr.w1.data[249] = data[15:8];
                    next_cr.w1.data[250] = data[23:16];
                    next_cr.w1.data[251] = data[31:24]; 
                end
            
            // W2
                CR_MUL_W2_META    :  begin
                    next_cr.w2.meta_data.neuron_idx = data[7:0]; //in metadata
                    next_cr.w2.meta_data.data_len   = data[15:8];
                    next_cr.w2.meta_data.in_use     = data[16];
                end
                CR_MUL_W2_0       : begin 
                    next_cr.w2.data[0]   = data[7:0];
                    next_cr.w2.data[1]   = data[15:8];
                    next_cr.w2.data[2]   = data[23:16];
                    next_cr.w2.data[3]   = data[31:24]; 
                end
                CR_MUL_W2_1       : begin 
                    next_cr.w2.data[4]   = data[7:0];
                    next_cr.w2.data[5]   = data[15:8];
                    next_cr.w2.data[6]   = data[23:16];
                    next_cr.w2.data[7]   = data[31:24]; 
                end
                CR_MUL_W2_2       : begin 
                    next_cr.w2.data[8]   = data[7:0];
                    next_cr.w2.data[9]   = data[15:8];
                    next_cr.w2.data[10]  = data[23:16];
                    next_cr.w2.data[11]  = data[31:24]; 
                end
                CR_MUL_W2_3       : begin 
                    next_cr.w2.data[12]  = data[7:0];
                    next_cr.w2.data[13]  = data[15:8];
                    next_cr.w2.data[14]  = data[23:16];
                    next_cr.w2.data[15]  = data[31:24]; 
                end
                CR_MUL_W2_4       : begin 
                    next_cr.w2.data[16]  = data[7:0];
                    next_cr.w2.data[17]  = data[15:8];
                    next_cr.w2.data[18]  = data[23:16];
                    next_cr.w2.data[19]  = data[31:24]; 
                end
                CR_MUL_W2_5       : begin 
                    next_cr.w2.data[20]  = data[7:0];
                    next_cr.w2.data[21]  = data[15:8];
                    next_cr.w2.data[22]  = data[23:16];
                    next_cr.w2.data[23]  = data[31:24]; 
                end
                CR_MUL_W2_6       : begin 
                    next_cr.w2.data[24]  = data[7:0];
                    next_cr.w2.data[25]  = data[15:8];
                    next_cr.w2.data[26]  = data[23:16];
                    next_cr.w2.data[27]  = data[31:24]; 
                end
                CR_MUL_W2_7       : begin 
                    next_cr.w2.data[28]  = data[7:0];
                    next_cr.w2.data[29]  = data[15:8];
                    next_cr.w2.data[30]  = data[23:16];
                    next_cr.w2.data[31]  = data[31:24]; 
                end
                CR_MUL_W2_8       : begin 
                    next_cr.w2.data[32]  = data[7:0];
                    next_cr.w2.data[33]  = data[15:8];
                    next_cr.w2.data[34]  = data[23:16];
                    next_cr.w2.data[35]  = data[31:24]; 
                end
                CR_MUL_W2_9       : begin 
                    next_cr.w2.data[36]  = data[7:0];
                    next_cr.w2.data[37]  = data[15:8];
                    next_cr.w2.data[38]  = data[23:16];
                    next_cr.w2.data[39]  = data[31:24]; 
                end
                CR_MUL_W2_10      : begin 
                    next_cr.w2.data[40]  = data[7:0];
                    next_cr.w2.data[41]  = data[15:8];
                    next_cr.w2.data[42]  = data[23:16];
                    next_cr.w2.data[43]  = data[31:24]; 
                end
                CR_MUL_W2_11      : begin 
                    next_cr.w2.data[44]  = data[7:0];
                    next_cr.w2.data[45]  = data[15:8];
                    next_cr.w2.data[46]  = data[23:16];
                    next_cr.w2.data[47]  = data[31:24]; 
                end
                CR_MUL_W2_12      : begin 
                    next_cr.w2.data[48]  = data[7:0];
                    next_cr.w2.data[49]  = data[15:8];
                    next_cr.w2.data[50]  = data[23:16];
                    next_cr.w2.data[51]  = data[31:24]; 
                end
                CR_MUL_W2_13      : begin 
                    next_cr.w2.data[52]  = data[7:0];
                    next_cr.w2.data[53]  = data[15:8];
                    next_cr.w2.data[54]  = data[23:16];
                    next_cr.w2.data[55]  = data[31:24]; 
                end
                CR_MUL_W2_14      : begin 
                    next_cr.w2.data[56]  = data[7:0];
                    next_cr.w2.data[57]  = data[15:8];
                    next_cr.w2.data[58]  = data[23:16];
                    next_cr.w2.data[59]  = data[31:24]; 
                end
                CR_MUL_W2_15      : begin 
                    next_cr.w2.data[60]  = data[7:0];
                    next_cr.w2.data[61]  = data[15:8];
                    next_cr.w2.data[62]  = data[23:16];
                    next_cr.w2.data[63]  = data[31:24]; 
                end
                CR_MUL_W2_16      : begin 
                    next_cr.w2.data[64]  = data[7:0];
                    next_cr.w2.data[65]  = data[15:8];
                    next_cr.w2.data[66]  = data[23:16];
                    next_cr.w2.data[67]  = data[31:24]; 
                end
                CR_MUL_W2_17      : begin 
                    next_cr.w2.data[68]  = data[7:0];
                    next_cr.w2.data[69]  = data[15:8];
                    next_cr.w2.data[70]  = data[23:16];
                    next_cr.w2.data[71]  = data[31:24]; 
                end
                CR_MUL_W2_18      : begin 
                    next_cr.w2.data[72]  = data[7:0];
                    next_cr.w2.data[73]  = data[15:8];
                    next_cr.w2.data[74]  = data[23:16];
                    next_cr.w2.data[75]  = data[31:24]; 
                end
                CR_MUL_W2_19      : begin 
                    next_cr.w2.data[76]  = data[7:0];
                    next_cr.w2.data[77]  = data[15:8];
                    next_cr.w2.data[78]  = data[23:16];
                    next_cr.w2.data[79]  = data[31:24]; 
                end
                CR_MUL_W2_20      : begin 
                    next_cr.w2.data[80]  = data[7:0];
                    next_cr.w2.data[81]  = data[15:8];
                    next_cr.w2.data[82]  = data[23:16];
                    next_cr.w2.data[83]  = data[31:24]; 
                end
                CR_MUL_W2_21      : begin 
                    next_cr.w2.data[84]  = data[7:0];
                    next_cr.w2.data[85]  = data[15:8];
                    next_cr.w2.data[86]  = data[23:16];
                    next_cr.w2.data[87]  = data[31:24]; 
                end
                CR_MUL_W2_22      : begin 
                    next_cr.w2.data[88]  = data[7:0];
                    next_cr.w2.data[89]  = data[15:8];
                    next_cr.w2.data[90]  = data[23:16];
                    next_cr.w2.data[91]  = data[31:24]; 
                end
                CR_MUL_W2_23      : begin 
                    next_cr.w2.data[92]  = data[7:0];
                    next_cr.w2.data[93]  = data[15:8];
                    next_cr.w2.data[94]  = data[23:16];
                    next_cr.w2.data[95]  = data[31:24]; 
                end
                CR_MUL_W2_24      : begin 
                    next_cr.w2.data[96]  = data[7:0];
                    next_cr.w2.data[97]  = data[15:8];
                    next_cr.w2.data[98]  = data[23:16];
                    next_cr.w2.data[99]  = data[31:24]; 
                end
                CR_MUL_W2_25      : begin 
                    next_cr.w2.data[100] = data[7:0];
                    next_cr.w2.data[101] = data[15:8];
                    next_cr.w2.data[102] = data[23:16];
                    next_cr.w2.data[103] = data[31:24]; 
                end
                CR_MUL_W2_26      : begin 
                    next_cr.w2.data[104] = data[7:0];
                    next_cr.w2.data[105] = data[15:8];
                    next_cr.w2.data[106] = data[23:16];
                    next_cr.w2.data[107] = data[31:24]; 
                end
                CR_MUL_W2_27      : begin 
                    next_cr.w2.data[108] = data[7:0];
                    next_cr.w2.data[109] = data[15:8];
                    next_cr.w2.data[110] = data[23:16];
                    next_cr.w2.data[111] = data[31:24]; 
                end
                CR_MUL_W2_28      : begin 
                    next_cr.w2.data[112] = data[7:0];
                    next_cr.w2.data[113] = data[15:8];
                    next_cr.w2.data[114] = data[23:16];
                    next_cr.w2.data[115] = data[31:24]; 
                end
                CR_MUL_W2_29      : begin 
                    next_cr.w2.data[116] = data[7:0];
                    next_cr.w2.data[117] = data[15:8];
                    next_cr.w2.data[118] = data[23:16];
                    next_cr.w2.data[119] = data[31:24]; 
                end
                CR_MUL_W2_30      : begin 
                    next_cr.w2.data[120] = data[7:0];
                    next_cr.w2.data[121] = data[15:8];
                    next_cr.w2.data[122] = data[23:16];
                    next_cr.w2.data[123] = data[31:24]; 
                end
                CR_MUL_W2_31      : begin 
                    next_cr.w2.data[124] = data[7:0];
                    next_cr.w2.data[125] = data[15:8];
                    next_cr.w2.data[126] = data[23:16];
                    next_cr.w2.data[127] = data[31:24]; 
                end
                CR_MUL_W2_32      : begin 
                    next_cr.w2.data[128] = data[7:0];
                    next_cr.w2.data[129] = data[15:8];
                    next_cr.w2.data[130] = data[23:16];
                    next_cr.w2.data[131] = data[31:24]; 
                end
                CR_MUL_W2_33      : begin 
                    next_cr.w2.data[132] = data[7:0];
                    next_cr.w2.data[133] = data[15:8];
                    next_cr.w2.data[134] = data[23:16];
                    next_cr.w2.data[135] = data[31:24]; 
                end
                CR_MUL_W2_34      : begin 
                    next_cr.w2.data[136] = data[7:0];
                    next_cr.w2.data[137] = data[15:8];
                    next_cr.w2.data[138] = data[23:16];
                    next_cr.w2.data[139] = data[31:24]; 
                end
                CR_MUL_W2_35      : begin 
                    next_cr.w2.data[140] = data[7:0];
                    next_cr.w2.data[141] = data[15:8];
                    next_cr.w2.data[142] = data[23:16];
                    next_cr.w2.data[143] = data[31:24]; 
                end
                CR_MUL_W2_36      : begin 
                    next_cr.w2.data[144] = data[7:0];
                    next_cr.w2.data[145] = data[15:8];
                    next_cr.w2.data[146] = data[23:16];
                    next_cr.w2.data[147] = data[31:24]; 
                end
                CR_MUL_W2_37      : begin 
                    next_cr.w2.data[148] = data[7:0];
                    next_cr.w2.data[149] = data[15:8];
                    next_cr.w2.data[150] = data[23:16];
                    next_cr.w2.data[151] = data[31:24]; 
                end
                CR_MUL_W2_38      : begin 
                    next_cr.w2.data[152] = data[7:0];
                    next_cr.w2.data[153] = data[15:8];
                    next_cr.w2.data[154] = data[23:16];
                    next_cr.w2.data[155] = data[31:24]; 
                end
                CR_MUL_W2_39      : begin 
                    next_cr.w2.data[156] = data[7:0];
                    next_cr.w2.data[157] = data[15:8];
                    next_cr.w2.data[158] = data[23:16];
                    next_cr.w2.data[159] = data[31:24]; 
                end
                CR_MUL_W2_40      : begin 
                    next_cr.w2.data[160] = data[7:0];
                    next_cr.w2.data[161] = data[15:8];
                    next_cr.w2.data[162] = data[23:16];
                    next_cr.w2.data[163] = data[31:24]; 
                end
                CR_MUL_W2_41      : begin 
                    next_cr.w2.data[164] = data[7:0];
                    next_cr.w2.data[165] = data[15:8];
                    next_cr.w2.data[166] = data[23:16];
                    next_cr.w2.data[167] = data[31:24]; 
                end
                CR_MUL_W2_42      : begin 
                    next_cr.w2.data[168] = data[7:0];
                    next_cr.w2.data[169] = data[15:8];
                    next_cr.w2.data[170] = data[23:16];
                    next_cr.w2.data[171] = data[31:24]; 
                end
                CR_MUL_W2_43      : begin 
                    next_cr.w2.data[172] = data[7:0];
                    next_cr.w2.data[173] = data[15:8];
                    next_cr.w2.data[174] = data[23:16];
                    next_cr.w2.data[175] = data[31:24]; 
                end
                CR_MUL_W2_44      : begin 
                    next_cr.w2.data[176] = data[7:0];
                    next_cr.w2.data[177] = data[15:8];
                    next_cr.w2.data[178] = data[23:16];
                    next_cr.w2.data[179] = data[31:24]; 
                end
                CR_MUL_W2_45      : begin 
                    next_cr.w2.data[180] = data[7:0];
                    next_cr.w2.data[181] = data[15:8];
                    next_cr.w2.data[182] = data[23:16];
                    next_cr.w2.data[183] = data[31:24]; 
                end
                CR_MUL_W2_46      : begin 
                    next_cr.w2.data[184] = data[7:0];
                    next_cr.w2.data[185] = data[15:8];
                    next_cr.w2.data[186] = data[23:16];
                    next_cr.w2.data[187] = data[31:24]; 
                end
                CR_MUL_W2_47      : begin 
                    next_cr.w2.data[188] = data[7:0];
                    next_cr.w2.data[189] = data[15:8];
                    next_cr.w2.data[190] = data[23:16];
                    next_cr.w2.data[191] = data[31:24]; 
                end
                CR_MUL_W2_48      : begin 
                    next_cr.w2.data[192] = data[7:0];
                    next_cr.w2.data[193] = data[15:8];
                    next_cr.w2.data[194] = data[23:16];
                    next_cr.w2.data[195] = data[31:24]; 
                end
                CR_MUL_W2_49      : begin 
                    next_cr.w2.data[196] = data[7:0];
                    next_cr.w2.data[197] = data[15:8];
                    next_cr.w2.data[198] = data[23:16];
                    next_cr.w2.data[199] = data[31:24]; 
                end
                CR_MUL_W2_50      : begin 
                    next_cr.w2.data[200] = data[7:0];
                    next_cr.w2.data[201] = data[15:8];
                    next_cr.w2.data[202] = data[23:16];
                    next_cr.w2.data[203] = data[31:24]; 
                end
                CR_MUL_W2_51      : begin 
                    next_cr.w2.data[204] = data[7:0];
                    next_cr.w2.data[205] = data[15:8];
                    next_cr.w2.data[206] = data[23:16];
                    next_cr.w2.data[207] = data[31:24]; 
                end
                CR_MUL_W2_52      : begin 
                    next_cr.w2.data[208] = data[7:0];
                    next_cr.w2.data[209] = data[15:8];
                    next_cr.w2.data[210] = data[23:16];
                    next_cr.w2.data[211] = data[31:24]; 
                end
                CR_MUL_W2_53      : begin 
                    next_cr.w2.data[212] = data[7:0];
                    next_cr.w2.data[213] = data[15:8];
                    next_cr.w2.data[214] = data[23:16];
                    next_cr.w2.data[215] = data[31:24]; 
                end
                CR_MUL_W2_54      : begin 
                    next_cr.w2.data[216] = data[7:0];
                    next_cr.w2.data[217] = data[15:8];
                    next_cr.w2.data[218] = data[23:16];
                    next_cr.w2.data[219] = data[31:24]; 
                end
                CR_MUL_W2_55      : begin 
                    next_cr.w2.data[220] = data[7:0];
                    next_cr.w2.data[221] = data[15:8];
                    next_cr.w2.data[222] = data[23:16];
                    next_cr.w2.data[223] = data[31:24]; 
                end
                CR_MUL_W2_56      : begin 
                    next_cr.w2.data[224] = data[7:0];
                    next_cr.w2.data[225] = data[15:8];
                    next_cr.w2.data[226] = data[23:16];
                    next_cr.w2.data[227] = data[31:24]; 
                end
                CR_MUL_W2_57      : begin 
                    next_cr.w2.data[228] = data[7:0];
                    next_cr.w2.data[229] = data[15:8];
                    next_cr.w2.data[230] = data[23:16];
                    next_cr.w2.data[231] = data[31:24]; 
                end
                CR_MUL_W2_58      : begin 
                    next_cr.w2.data[232] = data[7:0];
                    next_cr.w2.data[233] = data[15:8];
                    next_cr.w2.data[234] = data[23:16];
                    next_cr.w2.data[235] = data[31:24]; 
                end
                CR_MUL_W2_59      : begin 
                    next_cr.w2.data[236] = data[7:0];
                    next_cr.w2.data[237] = data[15:8];
                    next_cr.w2.data[238] = data[23:16];
                    next_cr.w2.data[239] = data[31:24]; 
                end
                CR_MUL_W2_60      : begin 
                    next_cr.w2.data[240] = data[7:0];
                    next_cr.w2.data[241] = data[15:8];
                    next_cr.w2.data[242] = data[23:16];
                    next_cr.w2.data[243] = data[31:24]; 
                end
                CR_MUL_W2_61      : begin 
                    next_cr.w2.data[244] = data[7:0];
                    next_cr.w2.data[245] = data[15:8];
                    next_cr.w2.data[246] = data[23:16];
                    next_cr.w2.data[247] = data[31:24]; 
                end
                CR_MUL_W2_62      : begin 
                    next_cr.w2.data[248] = data[7:0];
                    next_cr.w2.data[249] = data[15:8];
                    next_cr.w2.data[250] = data[23:16];
                    next_cr.w2.data[251] = data[31:24]; 
                end
            // W3
                CR_MUL_W3_META    :  begin
                    next_cr.w3.meta_data.neuron_idx = data[7:0]; //in metadata
                    next_cr.w3.meta_data.data_len   = data[15:8];
                    next_cr.w3.meta_data.in_use     = data[16];
                end
                CR_MUL_W3_0       : begin 
                    next_cr.w3.data[0]   = data[7:0];
                    next_cr.w3.data[1]   = data[15:8];
                    next_cr.w3.data[2]   = data[23:16];
                    next_cr.w3.data[3]   = data[31:24]; 
                end
                CR_MUL_W3_1       : begin 
                    next_cr.w3.data[4]   = data[7:0];
                    next_cr.w3.data[5]   = data[15:8];
                    next_cr.w3.data[6]   = data[23:16];
                    next_cr.w3.data[7]   = data[31:24]; 
                end
                CR_MUL_W3_2       : begin 
                    next_cr.w3.data[8]   = data[7:0];
                    next_cr.w3.data[9]   = data[15:8];
                    next_cr.w3.data[10]  = data[23:16];
                    next_cr.w3.data[11]  = data[31:24]; 
                end
                CR_MUL_W3_3       : begin 
                    next_cr.w3.data[12]  = data[7:0];
                    next_cr.w3.data[13]  = data[15:8];
                    next_cr.w3.data[14]  = data[23:16];
                    next_cr.w3.data[15]  = data[31:24]; 
                end
                CR_MUL_W3_4       : begin 
                    next_cr.w3.data[16]  = data[7:0];
                    next_cr.w3.data[17]  = data[15:8];
                    next_cr.w3.data[18]  = data[23:16];
                    next_cr.w3.data[19]  = data[31:24]; 
                end
                CR_MUL_W3_5       : begin 
                    next_cr.w3.data[20]  = data[7:0];
                    next_cr.w3.data[21]  = data[15:8];
                    next_cr.w3.data[22]  = data[23:16];
                    next_cr.w3.data[23]  = data[31:24]; 
                end
                CR_MUL_W3_6       : begin 
                    next_cr.w3.data[24]  = data[7:0];
                    next_cr.w3.data[25]  = data[15:8];
                    next_cr.w3.data[26]  = data[23:16];
                    next_cr.w3.data[27]  = data[31:24]; 
                end
                CR_MUL_W3_7       : begin 
                    next_cr.w3.data[28]  = data[7:0];
                    next_cr.w3.data[29]  = data[15:8];
                    next_cr.w3.data[30]  = data[23:16];
                    next_cr.w3.data[31]  = data[31:24]; 
                end
                CR_MUL_W3_8       : begin 
                    next_cr.w3.data[32]  = data[7:0];
                    next_cr.w3.data[33]  = data[15:8];
                    next_cr.w3.data[34]  = data[23:16];
                    next_cr.w3.data[35]  = data[31:24]; 
                end
                CR_MUL_W3_9       : begin 
                    next_cr.w3.data[36]  = data[7:0];
                    next_cr.w3.data[37]  = data[15:8];
                    next_cr.w3.data[38]  = data[23:16];
                    next_cr.w3.data[39]  = data[31:24]; 
                end
                CR_MUL_W3_10      : begin 
                    next_cr.w3.data[40]  = data[7:0];
                    next_cr.w3.data[41]  = data[15:8];
                    next_cr.w3.data[42]  = data[23:16];
                    next_cr.w3.data[43]  = data[31:24]; 
                end
                CR_MUL_W3_11      : begin 
                    next_cr.w3.data[44]  = data[7:0];
                    next_cr.w3.data[45]  = data[15:8];
                    next_cr.w3.data[46]  = data[23:16];
                    next_cr.w3.data[47]  = data[31:24]; 
                end
                CR_MUL_W3_12      : begin 
                    next_cr.w3.data[48]  = data[7:0];
                    next_cr.w3.data[49]  = data[15:8];
                    next_cr.w3.data[50]  = data[23:16];
                    next_cr.w3.data[51]  = data[31:24]; 
                end
                CR_MUL_W3_13      : begin 
                    next_cr.w3.data[52]  = data[7:0];
                    next_cr.w3.data[53]  = data[15:8];
                    next_cr.w3.data[54]  = data[23:16];
                    next_cr.w3.data[55]  = data[31:24]; 
                end
                CR_MUL_W3_14      : begin 
                    next_cr.w3.data[56]  = data[7:0];
                    next_cr.w3.data[57]  = data[15:8];
                    next_cr.w3.data[58]  = data[23:16];
                    next_cr.w3.data[59]  = data[31:24]; 
                end
                CR_MUL_W3_15      : begin 
                    next_cr.w3.data[60]  = data[7:0];
                    next_cr.w3.data[61]  = data[15:8];
                    next_cr.w3.data[62]  = data[23:16];
                    next_cr.w3.data[63]  = data[31:24]; 
                end
                CR_MUL_W3_16      : begin 
                    next_cr.w3.data[64]  = data[7:0];
                    next_cr.w3.data[65]  = data[15:8];
                    next_cr.w3.data[66]  = data[23:16];
                    next_cr.w3.data[67]  = data[31:24]; 
                end
                CR_MUL_W3_17      : begin 
                    next_cr.w3.data[68]  = data[7:0];
                    next_cr.w3.data[69]  = data[15:8];
                    next_cr.w3.data[70]  = data[23:16];
                    next_cr.w3.data[71]  = data[31:24]; 
                end
                CR_MUL_W3_18      : begin 
                    next_cr.w3.data[72]  = data[7:0];
                    next_cr.w3.data[73]  = data[15:8];
                    next_cr.w3.data[74]  = data[23:16];
                    next_cr.w3.data[75]  = data[31:24]; 
                end
                CR_MUL_W3_19      : begin 
                    next_cr.w3.data[76]  = data[7:0];
                    next_cr.w3.data[77]  = data[15:8];
                    next_cr.w3.data[78]  = data[23:16];
                    next_cr.w3.data[79]  = data[31:24]; 
                end
                CR_MUL_W3_20      : begin 
                    next_cr.w3.data[80]  = data[7:0];
                    next_cr.w3.data[81]  = data[15:8];
                    next_cr.w3.data[82]  = data[23:16];
                    next_cr.w3.data[83]  = data[31:24]; 
                end
                CR_MUL_W3_21      : begin 
                    next_cr.w3.data[84]  = data[7:0];
                    next_cr.w3.data[85]  = data[15:8];
                    next_cr.w3.data[86]  = data[23:16];
                    next_cr.w3.data[87]  = data[31:24]; 
                end
                CR_MUL_W3_22      : begin 
                    next_cr.w3.data[88]  = data[7:0];
                    next_cr.w3.data[89]  = data[15:8];
                    next_cr.w3.data[90]  = data[23:16];
                    next_cr.w3.data[91]  = data[31:24]; 
                end
                CR_MUL_W3_23      : begin 
                    next_cr.w3.data[92]  = data[7:0];
                    next_cr.w3.data[93]  = data[15:8];
                    next_cr.w3.data[94]  = data[23:16];
                    next_cr.w3.data[95]  = data[31:24]; 
                end
                CR_MUL_W3_24      : begin 
                    next_cr.w3.data[96]  = data[7:0];
                    next_cr.w3.data[97]  = data[15:8];
                    next_cr.w3.data[98]  = data[23:16];
                    next_cr.w3.data[99]  = data[31:24]; 
                end
                CR_MUL_W3_25      : begin 
                    next_cr.w3.data[100] = data[7:0];
                    next_cr.w3.data[101] = data[15:8];
                    next_cr.w3.data[102] = data[23:16];
                    next_cr.w3.data[103] = data[31:24]; 
                end
                CR_MUL_W3_26      : begin 
                    next_cr.w3.data[104] = data[7:0];
                    next_cr.w3.data[105] = data[15:8];
                    next_cr.w3.data[106] = data[23:16];
                    next_cr.w3.data[107] = data[31:24]; 
                end
                CR_MUL_W3_27      : begin 
                    next_cr.w3.data[108] = data[7:0];
                    next_cr.w3.data[109] = data[15:8];
                    next_cr.w3.data[110] = data[23:16];
                    next_cr.w3.data[111] = data[31:24]; 
                end
                CR_MUL_W3_28      : begin 
                    next_cr.w3.data[112] = data[7:0];
                    next_cr.w3.data[113] = data[15:8];
                    next_cr.w3.data[114] = data[23:16];
                    next_cr.w3.data[115] = data[31:24]; 
                end
                CR_MUL_W3_29      : begin 
                    next_cr.w3.data[116] = data[7:0];
                    next_cr.w3.data[117] = data[15:8];
                    next_cr.w3.data[118] = data[23:16];
                    next_cr.w3.data[119] = data[31:24]; 
                end
                CR_MUL_W3_30      : begin 
                    next_cr.w3.data[120] = data[7:0];
                    next_cr.w3.data[121] = data[15:8];
                    next_cr.w3.data[122] = data[23:16];
                    next_cr.w3.data[123] = data[31:24]; 
                end
                CR_MUL_W3_31      : begin 
                    next_cr.w3.data[124] = data[7:0];
                    next_cr.w3.data[125] = data[15:8];
                    next_cr.w3.data[126] = data[23:16];
                    next_cr.w3.data[127] = data[31:24]; 
                end
                CR_MUL_W3_32      : begin 
                    next_cr.w3.data[128] = data[7:0];
                    next_cr.w3.data[129] = data[15:8];
                    next_cr.w3.data[130] = data[23:16];
                    next_cr.w3.data[131] = data[31:24]; 
                end
                CR_MUL_W3_33      : begin 
                    next_cr.w3.data[132] = data[7:0];
                    next_cr.w3.data[133] = data[15:8];
                    next_cr.w3.data[134] = data[23:16];
                    next_cr.w3.data[135] = data[31:24]; 
                end
                CR_MUL_W3_34      : begin 
                    next_cr.w3.data[136] = data[7:0];
                    next_cr.w3.data[137] = data[15:8];
                    next_cr.w3.data[138] = data[23:16];
                    next_cr.w3.data[139] = data[31:24]; 
                end
                CR_MUL_W3_35      : begin 
                    next_cr.w3.data[140] = data[7:0];
                    next_cr.w3.data[141] = data[15:8];
                    next_cr.w3.data[142] = data[23:16];
                    next_cr.w3.data[143] = data[31:24]; 
                end
                CR_MUL_W3_36      : begin 
                    next_cr.w3.data[144] = data[7:0];
                    next_cr.w3.data[145] = data[15:8];
                    next_cr.w3.data[146] = data[23:16];
                    next_cr.w3.data[147] = data[31:24]; 
                end
                CR_MUL_W3_37      : begin 
                    next_cr.w3.data[148] = data[7:0];
                    next_cr.w3.data[149] = data[15:8];
                    next_cr.w3.data[150] = data[23:16];
                    next_cr.w3.data[151] = data[31:24]; 
                end
                CR_MUL_W3_38      : begin 
                    next_cr.w3.data[152] = data[7:0];
                    next_cr.w3.data[153] = data[15:8];
                    next_cr.w3.data[154] = data[23:16];
                    next_cr.w3.data[155] = data[31:24]; 
                end
                CR_MUL_W3_39      : begin 
                    next_cr.w3.data[156] = data[7:0];
                    next_cr.w3.data[157] = data[15:8];
                    next_cr.w3.data[158] = data[23:16];
                    next_cr.w3.data[159] = data[31:24]; 
                end
                CR_MUL_W3_40      : begin 
                    next_cr.w3.data[160] = data[7:0];
                    next_cr.w3.data[161] = data[15:8];
                    next_cr.w3.data[162] = data[23:16];
                    next_cr.w3.data[163] = data[31:24]; 
                end
                CR_MUL_W3_41      : begin 
                    next_cr.w3.data[164] = data[7:0];
                    next_cr.w3.data[165] = data[15:8];
                    next_cr.w3.data[166] = data[23:16];
                    next_cr.w3.data[167] = data[31:24]; 
                end
                CR_MUL_W3_42      : begin 
                    next_cr.w3.data[168] = data[7:0];
                    next_cr.w3.data[169] = data[15:8];
                    next_cr.w3.data[170] = data[23:16];
                    next_cr.w3.data[171] = data[31:24]; 
                end
                CR_MUL_W3_43      : begin 
                    next_cr.w3.data[172] = data[7:0];
                    next_cr.w3.data[173] = data[15:8];
                    next_cr.w3.data[174] = data[23:16];
                    next_cr.w3.data[175] = data[31:24]; 
                end
                CR_MUL_W3_44      : begin 
                    next_cr.w3.data[176] = data[7:0];
                    next_cr.w3.data[177] = data[15:8];
                    next_cr.w3.data[178] = data[23:16];
                    next_cr.w3.data[179] = data[31:24]; 
                end
                CR_MUL_W3_45      : begin 
                    next_cr.w3.data[180] = data[7:0];
                    next_cr.w3.data[181] = data[15:8];
                    next_cr.w3.data[182] = data[23:16];
                    next_cr.w3.data[183] = data[31:24]; 
                end
                CR_MUL_W3_46      : begin 
                    next_cr.w3.data[184] = data[7:0];
                    next_cr.w3.data[185] = data[15:8];
                    next_cr.w3.data[186] = data[23:16];
                    next_cr.w3.data[187] = data[31:24]; 
                end
                CR_MUL_W3_47      : begin 
                    next_cr.w3.data[188] = data[7:0];
                    next_cr.w3.data[189] = data[15:8];
                    next_cr.w3.data[190] = data[23:16];
                    next_cr.w3.data[191] = data[31:24]; 
                end
                CR_MUL_W3_48      : begin 
                    next_cr.w3.data[192] = data[7:0];
                    next_cr.w3.data[193] = data[15:8];
                    next_cr.w3.data[194] = data[23:16];
                    next_cr.w3.data[195] = data[31:24]; 
                end
                CR_MUL_W3_49      : begin 
                    next_cr.w3.data[196] = data[7:0];
                    next_cr.w3.data[197] = data[15:8];
                    next_cr.w3.data[198] = data[23:16];
                    next_cr.w3.data[199] = data[31:24]; 
                end
                CR_MUL_W3_50      : begin 
                    next_cr.w3.data[200] = data[7:0];
                    next_cr.w3.data[201] = data[15:8];
                    next_cr.w3.data[202] = data[23:16];
                    next_cr.w3.data[203] = data[31:24]; 
                end
                CR_MUL_W3_51      : begin 
                    next_cr.w3.data[204] = data[7:0];
                    next_cr.w3.data[205] = data[15:8];
                    next_cr.w3.data[206] = data[23:16];
                    next_cr.w3.data[207] = data[31:24]; 
                end
                CR_MUL_W3_52      : begin 
                    next_cr.w3.data[208] = data[7:0];
                    next_cr.w3.data[209] = data[15:8];
                    next_cr.w3.data[210] = data[23:16];
                    next_cr.w3.data[211] = data[31:24]; 
                end
                CR_MUL_W3_53      : begin 
                    next_cr.w3.data[212] = data[7:0];
                    next_cr.w3.data[213] = data[15:8];
                    next_cr.w3.data[214] = data[23:16];
                    next_cr.w3.data[215] = data[31:24]; 
                end
                CR_MUL_W3_54      : begin 
                    next_cr.w3.data[216] = data[7:0];
                    next_cr.w3.data[217] = data[15:8];
                    next_cr.w3.data[218] = data[23:16];
                    next_cr.w3.data[219] = data[31:24]; 
                end
                CR_MUL_W3_55      : begin 
                    next_cr.w3.data[220] = data[7:0];
                    next_cr.w3.data[221] = data[15:8];
                    next_cr.w3.data[222] = data[23:16];
                    next_cr.w3.data[223] = data[31:24]; 
                end
                CR_MUL_W3_56      : begin 
                    next_cr.w3.data[224] = data[7:0];
                    next_cr.w3.data[225] = data[15:8];
                    next_cr.w3.data[226] = data[23:16];
                    next_cr.w3.data[227] = data[31:24]; 
                end
                CR_MUL_W3_57      : begin 
                    next_cr.w3.data[228] = data[7:0];
                    next_cr.w3.data[229] = data[15:8];
                    next_cr.w3.data[230] = data[23:16];
                    next_cr.w3.data[231] = data[31:24]; 
                end
                CR_MUL_W3_58      : begin 
                    next_cr.w3.data[232] = data[7:0];
                    next_cr.w3.data[233] = data[15:8];
                    next_cr.w3.data[234] = data[23:16];
                    next_cr.w3.data[235] = data[31:24]; 
                end
                CR_MUL_W3_59      : begin 
                    next_cr.w3.data[236] = data[7:0];
                    next_cr.w3.data[237] = data[15:8];
                    next_cr.w3.data[238] = data[23:16];
                    next_cr.w3.data[239] = data[31:24]; 
                end
                CR_MUL_W3_60      : begin 
                    next_cr.w3.data[240] = data[7:0];
                    next_cr.w3.data[241] = data[15:8];
                    next_cr.w3.data[242] = data[23:16];
                    next_cr.w3.data[243] = data[31:24]; 
                end
                CR_MUL_W3_61      : begin 
                    next_cr.w3.data[244] = data[7:0];
                    next_cr.w3.data[245] = data[15:8];
                    next_cr.w3.data[246] = data[23:16];
                    next_cr.w3.data[247] = data[31:24]; 
                end
                CR_MUL_W3_62      : begin 
                    next_cr.w3.data[248] = data[7:0];
                    next_cr.w3.data[249] = data[15:8];
                    next_cr.w3.data[250] = data[23:16];
                    next_cr.w3.data[251] = data[31:24]; 
                end
            // MUL ACCEL OUTPUT
                CR_MUL_OUT_META    : begin //in 
                    next_cr.neuron_out.meta_data.matrix_col_num = data[7:0]; //in metadata
                    next_cr.neuron_out.meta_data.matrix_row_num = data[15:8];
                    next_cr.neuron_out.meta_data.in_use_by_accel = data[16];
                    next_cr.neuron_out.meta_data.mov_out_to_in   = data[17];
                    next_cr.neuron_out.meta_data.output_ready    = data[18];
                end 
                CR_MUL_OUT_0       : begin 
                    next_cr.neuron_out.data[0]   = data[7:0];
                    next_cr.neuron_out.data[1]   = data[15:8];
                    next_cr.neuron_out.data[2]   = data[23:16];
                    next_cr.neuron_out.data[3]   = data[31:24]; 
                end
                CR_MUL_OUT_1       : begin 
                    next_cr.neuron_out.data[4]   = data[7:0];
                    next_cr.neuron_out.data[5]   = data[15:8];
                    next_cr.neuron_out.data[6]   = data[23:16];
                    next_cr.neuron_out.data[7]   = data[31:24]; 
                end
                CR_MUL_OUT_2       : begin 
                    next_cr.neuron_out.data[8]   = data[7:0];
                    next_cr.neuron_out.data[9]   = data[15:8];
                    next_cr.neuron_out.data[10]  = data[23:16];
                    next_cr.neuron_out.data[11]  = data[31:24]; 
                end
                CR_MUL_OUT_3       : begin 
                    next_cr.neuron_out.data[12]  = data[7:0];
                    next_cr.neuron_out.data[13]  = data[15:8];
                    next_cr.neuron_out.data[14]  = data[23:16];
                    next_cr.neuron_out.data[15]  = data[31:24]; 
                end
                CR_MUL_OUT_4       : begin 
                    next_cr.neuron_out.data[16]  = data[7:0];
                    next_cr.neuron_out.data[17]  = data[15:8];
                    next_cr.neuron_out.data[18]  = data[23:16];
                    next_cr.neuron_out.data[19]  = data[31:24]; 
                end
                CR_MUL_OUT_5       : begin 
                    next_cr.neuron_out.data[20]  = data[7:0];
                    next_cr.neuron_out.data[21]  = data[15:8];
                    next_cr.neuron_out.data[22]  = data[23:16];
                    next_cr.neuron_out.data[23]  = data[31:24]; 
                end
                CR_MUL_OUT_6       : begin 
                    next_cr.neuron_out.data[24]  = data[7:0];
                    next_cr.neuron_out.data[25]  = data[15:8];
                    next_cr.neuron_out.data[26]  = data[23:16];
                    next_cr.neuron_out.data[27]  = data[31:24]; 
                end
                CR_MUL_OUT_7       : begin 
                    next_cr.neuron_out.data[28]  = data[7:0];
                    next_cr.neuron_out.data[29]  = data[15:8];
                    next_cr.neuron_out.data[30]  = data[23:16];
                    next_cr.neuron_out.data[31]  = data[31:24]; 
                end
                CR_MUL_OUT_8       : begin 
                    next_cr.neuron_out.data[32]  = data[7:0];
                    next_cr.neuron_out.data[33]  = data[15:8];
                    next_cr.neuron_out.data[34]  = data[23:16];
                    next_cr.neuron_out.data[35]  = data[31:24]; 
                end
                CR_MUL_OUT_9       : begin 
                    next_cr.neuron_out.data[36]  = data[7:0];
                    next_cr.neuron_out.data[37]  = data[15:8];
                    next_cr.neuron_out.data[38]  = data[23:16];
                    next_cr.neuron_out.data[39]  = data[31:24]; 
                end
                CR_MUL_OUT_10      : begin 
                    next_cr.neuron_out.data[40]  = data[7:0];
                    next_cr.neuron_out.data[41]  = data[15:8];
                    next_cr.neuron_out.data[42]  = data[23:16];
                    next_cr.neuron_out.data[43]  = data[31:24]; 
                end
                CR_MUL_OUT_11      : begin 
                    next_cr.neuron_out.data[44]  = data[7:0];
                    next_cr.neuron_out.data[45]  = data[15:8];
                    next_cr.neuron_out.data[46]  = data[23:16];
                    next_cr.neuron_out.data[47]  = data[31:24]; 
                end
                CR_MUL_OUT_12      : begin 
                    next_cr.neuron_out.data[48]  = data[7:0];
                    next_cr.neuron_out.data[49]  = data[15:8];
                    next_cr.neuron_out.data[50]  = data[23:16];
                    next_cr.neuron_out.data[51]  = data[31:24]; 
                end
                CR_MUL_OUT_13      : begin 
                    next_cr.neuron_out.data[52]  = data[7:0];
                    next_cr.neuron_out.data[53]  = data[15:8];
                    next_cr.neuron_out.data[54]  = data[23:16];
                    next_cr.neuron_out.data[55]  = data[31:24]; 
                end
                CR_MUL_OUT_14      : begin 
                    next_cr.neuron_out.data[56]  = data[7:0];
                    next_cr.neuron_out.data[57]  = data[15:8];
                    next_cr.neuron_out.data[58]  = data[23:16];
                    next_cr.neuron_out.data[59]  = data[31:24]; 
                end
                CR_MUL_OUT_15      : begin 
                    next_cr.neuron_out.data[60]  = data[7:0];
                    next_cr.neuron_out.data[61]  = data[15:8];
                    next_cr.neuron_out.data[62]  = data[23:16];
                    next_cr.neuron_out.data[63]  = data[31:24]; 
                end
                CR_MUL_OUT_16      : begin 
                    next_cr.neuron_out.data[64]  = data[7:0];
                    next_cr.neuron_out.data[65]  = data[15:8];
                    next_cr.neuron_out.data[66]  = data[23:16];
                    next_cr.neuron_out.data[67]  = data[31:24]; 
                end
                CR_MUL_OUT_17      : begin 
                    next_cr.neuron_out.data[68]  = data[7:0];
                    next_cr.neuron_out.data[69]  = data[15:8];
                    next_cr.neuron_out.data[70]  = data[23:16];
                    next_cr.neuron_out.data[71]  = data[31:24]; 
                end
                CR_MUL_OUT_18      : begin 
                    next_cr.neuron_out.data[72]  = data[7:0];
                    next_cr.neuron_out.data[73]  = data[15:8];
                    next_cr.neuron_out.data[74]  = data[23:16];
                    next_cr.neuron_out.data[75]  = data[31:24]; 
                end
                CR_MUL_OUT_19      : begin 
                    next_cr.neuron_out.data[76]  = data[7:0];
                    next_cr.neuron_out.data[77]  = data[15:8];
                    next_cr.neuron_out.data[78]  = data[23:16];
                    next_cr.neuron_out.data[79]  = data[31:24]; 
                end
                CR_MUL_OUT_20      : begin 
                    next_cr.neuron_out.data[80]  = data[7:0];
                    next_cr.neuron_out.data[81]  = data[15:8];
                    next_cr.neuron_out.data[82]  = data[23:16];
                    next_cr.neuron_out.data[83]  = data[31:24]; 
                end
                CR_MUL_OUT_21      : begin 
                    next_cr.neuron_out.data[84]  = data[7:0];
                    next_cr.neuron_out.data[85]  = data[15:8];
                    next_cr.neuron_out.data[86]  = data[23:16];
                    next_cr.neuron_out.data[87]  = data[31:24]; 
                end
                CR_MUL_OUT_22      : begin 
                    next_cr.neuron_out.data[88]  = data[7:0];
                    next_cr.neuron_out.data[89]  = data[15:8];
                    next_cr.neuron_out.data[90]  = data[23:16];
                    next_cr.neuron_out.data[91]  = data[31:24]; 
                end
                CR_MUL_OUT_23      : begin 
                    next_cr.neuron_out.data[92]  = data[7:0];
                    next_cr.neuron_out.data[93]  = data[15:8];
                    next_cr.neuron_out.data[94]  = data[23:16];
                    next_cr.neuron_out.data[95]  = data[31:24]; 
                end
                CR_MUL_OUT_24      : begin 
                    next_cr.neuron_out.data[96]  = data[7:0];
                    next_cr.neuron_out.data[97]  = data[15:8];
                    next_cr.neuron_out.data[98]  = data[23:16];
                    next_cr.neuron_out.data[99]  = data[31:24]; 
                end
                CR_MUL_OUT_25      : begin 
                    next_cr.neuron_out.data[100] = data[7:0];
                    next_cr.neuron_out.data[101] = data[15:8];
                    next_cr.neuron_out.data[102] = data[23:16];
                    next_cr.neuron_out.data[103] = data[31:24]; 
                end
                CR_MUL_OUT_26      : begin 
                    next_cr.neuron_out.data[104] = data[7:0];
                    next_cr.neuron_out.data[105] = data[15:8];
                    next_cr.neuron_out.data[106] = data[23:16];
                    next_cr.neuron_out.data[107] = data[31:24]; 
                end
                CR_MUL_OUT_27      : begin 
                    next_cr.neuron_out.data[108] = data[7:0];
                    next_cr.neuron_out.data[109] = data[15:8];
                    next_cr.neuron_out.data[110] = data[23:16];
                    next_cr.neuron_out.data[111] = data[31:24]; 
                end
                CR_MUL_OUT_28      : begin 
                    next_cr.neuron_out.data[112] = data[7:0];
                    next_cr.neuron_out.data[113] = data[15:8];
                    next_cr.neuron_out.data[114] = data[23:16];
                    next_cr.neuron_out.data[115] = data[31:24]; 
                end
                CR_MUL_OUT_29      : begin 
                    next_cr.neuron_out.data[116] = data[7:0];
                    next_cr.neuron_out.data[117] = data[15:8];
                    next_cr.neuron_out.data[118] = data[23:16];
                    next_cr.neuron_out.data[119] = data[31:24]; 
                end
                CR_MUL_OUT_30      : begin 
                    next_cr.neuron_out.data[120] = data[7:0];
                    next_cr.neuron_out.data[121] = data[15:8];
                    next_cr.neuron_out.data[122] = data[23:16];
                    next_cr.neuron_out.data[123] = data[31:24]; 
                end
                CR_MUL_OUT_31      : begin 
                    next_cr.neuron_out.data[124] = data[7:0];
                    next_cr.neuron_out.data[125] = data[15:8];
                    next_cr.neuron_out.data[126] = data[23:16];
                    next_cr.neuron_out.data[127] = data[31:24]; 
                end
                CR_MUL_OUT_32      : begin 
                    next_cr.neuron_out.data[128] = data[7:0];
                    next_cr.neuron_out.data[129] = data[15:8];
                    next_cr.neuron_out.data[130] = data[23:16];
                    next_cr.neuron_out.data[131] = data[31:24]; 
                end
                CR_MUL_OUT_33      : begin 
                    next_cr.neuron_out.data[132] = data[7:0];
                    next_cr.neuron_out.data[133] = data[15:8];
                    next_cr.neuron_out.data[134] = data[23:16];
                    next_cr.neuron_out.data[135] = data[31:24]; 
                end
                CR_MUL_OUT_34      : begin 
                    next_cr.neuron_out.data[136] = data[7:0];
                    next_cr.neuron_out.data[137] = data[15:8];
                    next_cr.neuron_out.data[138] = data[23:16];
                    next_cr.neuron_out.data[139] = data[31:24]; 
                end
                CR_MUL_OUT_35      : begin 
                    next_cr.neuron_out.data[140] = data[7:0];
                    next_cr.neuron_out.data[141] = data[15:8];
                    next_cr.neuron_out.data[142] = data[23:16];
                    next_cr.neuron_out.data[143] = data[31:24]; 
                end
                CR_MUL_OUT_36      : begin 
                    next_cr.neuron_out.data[144] = data[7:0];
                    next_cr.neuron_out.data[145] = data[15:8];
                    next_cr.neuron_out.data[146] = data[23:16];
                    next_cr.neuron_out.data[147] = data[31:24]; 
                end
                CR_MUL_OUT_37      : begin 
                    next_cr.neuron_out.data[148] = data[7:0];
                    next_cr.neuron_out.data[149] = data[15:8];
                    next_cr.neuron_out.data[150] = data[23:16];
                    next_cr.neuron_out.data[151] = data[31:24]; 
                end
                CR_MUL_OUT_38      : begin 
                    next_cr.neuron_out.data[152] = data[7:0];
                    next_cr.neuron_out.data[153] = data[15:8];
                    next_cr.neuron_out.data[154] = data[23:16];
                    next_cr.neuron_out.data[155] = data[31:24]; 
                end
                CR_MUL_OUT_39      : begin 
                    next_cr.neuron_out.data[156] = data[7:0];
                    next_cr.neuron_out.data[157] = data[15:8];
                    next_cr.neuron_out.data[158] = data[23:16];
                    next_cr.neuron_out.data[159] = data[31:24]; 
                end
                CR_MUL_OUT_40      : begin 
                    next_cr.neuron_out.data[160] = data[7:0];
                    next_cr.neuron_out.data[161] = data[15:8];
                    next_cr.neuron_out.data[162] = data[23:16];
                    next_cr.neuron_out.data[163] = data[31:24]; 
                end
                CR_MUL_OUT_41      : begin 
                    next_cr.neuron_out.data[164] = data[7:0];
                    next_cr.neuron_out.data[165] = data[15:8];
                    next_cr.neuron_out.data[166] = data[23:16];
                    next_cr.neuron_out.data[167] = data[31:24]; 
                end
                CR_MUL_OUT_42      : begin 
                    next_cr.neuron_out.data[168] = data[7:0];
                    next_cr.neuron_out.data[169] = data[15:8];
                    next_cr.neuron_out.data[170] = data[23:16];
                    next_cr.neuron_out.data[171] = data[31:24]; 
                end
                CR_MUL_OUT_43      : begin 
                    next_cr.neuron_out.data[172] = data[7:0];
                    next_cr.neuron_out.data[173] = data[15:8];
                    next_cr.neuron_out.data[174] = data[23:16];
                    next_cr.neuron_out.data[175] = data[31:24]; 
                end
                CR_MUL_OUT_44      : begin 
                    next_cr.neuron_out.data[176] = data[7:0];
                    next_cr.neuron_out.data[177] = data[15:8];
                    next_cr.neuron_out.data[178] = data[23:16];
                    next_cr.neuron_out.data[179] = data[31:24]; 
                end
                CR_MUL_OUT_45      : begin 
                    next_cr.neuron_out.data[180] = data[7:0];
                    next_cr.neuron_out.data[181] = data[15:8];
                    next_cr.neuron_out.data[182] = data[23:16];
                    next_cr.neuron_out.data[183] = data[31:24]; 
                end
                CR_MUL_OUT_46      : begin 
                    next_cr.neuron_out.data[184] = data[7:0];
                    next_cr.neuron_out.data[185] = data[15:8];
                    next_cr.neuron_out.data[186] = data[23:16];
                    next_cr.neuron_out.data[187] = data[31:24]; 
                end
                CR_MUL_OUT_47      : begin 
                    next_cr.neuron_out.data[188] = data[7:0];
                    next_cr.neuron_out.data[189] = data[15:8];
                    next_cr.neuron_out.data[190] = data[23:16];
                    next_cr.neuron_out.data[191] = data[31:24]; 
                end
                CR_MUL_OUT_48      : begin 
                    next_cr.neuron_out.data[192] = data[7:0];
                    next_cr.neuron_out.data[193] = data[15:8];
                    next_cr.neuron_out.data[194] = data[23:16];
                    next_cr.neuron_out.data[195] = data[31:24]; 
                end
                CR_MUL_OUT_49      : begin 
                    next_cr.neuron_out.data[196] = data[7:0];
                    next_cr.neuron_out.data[197] = data[15:8];
                    next_cr.neuron_out.data[198] = data[23:16];
                    next_cr.neuron_out.data[199] = data[31:24]; 
                end
                CR_MUL_OUT_50      : begin 
                    next_cr.neuron_out.data[200] = data[7:0];
                    next_cr.neuron_out.data[201] = data[15:8];
                    next_cr.neuron_out.data[202] = data[23:16];
                    next_cr.neuron_out.data[203] = data[31:24]; 
                end
                CR_MUL_OUT_51      : begin 
                    next_cr.neuron_out.data[204] = data[7:0];
                    next_cr.neuron_out.data[205] = data[15:8];
                    next_cr.neuron_out.data[206] = data[23:16];
                    next_cr.neuron_out.data[207] = data[31:24]; 
                end
                CR_MUL_OUT_52      : begin 
                    next_cr.neuron_out.data[208] = data[7:0];
                    next_cr.neuron_out.data[209] = data[15:8];
                    next_cr.neuron_out.data[210] = data[23:16];
                    next_cr.neuron_out.data[211] = data[31:24]; 
                end
                CR_MUL_OUT_53      : begin 
                    next_cr.neuron_out.data[212] = data[7:0];
                    next_cr.neuron_out.data[213] = data[15:8];
                    next_cr.neuron_out.data[214] = data[23:16];
                    next_cr.neuron_out.data[215] = data[31:24]; 
                end
                CR_MUL_OUT_54      : begin 
                    next_cr.neuron_out.data[216] = data[7:0];
                    next_cr.neuron_out.data[217] = data[15:8];
                    next_cr.neuron_out.data[218] = data[23:16];
                    next_cr.neuron_out.data[219] = data[31:24]; 
                end
                CR_MUL_OUT_55      : begin 
                    next_cr.neuron_out.data[220] = data[7:0];
                    next_cr.neuron_out.data[221] = data[15:8];
                    next_cr.neuron_out.data[222] = data[23:16];
                    next_cr.neuron_out.data[223] = data[31:24]; 
                end
                CR_MUL_OUT_56      : begin 
                    next_cr.neuron_out.data[224] = data[7:0];
                    next_cr.neuron_out.data[225] = data[15:8];
                    next_cr.neuron_out.data[226] = data[23:16];
                    next_cr.neuron_out.data[227] = data[31:24]; 
                end
                CR_MUL_OUT_57      : begin 
                    next_cr.neuron_out.data[228] = data[7:0];
                    next_cr.neuron_out.data[229] = data[15:8];
                    next_cr.neuron_out.data[230] = data[23:16];
                    next_cr.neuron_out.data[231] = data[31:24]; 
                end
                CR_MUL_OUT_58      : begin 
                    next_cr.neuron_out.data[232] = data[7:0];
                    next_cr.neuron_out.data[233] = data[15:8];
                    next_cr.neuron_out.data[234] = data[23:16];
                    next_cr.neuron_out.data[235] = data[31:24]; 
                end
                CR_MUL_OUT_59      : begin 
                    next_cr.neuron_out.data[236] = data[7:0];
                    next_cr.neuron_out.data[237] = data[15:8];
                    next_cr.neuron_out.data[238] = data[23:16];
                    next_cr.neuron_out.data[239] = data[31:24]; 
                end
                CR_MUL_OUT_60      : begin 
                    next_cr.neuron_out.data[240] = data[7:0];
                    next_cr.neuron_out.data[241] = data[15:8];
                    next_cr.neuron_out.data[242] = data[23:16];
                    next_cr.neuron_out.data[243] = data[31:24]; 
                end
                CR_MUL_OUT_61      : begin 
                    next_cr.neuron_out.data[244] = data[7:0];
                    next_cr.neuron_out.data[245] = data[15:8];
                    next_cr.neuron_out.data[246] = data[23:16];
                    next_cr.neuron_out.data[247] = data[31:24]; 
                end
                CR_MUL_OUT_62      : begin 
                    next_cr.neuron_out.data[248] = data[7:0];
                    next_cr.neuron_out.data[249] = data[15:8];
                    next_cr.neuron_out.data[250] = data[23:16];
                    next_cr.neuron_out.data[251] = data[31:24]; 
                end
            // OTHERS
            default   : /* Do nothing */;
        endcase
    end

    
end

// This is the load
always_comb begin
    pre_q   = 32'b0;
    //pre_q_b = 32'b0;
    if(rden) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_XOR_IN_1       : pre_q = {24'b0 , cr.xor_inp1};
            CR_XOR_IN_2       : pre_q = {24'b0 , cr.xor_inp2};
            CR_XOR_OUT       : pre_q = {24'b0 , cr.xor_result};

            // CR MUL IN
                CR_MUL_IN_META : pre_q = {  13'b0, 
                                            cr.neuron_in.meta_data.output_ready ,
                                            cr.neuron_in.meta_data.mov_out_to_in ,
                                            cr.neuron_in.meta_data.in_use_by_accel,
                                            cr.neuron_in.meta_data.matrix_row_num,
                                            cr.neuron_in.meta_data.matrix_col_num };   
                CR_MUL_IN_0    : pre_q = {  cr.neuron_in.data[3],
                                            cr.neuron_in.data[2],
                                            cr.neuron_in.data[1],
                                            cr.neuron_in.data[0] };
                CR_MUL_IN_1    : pre_q = {  cr.neuron_in.data[7],
                                            cr.neuron_in.data[6],
                                            cr.neuron_in.data[5],
                                            cr.neuron_in.data[4] };
                CR_MUL_IN_2    : pre_q = {  cr.neuron_in.data[11],
                                            cr.neuron_in.data[10],
                                            cr.neuron_in.data[9],
                                            cr.neuron_in.data[8] };
                CR_MUL_IN_3    : pre_q = {  cr.neuron_in.data[15],
                                            cr.neuron_in.data[14],
                                            cr.neuron_in.data[13],
                                            cr.neuron_in.data[12] };
                CR_MUL_IN_4    : pre_q = {  cr.neuron_in.data[19],
                                            cr.neuron_in.data[18],
                                            cr.neuron_in.data[17],
                                            cr.neuron_in.data[16] };
                CR_MUL_IN_5    : pre_q = {  cr.neuron_in.data[23],
                                            cr.neuron_in.data[22],
                                            cr.neuron_in.data[21],
                                            cr.neuron_in.data[20] };
                CR_MUL_IN_6    : pre_q = {  cr.neuron_in.data[27],
                                            cr.neuron_in.data[26],
                                            cr.neuron_in.data[25],
                                            cr.neuron_in.data[24] };
                CR_MUL_IN_7    : pre_q = {  cr.neuron_in.data[31],
                                            cr.neuron_in.data[30],
                                            cr.neuron_in.data[29],
                                            cr.neuron_in.data[28] };
                CR_MUL_IN_8    : pre_q = {  cr.neuron_in.data[35],
                                            cr.neuron_in.data[34],
                                            cr.neuron_in.data[33],
                                            cr.neuron_in.data[32] };
                CR_MUL_IN_9    : pre_q = {  cr.neuron_in.data[39],
                                            cr.neuron_in.data[38],
                                            cr.neuron_in.data[37],
                                            cr.neuron_in.data[36] };
                CR_MUL_IN_10   : pre_q = {  cr.neuron_in.data[43],
                                            cr.neuron_in.data[42],
                                            cr.neuron_in.data[41],
                                            cr.neuron_in.data[40] };
                CR_MUL_IN_11   : pre_q = {  cr.neuron_in.data[47],
                                            cr.neuron_in.data[46],
                                            cr.neuron_in.data[45],
                                            cr.neuron_in.data[44] };
                CR_MUL_IN_12   : pre_q = {  cr.neuron_in.data[51],
                                            cr.neuron_in.data[50],
                                            cr.neuron_in.data[49],
                                            cr.neuron_in.data[48] };
                CR_MUL_IN_13   : pre_q = {  cr.neuron_in.data[55],
                                            cr.neuron_in.data[54],
                                            cr.neuron_in.data[53],
                                            cr.neuron_in.data[52] };
                CR_MUL_IN_14   : pre_q = {  cr.neuron_in.data[59],
                                            cr.neuron_in.data[58],
                                            cr.neuron_in.data[57],
                                            cr.neuron_in.data[56] };
                CR_MUL_IN_15   : pre_q = {  cr.neuron_in.data[63],
                                            cr.neuron_in.data[62],
                                            cr.neuron_in.data[61],
                                            cr.neuron_in.data[60] };
                CR_MUL_IN_16   : pre_q = {  cr.neuron_in.data[67],
                                            cr.neuron_in.data[66],
                                            cr.neuron_in.data[65],
                                            cr.neuron_in.data[64] };
                CR_MUL_IN_17   : pre_q = {  cr.neuron_in.data[71],
                                            cr.neuron_in.data[70],
                                            cr.neuron_in.data[69],
                                            cr.neuron_in.data[68] };
                CR_MUL_IN_18   : pre_q = {  cr.neuron_in.data[75],
                                            cr.neuron_in.data[74],
                                            cr.neuron_in.data[73],
                                            cr.neuron_in.data[72] };
                CR_MUL_IN_19   : pre_q = {  cr.neuron_in.data[79],
                                            cr.neuron_in.data[78],
                                            cr.neuron_in.data[77],
                                            cr.neuron_in.data[76] };
                CR_MUL_IN_20   : pre_q = {  cr.neuron_in.data[83],
                                            cr.neuron_in.data[82],
                                            cr.neuron_in.data[81],
                                            cr.neuron_in.data[80] };
                CR_MUL_IN_21   : pre_q = {  cr.neuron_in.data[87],
                                            cr.neuron_in.data[86],
                                            cr.neuron_in.data[85],
                                            cr.neuron_in.data[84] };
                CR_MUL_IN_22   : pre_q = {  cr.neuron_in.data[91],
                                            cr.neuron_in.data[90],
                                            cr.neuron_in.data[89],
                                            cr.neuron_in.data[88] };
                CR_MUL_IN_23   : pre_q = {  cr.neuron_in.data[95],
                                            cr.neuron_in.data[94],
                                            cr.neuron_in.data[93],
                                            cr.neuron_in.data[92] };
                CR_MUL_IN_24   : pre_q = {  cr.neuron_in.data[99],
                                            cr.neuron_in.data[98],
                                            cr.neuron_in.data[97],
                                            cr.neuron_in.data[96] };
                CR_MUL_IN_25   : pre_q = {  cr.neuron_in.data[103],
                                            cr.neuron_in.data[102],
                                            cr.neuron_in.data[101],
                                            cr.neuron_in.data[100] };
                CR_MUL_IN_26   : pre_q = {  cr.neuron_in.data[107],
                                            cr.neuron_in.data[106],
                                            cr.neuron_in.data[105],
                                            cr.neuron_in.data[104] };
                CR_MUL_IN_27   : pre_q = {  cr.neuron_in.data[111],
                                            cr.neuron_in.data[110],
                                            cr.neuron_in.data[109],
                                            cr.neuron_in.data[108] };
                CR_MUL_IN_28   : pre_q = {  cr.neuron_in.data[115],
                                            cr.neuron_in.data[114],
                                            cr.neuron_in.data[113],
                                            cr.neuron_in.data[112] };
                CR_MUL_IN_29   : pre_q = {  cr.neuron_in.data[119],
                                            cr.neuron_in.data[118],
                                            cr.neuron_in.data[117],
                                            cr.neuron_in.data[116] };
                CR_MUL_IN_30   : pre_q = {  cr.neuron_in.data[123],
                                            cr.neuron_in.data[122],
                                            cr.neuron_in.data[121],
                                            cr.neuron_in.data[120] };
                CR_MUL_IN_31   : pre_q = {  cr.neuron_in.data[127],
                                            cr.neuron_in.data[126],
                                            cr.neuron_in.data[125],
                                            cr.neuron_in.data[124] };
                CR_MUL_IN_32   : pre_q = {  cr.neuron_in.data[131],
                                            cr.neuron_in.data[130],
                                            cr.neuron_in.data[129],
                                            cr.neuron_in.data[128] };
                CR_MUL_IN_33   : pre_q = {  cr.neuron_in.data[135],
                                            cr.neuron_in.data[134],
                                            cr.neuron_in.data[133],
                                            cr.neuron_in.data[132] };
                CR_MUL_IN_34   : pre_q = {  cr.neuron_in.data[139],
                                            cr.neuron_in.data[138],
                                            cr.neuron_in.data[137],
                                            cr.neuron_in.data[136] };
                CR_MUL_IN_35   : pre_q = {  cr.neuron_in.data[143],
                                            cr.neuron_in.data[142],
                                            cr.neuron_in.data[141],
                                            cr.neuron_in.data[140] };
                CR_MUL_IN_36   : pre_q = {  cr.neuron_in.data[147],
                                            cr.neuron_in.data[146],
                                            cr.neuron_in.data[145],
                                            cr.neuron_in.data[144] };
                CR_MUL_IN_37   : pre_q = {  cr.neuron_in.data[151],
                                            cr.neuron_in.data[150],
                                            cr.neuron_in.data[149],
                                            cr.neuron_in.data[148] };
                CR_MUL_IN_38   : pre_q = {  cr.neuron_in.data[155],
                                            cr.neuron_in.data[154],
                                            cr.neuron_in.data[153],
                                            cr.neuron_in.data[152] };
                CR_MUL_IN_39   : pre_q = {  cr.neuron_in.data[159],
                                            cr.neuron_in.data[158],
                                            cr.neuron_in.data[157],
                                            cr.neuron_in.data[156] };
                CR_MUL_IN_40   : pre_q = {  cr.neuron_in.data[163],
                                            cr.neuron_in.data[162],
                                            cr.neuron_in.data[161],
                                            cr.neuron_in.data[160] };
                CR_MUL_IN_41   : pre_q = {  cr.neuron_in.data[167],
                                            cr.neuron_in.data[166],
                                            cr.neuron_in.data[165],
                                            cr.neuron_in.data[164] };
                CR_MUL_IN_42   : pre_q = {  cr.neuron_in.data[171],
                                            cr.neuron_in.data[170],
                                            cr.neuron_in.data[169],
                                            cr.neuron_in.data[168] };
                CR_MUL_IN_43   : pre_q = {  cr.neuron_in.data[175],
                                            cr.neuron_in.data[174],
                                            cr.neuron_in.data[173],
                                            cr.neuron_in.data[172] };
                CR_MUL_IN_44   : pre_q = {  cr.neuron_in.data[179],
                                            cr.neuron_in.data[178],
                                            cr.neuron_in.data[177],
                                            cr.neuron_in.data[176] };
                CR_MUL_IN_45   : pre_q = {  cr.neuron_in.data[183],
                                            cr.neuron_in.data[182],
                                            cr.neuron_in.data[181],
                                            cr.neuron_in.data[180] };
                CR_MUL_IN_46   : pre_q = {  cr.neuron_in.data[187],
                                            cr.neuron_in.data[186],
                                            cr.neuron_in.data[185],
                                            cr.neuron_in.data[184] };
                CR_MUL_IN_47   : pre_q = {  cr.neuron_in.data[191],
                                            cr.neuron_in.data[190],
                                            cr.neuron_in.data[189],
                                            cr.neuron_in.data[188] };
                CR_MUL_IN_48   : pre_q = {  cr.neuron_in.data[195],
                                            cr.neuron_in.data[194],
                                            cr.neuron_in.data[193],
                                            cr.neuron_in.data[192] };
                CR_MUL_IN_49   : pre_q = {  cr.neuron_in.data[199],
                                            cr.neuron_in.data[198],
                                            cr.neuron_in.data[197],
                                            cr.neuron_in.data[196] };
                CR_MUL_IN_50   : pre_q = {  cr.neuron_in.data[203],
                                            cr.neuron_in.data[202],
                                            cr.neuron_in.data[201],
                                            cr.neuron_in.data[200] };
                CR_MUL_IN_51   : pre_q = {  cr.neuron_in.data[207],
                                            cr.neuron_in.data[206],
                                            cr.neuron_in.data[205],
                                            cr.neuron_in.data[204] };
                CR_MUL_IN_52   : pre_q = {  cr.neuron_in.data[211],
                                            cr.neuron_in.data[210],
                                            cr.neuron_in.data[209],
                                            cr.neuron_in.data[208] };
                CR_MUL_IN_53   : pre_q = {  cr.neuron_in.data[215],
                                            cr.neuron_in.data[214],
                                            cr.neuron_in.data[213],
                                            cr.neuron_in.data[212] };
                CR_MUL_IN_54   : pre_q = {  cr.neuron_in.data[219],
                                            cr.neuron_in.data[218],
                                            cr.neuron_in.data[217],
                                            cr.neuron_in.data[216] };
                CR_MUL_IN_55   : pre_q = {  cr.neuron_in.data[223],
                                            cr.neuron_in.data[222],
                                            cr.neuron_in.data[221],
                                            cr.neuron_in.data[220] };
                CR_MUL_IN_56   : pre_q = {  cr.neuron_in.data[227],
                                            cr.neuron_in.data[226],
                                            cr.neuron_in.data[225],
                                            cr.neuron_in.data[224] };
                CR_MUL_IN_57   : pre_q = {  cr.neuron_in.data[231],
                                            cr.neuron_in.data[230],
                                            cr.neuron_in.data[229],
                                            cr.neuron_in.data[228] };
                CR_MUL_IN_58   : pre_q = {  cr.neuron_in.data[235],
                                            cr.neuron_in.data[234],
                                            cr.neuron_in.data[233],
                                            cr.neuron_in.data[232] };
                CR_MUL_IN_59   : pre_q = {  cr.neuron_in.data[239],
                                            cr.neuron_in.data[238],
                                            cr.neuron_in.data[237],
                                            cr.neuron_in.data[236] };
                CR_MUL_IN_60   : pre_q = {  cr.neuron_in.data[243],
                                            cr.neuron_in.data[242],
                                            cr.neuron_in.data[241],
                                            cr.neuron_in.data[240] };
                CR_MUL_IN_61   : pre_q = {  cr.neuron_in.data[247],
                                            cr.neuron_in.data[246],
                                            cr.neuron_in.data[245],
                                            cr.neuron_in.data[244] };
                CR_MUL_IN_62   : pre_q = {  cr.neuron_in.data[251],
                                            cr.neuron_in.data[250],
                                            cr.neuron_in.data[249],
                                            cr.neuron_in.data[248] };
    
                
            // W1
                CR_MUL_W1_META : pre_q = {  15'b0,
                                            cr.w1.meta_data.in_use,
                                            cr.w1.meta_data.data_len,  
                                            cr.w1.meta_data.neuron_idx };
                CR_MUL_W1_0    : pre_q = {  cr.w1.data[3],
                                            cr.w1.data[2],
                                            cr.w1.data[1],
                                            cr.w1.data[0] };
                CR_MUL_W1_1    : pre_q = {  cr.w1.data[7],
                                            cr.w1.data[6],
                                            cr.w1.data[5],
                                            cr.w1.data[4] };
                CR_MUL_W1_2    : pre_q = {  cr.w1.data[11],
                                            cr.w1.data[10],
                                            cr.w1.data[9],
                                            cr.w1.data[8] };
                CR_MUL_W1_3    : pre_q = {  cr.w1.data[15],
                                            cr.w1.data[14],
                                            cr.w1.data[13],
                                            cr.w1.data[12] };
                CR_MUL_W1_4    : pre_q = {  cr.w1.data[19],
                                            cr.w1.data[18],
                                            cr.w1.data[17],
                                            cr.w1.data[16] };
                CR_MUL_W1_5    : pre_q = {  cr.w1.data[23],
                                            cr.w1.data[22],
                                            cr.w1.data[21],
                                            cr.w1.data[20] };
                CR_MUL_W1_6    : pre_q = {  cr.w1.data[27],
                                            cr.w1.data[26],
                                            cr.w1.data[25],
                                            cr.w1.data[24] };
                CR_MUL_W1_7    : pre_q = {  cr.w1.data[31],
                                            cr.w1.data[30],
                                            cr.w1.data[29],
                                            cr.w1.data[28] };
                CR_MUL_W1_8    : pre_q = {  cr.w1.data[35],
                                            cr.w1.data[34],
                                            cr.w1.data[33],
                                            cr.w1.data[32] };
                CR_MUL_W1_9    : pre_q = {  cr.w1.data[39],
                                            cr.w1.data[38],
                                            cr.w1.data[37],
                                            cr.w1.data[36] };
                CR_MUL_W1_10   : pre_q = {  cr.w1.data[43],
                                            cr.w1.data[42],
                                            cr.w1.data[41],
                                            cr.w1.data[40] };
                CR_MUL_W1_11   : pre_q = {  cr.w1.data[47],
                                            cr.w1.data[46],
                                            cr.w1.data[45],
                                            cr.w1.data[44] };
                CR_MUL_W1_12   : pre_q = {  cr.w1.data[51],
                                            cr.w1.data[50],
                                            cr.w1.data[49],
                                            cr.w1.data[48] };
                CR_MUL_W1_13   : pre_q = {  cr.w1.data[55],
                                            cr.w1.data[54],
                                            cr.w1.data[53],
                                            cr.w1.data[52] };
                CR_MUL_W1_14   : pre_q = {  cr.w1.data[59],
                                            cr.w1.data[58],
                                            cr.w1.data[57],
                                            cr.w1.data[56] };
                CR_MUL_W1_15   : pre_q = {  cr.w1.data[63],
                                            cr.w1.data[62],
                                            cr.w1.data[61],
                                            cr.w1.data[60] };
                CR_MUL_W1_16   : pre_q = {  cr.w1.data[67],
                                            cr.w1.data[66],
                                            cr.w1.data[65],
                                            cr.w1.data[64] };
                CR_MUL_W1_17   : pre_q = {  cr.w1.data[71],
                                            cr.w1.data[70],
                                            cr.w1.data[69],
                                            cr.w1.data[68] };
                CR_MUL_W1_18   : pre_q = {  cr.w1.data[75],
                                            cr.w1.data[74],
                                            cr.w1.data[73],
                                            cr.w1.data[72] };
                CR_MUL_W1_19   : pre_q = {  cr.w1.data[79],
                                            cr.w1.data[78],
                                            cr.w1.data[77],
                                            cr.w1.data[76] };
                CR_MUL_W1_20   : pre_q = {  cr.w1.data[83],
                                            cr.w1.data[82],
                                            cr.w1.data[81],
                                            cr.w1.data[80] };
                CR_MUL_W1_21   : pre_q = {  cr.w1.data[87],
                                            cr.w1.data[86],
                                            cr.w1.data[85],
                                            cr.w1.data[84] };
                CR_MUL_W1_22   : pre_q = {  cr.w1.data[91],
                                            cr.w1.data[90],
                                            cr.w1.data[89],
                                            cr.w1.data[88] };
                CR_MUL_W1_23   : pre_q = {  cr.w1.data[95],
                                            cr.w1.data[94],
                                            cr.w1.data[93],
                                            cr.w1.data[92] };
                CR_MUL_W1_24   : pre_q = {  cr.w1.data[99],
                                            cr.w1.data[98],
                                            cr.w1.data[97],
                                            cr.w1.data[96] };
                CR_MUL_W1_25   : pre_q = {  cr.w1.data[103],
                                            cr.w1.data[102],
                                            cr.w1.data[101],
                                            cr.w1.data[100] };
                CR_MUL_W1_26   : pre_q = {  cr.w1.data[107],
                                            cr.w1.data[106],
                                            cr.w1.data[105],
                                            cr.w1.data[104] };
                CR_MUL_W1_27   : pre_q = {  cr.w1.data[111],
                                            cr.w1.data[110],
                                            cr.w1.data[109],
                                            cr.w1.data[108] };
                CR_MUL_W1_28   : pre_q = {  cr.w1.data[115],
                                            cr.w1.data[114],
                                            cr.w1.data[113],
                                            cr.w1.data[112] };
                CR_MUL_W1_29   : pre_q = {  cr.w1.data[119],
                                            cr.w1.data[118],
                                            cr.w1.data[117],
                                            cr.w1.data[116] };
                CR_MUL_W1_30   : pre_q = {  cr.w1.data[123],
                                            cr.w1.data[122],
                                            cr.w1.data[121],
                                            cr.w1.data[120] };
                CR_MUL_W1_31   : pre_q = {  cr.w1.data[127],
                                            cr.w1.data[126],
                                            cr.w1.data[125],
                                            cr.w1.data[124] };
                CR_MUL_W1_32   : pre_q = {  cr.w1.data[131],
                                            cr.w1.data[130],
                                            cr.w1.data[129],
                                            cr.w1.data[128] };
                CR_MUL_W1_33   : pre_q = {  cr.w1.data[135],
                                            cr.w1.data[134],
                                            cr.w1.data[133],
                                            cr.w1.data[132] };
                CR_MUL_W1_34   : pre_q = {  cr.w1.data[139],
                                            cr.w1.data[138],
                                            cr.w1.data[137],
                                            cr.w1.data[136] };
                CR_MUL_W1_35   : pre_q = {  cr.w1.data[143],
                                            cr.w1.data[142],
                                            cr.w1.data[141],
                                            cr.w1.data[140] };
                CR_MUL_W1_36   : pre_q = {  cr.w1.data[147],
                                            cr.w1.data[146],
                                            cr.w1.data[145],
                                            cr.w1.data[144] };
                CR_MUL_W1_37   : pre_q = {  cr.w1.data[151],
                                            cr.w1.data[150],
                                            cr.w1.data[149],
                                            cr.w1.data[148] };
                CR_MUL_W1_38   : pre_q = {  cr.w1.data[155],
                                            cr.w1.data[154],
                                            cr.w1.data[153],
                                            cr.w1.data[152] };
                CR_MUL_W1_39   : pre_q = {  cr.w1.data[159],
                                            cr.w1.data[158],
                                            cr.w1.data[157],
                                            cr.w1.data[156] };
                CR_MUL_W1_40   : pre_q = {  cr.w1.data[163],
                                            cr.w1.data[162],
                                            cr.w1.data[161],
                                            cr.w1.data[160] };
                CR_MUL_W1_41   : pre_q = {  cr.w1.data[167],
                                            cr.w1.data[166],
                                            cr.w1.data[165],
                                            cr.w1.data[164] };
                CR_MUL_W1_42   : pre_q = {  cr.w1.data[171],
                                            cr.w1.data[170],
                                            cr.w1.data[169],
                                            cr.w1.data[168] };
                CR_MUL_W1_43   : pre_q = {  cr.w1.data[175],
                                            cr.w1.data[174],
                                            cr.w1.data[173],
                                            cr.w1.data[172] };
                CR_MUL_W1_44   : pre_q = {  cr.w1.data[179],
                                            cr.w1.data[178],
                                            cr.w1.data[177],
                                            cr.w1.data[176] };
                CR_MUL_W1_45   : pre_q = {  cr.w1.data[183],
                                            cr.w1.data[182],
                                            cr.w1.data[181],
                                            cr.w1.data[180] };
                CR_MUL_W1_46   : pre_q = {  cr.w1.data[187],
                                            cr.w1.data[186],
                                            cr.w1.data[185],
                                            cr.w1.data[184] };
                CR_MUL_W1_47   : pre_q = {  cr.w1.data[191],
                                            cr.w1.data[190],
                                            cr.w1.data[189],
                                            cr.w1.data[188] };
                CR_MUL_W1_48   : pre_q = {  cr.w1.data[195],
                                            cr.w1.data[194],
                                            cr.w1.data[193],
                                            cr.w1.data[192] };
                CR_MUL_W1_49   : pre_q = {  cr.w1.data[199],
                                            cr.w1.data[198],
                                            cr.w1.data[197],
                                            cr.w1.data[196] };
                CR_MUL_W1_50   : pre_q = {  cr.w1.data[203],
                                            cr.w1.data[202],
                                            cr.w1.data[201],
                                            cr.w1.data[200] };
                CR_MUL_W1_51   : pre_q = {  cr.w1.data[207],
                                            cr.w1.data[206],
                                            cr.w1.data[205],
                                            cr.w1.data[204] };
                CR_MUL_W1_52   : pre_q = {  cr.w1.data[211],
                                            cr.w1.data[210],
                                            cr.w1.data[209],
                                            cr.w1.data[208] };
                CR_MUL_W1_53   : pre_q = {  cr.w1.data[215],
                                            cr.w1.data[214],
                                            cr.w1.data[213],
                                            cr.w1.data[212] };
                CR_MUL_W1_54   : pre_q = {  cr.w1.data[219],
                                            cr.w1.data[218],
                                            cr.w1.data[217],
                                            cr.w1.data[216] };
                CR_MUL_W1_55   : pre_q = {  cr.w1.data[223],
                                            cr.w1.data[222],
                                            cr.w1.data[221],
                                            cr.w1.data[220] };
                CR_MUL_W1_56   : pre_q = {  cr.w1.data[227],
                                            cr.w1.data[226],
                                            cr.w1.data[225],
                                            cr.w1.data[224] };
                CR_MUL_W1_57   : pre_q = {  cr.w1.data[231],
                                            cr.w1.data[230],
                                            cr.w1.data[229],
                                            cr.w1.data[228] };
                CR_MUL_W1_58   : pre_q = {  cr.w1.data[235],
                                            cr.w1.data[234],
                                            cr.w1.data[233],
                                            cr.w1.data[232] };
                CR_MUL_W1_59   : pre_q = {  cr.w1.data[239],
                                            cr.w1.data[238],
                                            cr.w1.data[237],
                                            cr.w1.data[236] };
                CR_MUL_W1_60   : pre_q = {  cr.w1.data[243],
                                            cr.w1.data[242],
                                            cr.w1.data[241],
                                            cr.w1.data[240] };
                CR_MUL_W1_61   : pre_q = {  cr.w1.data[247],
                                            cr.w1.data[246],
                                            cr.w1.data[245],
                                            cr.w1.data[244] };
                CR_MUL_W1_62   : pre_q = {  cr.w1.data[251],
                                            cr.w1.data[250],
                                            cr.w1.data[249],
                                            cr.w1.data[248] };
            // W2 
                CR_MUL_W2_META :  pre_q = {  15'b0,
                                            cr.w2.meta_data.in_use,
                                            cr.w2.meta_data.data_len,  
                                            cr.w2.meta_data.neuron_idx };
                CR_MUL_W2_0    : pre_q = {  cr.w2.data[3],
                                            cr.w2.data[2],
                                            cr.w2.data[1],
                                            cr.w2.data[0] };
                CR_MUL_W2_1    : pre_q = {  cr.w2.data[7],
                                            cr.w2.data[6],
                                            cr.w2.data[5],
                                            cr.w2.data[4] };
                CR_MUL_W2_2    : pre_q = {  cr.w2.data[11],
                                            cr.w2.data[10],
                                            cr.w2.data[9],
                                            cr.w2.data[8] };
                CR_MUL_W2_3    : pre_q = {  cr.w2.data[15],
                                            cr.w2.data[14],
                                            cr.w2.data[13],
                                            cr.w2.data[12] };
                CR_MUL_W2_4    : pre_q = {  cr.w2.data[19],
                                            cr.w2.data[18],
                                            cr.w2.data[17],
                                            cr.w2.data[16] };
                CR_MUL_W2_5    : pre_q = {  cr.w2.data[23],
                                            cr.w2.data[22],
                                            cr.w2.data[21],
                                            cr.w2.data[20] };
                CR_MUL_W2_6    : pre_q = {  cr.w2.data[27],
                                            cr.w2.data[26],
                                            cr.w2.data[25],
                                            cr.w2.data[24] };
                CR_MUL_W2_7    : pre_q = {  cr.w2.data[31],
                                            cr.w2.data[30],
                                            cr.w2.data[29],
                                            cr.w2.data[28] };
                CR_MUL_W2_8    : pre_q = {  cr.w2.data[35],
                                            cr.w2.data[34],
                                            cr.w2.data[33],
                                            cr.w2.data[32] };
                CR_MUL_W2_9    : pre_q = {  cr.w2.data[39],
                                            cr.w2.data[38],
                                            cr.w2.data[37],
                                            cr.w2.data[36] };
                CR_MUL_W2_10   : pre_q = {  cr.w2.data[43],
                                            cr.w2.data[42],
                                            cr.w2.data[41],
                                            cr.w2.data[40] };
                CR_MUL_W2_11   : pre_q = {  cr.w2.data[47],
                                            cr.w2.data[46],
                                            cr.w2.data[45],
                                            cr.w2.data[44] };
                CR_MUL_W2_12   : pre_q = {  cr.w2.data[51],
                                            cr.w2.data[50],
                                            cr.w2.data[49],
                                            cr.w2.data[48] };
                CR_MUL_W2_13   : pre_q = {  cr.w2.data[55],
                                            cr.w2.data[54],
                                            cr.w2.data[53],
                                            cr.w2.data[52] };
                CR_MUL_W2_14   : pre_q = {  cr.w2.data[59],
                                            cr.w2.data[58],
                                            cr.w2.data[57],
                                            cr.w2.data[56] };
                CR_MUL_W2_15   : pre_q = {  cr.w2.data[63],
                                            cr.w2.data[62],
                                            cr.w2.data[61],
                                            cr.w2.data[60] };
                CR_MUL_W2_16   : pre_q = {  cr.w2.data[67],
                                            cr.w2.data[66],
                                            cr.w2.data[65],
                                            cr.w2.data[64] };
                CR_MUL_W2_17   : pre_q = {  cr.w2.data[71],
                                            cr.w2.data[70],
                                            cr.w2.data[69],
                                            cr.w2.data[68] };
                CR_MUL_W2_18   : pre_q = {  cr.w2.data[75],
                                            cr.w2.data[74],
                                            cr.w2.data[73],
                                            cr.w2.data[72] };
                CR_MUL_W2_19   : pre_q = {  cr.w2.data[79],
                                            cr.w2.data[78],
                                            cr.w2.data[77],
                                            cr.w2.data[76] };
                CR_MUL_W2_20   : pre_q = {  cr.w2.data[83],
                                            cr.w2.data[82],
                                            cr.w2.data[81],
                                            cr.w2.data[80] };
                CR_MUL_W2_21   : pre_q = {  cr.w2.data[87],
                                            cr.w2.data[86],
                                            cr.w2.data[85],
                                            cr.w2.data[84] };
                CR_MUL_W2_22   : pre_q = {  cr.w2.data[91],
                                            cr.w2.data[90],
                                            cr.w2.data[89],
                                            cr.w2.data[88] };
                CR_MUL_W2_23   : pre_q = {  cr.w2.data[95],
                                            cr.w2.data[94],
                                            cr.w2.data[93],
                                            cr.w2.data[92] };
                CR_MUL_W2_24   : pre_q = {  cr.w2.data[99],
                                            cr.w2.data[98],
                                            cr.w2.data[97],
                                            cr.w2.data[96] };
                CR_MUL_W2_25   : pre_q = {  cr.w2.data[103],
                                            cr.w2.data[102],
                                            cr.w2.data[101],
                                            cr.w2.data[100] };
                CR_MUL_W2_26   : pre_q = {  cr.w2.data[107],
                                            cr.w2.data[106],
                                            cr.w2.data[105],
                                            cr.w2.data[104] };
                CR_MUL_W2_27   : pre_q = {  cr.w2.data[111],
                                            cr.w2.data[110],
                                            cr.w2.data[109],
                                            cr.w2.data[108] };
                CR_MUL_W2_28   : pre_q = {  cr.w2.data[115],
                                            cr.w2.data[114],
                                            cr.w2.data[113],
                                            cr.w2.data[112] };
                CR_MUL_W2_29   : pre_q = {  cr.w2.data[119],
                                            cr.w2.data[118],
                                            cr.w2.data[117],
                                            cr.w2.data[116] };
                CR_MUL_W2_30   : pre_q = {  cr.w2.data[123],
                                            cr.w2.data[122],
                                            cr.w2.data[121],
                                            cr.w2.data[120] };
                CR_MUL_W2_31   : pre_q = {  cr.w2.data[127],
                                            cr.w2.data[126],
                                            cr.w2.data[125],
                                            cr.w2.data[124] };
                CR_MUL_W2_32   : pre_q = {  cr.w2.data[131],
                                            cr.w2.data[130],
                                            cr.w2.data[129],
                                            cr.w2.data[128] };
                CR_MUL_W2_33   : pre_q = {  cr.w2.data[135],
                                            cr.w2.data[134],
                                            cr.w2.data[133],
                                            cr.w2.data[132] };
                CR_MUL_W2_34   : pre_q = {  cr.w2.data[139],
                                            cr.w2.data[138],
                                            cr.w2.data[137],
                                            cr.w2.data[136] };
                CR_MUL_W2_35   : pre_q = {  cr.w2.data[143],
                                            cr.w2.data[142],
                                            cr.w2.data[141],
                                            cr.w2.data[140] };
                CR_MUL_W2_36   : pre_q = {  cr.w2.data[147],
                                            cr.w2.data[146],
                                            cr.w2.data[145],
                                            cr.w2.data[144] };
                CR_MUL_W2_37   : pre_q = {  cr.w2.data[151],
                                            cr.w2.data[150],
                                            cr.w2.data[149],
                                            cr.w2.data[148] };
                CR_MUL_W2_38   : pre_q = {  cr.w2.data[155],
                                            cr.w2.data[154],
                                            cr.w2.data[153],
                                            cr.w2.data[152] };
                CR_MUL_W2_39   : pre_q = {  cr.w2.data[159],
                                            cr.w2.data[158],
                                            cr.w2.data[157],
                                            cr.w2.data[156] };
                CR_MUL_W2_40   : pre_q = {  cr.w2.data[163],
                                            cr.w2.data[162],
                                            cr.w2.data[161],
                                            cr.w2.data[160] };
                CR_MUL_W2_41   : pre_q = {  cr.w2.data[167],
                                            cr.w2.data[166],
                                            cr.w2.data[165],
                                            cr.w2.data[164] };
                CR_MUL_W2_42   : pre_q = {  cr.w2.data[171],
                                            cr.w2.data[170],
                                            cr.w2.data[169],
                                            cr.w2.data[168] };
                CR_MUL_W2_43   : pre_q = {  cr.w2.data[175],
                                            cr.w2.data[174],
                                            cr.w2.data[173],
                                            cr.w2.data[172] };
                CR_MUL_W2_44   : pre_q = {  cr.w2.data[179],
                                            cr.w2.data[178],
                                            cr.w2.data[177],
                                            cr.w2.data[176] };
                CR_MUL_W2_45   : pre_q = {  cr.w2.data[183],
                                            cr.w2.data[182],
                                            cr.w2.data[181],
                                            cr.w2.data[180] };
                CR_MUL_W2_46   : pre_q = {  cr.w2.data[187],
                                            cr.w2.data[186],
                                            cr.w2.data[185],
                                            cr.w2.data[184] };
                CR_MUL_W2_47   : pre_q = {  cr.w2.data[191],
                                            cr.w2.data[190],
                                            cr.w2.data[189],
                                            cr.w2.data[188] };
                CR_MUL_W2_48   : pre_q = {  cr.w2.data[195],
                                            cr.w2.data[194],
                                            cr.w2.data[193],
                                            cr.w2.data[192] };
                CR_MUL_W2_49   : pre_q = {  cr.w2.data[199],
                                            cr.w2.data[198],
                                            cr.w2.data[197],
                                            cr.w2.data[196] };
                CR_MUL_W2_50   : pre_q = {  cr.w2.data[203],
                                            cr.w2.data[202],
                                            cr.w2.data[201],
                                            cr.w2.data[200] };
                CR_MUL_W2_51   : pre_q = {  cr.w2.data[207],
                                            cr.w2.data[206],
                                            cr.w2.data[205],
                                            cr.w2.data[204] };
                CR_MUL_W2_52   : pre_q = {  cr.w2.data[211],
                                            cr.w2.data[210],
                                            cr.w2.data[209],
                                            cr.w2.data[208] };
                CR_MUL_W2_53   : pre_q = {  cr.w2.data[215],
                                            cr.w2.data[214],
                                            cr.w2.data[213],
                                            cr.w2.data[212] };
                CR_MUL_W2_54   : pre_q = {  cr.w2.data[219],
                                            cr.w2.data[218],
                                            cr.w2.data[217],
                                            cr.w2.data[216] };
                CR_MUL_W2_55   : pre_q = {  cr.w2.data[223],
                                            cr.w2.data[222],
                                            cr.w2.data[221],
                                            cr.w2.data[220] };
                CR_MUL_W2_56   : pre_q = {  cr.w2.data[227],
                                            cr.w2.data[226],
                                            cr.w2.data[225],
                                            cr.w2.data[224] };
                CR_MUL_W2_57   : pre_q = {  cr.w2.data[231],
                                            cr.w2.data[230],
                                            cr.w2.data[229],
                                            cr.w2.data[228] };
                CR_MUL_W2_58   : pre_q = {  cr.w2.data[235],
                                            cr.w2.data[234],
                                            cr.w2.data[233],
                                            cr.w2.data[232] };
                CR_MUL_W2_59   : pre_q = {  cr.w2.data[239],
                                            cr.w2.data[238],
                                            cr.w2.data[237],
                                            cr.w2.data[236] };
                CR_MUL_W2_60   : pre_q = {  cr.w2.data[243],
                                            cr.w2.data[242],
                                            cr.w2.data[241],
                                            cr.w2.data[240] };
                CR_MUL_W2_61   : pre_q = {  cr.w2.data[247],
                                            cr.w2.data[246],
                                            cr.w2.data[245],
                                            cr.w2.data[244] };
                CR_MUL_W2_62   : pre_q = {  cr.w2.data[251],
                                            cr.w2.data[250],
                                            cr.w2.data[249],
                                            cr.w2.data[248] };
            // W3
                CR_MUL_W3_META : pre_q = {  15'b0,
                                            cr.w3.meta_data.in_use,
                                            cr.w3.meta_data.data_len,  
                                            cr.w3.meta_data.neuron_idx };
                CR_MUL_W3_0    : pre_q = {  cr.w3.data[3],
                                            cr.w3.data[2],
                                            cr.w3.data[1],
                                            cr.w3.data[0] };
                CR_MUL_W3_1    : pre_q = {  cr.w3.data[7],
                                            cr.w3.data[6],
                                            cr.w3.data[5],
                                            cr.w3.data[4] };
                CR_MUL_W3_2    : pre_q = {  cr.w3.data[11],
                                            cr.w3.data[10],
                                            cr.w3.data[9],
                                            cr.w3.data[8] };
                CR_MUL_W3_3    : pre_q = {  cr.w3.data[15],
                                            cr.w3.data[14],
                                            cr.w3.data[13],
                                            cr.w3.data[12] };
                CR_MUL_W3_4    : pre_q = {  cr.w3.data[19],
                                            cr.w3.data[18],
                                            cr.w3.data[17],
                                            cr.w3.data[16] };
                CR_MUL_W3_5    : pre_q = {  cr.w3.data[23],
                                            cr.w3.data[22],
                                            cr.w3.data[21],
                                            cr.w3.data[20] };
                CR_MUL_W3_6    : pre_q = {  cr.w3.data[27],
                                            cr.w3.data[26],
                                            cr.w3.data[25],
                                            cr.w3.data[24] };
                CR_MUL_W3_7    : pre_q = {  cr.w3.data[31],
                                            cr.w3.data[30],
                                            cr.w3.data[29],
                                            cr.w3.data[28] };
                CR_MUL_W3_8    : pre_q = {  cr.w3.data[35],
                                            cr.w3.data[34],
                                            cr.w3.data[33],
                                            cr.w3.data[32] };
                CR_MUL_W3_9    : pre_q = {  cr.w3.data[39],
                                            cr.w3.data[38],
                                            cr.w3.data[37],
                                            cr.w3.data[36] };
                CR_MUL_W3_10   : pre_q = {  cr.w3.data[43],
                                            cr.w3.data[42],
                                            cr.w3.data[41],
                                            cr.w3.data[40] };
                CR_MUL_W3_11   : pre_q = {  cr.w3.data[47],
                                            cr.w3.data[46],
                                            cr.w3.data[45],
                                            cr.w3.data[44] };
                CR_MUL_W3_12   : pre_q = {  cr.w3.data[51],
                                            cr.w3.data[50],
                                            cr.w3.data[49],
                                            cr.w3.data[48] };
                CR_MUL_W3_13   : pre_q = {  cr.w3.data[55],
                                            cr.w3.data[54],
                                            cr.w3.data[53],
                                            cr.w3.data[52] };
                CR_MUL_W3_14   : pre_q = {  cr.w3.data[59],
                                            cr.w3.data[58],
                                            cr.w3.data[57],
                                            cr.w3.data[56] };
                CR_MUL_W3_15   : pre_q = {  cr.w3.data[63],
                                            cr.w3.data[62],
                                            cr.w3.data[61],
                                            cr.w3.data[60] };
                CR_MUL_W3_16   : pre_q = {  cr.w3.data[67],
                                            cr.w3.data[66],
                                            cr.w3.data[65],
                                            cr.w3.data[64] };
                CR_MUL_W3_17   : pre_q = {  cr.w3.data[71],
                                            cr.w3.data[70],
                                            cr.w3.data[69],
                                            cr.w3.data[68] };
                CR_MUL_W3_18   : pre_q = {  cr.w3.data[75],
                                            cr.w3.data[74],
                                            cr.w3.data[73],
                                            cr.w3.data[72] };
                CR_MUL_W3_19   : pre_q = {  cr.w3.data[79],
                                            cr.w3.data[78],
                                            cr.w3.data[77],
                                            cr.w3.data[76] };
                CR_MUL_W3_20   : pre_q = {  cr.w3.data[83],
                                            cr.w3.data[82],
                                            cr.w3.data[81],
                                            cr.w3.data[80] };
                CR_MUL_W3_21   : pre_q = {  cr.w3.data[87],
                                            cr.w3.data[86],
                                            cr.w3.data[85],
                                            cr.w3.data[84] };
                CR_MUL_W3_22   : pre_q = {  cr.w3.data[91],
                                            cr.w3.data[90],
                                            cr.w3.data[89],
                                            cr.w3.data[88] };
                CR_MUL_W3_23   : pre_q = {  cr.w3.data[95],
                                            cr.w3.data[94],
                                            cr.w3.data[93],
                                            cr.w3.data[92] };
                CR_MUL_W3_24   : pre_q = {  cr.w3.data[99],
                                            cr.w3.data[98],
                                            cr.w3.data[97],
                                            cr.w3.data[96] };
                CR_MUL_W3_25   : pre_q = {  cr.w3.data[103],
                                            cr.w3.data[102],
                                            cr.w3.data[101],
                                            cr.w3.data[100] };
                CR_MUL_W3_26   : pre_q = {  cr.w3.data[107],
                                            cr.w3.data[106],
                                            cr.w3.data[105],
                                            cr.w3.data[104] };
                CR_MUL_W3_27   : pre_q = {  cr.w3.data[111],
                                            cr.w3.data[110],
                                            cr.w3.data[109],
                                            cr.w3.data[108] };
                CR_MUL_W3_28   : pre_q = {  cr.w3.data[115],
                                            cr.w3.data[114],
                                            cr.w3.data[113],
                                            cr.w3.data[112] };
                CR_MUL_W3_29   : pre_q = {  cr.w3.data[119],
                                            cr.w3.data[118],
                                            cr.w3.data[117],
                                            cr.w3.data[116] };
                CR_MUL_W3_30   : pre_q = {  cr.w3.data[123],
                                            cr.w3.data[122],
                                            cr.w3.data[121],
                                            cr.w3.data[120] };
                CR_MUL_W3_31   : pre_q = {  cr.w3.data[127],
                                            cr.w3.data[126],
                                            cr.w3.data[125],
                                            cr.w3.data[124] };
                CR_MUL_W3_32   : pre_q = {  cr.w3.data[131],
                                            cr.w3.data[130],
                                            cr.w3.data[129],
                                            cr.w3.data[128] };
                CR_MUL_W3_33   : pre_q = {  cr.w3.data[135],
                                            cr.w3.data[134],
                                            cr.w3.data[133],
                                            cr.w3.data[132] };
                CR_MUL_W3_34   : pre_q = {  cr.w3.data[139],
                                            cr.w3.data[138],
                                            cr.w3.data[137],
                                            cr.w3.data[136] };
                CR_MUL_W3_35   : pre_q = {  cr.w3.data[143],
                                            cr.w3.data[142],
                                            cr.w3.data[141],
                                            cr.w3.data[140] };
                CR_MUL_W3_36   : pre_q = {  cr.w3.data[147],
                                            cr.w3.data[146],
                                            cr.w3.data[145],
                                            cr.w3.data[144] };
                CR_MUL_W3_37   : pre_q = {  cr.w3.data[151],
                                            cr.w3.data[150],
                                            cr.w3.data[149],
                                            cr.w3.data[148] };
                CR_MUL_W3_38   : pre_q = {  cr.w3.data[155],
                                            cr.w3.data[154],
                                            cr.w3.data[153],
                                            cr.w3.data[152] };
                CR_MUL_W3_39   : pre_q = {  cr.w3.data[159],
                                            cr.w3.data[158],
                                            cr.w3.data[157],
                                            cr.w3.data[156] };
                CR_MUL_W3_40   : pre_q = {  cr.w3.data[163],
                                            cr.w3.data[162],
                                            cr.w3.data[161],
                                            cr.w3.data[160] };
                CR_MUL_W3_41   : pre_q = {  cr.w3.data[167],
                                            cr.w3.data[166],
                                            cr.w3.data[165],
                                            cr.w3.data[164] };
                CR_MUL_W3_42   : pre_q = {  cr.w3.data[171],
                                            cr.w3.data[170],
                                            cr.w3.data[169],
                                            cr.w3.data[168] };
                CR_MUL_W3_43   : pre_q = {  cr.w3.data[175],
                                            cr.w3.data[174],
                                            cr.w3.data[173],
                                            cr.w3.data[172] };
                CR_MUL_W3_44   : pre_q = {  cr.w3.data[179],
                                            cr.w3.data[178],
                                            cr.w3.data[177],
                                            cr.w3.data[176] };
                CR_MUL_W3_45   : pre_q = {  cr.w3.data[183],
                                            cr.w3.data[182],
                                            cr.w3.data[181],
                                            cr.w3.data[180] };
                CR_MUL_W3_46   : pre_q = {  cr.w3.data[187],
                                            cr.w3.data[186],
                                            cr.w3.data[185],
                                            cr.w3.data[184] };
                CR_MUL_W3_47   : pre_q = {  cr.w3.data[191],
                                            cr.w3.data[190],
                                            cr.w3.data[189],
                                            cr.w3.data[188] };
                CR_MUL_W3_48   : pre_q = {  cr.w3.data[195],
                                            cr.w3.data[194],
                                            cr.w3.data[193],
                                            cr.w3.data[192] };
                CR_MUL_W3_49   : pre_q = {  cr.w3.data[199],
                                            cr.w3.data[198],
                                            cr.w3.data[197],
                                            cr.w3.data[196] };
                CR_MUL_W3_50   : pre_q = {  cr.w3.data[203],
                                            cr.w3.data[202],
                                            cr.w3.data[201],
                                            cr.w3.data[200] };
                CR_MUL_W3_51   : pre_q = {  cr.w3.data[207],
                                            cr.w3.data[206],
                                            cr.w3.data[205],
                                            cr.w3.data[204] };
                CR_MUL_W3_52   : pre_q = {  cr.w3.data[211],
                                            cr.w3.data[210],
                                            cr.w3.data[209],
                                            cr.w3.data[208] };
                CR_MUL_W3_53   : pre_q = {  cr.w3.data[215],
                                            cr.w3.data[214],
                                            cr.w3.data[213],
                                            cr.w3.data[212] };
                CR_MUL_W3_54   : pre_q = {  cr.w3.data[219],
                                            cr.w3.data[218],
                                            cr.w3.data[217],
                                            cr.w3.data[216] };
                CR_MUL_W3_55   : pre_q = {  cr.w3.data[223],
                                            cr.w3.data[222],
                                            cr.w3.data[221],
                                            cr.w3.data[220] };
                CR_MUL_W3_56   : pre_q = {  cr.w3.data[227],
                                            cr.w3.data[226],
                                            cr.w3.data[225],
                                            cr.w3.data[224] };
                CR_MUL_W3_57   : pre_q = {  cr.w3.data[231],
                                            cr.w3.data[230],
                                            cr.w3.data[229],
                                            cr.w3.data[228] };
                CR_MUL_W3_58   : pre_q = {  cr.w3.data[235],
                                            cr.w3.data[234],
                                            cr.w3.data[233],
                                            cr.w3.data[232] };
                CR_MUL_W3_59   : pre_q = {  cr.w3.data[239],
                                            cr.w3.data[238],
                                            cr.w3.data[237],
                                            cr.w3.data[236] };
                CR_MUL_W3_60   : pre_q = {  cr.w3.data[243],
                                            cr.w3.data[242],
                                            cr.w3.data[241],
                                            cr.w3.data[240] };
                CR_MUL_W3_61   : pre_q = {  cr.w3.data[247],
                                            cr.w3.data[246],
                                            cr.w3.data[245],
                                            cr.w3.data[244] };
                CR_MUL_W3_62   : pre_q = {  cr.w3.data[251],
                                            cr.w3.data[250],
                                            cr.w3.data[249],
                                            cr.w3.data[248] };
            // OUT
                CR_MUL_OUT_META : pre_q = {  13'b0, 
                                            cr.neuron_out.meta_data.output_ready ,
                                            cr.neuron_out.meta_data.mov_out_to_in ,
                                            cr.neuron_out.meta_data.in_use_by_accel,
                                            cr.neuron_out.meta_data.matrix_row_num,
                                            cr.neuron_out.meta_data.matrix_col_num };
                CR_MUL_OUT_0    : pre_q = {  cr.neuron_out.data[3],
                                            cr.neuron_out.data[2],
                                            cr.neuron_out.data[1],
                                            cr.neuron_out.data[0] };
                CR_MUL_OUT_1    : pre_q = {  cr.neuron_out.data[7],
                                            cr.neuron_out.data[6],
                                            cr.neuron_out.data[5],
                                            cr.neuron_out.data[4] };
                CR_MUL_OUT_2    : pre_q = {  cr.neuron_out.data[11],
                                            cr.neuron_out.data[10],
                                            cr.neuron_out.data[9],
                                            cr.neuron_out.data[8] };
                CR_MUL_OUT_3    : pre_q = {  cr.neuron_out.data[15],
                                            cr.neuron_out.data[14],
                                            cr.neuron_out.data[13],
                                            cr.neuron_out.data[12] };
                CR_MUL_OUT_4    : pre_q = {  cr.neuron_out.data[19],
                                            cr.neuron_out.data[18],
                                            cr.neuron_out.data[17],
                                            cr.neuron_out.data[16] };
                CR_MUL_OUT_5    : pre_q = {  cr.neuron_out.data[23],
                                            cr.neuron_out.data[22],
                                            cr.neuron_out.data[21],
                                            cr.neuron_out.data[20] };
                CR_MUL_OUT_6    : pre_q = {  cr.neuron_out.data[27],
                                            cr.neuron_out.data[26],
                                            cr.neuron_out.data[25],
                                            cr.neuron_out.data[24] };
                CR_MUL_OUT_7    : pre_q = {  cr.neuron_out.data[31],
                                            cr.neuron_out.data[30],
                                            cr.neuron_out.data[29],
                                            cr.neuron_out.data[28] };
                CR_MUL_OUT_8    : pre_q = {  cr.neuron_out.data[35],
                                            cr.neuron_out.data[34],
                                            cr.neuron_out.data[33],
                                            cr.neuron_out.data[32] };
                CR_MUL_OUT_9    : pre_q = {  cr.neuron_out.data[39],
                                            cr.neuron_out.data[38],
                                            cr.neuron_out.data[37],
                                            cr.neuron_out.data[36] };
                CR_MUL_OUT_10   : pre_q = {  cr.neuron_out.data[43],
                                            cr.neuron_out.data[42],
                                            cr.neuron_out.data[41],
                                            cr.neuron_out.data[40] };
                CR_MUL_OUT_11   : pre_q = {  cr.neuron_out.data[47],
                                            cr.neuron_out.data[46],
                                            cr.neuron_out.data[45],
                                            cr.neuron_out.data[44] };
                CR_MUL_OUT_12   : pre_q = {  cr.neuron_out.data[51],
                                            cr.neuron_out.data[50],
                                            cr.neuron_out.data[49],
                                            cr.neuron_out.data[48] };
                CR_MUL_OUT_13   : pre_q = {  cr.neuron_out.data[55],
                                            cr.neuron_out.data[54],
                                            cr.neuron_out.data[53],
                                            cr.neuron_out.data[52] };
                CR_MUL_OUT_14   : pre_q = {  cr.neuron_out.data[59],
                                            cr.neuron_out.data[58],
                                            cr.neuron_out.data[57],
                                            cr.neuron_out.data[56] };
                CR_MUL_OUT_15   : pre_q = {  cr.neuron_out.data[63],
                                            cr.neuron_out.data[62],
                                            cr.neuron_out.data[61],
                                            cr.neuron_out.data[60] };
                CR_MUL_OUT_16   : pre_q = {  cr.neuron_out.data[67],
                                            cr.neuron_out.data[66],
                                            cr.neuron_out.data[65],
                                            cr.neuron_out.data[64] };
                CR_MUL_OUT_17   : pre_q = {  cr.neuron_out.data[71],
                                            cr.neuron_out.data[70],
                                            cr.neuron_out.data[69],
                                            cr.neuron_out.data[68] };
                CR_MUL_OUT_18   : pre_q = {  cr.neuron_out.data[75],
                                            cr.neuron_out.data[74],
                                            cr.neuron_out.data[73],
                                            cr.neuron_out.data[72] };
                CR_MUL_OUT_19   : pre_q = {  cr.neuron_out.data[79],
                                            cr.neuron_out.data[78],
                                            cr.neuron_out.data[77],
                                            cr.neuron_out.data[76] };
                CR_MUL_OUT_20   : pre_q = {  cr.neuron_out.data[83],
                                            cr.neuron_out.data[82],
                                            cr.neuron_out.data[81],
                                            cr.neuron_out.data[80] };
                CR_MUL_OUT_21   : pre_q = {  cr.neuron_out.data[87],
                                            cr.neuron_out.data[86],
                                            cr.neuron_out.data[85],
                                            cr.neuron_out.data[84] };
                CR_MUL_OUT_22   : pre_q = {  cr.neuron_out.data[91],
                                            cr.neuron_out.data[90],
                                            cr.neuron_out.data[89],
                                            cr.neuron_out.data[88] };
                CR_MUL_OUT_23   : pre_q = {  cr.neuron_out.data[95],
                                            cr.neuron_out.data[94],
                                            cr.neuron_out.data[93],
                                            cr.neuron_out.data[92] };
                CR_MUL_OUT_24   : pre_q = {  cr.neuron_out.data[99],
                                            cr.neuron_out.data[98],
                                            cr.neuron_out.data[97],
                                            cr.neuron_out.data[96] };
                CR_MUL_OUT_25   : pre_q = {  cr.neuron_out.data[103],
                                            cr.neuron_out.data[102],
                                            cr.neuron_out.data[101],
                                            cr.neuron_out.data[100] };
                CR_MUL_OUT_26   : pre_q = {  cr.neuron_out.data[107],
                                            cr.neuron_out.data[106],
                                            cr.neuron_out.data[105],
                                            cr.neuron_out.data[104] };
                CR_MUL_OUT_27   : pre_q = {  cr.neuron_out.data[111],
                                            cr.neuron_out.data[110],
                                            cr.neuron_out.data[109],
                                            cr.neuron_out.data[108] };
                CR_MUL_OUT_28   : pre_q = {  cr.neuron_out.data[115],
                                            cr.neuron_out.data[114],
                                            cr.neuron_out.data[113],
                                            cr.neuron_out.data[112] };
                CR_MUL_OUT_29   : pre_q = {  cr.neuron_out.data[119],
                                            cr.neuron_out.data[118],
                                            cr.neuron_out.data[117],
                                            cr.neuron_out.data[116] };
                CR_MUL_OUT_30   : pre_q = {  cr.neuron_out.data[123],
                                            cr.neuron_out.data[122],
                                            cr.neuron_out.data[121],
                                            cr.neuron_out.data[120] };
                CR_MUL_OUT_31   : pre_q = {  cr.neuron_out.data[127],
                                            cr.neuron_out.data[126],
                                            cr.neuron_out.data[125],
                                            cr.neuron_out.data[124] };
                CR_MUL_OUT_32   : pre_q = {  cr.neuron_out.data[131],
                                            cr.neuron_out.data[130],
                                            cr.neuron_out.data[129],
                                            cr.neuron_out.data[128] };
                CR_MUL_OUT_33   : pre_q = {  cr.neuron_out.data[135],
                                            cr.neuron_out.data[134],
                                            cr.neuron_out.data[133],
                                            cr.neuron_out.data[132] };
                CR_MUL_OUT_34   : pre_q = {  cr.neuron_out.data[139],
                                            cr.neuron_out.data[138],
                                            cr.neuron_out.data[137],
                                            cr.neuron_out.data[136] };
                CR_MUL_OUT_35   : pre_q = {  cr.neuron_out.data[143],
                                            cr.neuron_out.data[142],
                                            cr.neuron_out.data[141],
                                            cr.neuron_out.data[140] };
                CR_MUL_OUT_36   : pre_q = {  cr.neuron_out.data[147],
                                            cr.neuron_out.data[146],
                                            cr.neuron_out.data[145],
                                            cr.neuron_out.data[144] };
                CR_MUL_OUT_37   : pre_q = {  cr.neuron_out.data[151],
                                            cr.neuron_out.data[150],
                                            cr.neuron_out.data[149],
                                            cr.neuron_out.data[148] };
                CR_MUL_OUT_38   : pre_q = {  cr.neuron_out.data[155],
                                            cr.neuron_out.data[154],
                                            cr.neuron_out.data[153],
                                            cr.neuron_out.data[152] };
                CR_MUL_OUT_39   : pre_q = {  cr.neuron_out.data[159],
                                            cr.neuron_out.data[158],
                                            cr.neuron_out.data[157],
                                            cr.neuron_out.data[156] };
                CR_MUL_OUT_40   : pre_q = {  cr.neuron_out.data[163],
                                            cr.neuron_out.data[162],
                                            cr.neuron_out.data[161],
                                            cr.neuron_out.data[160] };
                CR_MUL_OUT_41   : pre_q = {  cr.neuron_out.data[167],
                                            cr.neuron_out.data[166],
                                            cr.neuron_out.data[165],
                                            cr.neuron_out.data[164] };
                CR_MUL_OUT_42   : pre_q = {  cr.neuron_out.data[171],
                                            cr.neuron_out.data[170],
                                            cr.neuron_out.data[169],
                                            cr.neuron_out.data[168] };
                CR_MUL_OUT_43   : pre_q = {  cr.neuron_out.data[175],
                                            cr.neuron_out.data[174],
                                            cr.neuron_out.data[173],
                                            cr.neuron_out.data[172] };
                CR_MUL_OUT_44   : pre_q = {  cr.neuron_out.data[179],
                                            cr.neuron_out.data[178],
                                            cr.neuron_out.data[177],
                                            cr.neuron_out.data[176] };
                CR_MUL_OUT_45   : pre_q = {  cr.neuron_out.data[183],
                                            cr.neuron_out.data[182],
                                            cr.neuron_out.data[181],
                                            cr.neuron_out.data[180] };
                CR_MUL_OUT_46   : pre_q = {  cr.neuron_out.data[187],
                                            cr.neuron_out.data[186],
                                            cr.neuron_out.data[185],
                                            cr.neuron_out.data[184] };
                CR_MUL_OUT_47   : pre_q = {  cr.neuron_out.data[191],
                                            cr.neuron_out.data[190],
                                            cr.neuron_out.data[189],
                                            cr.neuron_out.data[188] };
                CR_MUL_OUT_48   : pre_q = {  cr.neuron_out.data[195],
                                            cr.neuron_out.data[194],
                                            cr.neuron_out.data[193],
                                            cr.neuron_out.data[192] };
                CR_MUL_OUT_49   : pre_q = {  cr.neuron_out.data[199],
                                            cr.neuron_out.data[198],
                                            cr.neuron_out.data[197],
                                            cr.neuron_out.data[196] };
                CR_MUL_OUT_50   : pre_q = {  cr.neuron_out.data[203],
                                            cr.neuron_out.data[202],
                                            cr.neuron_out.data[201],
                                            cr.neuron_out.data[200] };
                CR_MUL_OUT_51   : pre_q = {  cr.neuron_out.data[207],
                                            cr.neuron_out.data[206],
                                            cr.neuron_out.data[205],
                                            cr.neuron_out.data[204] };
                CR_MUL_OUT_52   : pre_q = {  cr.neuron_out.data[211],
                                            cr.neuron_out.data[210],
                                            cr.neuron_out.data[209],
                                            cr.neuron_out.data[208] };
                CR_MUL_OUT_53   : pre_q = {  cr.neuron_out.data[215],
                                            cr.neuron_out.data[214],
                                            cr.neuron_out.data[213],
                                            cr.neuron_out.data[212] };
                CR_MUL_OUT_54   : pre_q = {  cr.neuron_out.data[219],
                                            cr.neuron_out.data[218],
                                            cr.neuron_out.data[217],
                                            cr.neuron_out.data[216] };
                CR_MUL_OUT_55   : pre_q = {  cr.neuron_out.data[223],
                                            cr.neuron_out.data[222],
                                            cr.neuron_out.data[221],
                                            cr.neuron_out.data[220] };
                CR_MUL_OUT_56   : pre_q = {  cr.neuron_out.data[227],
                                            cr.neuron_out.data[226],
                                            cr.neuron_out.data[225],
                                            cr.neuron_out.data[224] };
                CR_MUL_OUT_57   : pre_q = {  cr.neuron_out.data[231],
                                            cr.neuron_out.data[230],
                                            cr.neuron_out.data[229],
                                            cr.neuron_out.data[228] };
                CR_MUL_OUT_58   : pre_q = {  cr.neuron_out.data[235],
                                            cr.neuron_out.data[234],
                                            cr.neuron_out.data[233],
                                            cr.neuron_out.data[232] };
                CR_MUL_OUT_59   : pre_q = {  cr.neuron_out.data[239],
                                            cr.neuron_out.data[238],
                                            cr.neuron_out.data[237],
                                            cr.neuron_out.data[236] };
                CR_MUL_OUT_60   : pre_q = {  cr.neuron_out.data[243],
                                            cr.neuron_out.data[242],
                                            cr.neuron_out.data[241],
                                            cr.neuron_out.data[240] };
                CR_MUL_OUT_61   : pre_q = {  cr.neuron_out.data[247],
                                            cr.neuron_out.data[246],
                                            cr.neuron_out.data[245],
                                            cr.neuron_out.data[244] };
                CR_MUL_OUT_62   : pre_q = {  cr.neuron_out.data[251],
                                            cr.neuron_out.data[250],
                                            cr.neuron_out.data[249],
                                            cr.neuron_out.data[248] };
            default        : pre_q = 32'b0;
        endcase
    end
    
    //Fabric Read
   // unique casez (address_b) // address holds the offset
        // ---- RW memory ----
      //  CR_0       : pre_q_b = {24'b0 , cr.xor_inp1};
      //  CR_1       : pre_q_b = {24'b0 , cr.xor_inp2};
       // CR_2       : pre_q_b = {24'b0 , cr.xor_result};
      //  default        : pre_q_b = 32'b0;
   // endcase
end


// Sample the data load - synchorus load
`MAFIA_DFF(q,   pre_q, Clk)
//`MAFIA_DFF(q_b, pre_q_b, Clk)

endmodule