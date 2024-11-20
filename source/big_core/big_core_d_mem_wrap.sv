`include "macros.vh"

module big_core_d_mem_wrap #(
    parameter WORD_WIDTH,   // no default value.
    parameter ADRS_WIDTH    // no default value.
) (
    input  logic        clock           ,
    // Interface A
    input  logic [31:0] q103_address_a  ,
    input  logic        q103_wren_a     ,
    input  logic        q103_rden_a     ,
    input  logic [3:0]  q103_byteena_a  ,
    input  logic [31:0] q103_data_a     ,
    output logic [31:0] q105_q_a        ,
    output logic        q105_q_valid_a  ,
    // Interface B
    input  logic [31:0] q503_address_b  ,
    input  logic        q503_wren_b     ,
    input  logic [3:0]  q503_byteena_b  ,
    input  logic [31:0] q503_data_b     ,
    output logic [31:0] q505_q_b     
);

// Support the byte enable for the data memory by shifting the data to the correct position
// Half & Byte Write
logic [31:0] q103_shift_data_a;
logic [3:0]  q103_shift_byteena_a;
// Declare intermediate signals
logic [31:0] q104_pre_q_a;
logic [31:0] q104_q_a;

// Accessing the local tile or writing to other local d_mem region
logic [31:0] q104_address_a;
`MAFIA_DFF(q104_address_a[1:0], q103_address_a[1:0], clock)

assign q103_shift_data_a = (q103_address_a[1:0] == 2'b01) ? { q103_data_a[23:0], 8'b0   } :
                           (q103_address_a[1:0] == 2'b10) ? { q103_data_a[15:0], 16'b0  } :
                           (q103_address_a[1:0] == 2'b11) ? { q103_data_a[7:0],  24'b0  } :
                                                              q103_data_a;

assign q103_shift_byteena_a = (q103_address_a[1:0] == 2'b01) ? { q103_byteena_a[2:0], 1'b0 } :
                              (q103_address_a[1:0] == 2'b10) ? { q103_byteena_a[1:0], 2'b0 } :
                              (q103_address_a[1:0] == 2'b11) ? { q103_byteena_a[0],   3'b0 } :
                                                                 q103_byteena_a;



mem #(
    .WORD_WIDTH(WORD_WIDTH),
    .ADRS_WIDTH(ADRS_WIDTH)
) d_mem (
    .clock      (clock),
    // Core interface (instruction fetch)
    .address_a  (q103_address_a[31:2]),
    .data_a     (q103_shift_data_a),
    .wren_a     (q103_wren_a),
    .byteena_a  (q103_shift_byteena_a),
    .q_a        (q104_pre_q_a),
    // Fabric interface
    .address_b  (q503_address_b[31:2]),
    .data_b     (q503_data_b),
    .wren_b     (q503_wren_b),
    .byteena_b  (q503_byteena_b),
    .q_b        (q505_q_b)
);

assign q104_q_a = (q104_address_a[1:0] == 2'b01) ? { 8'b0,  q104_pre_q_a[31:8]   } :
                  (q104_address_a[1:0] == 2'b10) ? { 16'b0, q104_pre_q_a[31:16] } :
                  (q104_address_a[1:0] == 2'b11) ? { 24'b0, q104_pre_q_a[31:24] } :
                                                    q104_pre_q_a;
`MAFIA_DFF(q105_q_a, q104_q_a, clock)
logic q103_q_rd_valid_a;
logic q104_q_valid_a;
assign q103_q_rd_valid_a = q103_rden_a;
`MAFIA_DFF(q104_q_valid_a, q103_q_rd_valid_a, clock)
`MAFIA_DFF(q105_q_valid_a, q104_q_valid_a, clock)


endmodule
