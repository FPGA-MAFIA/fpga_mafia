
`include "macros.vh"

module mini_core_accel_top
import mini_core_pkg::*;
import mini_core_accel_pkg::*;
#(parameter RF_NUM_MSB=15)  //default 15 for rv32e compatible (save space on FPGA
(
input  logic        Clock  ,
input  logic        Rst    ,
input  t_tile_id    local_tile_id,
//============================================
//      fabric interface
//============================================
input  logic            InFabricValidQ503H  ,
input  var t_tile_trans InFabricQ503H       ,
output logic            mini_core_ready     ,
//
output logic            OutFabricValidQ505H ,
output var t_tile_trans OutFabricQ505H      ,
input  var t_fab_ready  fab_ready 
);

logic [31:0] PcQ100H;             // To I_MEM
logic [31:0] PreInstructionQ101H; // From I_MEM
logic [31:0] DMemWrDataQ103H;     // To D_MEM
logic [31:0] DMemAddressQ103H;    // To D_MEM
logic [3:0]  DMemByteEnQ103H;     // To D_MEM
logic        DMemWrEnQ103H;       // To D_MEM
logic        DMemRdEnQ103H;       // To D_MEM
logic [31:0] DMemRdRspQ104H;      // From D_MEM

logic DMemReady;
logic ReadyQ101H;
t_core2mem_req Core2DmemReqQ103H;

mini_core 
#( .RF_NUM_MSB(RF_NUM_MSB) )    
mini_core (
   .Clock               ( Clock              ), // input  logic        Clock,
   .Rst                 ( Rst                ), // input  logic        Rst,
   // Instruction Memory
   .ReadyQ101H          ( ReadyQ101H    ), // output logic        ReadyQ101H,          // To I_MEM
   .PcQ100H             ( PcQ100H            ), // output logic [31:0] PcQ100H,             // To I_MEM
   .PreInstructionQ101H ( PreInstructionQ101H), // input  logic [31:0] PreInstructionQ101H, // From I_MEM
   // Data Memory
   .DMemReady           ( DMemReady     ), // input  logic        DMemReady  , // From D_MEM
   .Core2DmemReqQ103H   ( Core2DmemReqQ103H  ), // output logic [31:0] DMemWrDataQ103H,     // To D_MEM
   .DMemRdRspQ104H      ( DMemRdRspQ104H     )  // input  logic [31:0] DMemRdRspQ104H       // From D_MEM
);

assign DMemWrDataQ103H = Core2DmemReqQ103H.WrData;
assign DMemAddressQ103H = Core2DmemReqQ103H.Address;
assign DMemByteEnQ103H = Core2DmemReqQ103H.ByteEn;
assign DMemWrEnQ103H = Core2DmemReqQ103H.WrEn;
assign DMemRdEnQ103H = Core2DmemReqQ103H.RdEn;

t_accel_farm_input   accel_farm_input;
t_accel_farm_output  accel_farm_output; 
//---------------------------------------------------
mini_core_accel_mem_wrap mini_core_accel_mem_wrap(
 .Clock                 (Clock)  ,             
 .Rst                   (Rst)    ,             
 .local_tile_id         (local_tile_id)       , 
// //============================================
// //      core interface
// //============================================
// i_mem
 .ReadyQ101H            (ReadyQ101H), 
 .PcQ100H               (PcQ100H),             
 .PreInstructionQ101H   (PreInstructionQ101H),
// d_mem
 .DMemWrDataQ103H       (DMemWrDataQ103H),     
 .DMemAddressQ103H      (DMemAddressQ103H),    
 .DMemByteEnQ103H       (DMemByteEnQ103H),     
 .DMemWrEnQ103H         (DMemWrEnQ103H),      
 .DMemRdEnQ103H         (DMemRdEnQ103H),       
 .DMemRdRspQ104H        (DMemRdRspQ104H),      
 .DMemReady             (DMemReady),      
 //============================================
 //     cr_mem (accelerators)
//============================================
  .accel_farm_output    (accel_farm_output),
  .accel_farm_input     (accel_farm_input), 
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    (InFabricValidQ503H),  
 .InFabricQ503H         (InFabricQ503H),       
 .mini_core_ready       (mini_core_ready),      
 //
 .OutFabricQ505H        (OutFabricQ505H),       
 .OutFabricValidQ505H   (OutFabricValidQ505H),  
 .fab_ready             (fab_ready)            
);

mini_core_accel_farm 
#(.MUL_NUM(INT8_MULTIPLIER_NUM), .NEURON_MAC_NUM(NEURON_MAC_NUM))  
mini_core_accel_farm 
(
    .clock             (Clock),
    .rst               (Rst),
    .accel_farm_input  (accel_farm_input),
    .accel_farm_output (accel_farm_output)
);

endmodule
