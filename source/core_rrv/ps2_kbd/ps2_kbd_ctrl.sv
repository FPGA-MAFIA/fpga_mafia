
`include "macros.vh"

module ps2_kbd_ctrl
(
    // PS2 interface
    input  logic       kbd_clk,
    input  logic       data_in_kc,
    // Core interface
    input  logic       core_clk,
    input  logic       core_rst, 
    input  logic       core_read_en,
    output logic [7:0] data_out_cc, 
    output logic       valid_cc, 
    output logic       error,
    //CR - Control register & indications
    output logic       data_ready,
    input  logic       scanf_en   
);
    

logic fifo_empty;
logic fifo_full;
assign error = 1'b0;
// We need a async reset for the kbd_clk domain
// This is due to kbd domain clk is not toggling during reset 
// we need to reset the register in a async way using special macros
logic async_rst;
assign async_rst = core_rst;

// From the kbd side: 
// - shift register a valid bit to indicate what part of the transmission we are in
// when bit 0 is set, we are in the start bit
// when bit 10 is set, we are in the stop bit
logic [10:0] shift_valid_vec_kc;
logic [10:0] next_shift_valid_vec_kc;
assign next_shift_valid_vec_kc[10:0] = {shift_valid_vec_kc[9:0], shift_valid_vec_kc[10]};
`MAFIA_ASYNC_RST_VAL_DFF(shift_valid_vec_kc, next_shift_valid_vec_kc, kbd_clk, async_rst, 11'h1)

// - Shift register the data input
logic [10:0] shift_data_vec_kc;
logic [10:0] next_shift_data_vec_kc;

assign next_shift_data_vec_kc[10:0] = {shift_data_vec_kc[9:0], data_in_kc};
`MAFIA_ASYNC_RST_VAL_DFF(shift_data_vec_kc, next_shift_data_vec_kc, kbd_clk, async_rst, 11'h7FF)


// Detect the stop bit an use it to sample the data in the fifo:
logic data_ready_kc; // kc->Kbd Clock
logic data_ready_cc; // cc->Core Clock
logic data_ready_sample_cc; 
assign data_ready_kc = (shift_valid_vec_kc[10]);
// Use a meta flop to sample ready indication
`MAFIA_METAFLOP(data_ready_cc, data_ready_kc, core_clk)
`MAFIA_DFF(data_ready_sample_cc, data_ready_cc, core_clk)

// Posedge detection so we push only once for each data
// Set only when the data is ready and the sample is not ready -> indicating this is the first time we sample the data
// also we need to have the scanf_en to be set to allow the push
logic en_cc_domain_push;
assign en_cc_domain_push =     (data_ready_cc & !data_ready_sample_cc)
                            && scanf_en
                            && (!fifo_full);


// The data is ready when the stop bit is set
logic [7:0] data_to_push_kc;
logic [7:0] pre_data_to_push_cc;
logic [7:0] data_to_push_cc;
logic       push_cc;
assign data_to_push_kc = shift_data_vec_kc[8:1];

// This is strage. we are assigning a kc domain signal to a cc domain signal
// I think this is legal due to the assumption that the data is stable.
/// This  are waiting for the data_ready to be stable on the cc domain
`MAFIA_DFF(push_cc, en_cc_domain_push , core_clk)
// Note! we are not using a meta flop here
`MAFIA_EN_DFF(pre_data_to_push_cc[7:0], data_to_push_kc[7:0], en_cc_domain_push, core_clk)
assign data_to_push_cc[0] = pre_data_to_push_cc[7];
assign data_to_push_cc[1] = pre_data_to_push_cc[6];
assign data_to_push_cc[2] = pre_data_to_push_cc[5];
assign data_to_push_cc[3] = pre_data_to_push_cc[4];
assign data_to_push_cc[4] = pre_data_to_push_cc[3];
assign data_to_push_cc[5] = pre_data_to_push_cc[2];
assign data_to_push_cc[6] = pre_data_to_push_cc[1];
assign data_to_push_cc[7] = pre_data_to_push_cc[0];


fifo #(.FIFO_DEPTH(4), .DATA_WIDTH(8)) fifo 
(
    .clk          (core_clk       ) , //input  logic                   clk,
    .rst          (core_rst       ) , //input  logic                   rst,
    .push         (push_cc        ) , //input  logic                   push,
    .push_data    (data_to_push_cc) , //input  logic[DATA_WIDTH-1:0]   push_data,
    .pop          (core_read_en   ) , //input  logic                   pop,
    .pop_data     (data_out_cc    ) , //output logic [DATA_WIDTH-1:0]  pop_data,
    .full         (fifo_full      ) , //output logic                   full,
    .almost_full  (               ) , //output logic                   almost_full,
    .empty        (fifo_empty     )   //output logic                   empty
);

assign valid_cc   = !fifo_empty & core_read_en;
assign data_ready = !fifo_empty;


endmodule