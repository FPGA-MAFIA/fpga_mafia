package sdram_ctrl_pkg;

// The following parameters are for de10-lite 32MBx16 SDRAM
// Grade speed -7.5 with 133MHz clock. 
// Period is 7.5ns

// duration of operations in clock cycles
parameter  tRCD        = 2;     // Activate command to READ/WRITE. 
parameter  tCAC        = 2;     // CAS latency counter. Read latency. 
parameter  tRAS        = 5;     // Activation to Precharge. 
parameter  tRP         = 2;     // Precharge cycle consists of precharge_cmd + 1 nop 
parameter  tDPL        = 2;     // number on nops after write 
parameter  tRC         = 8;     // refresh cycle consists of refresh_cmd and 7 nops
parameter  tMRD        = 2;     // Mode register program time consists of 1 mrs_cmd + 1 nop
parameter  RefreshRate = 1560;  // Refresh time. tref = 64ms -> 64ms/8192 rows 

//parameter NopMaxDuration           = 13334;         // when power up no operation should be taken during that period (100us/7.5ns)
parameter NopMaxDuration           = 20;
parameter TimesToRefreshWhenInit   = 8;    
parameter Set2Burst       = 10'b0_00_010_0_011;   // set sequential burst of lenght 8. set CAS latency to 2 cycles(for 133Mhz op). 
parameter SetSingleAccess = 10'b1_00_010_0_000;

typedef struct packed {
    logic  [13:0] NopInitCounter;
    logic  [1:0]  PrechargeCounter;
    logic  [1:0]  ActivationCounter;
    logic  [1:0]  ReadCounter;
    logic  [1:0]  WriteNopCounter;
    logic  [3:0]  RefreshTrcCounter;
    logic  [3:0]  RefreshInitCounter; // Indicates the 8 refreshes that runs in initialization
    logic         ModeRegisterSetCounter;
} sdram_counters;

typedef struct packed {
    logic  [13:0] NopInitCounter;
    logic  [1:0]  PrechargeCounter;
    logic  [1:0]  ActivationCounter;
    logic  [1:0]  ReadCounter;
    logic  [1:0]  WriteNopCounter;
    logic  [3:0]  RefreshTrcCounter;
    logic  [3:0]  RefreshInitCounter;
    logic         ModeRegisterSetCounter;
} next_sdram_counters;

typedef enum {
    RST,        
    INIT_WAIT,     // Initialization state - waiting
    INIT_PREA,     // Initialization state - precharge 
    INIT_REFRESH,  // Initialization state - refresh
    INIT_NOP,      // Initialization state - nops at refresh
    INIT_MODE_REG, // Initialization state - mode reg set
    IDLE,         // Waiting for commands  
    ACTIVATE,     // Open row
    READ,         // read 
    WRITE,        // write
    PRECHARGE,    // precharge 
    REFRESH       // refresh
} sdram_states;

typedef enum logic [2:0] {  // {RAS_N, CAS_N, WE_N}
    NOP_CMD           = 3'b111,
    READ_CMD          = 3'b101,
    WRITE_CMD         = 3'b100,
    ACTIVATE_CMD      = 3'b011,
    PRECHARGE_ALL_CMD = 3'b010,
    AUTO_REFRESH_CMD  = 3'b001,
    MRS_CMD           = 3'b000  
} sdram_cmd;



endpackage