package sdram_ctrl_pkg;

// The following parameters are for de10-lite 32MBx16 SDRAM
// Grade speed -7 with 143MHz clock. 
// Period is 7ns

// duration of operations in clock cycles
parameter  tRCD        = 3;     // Activate command to READ/WRITE. 
parameter  tCAC        = 3;     // CAS latency counter. Read latency. 
parameter  tRAS        = 6;     // Activation to Precharge. 
parameter  tRP         = 3;     // Precharge cycle consists of precharge_cmd + 2 nops 
parameter  tRC         = 9;     // refresh cycle consists of refresh_cmd and 8 nops
parameter  tMRD        = 2;     // Mode register program time consists of 1 mrs_cmd + 1 nop
parameter  RefreshRate = 1560;  // Refresh time. tref = 64ms -> 64ms/8192 rows 


parameter NopMaxDuration           = 14280;                    // when power up no operation should be taken during that period (100us/7ns)
parameter TimesToRefreshWhenInit   = 8;    
parameter Set2Burst       = 10'b0_00_011_0_011;                // set sequential burst of lenght 8. set CAS latency to 3 cycles(for 143Mhz op). 
parameter SetSingleAccess = 10'b1_00_011_0_000;

typedef struct packed {
    logic  [13:0] NopInitCounter;
    logic  [1:0]  PrechargeCounter;
    logic  [3:0]  RefreshCounter;
    logic  [3:0]  RefreshInitCounter;
    logic         ModeRegisterSetCounter;  
} sdram_counters;

typedef struct packed {
    logic [14:0]  NextNopInitCounter;
    logic  [1:0]  NextPrechargeCounter;
    logic  [3:0]  NextRefreshCounter;
    logic  [3:0]  NextRefreshInitCounter;
    logic         NextModeRegisterSetCounter;
} next_sdram_counters;

typedef enum {
    INIT,       // Initialization 
    IDLE,       // Waiting for commands  
    ACTIVATE,   // Open row
    READ,       // read 
    WRITE,      // write
    PRECHARGE,  // precharge 
    REFRESH     // refresh
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