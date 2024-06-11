
`include "macros.vh"

module big_core_cachel1_top
import big_core_pkg::*;
#(parameter RF_NUM_MSB=15)  //default 15 for rv32e compatible (save space on FPGA
(
input  logic        Clock  ,
input  logic        Rst    ,
input  t_tile_id    local_tile_id,
input  logic        RstPc,
//============================================
//      keyboard interface
//============================================
input logic             kbd_clk,       // Clock from keyboard
input logic             data_in_kc,    // Data from keyboard
//============================================
//      vga interface
//============================================
output logic        inDisplayArea,
output t_vga_out    vga_out,         // VGA_OUTPUT
//============================================
//      fpga interface
//============================================             
input  var t_fpga_in   fpga_in,  // CR_MEM
output t_fpga_out      fpga_out,      // CR_MEM
//============================================
//      sdram controller interface
//============================================             
output logic    [12:0]  DRAM_ADDR,  // Address Bus: Multiplexed row/column address for accessing SDRAM
output logic	[1:0]	DRAM_BA,    // Bank Address: Selects one of the internal banks within the SDRAM 
output logic		   	DRAM_CAS_N, // Column Address Strobe (CAS) Negative: Initiates column access
output logic	      	DRAM_CKE,   // Clock Enable: Enables or disables the clock to save power
output logic	     	DRAM_CLK,   // Clock: System clock signal for SDRAM
output logic     		DRAM_CS_N,  // Chip Select Negative: Enables the SDRAM chip when low
inout          [15:0]	DRAM_DQ,    // Data Bus: Bidirectional bus for data transfer to/from SDRAM
output logic		    DRAM_DQML,  // Lower Byte Data Mask: Masks lower byte during read/write operations
output logic			DRAM_RAS_N, // Row Address Strobe (RAS) Negative: Initiates row access
output logic		    DRAM_DQMH,  // Upper Byte Data Mask: Masks upper byte during read/write operations
output logic		    DRAM_WE_N   // Write Enable Negative: Determines if the operation is a read(high) or write(low)

);

logic DMemReady;
logic ReadyQ101H;
t_core2mem_req Core2DmemReqQ103H;

big_core 
#( .RF_NUM_MSB(RF_NUM_MSB) )    
big_core (
   .Clock               ( Clock              ), // input  logic        Clock,
   .Rst                 ( Rst                ), // input  logic        Rst,
   .RstPc               ( RstPc              ), // input  logic        RstPc,
   // Instruction Memory
   .ReadyQ101H          ( ReadyQ101H    ), // output logic        ReadyQ101H,          // To I_MEM
   .PcQ100H             ( PcQ100H            ), // output logic [31:0] PcQ100H,             // To I_MEM
   .PreInstructionQ101H ( PreInstructionQ101H), // input  logic [31:0] PreInstructionQ101H, // From I_MEM
   // Data Memory
   .DMemReady           ( DMemReady     ), // input  logic        DMemReady  , // From D_MEM
   .Core2DmemReqQ103H   ( Core2DmemReqQ103H  ), // output logic [31:0] DMemWrDataQ103H,     // To D_MEM
   .DMemRdRspQ105H      ( DMemRdRspQ105H     )  // input  logic [31:0] DMemRdRspQ105H       // From D_MEM
);


mem_ss mem_ss
(
 .Clock                 (Clock)  ,              
 .Rst                   (Rst)    ,              
//============================================
//      core interface
//============================================
// i_mem
 .ReadyQ101H            (ReadyQ101H),          // input :to imem
 .PcQ100H               (PcQ100H),             // input :current pc    ,
 .PreInstructionQ101H   (PreInstructionQ101H), // output from i_mem : instruction,
// d_mem_ss (cache, vga, csr)
 .Core2DmemReqQ103H     (Core2DmemReqQ103H),      
 .DMemRdRspQ105H        (DMemRdRspQ105H),      
 .DMemReady             (DMemReady),      
//=========================================
//     vga interface
//=========================================
 .inDisplayArea         (inDisplayArea),
 .vga_out               (vga_out)              
);



ps2_kbd_ctrl ps2_kbd_ctrl  
(
    .kbd_clk       (kbd_clk    ), //input  logic       kbd_clk,
    .data_in_kc    (data_in_kc ), //input  logic       data_in_kc,

    .core_clk      (Clock    ), //input  logic       core_clk,
    .core_rst      (Rst    ), //input  logic       core_rst, 
    // Pop when the kbd_pop signal is high -> automatically set when core reads the kbd cr data
    .core_read_en  (kbd_ctrl.kbd_pop     ), //input  logic       core_read_en,
    // the pop signals from the fifo:
    .data_out_cc   (kbd_data_rd.kbd_data ), //output logic [7:0] data_out_cc, 
    .data_ready    (kbd_data_rd.kbd_ready), //output logic       data_ready,
    .valid_cc      (                     ), //output logic       valid_cc, 
    .error         (                     ), //output logic       error,
    // disable keyboard inputs when scanf is disabled
    .scanf_en      (kbd_ctrl.kbd_scanf_en)  //input  logic       scanf_en   
);




endmodule