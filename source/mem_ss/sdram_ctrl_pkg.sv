package sdram_ctrl_pkg;

// The following parameters are for de10-lite 32MBx16 SDRAM
// Grade speed -5 with 200MHz clock. 

// Timing parameters
parameter  tRCDMax     = 3;     // Activate command to READ/WRITE. 3 clock cycles (15ns) 
parameter  tCACMax     = 3;     // CAS latency counter. Read latency. 3 clock cycles (15ns)
parameter  tRASMax     = 7;     // Activation to Precharge. 7 clock cycles (35ns)
parameter  tRPMax      = 3;     // Precharge to Activation(cycles to perform precharge). 3 clock cycles (15ns)
parameter  tRCMax      = 10;    // Refresh to refresh(cycles to perform refresh). 10 clock cycles (50ns)
parameter  tMRDMax     = 10;    // Mode register program time.
parameter  RefreshMax  = 1560;  // Refresh time. tref = 64ms -> 64ms/8192 rows 


parameter InhibitMax               = 20000;                    // when power up no operation should be taken during that period (100us/5ns)
parameter InitRefreshMax           = 80;                       // 8 refresh cycles are needed at power up. Each one is tRCMax   
parameter ModeRegAddrBitsSetBurst  = 13'b000_0_00_011_0_011; // set sequential burst of lenght 8. set CAS latency to 3 cycles(for 200Mhz op). 
parameter ModeRegAddrBitsSetSingle = 13'b000_1_00_011_0_000;

typedef enum {
   INIT            // Initial state
   IDLE,           // Waiting for commands
   MRS,            // Mode register set. 
   ACTIVATE,       // Row is activated 
   READ,           // Performing read operation
   WRITE,          // Performing write operation
   PRECHARGE,      // Precharging 
   REFRESH,        // Perform auti-refresh cycle
   NOP,            // NOP              
   PRECHARGE_ALL            // Precharge all
} sdram_states;

endpackage