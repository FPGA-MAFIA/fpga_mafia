
`include "macros.sv"

module mini_top
import mini_core_pkg::*;
import router_pkg::*;
(
input  logic        Clock  ,
input  logic        Rst    ,
input  t_tile_id    local_tile_id,
//============================================
//      fabric interface
//============================================
input  logic            InFabricValidQ503H  ,
input  var t_tile_trans InFabricQ503H       ,
output logic            OutFabricValidQ505H ,
output var t_tile_trans OutFabricQ505H 
);

logic [31:0] PcQ100H;             // To I_MEM
logic [31:0] PreInstructionQ101H; // From I_MEM
logic [31:0] DMemWrDataQ103H;     // To D_MEM
logic [31:0] DMemAddressQ103H;    // To D_MEM
logic [3:0]  DMemByteEnQ103H;     // To D_MEM
logic        DMemWrEnQ103H;       // To D_MEM
logic        DMemRdEnQ103H;       // To D_MEM
logic [31:0] DMemRdRspQ104H;      // From D_MEM


mini_core mini_core (
   .Clock               ( Clock              ), // input  logic        Clock,
   .Rst                 ( Rst                ), // input  logic        Rst,
   // Instruction Memory
   .PcQ100H             ( PcQ100H            ), // output logic [31:0] PcQ100H,             // To I_MEM
   .PreInstructionQ101H ( PreInstructionQ101H), // input  logic [31:0] PreInstructionQ101H, // From I_MEM
   // Data Memory
   .DMemWrDataQ103H     ( DMemWrDataQ103H    ), // output logic [31:0] DMemWrDataQ103H,     // To D_MEM
   .DMemAddressQ103H    ( DMemAddressQ103H   ), // output logic [31:0] DMemAddressQ103H,    // To D_MEM
   .DMemByteEnQ103H     ( DMemByteEnQ103H    ), // output logic [3:0]  DMemByteEnQ103H,     // To D_MEM
   .DMemWrEnQ103H       ( DMemWrEnQ103H      ), // output logic        DMemWrEnQ103H,       // To D_MEM
   .DMemRdEnQ103H       ( DMemRdEnQ103H      ), // output logic        DMemRdEnQ103H,       // To D_MEM
   .DMemRdRspQ104H      ( DMemRdRspQ104H     )  // input  logic [31:0] DMemRdRspQ104H       // From D_MEM
);

//---------------------------------------------------
mini_mem_wrap mini_mem_wrap(
 .Clock                 (Clock)  ,              // input  logic        Clock  ,
 .Rst                   (Rst)    ,              // input  logic        Rst    ,
 .local_tile_id         (local_tile_id)       , //input  t_tile_id    local_tile_id,
// //============================================
// //      core interface
// //============================================
// i_mem
 .PcQ100H               (PcQ100H),             //input  logic [31:0] PcQ100H,        //curr_pc    ,
 .PreInstructionQ101H   (PreInstructionQ101H), //output logic [31:0] PreInstructionQ101H, //instruction,
// d_mem
 .DMemWrDataQ103H       (DMemWrDataQ103H),     // input  logic [31:0] DMemWrDataQ103H,     // To D_MEM
 .DMemAddressQ103H      (DMemAddressQ103H),    // input  logic [31:0] DMemAddressQ103H,    // To D_MEM
 .DMemByteEnQ103H       (DMemByteEnQ103H),     // input  logic [3:0]  DMemByteEnQ103H,     // To D_MEM
 .DMemWrEnQ103H         (DMemWrEnQ103H),       // input  logic        DMemWrEnQ103H,       // To D_MEM
 .DMemRdEnQ103H         (DMemRdEnQ103H),       // input  logic        DMemRdEnQ103H,       // To D_MEM
 .DMemRdRspQ104H        (DMemRdRspQ104H),      // output logic [31:0] DMemRdRspQ104H       // From D_MEM
//============================================
//      fabric interface
//============================================
 .InFabricValidQ503H    (InFabricValidQ503H),   // input  logic        F2C_ReqValidQ503H     ,
 .InFabricQ503H         (InFabricQ503H),        // input  t_opcode     F2C_ReqOpcodeQ503H    ,
 .OutFabricQ505H        (OutFabricQ505H),       // output t_rdata      F2C_RspDataQ504H      ,
 .OutFabricValidQ505H   (OutFabricValidQ505H)   // output logic        F2C_RspValidQ504H
);


endmodule