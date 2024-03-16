
`include "macros.vh"

module mini_core_top
import mini_core_pkg::*;
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

//---------------------------------------------------
mini_mem_wrap mini_mem_wrap(
 .Clock                 (Clock)  ,              // input  logic        Clock  ,
 .Rst                   (Rst)    ,              // input  logic        Rst    ,
 .local_tile_id         (local_tile_id)       , //input  t_tile_id    local_tile_id,
// //============================================
// //      core interface
// //============================================
// i_mem
 .ReadyQ101H            (ReadyQ101H), // input logic        ReadyQ101H,          // To I_MEM
 .PcQ100H               (PcQ100H),             //input  logic [31:0] PcQ100H,        //curr_pc    ,
 .PreInstructionQ101H   (PreInstructionQ101H), //output logic [31:0] PreInstructionQ101H, //instruction,
// d_mem
 .DMemWrDataQ103H       (DMemWrDataQ103H),     // input  logic [31:0] DMemWrDataQ103H,     // To D_MEM
 .DMemAddressQ103H      (DMemAddressQ103H),    // input  logic [31:0] DMemAddressQ103H,    // To D_MEM
 .DMemByteEnQ103H       (DMemByteEnQ103H),     // input  logic [3:0]  DMemByteEnQ103H,     // To D_MEM
 .DMemWrEnQ103H         (DMemWrEnQ103H),       // input  logic        DMemWrEnQ103H,       // To D_MEM
 .DMemRdEnQ103H         (DMemRdEnQ103H),       // input  logic        DMemRdEnQ103H,       // To D_MEM
 .DMemRdRspQ104H        (DMemRdRspQ104H),      // output logic [31:0] DMemRdRspQ104H       // From D_MEM
 .DMemReady        (DMemReady),      // output logic        DMemReady  , // From D_MEM
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    (InFabricValidQ503H),   // input  logic        F2C_ReqValidQ503H     ,
 .InFabricQ503H         (InFabricQ503H),        // input  t_opcode     F2C_ReqOpcodeQ503H    ,
 .mini_core_ready       (mini_core_ready),      // output logic ready for arbiter
 //
 .OutFabricQ505H        (OutFabricQ505H),       // output t_rdata      F2C_RspDataQ504H      ,
 .OutFabricValidQ505H   (OutFabricValidQ505H),  // output logic        F2C_RspValidQ504H
 .fab_ready             (fab_ready)             // input
);


endmodule