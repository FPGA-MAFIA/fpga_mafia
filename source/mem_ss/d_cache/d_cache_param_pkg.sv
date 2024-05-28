//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : <TODO>
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description : 
//
//
//-----------------------------------------------------------------------------



package d_cache_param_pkg;

//TQ parameters
parameter TQ_ID_WIDTH     = 3;                       
parameter NUM_TQ_ENTRY    = 2**TQ_ID_WIDTH;                       



parameter WORD_WIDTH            = 32;                        // 4 Bytes - integer
parameter NUM_WORDS_IN_CL       = 4;                         // 
parameter NUM_BYTES_IN_CL       = 16;
 
//Address break-down: 
parameter ADDRESS_WIDTH         = 20;                        // OFFSET+SET+TAG -> 1MB
parameter OFFSET_WIDTH          = 4;                         // log2(4*4) -> log2(WORD * NUM_WORDS_IN_CL)
parameter SET_ADRS_WIDTH        = 8;
parameter TAG_WIDTH             = 8;
parameter CL_WIDTH              = WORD_WIDTH*NUM_WORDS_IN_CL;// (4Byte)*4 = 16 Bytes 
parameter LSB_OFFSET            = 0;                         // 16-byte offset
parameter MSB_OFFSET            = 3;                          
parameter LSB_WORD_OFFSET       = 2;                    // 4-byte Word offset
parameter MSB_WORD_OFFSET       = 3;  
parameter LSB_BYTE_OFFSET       = 0;                    // byte offset in a word
parameter MSB_BYTE_OFFSET       = 1;                       

parameter LSB_SET               = 4;                         // CL address is 16 bites (TAG_SET)
parameter MSB_SET               = 11;                        // 
parameter LSB_TAG               = 12;                        // 
parameter MSB_TAG               = 19;                        //
 
//Tag Array break-down: 
parameter CL_ADRS_WIDTH         = TAG_WIDTH + SET_ADRS_WIDTH;//16 -> Address[TAG_MSB:SET_LSB] = Address[19:4]
parameter WAY_WIDTH             = 2;
parameter NUM_WAYS              = 2**WAY_WIDTH;              //4 -> (2)^2. -> 2 bits represent 4 ways.
parameter WAY_ENTRY_SIZE        = (TAG_WIDTH+3); //{tag,valid,modified,mru} * NUM_WAYS
parameter SET_WIDTH             = WAY_ENTRY_SIZE*NUM_WAYS ; //{tag,valid,modified,mru} * NUM_WAYS
parameter NUM_SET               = 2**SET_ADRS_WIDTH;


typedef logic [CL_WIDTH      -1:0]  t_cl;
typedef logic [5             -1:0]  t_reg_id;
typedef logic [CL_ADRS_WIDTH -1:0]  t_cl_address;
typedef logic [TAG_WIDTH     -1:0]  t_tag;
typedef logic [SET_ADRS_WIDTH-1:0]  t_set_address;
typedef logic [SET_WIDTH     -1:0]  t_set_data;
typedef logic [ADDRESS_WIDTH -1:0]  t_address; 
typedef logic [TQ_ID_WIDTH   -1:0]  t_tq_id;
typedef logic [WORD_WIDTH -1:0]     t_word;
typedef logic [MSB_OFFSET     :0]   t_offset;
typedef logic [MSB_WORD_OFFSET:LSB_WORD_OFFSET]   t_word_offset;




typedef enum logic [2:0] {
  S_IDLE            = 3'h0,
  S_LU_CORE         = 3'h1,
  S_MB_WAIT_FILL    = 3'h2,
  S_MB_FILL_READY   = 3'h3,
  S_ERROR           = 3'h7
} t_tq_state ;

typedef enum logic [1:0] {
    NO_DATA_SRC     = 2'b00,
    DATA_SRC_CORE   = 2'b01,
    DATA_SRC_LOOKUP = 2'b10,
    DATA_SRC_FILL   = 2'b11
} t_data_src ;

typedef enum logic {
    RD_OP     = 1'b0 ,
    WR_OP     = 1'b1
} t_opcode ;

typedef enum logic [1:0] {
    NO_RSP  = 2'b00,
    HIT     = 2'b01,
    FILL    = 2'b10,
    MISS    = 2'b11
} t_lu_result ;

typedef enum logic [1:0] {
   NO_LU   = 2'b00 ,
   RD_LU   = 2'b01 ,
   WR_LU   = 2'b10 ,
   FILL_LU = 2'b11
} t_lu_opcode ;

typedef enum logic [1:0] {
    NO_FM_REQ      = 2'b00,
    DIRTY_EVICT_OP = 2'b01,
    FILL_REQ_OP    = 2'b11
} t_fm_req_op ;

typedef struct packed {
    logic         valid;
    logic         reject;
    logic         accept;
    t_address     address;
    t_reg_id      reg_id;
} t_ack ;

typedef struct packed {
    logic       valid;
    t_tq_id     tq_id;
    t_address   address;
    t_cl        data;
    t_fm_req_op opcode;
} t_fm_req ;

typedef struct packed {
    logic       valid;
    t_address   address;
    t_cl        data;
} t_fm_rd_rsp ;


// Core -> Cache request
typedef struct packed {
    logic        valid;
    t_reg_id     reg_id;
    t_opcode     opcode;
    t_address    address;
    t_word       data; 
    logic [3:0]  byte_en;
    logic        sign_extend;
} t_req ;

// Cache -> Core response
typedef struct packed {
    logic        valid;
    t_address    address;
    t_word       data;
    t_reg_id     reg_id;
} t_rd_rsp ;

typedef struct packed {
    logic        valid;
    t_lu_opcode  lu_op;
    t_tq_id      tq_id;
    t_address    address;
    t_cl         cl_data; //Fill Req
    t_word       data; //CoreWrites req
    logic        mb_hit_cancel;
    logic        rd_indication;
    logic        wr_indication;
    t_reg_id     reg_id;
    logic [3:0]  byte_en;
    logic        sign_extend;
} t_lu_req ;

typedef struct packed {
    logic        valid;
    t_lu_result  lu_result;
    t_lu_opcode  lu_op;
    t_tq_id      tq_id;
    t_cl         cl_data;
    t_reg_id     reg_id;
    // t_offset     offset;
    t_address    address;
    logic        rd_indication;
    logic        wr_match_in_pipe;
    logic [3:0]  byte_en;
    logic        sign_extend;
} t_lu_rsp ;


typedef struct packed {
    t_set_address set;
} t_set_rd_req ;

typedef struct packed {
    logic [NUM_WAYS-1:0][TAG_WIDTH-1:0] tags;
    logic [NUM_WAYS-1:0]                valid;
    logic [NUM_WAYS-1:0]                modified;
    logic [NUM_WAYS-1:0]                mru;
} t_set_rd_rsp ;

typedef struct packed {
    logic                                en;
    logic [SET_ADRS_WIDTH-1:0]           set;
    logic [NUM_WAYS-1:0][TAG_WIDTH-1:0]  tags;
    logic [NUM_WAYS-1:0]                 valid;
    logic [NUM_WAYS-1:0]                 modified;
    logic [NUM_WAYS-1:0]                 mru;
} t_set_wr_req ;


typedef struct packed {
    logic [SET_ADRS_WIDTH + WAY_WIDTH-1:0] data_array_address;
} t_cl_rd_req ;

typedef struct packed {
    logic [CL_WIDTH-1:0] cl_data;
} t_cl_rd_rsp ;

typedef struct packed {
    logic                                  valid;
    logic [SET_ADRS_WIDTH + WAY_WIDTH-1:0] data_array_address;
    logic [CL_WIDTH-1:0]                   data;
} t_cl_wr_req ;


typedef struct packed {
    logic                                   lu_valid;
    t_offset                                lu_offset;
    t_set_address                           lu_set; 
    t_tag                                   lu_tag;
    t_lu_opcode                             lu_op;
    t_tq_id                                 lu_tq_id;
    logic                                   hit;
    logic                                   miss;
    logic                                   mb_hit_cancel;
    logic [NUM_WAYS-1:0]                    set_ways_valid;
    logic [NUM_WAYS-1:0]                    set_ways_modified;
    logic [NUM_WAYS-1:0]                    set_ways_mru;
    logic [NUM_WAYS-1:0][TAG_WIDTH-1:0]     set_ways_tags;
    logic [NUM_WAYS-1:0]                    set_ways_victim;
    logic [NUM_WAYS-1:0]                    set_ways_hit;
    logic [WAY_WIDTH-1:0]                   set_ways_enc_hit;
    t_cl                                    cl_data;
    t_word                                  data;
    logic                                   fill_modified;
    logic                                   fill_rd;
    t_reg_id                                reg_id;
    logic                                   dirty_evict;
    logic [SET_ADRS_WIDTH + WAY_WIDTH-1:0]  data_array_address;
    logic                                   rd_indication;
    logic [3:0]                             byte_en;
    logic                                   sign_extend;
} t_pipe_bus; 


typedef struct packed {
    logic        rd_miss;
    logic        alloc_rd_fill;
    t_tq_id      lu_tq_id;
    t_cl_address cl_address;
} t_early_lu_rsp;


typedef struct packed {
t_tq_state                         state;
logic        [NUM_BYTES_IN_CL-1:0] merge_buffer_e_modified; 
t_cl                               merge_buffer_data; 
t_cl_address                       cl_address;
t_word_offset                      cl_word_offset; 
logic                              rd_indication; 
logic                              wr_indication; 
t_reg_id                           reg_id; 
logic [3:0]                        byte_en;     
logic                              sign_extend;
} t_tq_entry ;
endpackage