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



package mem_ss_param_pkg;

//TQ parameters
parameter TQ_ID_WIDTH     = 3;                       
parameter NUM_TQ_ENTRY    = 2**TQ_ID_WIDTH;                       

parameter WORD_WIDTH            = 32;                        // 4 Bytes - integer
parameter NUM_WORDS_IN_CL       = 4;                         // 
 
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


// cache -> fm request
typedef struct packed {
    logic       valid;
    t_tq_id     tq_id;
    t_address   address;
    t_cl        data;
    t_fm_req_op opcode;
} t_fm_req ;

// fm -> cache response
typedef struct packed {
    logic       valid;
    t_address   address;
    t_cl        data;
} t_fm_rd_rsp ;

// fm -> cache response
typedef struct packed {
    logic       valid;
    t_address   address;
    t_cl        data;
} t_sram_rd_rsp ;

// Core -> Cache request
typedef struct packed {
    logic        valid;
    t_reg_id     reg_id;
    t_opcode     opcode;
    t_address    address;
    t_word       data;    
} t_req ;

// Cache -> Core response
typedef struct packed {
    logic        valid;
    t_address    address;
    t_word       data;
   t_reg_id      reg_id;
} t_rd_rsp ;



endpackage