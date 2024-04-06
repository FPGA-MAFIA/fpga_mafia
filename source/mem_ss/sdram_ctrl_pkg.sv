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

/*
typedef struct packed {
    logic   [12:0]  DRAM_ADDR;  
	logic	[1:0]	DRAM_BA;
    logic           DRAM_CAS_N;
    logic           DRAM_CKE;
    logic           DRAM_CLK;
	logic     		DRAM_CS_N;
	logic  [15:0]	DRAM_DQ;
	logic		    DRAM_LDQM;
    logic	        DRAM_RAS_N;
	logic		    RAM_UDQM;
    logic           DRAM_WE_N;
} sdram_ctrl;
*/

typedef enum {
   // for INIT states details please refer to the documenttion Pages.22-23 
   INIT_NOP,       // Initialize state after power up
   INIT_PALL,      // precharge all banks at init stage
   INIT_REFRESH,   // performe refresh at init state
   /////////////////////////////////////////////////////////////////////
   IDLE,           // Waiting for commands
   MRS,            // Mode register set. 
   ACTIVE,         // Row is activated 
   READ,           // Performing read operation
   WRITE,          // Performing write operation
   PRECHARGE,      // Precharging 
   REFRESH        // Perform auti-refresh cycle
} sdram_states;

endpackage