package sdram_ctrl_pkg;

// The following parameters are for de10-lite 32MBx16 SDRAM
// Grade speed -5 with 200MHz clock. 

// The parameters were taken from the spec on Pg.19-20 
parameter  tRCDCounter = 3;  // Activate command to READ/WRITE. 3 clock cycles (15ns) 
parameter  tCACCounter = 3;  // CAS latency counter. Read latency. 3 clock cycles (15ns)
parameter  tRASCounter = 7;  // Activation to Precharge. 7 clock cycles (35ns)
parameter  tRPCounter  = 3;  // Precharge to Activation. 3 clock cycles (15ns)
parameter  tRCCounter  = 10; // Refresh to refresh. 10 clock cycles (50ns)
parameter  RefCounter  = 1560; // Refresh time. tref = 64ms -> 64ms/8192 rows    

parameter ModeRegistrSet = 15'b00000_0_00_011_0_011; // set sequential burst of lenght 8. set CAS latency to 3 cycles(for 200Mhz op). Set bit 9 to 1 for single Location access


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

typedef enum {
   INIT,        // Initialize state after power up
   IDLE,        // Waiting for commands
   MRS,         // Mode register set. 
   ACTIVE,      // Row is activated 
   READ,        // Performing read operation
   WRITE,       // Performing write operation
   PRECHARGE,   // Precharging 
   REFRESH,     // Perform auti-refresh cycle
   WAIT_REFRESH // Waiting to complete current command befire starting refresh   
} sdram_states;

endpackage