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



package cache_param_pkg;

//TQ parameters
parameter TQ_ID_WIDTH  = 3;                       
parameter NUM_TQ_ENTRY = 2**TQ_ID_WIDTH;                       



parameter WORD_WIDTH      = 32;                        // 4 Bytes - integer
parameter WORD_MSB        = 2;                         // [1:0] -> 4 Bytes
parameter NUM_WORDS_IN_CL = 4;                         // 
 
//Address break-down: 
parameter ADDRESS_WIDTH   = 20;                        // OFFSET+SET+TAG -> 1MB
parameter OFFSET_WIDTH    = 4;                         // log2(4*4) -> log2(WORD * NUM_WORDS_IN_CL)
parameter SET_ADRS_WIDTH  = 8;
parameter TAG_WIDTH       = 8;
parameter CL_WIDTH        = WORD_WIDTH*NUM_WORDS_IN_CL;// (4Byte)*4 = 16 Bytes 
parameter LSB_OFFSET      = 0;                         // 
parameter MSB_OFFSET      = 3;                         // CL is 32 Bytes
parameter LSB_SET         = 4;                         // CL address is 16 bites (TAG_SET)
parameter MSB_SET         = 11;                        // 
parameter LSB_TAG         = 12;                        // 
parameter MSB_TAG         = 19;                        //
 
//Tag Array break-down: 
parameter CL_ADRS_WIDTH   = TAG_WIDTH + SET_ADRS_WIDTH;//16 -> Address[TAG_MSB:SET_LSB] = Address[19:4]
parameter WAY_WIDTH       = 2;
parameter NUM_WAYS        = 2**WAY_WIDTH;              //4 -> (2)^2. -> 2 bits represent 4 ways.
parameter SET_WIDTH       = (TAG_WIDTH+4)*NUM_WAYS ; //{tag,valid,modified,mru,fill} * NUM_WAYS

typedef logic [CL_WIDTH      -1:0] t_cl;
typedef logic [5             -1:0] t_reg_id;
typedef logic [CL_ADRS_WIDTH -1:0] t_cl_address;
typedef logic [TAG_WIDTH     -1:0] t_tag;
typedef logic [SET_ADRS_WIDTH-1:0] t_set_address;
typedef logic [SET_WIDTH     -1:0] t_set_data;
typedef logic [ADDRESS_WIDTH -1:0] t_address; 
typedef logic [TQ_ID_WIDTH   -1:0] t_tq_id;



typedef enum logic [3:0] {
  IDLE            =   4'h0,
  CORE_WR_REQ     =   4'h1,
  LU_CORE_WR_REQ  =   4'h2,
  CORE_RD_REQ     =   4'h3,
  LU_CORE_RD_REQ  =   4'h4,
  CORE_RD_RSP     =   4'h5,
  WAIT_FILL       =   4'h6,
  FILL            =   4'h7,
  LU_FILL         =   4'h8,
  ERROR           =   4'hF
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
    HIT     = 2'b00 ,
    MISS    = 2'b01 ,
    REJECT  = 2'b10
} t_lu_result ;

typedef enum logic [1:0] {
   NO_LU   = 2'b00 ,
   RD_LU   = 2'b01 ,
   WR_LU   = 2'b10 ,
   FILL_LU = 2'b11
} t_lu_opcode ;

typedef struct packed {
    logic         valid;
    logic   [4:0] reg_id;
    t_opcode      opcode;
    t_address     address;
    t_cl          data;
} t_req ;

typedef struct packed {
    logic         valid;
    logic         reject;
    logic         accept;
    t_address     address;
    logic   [4:0] reg_id;
} t_ack ;

typedef struct packed {
    logic       valid;
    t_address   address;
    t_cl        data;
} t_fm_wr_req ;

typedef struct packed {
    logic       valid;
    t_tq_id     tq_id;
    t_address   address;
} t_fm_rd_req ;

typedef struct packed {
    logic       valid;
    t_tq_id     tq_id;
    t_cl        data;
} t_fm_rd_rsp ;

typedef struct packed {
    logic        valid;
    t_address    address;
    t_cl         data;
    logic   [4:0] reg_id;
} t_rd_rsp ;

typedef struct packed {
    logic        valid;
    t_lu_opcode  lu_op;
    t_tq_id      tq_id;
    t_address    address;
    t_cl         cl_data;
} t_lu_req ;

typedef struct packed {
    logic        valid;
    t_lu_result  lu_result;
    t_tq_id      tq_id;
    t_cl         data;
} t_lu_rsp ;


typedef struct packed {
    logic                 valid;
    t_set_address         set;
    t_tag                 tag;
    t_lu_opcode           lu_op;
    t_cl                  cl_data;
    t_tq_id               tq_id;
    logic                 hit;
    logic                 reject;
    logic                 dirty_evict;
    t_tag                 dirty_evict_tag;
    logic [NUM_WAYS-1:0]  aloc_way;
    logic [NUM_WAYS-1:0]  valid_way;
    logic [WAY_WIDTH-1:0] encoded_way;
} t_pipe_bus ;

typedef struct packed {
    t_set_address set;
} t_set_rd_req ;

typedef struct packed {
    logic [NUM_WAYS-1:0][TAG_WIDTH-1:0] tags;
    logic [NUM_WAYS-1:0]                valid;
    logic [NUM_WAYS-1:0]                modified;
    logic [NUM_WAYS-1:0]                mru;
    logic [NUM_WAYS-1:0]                fill;
} t_set_rd_rsp ;

typedef struct packed {
    logic                                en;
    logic [SET_ADRS_WIDTH-1:0]           set;
    logic [NUM_WAYS-1:0][TAG_WIDTH-1:0]  tags;
    logic [NUM_WAYS-1:0]                 valid;
    logic [NUM_WAYS-1:0]                 modified;
    logic [NUM_WAYS-1:0]                 mru;
    logic [NUM_WAYS-1:0]                 fill;
} t_set_wr_req ;


typedef struct packed {
    logic [SET_ADRS_WIDTH + WAY_WIDTH-1:0] cl_address;
} t_cl_rd_req ;

typedef struct packed {
    logic [CL_WIDTH-1:0] cl_data;
} t_cl_rd_rsp ;

typedef struct packed {
    logic                                  valid;
    logic [SET_ADRS_WIDTH + WAY_WIDTH-1:0] cl_address;
    logic [CL_WIDTH-1:0]                   data;
} t_cl_wr_req ;

    
endpackage