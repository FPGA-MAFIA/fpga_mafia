//-----------------------------------------------------------------------------
// Title            : data memory - Behavioral
// Project          : gpc_4t
//-----------------------------------------------------------------------------
// File             : big_core_mem_wrap.sv
// Original Author  : Amichai Ben-David
// Created          : 1/2020
//-----------------------------------------------------------------------------
// Description :
// Behavioral duel read duel write memory
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

`include "macros.vh"

//---------------------------------------------------
module big_core_mem_wrap
import big_core_pkg::*;
(
                input  logic        Clock  ,
                input  logic        Rst    ,
                input  t_tile_id    local_tile_id,
                //============================================
                //      core interface
                //============================================
                //     i_mem
                //============================================
                input  logic        ReadyQ101H,
                input  logic [31:0] PcQ100H,             //cur_pc    ,
                output logic [31:0] PreInstructionQ101H, //instruction,
                //============================================
                //     d_mem
                //============================================
                input  logic [31:0] DMemWrDataQ103H , // To D_MEM
                input  logic [31:0] DMemAddressQ103H, // To D_MEM
                input  logic [3:0]  DMemByteEnQ103H , // To D_MEM
                input  logic        DMemWrEnQ103H   , // To D_MEM
                input  logic        DMemRdEnQ103H   , // To D_MEM
                output logic [31:0] DMemRdRspQ105H  , // From D_MEM
                output logic        DMemReady  , // From D_MEM
                //============================================
                //      fabric interface
                //============================================
                input  logic            InFabricValidQ503H  ,
                input  var t_tile_trans InFabricQ503H       ,
                output logic            big_core_ready     ,
                //
                output logic            OutFabricValidQ505H ,
                output var t_tile_trans OutFabricQ505H      ,
                input  var t_fab_ready  fab_ready,
                //============================================
                //      keyboard interface
                //============================================
                input  var t_kbd_data_rd kbd_data_rd,
                output t_kbd_ctrl    kbd_ctrl,
                //============================================
                //      vga interface
                //============================================
                output logic        inDisplayArea,
                output t_vga_out    vga_out,         // VGA_OUTPUT 
                //============================================
                //      fpga interface
                //============================================ 
                // FPGA interface inputs              
                input  var t_fpga_in   fpga_in,     
                output t_fpga_out  fpga_out         // CR_MEM output to FPGA
           
);

logic [9:0] VGA_CounterX;
logic [9:0] VGA_CounterY;
logic        F2C_IMemHitQ503H;
logic        F2C_IMemWrEnQ503H;
logic [31:0] F2C_IMemRspDataQ504H;

logic        F2C_DMemHitQ503H;
logic        F2C_DMemWrEnQ503H;
logic [31:0] F2C_DMemRspDataQ504H;

logic        F2C_CrMemHitQ503H;
logic        F2C_CrMemWrEnQ503H;
logic [31:0] F2C_CrMemRspDataQ504H;

logic   F2C_CrMemHitQ504H;
logic   F2C_IMemHitQ504H ;
logic   F2C_DMemHitQ504H ;

t_tile_trans  C2F_OutFabricQ104H;
t_tile_trans  C2F_ReqQ103H;
logic         C2F_ReqValidQ103H;
logic         C2F_OutFabricValidQ104H;
logic         C2F_ReqFull, C2F_ReqEmpty;
logic [1:0] winner_dec_id;
logic [1:0] valid_candidate;

t_tile_trans F2C_InFabricQ503H;

logic F2C_OutFabricValidQ505H;
t_tile_trans F2C_OutFabricQ505H;
//===========================================
//    set F2C request 503 ( D_MEM )
//===========================================
// Set the F2C IMEM hit indications
assign F2C_IMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] > I_MEM_REGION_FLOOR) && 
                           (InFabricQ503H.address[MSB_REGION:LSB_REGION] < I_MEM_REGION_ROOF) ;
assign F2C_IMemWrEnQ503H = F2C_IMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);
// Set the F2C DMEM hit indications
assign F2C_DMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] > D_MEM_REGION_FLOOR) && 
                           (InFabricQ503H.address[MSB_REGION:LSB_REGION] < D_MEM_REGION_ROOF) ;
assign F2C_DMemWrEnQ503H = F2C_DMemHitQ503H && InFabricValidQ503H && ((InFabricQ503H.opcode == WR));
// Set the F2C CrMEM hit indications
assign F2C_CrMemHitQ503H  = (InFabricQ503H.address[MSB_REGION:LSB_REGION] >= CR_MEM_REGION_FLOOR) && 
                            (InFabricQ503H.address[MSB_REGION:LSB_REGION] < CR_MEM_REGION_ROOF) ;
assign F2C_CrMemWrEnQ503H = F2C_CrMemHitQ503H && InFabricValidQ503H && (InFabricQ503H.opcode == WR);

logic [31:0] InstructionQ101H; //instruction,
//==================================
// Instruction Memory
//==================================
//This is the instruction memory
mem  #(
  .WORD_WIDTH(32),                //FIXME - Parametrize!!
  .ADRS_WIDTH(I_MEM_ADRS_MSB+1)   //FIXME - Parametrize!!
) i_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (PcQ100H[I_MEM_ADRS_MSB:2]),           //FIXME - Parametrize!!
    .data_a     ('0),
    .wren_a     (1'b0),
    .byteena_a  (4'b0),
    .q_a        (InstructionQ101H),
    //fabric interface
    .address_b  (InFabricQ503H.address[I_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_b     (InFabricQ503H.data),              
    .wren_b     (F2C_IMemWrEnQ503H),                
    .byteena_b  (4'b1111), // NOTE no need to support byte enable for instruction memory
    .q_b        (F2C_IMemRspDataQ504H)              
    );

logic [31:0] LastInstructionFetchQ101H;
logic        SampleReadyQ101H;
`MAFIA_DFF   (SampleReadyQ101H, ReadyQ101H      , Clock)
`MAFIA_EN_DFF(LastInstructionFetchQ101H, InstructionQ101H, Clock , SampleReadyQ101H)
assign PreInstructionQ101H = SampleReadyQ101H ? InstructionQ101H : LastInstructionFetchQ101H;
//assign PreInstructionQ101H = InstructionQ101H;

//==================================
// Memory regions
//==================================
logic        LocalDMemWrEnQ103H;
logic        NonLocalDMemReqQ103H;
logic        MatchVGAMemRegionQ103H, MatchVGAMemRegionQ104H;
logic        MatchCRMemRegionQ103H,  MatchCRMemRegionQ104H;
//The VGA Base address is 0x00FF0000, and the Size is 0x9600 (38400 bytes) FIXME
//assign VgaSpaceQ103H = (DMemAddressQ103H[31:16] == 16'h00FF) && (DMemAddressQ103H[15:0] < 16'h9600);
assign MatchVGAMemRegionQ103H = ((DMemAddressQ103H[VGA_MSB_REGION:LSB_REGION] >= VGA_MEM_REGION_FLOOR) && (DMemAddressQ103H[VGA_MSB_REGION:LSB_REGION] <= VGA_MEM_REGION_ROOF));
`MAFIA_EN_DFF(MatchVGAMemRegionQ104H , MatchVGAMemRegionQ103H  , Clock, DMemReady)

assign MatchCRMemRegionQ103H  = MatchVGAMemRegionQ103H ? 1'b0 : ((DMemAddressQ103H[MSB_REGION:LSB_REGION] >= CR_MEM_REGION_FLOOR) && (DMemAddressQ103H[MSB_REGION:LSB_REGION] <= CR_MEM_REGION_ROOF));
`MAFIA_EN_DFF(MatchCRMemRegionQ104H  , MatchCRMemRegionQ103H   , Clock, DMemReady)

// accessing the local tile or writing to other  local d_mem region
assign LocalDMemWrEnQ103H     = (DMemWrEnQ103H) && 
                                ((DMemAddressQ103H[31:24] == local_tile_id) || (DMemAddressQ103H[31:24] == 8'b0)) &&
                                (!MatchVGAMemRegionQ103H);//FIXME - the VGA Space needs to be with a unique Tile ID
// FIXME - need to "freeze" the core PC when reading a non local address
// accessing DMem not from local_tile but other one
assign NonLocalDMemReqQ103H = (DMemWrEnQ103H || DMemRdEnQ103H) &&
                              (DMemAddressQ103H[31:24] != local_tile_id) && (DMemAddressQ103H[31:24] != 8'b0);
logic OutstandingReadReq;
logic SetOutstandingReadReqQ103H;
logic RstOutstandingReadReqQ503H;
// Set the OutstandingReadReq indication when there is a non local read request (MSB is not the local tile id or 0)
assign SetOutstandingReadReqQ103H = (DMemRdEnQ103H) &&
                                    (DMemAddressQ103H[31:24] != local_tile_id) && (DMemAddressQ103H[31:24] != 8'b0);


logic FabricDataRspValidQ503H;
assign FabricDataRspValidQ503H = (OutstandingReadReq) &&  (InFabricQ503H.opcode == RD_RSP) && InFabricValidQ503H ;
assign RstOutstandingReadReqQ503H = FabricDataRspValidQ503H || Rst;
`MAFIA_EN_RST_DFF(OutstandingReadReq, 1'b1 ,Clock, SetOutstandingReadReqQ103H, RstOutstandingReadReqQ503H) 

logic [31:0] FabricDataRspQ504H;
logic        FabricDataRspValidQ504H;
`MAFIA_DFF(FabricDataRspQ504H      , InFabricQ503H.data      , Clock)
`MAFIA_DFF(FabricDataRspValidQ504H , FabricDataRspValidQ503H , Clock)
// There are multiple reasons to unset the DMemReady - back pressure the core from accessing the memory
// 1) A outstanding read request was set and the read response was not received yet
// 2) The c2f_req_fifo is full
assign DMemReady  =!(OutstandingReadReq) &&  !C2F_ReqFull;

//==================================
// This logic is a special case for the WhoAmI request
// We are using a memory address of 0x00FFFFFF to detect the WhoAmI request and respond with the local tile id
//==================================
logic WhoAmIReqQ103H;
logic WhoAmIReqQ104H;
assign WhoAmIReqQ103H = (DMemAddressQ103H[31:24] == 8'b0) && (DMemAddressQ103H[23:0] == 24'hFFFFFF) && DMemRdEnQ103H;
`MAFIA_DFF(WhoAmIReqQ104H , WhoAmIReqQ103H , Clock)
// Support the byte enable for the data memory by shifting the data to the correct position
// Half & Byte Write
logic [31:0] ShiftDMemWrDataQ103H;
logic [3:0]  ShiftDMemByteEnQ103H;
logic [31:0] PreShiftRdDataQ104H;
logic [1:0]  DMemAddressQ104H;
logic [31:0] PreCRMemRdDataQ104H;

always_comb begin
ShiftDMemWrDataQ103H = (DMemAddressQ103H[1:0] == 2'b01 ) ? { DMemWrDataQ103H[23:0],8'b0  } :
                       (DMemAddressQ103H[1:0] == 2'b10 ) ? { DMemWrDataQ103H[15:0],16'b0 } :
                       (DMemAddressQ103H[1:0] == 2'b11 ) ? { DMemWrDataQ103H[7:0] ,24'b0 } :
                                                             DMemWrDataQ103H;
ShiftDMemByteEnQ103H = (DMemAddressQ103H[1:0] == 2'b01 ) ? { DMemByteEnQ103H[2:0],1'b0 } :
                       (DMemAddressQ103H[1:0] == 2'b10 ) ? { DMemByteEnQ103H[1:0],2'b0 } :
                       (DMemAddressQ103H[1:0] == 2'b11 ) ? { DMemByteEnQ103H[0]  ,3'b0 } :
                                                             DMemByteEnQ103H;
end               


`MAFIA_DFF(DMemAddressQ104H[1:0] , DMemAddressQ103H[1:0] , Clock)

// Half & Byte READ
logic [31:0] DMemRdRspQ104H;
logic [31:0] PreShiftDMemRdDataQ104H;
logic [31:0] ReIssuedPreShiftDMemRdDataQ104H;
logic [31:0] ReIssuedPreCrMemRdDataQ104H;
logic [31:0] ReIssuePreShiftVGAMemRdDataQ104H;
logic [31:0] PreShiftVGAMemRdDataQ104H;
logic [31:0] PreShiftCRMemRdDataQ104H;
assign PreShiftRdDataQ104H = MatchVGAMemRegionQ104H ? ReIssuePreShiftVGAMemRdDataQ104H : ReIssuedPreShiftDMemRdDataQ104H; 
assign DMemRdRspQ104H =  FabricDataRspValidQ504H         ? FabricDataRspQ504H                 ://Fabric response to an older core request
                        (WhoAmIReqQ104H)                 ? {24'b0,local_tile_id}              ://Special case - WhoAmI respond the "hard coded" local tile id
                         MatchCRMemRegionQ104H           ? ReIssuedPreCrMemRdDataQ104H        :
                        (DMemAddressQ104H[1:0] == 2'b01) ? { 8'b0,PreShiftRdDataQ104H[31:8] } : 
                        (DMemAddressQ104H[1:0] == 2'b10) ? {16'b0,PreShiftRdDataQ104H[31:16]} : 
                        (DMemAddressQ104H[1:0] == 2'b11) ? {24'b0,PreShiftRdDataQ104H[31:24]} : 
                                                                  PreShiftRdDataQ104H         ; 

 // increase read latency from 1 to 2 cycle latency 
`MAFIA_EN_DFF(DMemRdRspQ105H ,DMemRdRspQ104H, Clock, DMemReady)

mem   
#(.WORD_WIDTH(32),//FIXME - Parametrize!!
  .ADRS_WIDTH(D_MEM_ADRS_MSB+1) //FIXME - Parametrize!!
) d_mem  (
    .clock    (Clock),
    //Core interface (instruction fitch)
    .address_a  (DMemAddressQ103H[D_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_a     (ShiftDMemWrDataQ103H),
    .wren_a     (LocalDMemWrEnQ103H),
    .byteena_a  (ShiftDMemByteEnQ103H),
    .q_a        (PreShiftDMemRdDataQ104H),
    //fabric interface
    .address_b  (InFabricQ503H.address[D_MEM_ADRS_MSB:2]),//FIXME - Parametrize!!
    .data_b     (InFabricQ503H.data),              
    .wren_b     (F2C_DMemWrEnQ503H),                
    .byteena_b  (4'b1111),//FIXME - should accept the byte enable from the fabric
    .q_b        (F2C_DMemRspDataQ504H)              
    );


// re-issue mechanism of d_mem region
// When DmemReady = 1'b0. We have to pass the last data from Dmem untill back pressure is deactivated  
logic [31:0] LastDataFromDmemQ104H;
logic        SampleDmemReadyQ104H;
`MAFIA_DFF   (SampleDmemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromDmemQ104H, PreShiftDMemRdDataQ104H, Clock , SampleDmemReadyQ104H)
assign ReIssuedPreShiftDMemRdDataQ104H = SampleDmemReadyQ104H ? PreShiftDMemRdDataQ104H : LastDataFromDmemQ104H;
 
 //==================================
 // CR mem instantiation
 //==================================
 big_core_cr_mem big_core_cr_mem (
    .Clk              (Clock),
    .Rst              (Rst),
    .data             (DMemWrDataQ103H),
    .address          (DMemAddressQ103H),
    .wren             (DMemWrEnQ103H && MatchCRMemRegionQ103H),
    .rden             (DMemRdEnQ103H && MatchCRMemRegionQ103H),
    .q                (PreCRMemRdDataQ104H),
    //Fabric access interface
    .data_b           (InFabricQ503H.data),
    .address_b        (InFabricQ503H.address),
    .wren_b           (F2C_CrMemWrEnQ503H),
    .q_b              (F2C_CrMemRspDataQ504H),
    // VGA info
    .VGA_CounterX     (VGA_CounterX), //input  logic [9:0] VGA_CounterX,
    .VGA_CounterY     (VGA_CounterY), //input  logic [9:0] VGA_CounterY,
    // Keyboard interface
    .kbd_data_rd      (kbd_data_rd), //input  t_kbd_data_rd kbd_data_rd,
    .kbd_ctrl         (kbd_ctrl   ), //output t_kbd_ctrl    kbd_ctrl,
    // FPGA interface
    .fpga_in          (fpga_in),  
    .fpga_out         (fpga_out)
);
 
// re-issue mechanism of cr region
// When DmemReady = 1'b0. We have to pass the last data from CR untill back pressure is deactivated  
logic [31:0] LastDataFromCRmemQ104H;
logic        SampleCrmemReadyQ104H;
`MAFIA_DFF   (SampleCrmemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromCRmemQ104H, PreCRMemRdDataQ104H, Clock , SampleCrmemReadyQ104H)
assign ReIssuedPreCrMemRdDataQ104H = SampleCrmemReadyQ104H ? PreCRMemRdDataQ104H : LastDataFromCRmemQ104H;

 //==================================
 // VGA cntroller instantiation
 //==================================
logic [31:0] VgaAddressWithOffsetQ103H;
assign VgaAddressWithOffsetQ103H = DMemAddressQ103H - VGA_MEM_REGION_FLOOR;

logic [31:0]  VgaWrData;
logic [31:0]  VgaAdrsReq;
logic [3:0]   VgaWrByteEn;
logic         VgaWrEn;
assign VgaWrData    = ShiftDMemWrDataQ103H;
assign VgaAdrsReq   = VgaAddressWithOffsetQ103H;
assign VgaWrByteEn  = ShiftDMemByteEnQ103H;
assign VgaWrEn      = DMemWrEnQ103H && MatchVGAMemRegionQ103H;

big_core_vga_ctrl big_core_vga_ctrl (
   .Clk_50            (Clock),
   .Reset             (Rst),
   // Core interface
   // write
   .ReqDataQ503H       (VgaWrData),
   .ReqAddressQ503H    (VgaAdrsReq),
   .CtrlVGAMemByteEn   (VgaWrByteEn),
   .CtrlVgaMemWrEnQ503 (VgaWrEn),
   // read
   .CtrlVgaMemRdEnQ503 (VgaWrEn),
   .VgaRspDataQ504H    (PreShiftVGAMemRdDataQ104H),
   // VGA output
   .VGA_CounterX      (VGA_CounterX)  , // output  logic [9:0] VGA_CounterX,
   .VGA_CounterY      (VGA_CounterY)  , // output  logic [9:0] VGA_CounterY,
   .inDisplayArea     (inDisplayArea) ,
   .RED               (vga_out.VGA_R) ,
   .GREEN             (vga_out.VGA_G) ,
   .BLUE              (vga_out.VGA_B) ,
   .h_sync            (vga_out.VGA_HS),
   .v_sync            (vga_out.VGA_VS)
);

// re-issue mechanism of vga region
// When DmemReady = 1'b0. We have to pass the last data from VGA untill back pressure is deactivated  
logic [31:0] LastDataFromVgamemQ104H;
logic        SampleVgamemReadyQ104H;
`MAFIA_DFF   (SampleVgamemReadyQ104H, DMemReady      , Clock)
`MAFIA_EN_DFF(LastDataFromVgamemQ104H, PreShiftVGAMemRdDataQ104H, Clock , SampleVgamemReadyQ104H)
assign ReIssuePreShiftVGAMemRdDataQ104H = SampleVgamemReadyQ104H ? PreShiftVGAMemRdDataQ104H : LastDataFromVgamemQ104H;
//==================================
// F2C response 504 ( D_MEM/I_MEM )
//==================================
logic [31:0] F2C_RspDataQ504H;
`MAFIA_DFF(F2C_IMemHitQ504H , F2C_IMemHitQ503H , Clock)
`MAFIA_DFF(F2C_DMemHitQ504H , F2C_DMemHitQ503H , Clock)
`MAFIA_DFF(F2C_CrMemHitQ504H, F2C_CrMemHitQ503H, Clock)

assign F2C_RspDataQ504H   = F2C_CrMemHitQ504H ? F2C_CrMemRspDataQ504H : //CR hit is the highest priority
                            F2C_IMemHitQ504H  ? F2C_IMemRspDataQ504H  :
                            F2C_DMemHitQ504H  ? F2C_DMemRspDataQ504H  :
                                               '0                     ;

logic F2C_OutFabricValidQ503H, F2C_OutFabricValidQ504H;
t_tile_trans F2C_OutFabricQ504H;
logic [31:0] F2C_RdRspAddressQ503H;
assign F2C_OutFabricValidQ503H =  (InFabricValidQ503H && (InFabricQ503H.opcode == RD));
assign F2C_InFabricQ503H       = F2C_OutFabricValidQ503H   ?  InFabricQ503H  :  '0;
// Set the target address to the requestor id (This is the Read response address)
assign F2C_RdRspAddressQ503H = {F2C_InFabricQ503H.requestor_id[7:0],F2C_InFabricQ503H.address[23:0]};
`MAFIA_DFF(F2C_OutFabricValidQ504H                 , F2C_OutFabricValidQ503H , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.address              , F2C_RdRspAddressQ503H   , Clock) 
`MAFIA_DFF(F2C_OutFabricQ504H.opcode               , RD_RSP                  , Clock)
`MAFIA_DFF(F2C_OutFabricQ504H.requestor_id         , local_tile_id           , Clock) // The requestor id is the local tile id
`MAFIA_DFF(F2C_OutFabricQ504H.next_tile_fifo_arb_id, NULL_CARDINAL           , Clock) //will be overwritten in the tile
assign F2C_OutFabricQ504H.data =  F2C_RspDataQ504H;


//==================================
// Mux out Fabric Access Response/Request
//==================================
// We may have multiple transaction trying to access the fabric
// 1. A read response to fabric 
// 2. read/write request from the core the needs to access the fabric (a non local read/write)
// we solve this by using a fifo to accumulate the different transactions and use an arbiter to choose between them.
// and we can start back pressure the core/fabric if the corresponding fifo is full.
//==================================
// F2C FIFO - accumulate read responses to the fabric (A response to a Fabric 2 Core read request)
//==================================
// a FIFO to accumulate the read responses to the fabric
logic F2C_RspFull, F2C_RspEmpty;
logic F2C_AlmostFull;
fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(2))
f2c_rsp_fifo  (.clk       (Clock),
               .rst       (Rst),
               .push      (F2C_OutFabricValidQ504H),  // input
               .push_data (F2C_OutFabricQ504H),       // input
               .pop       (F2C_OutFabricValidQ505H),  // input
               .pop_data  (F2C_OutFabricQ505H),       // output
               .full      (F2C_RspFull),              // output
               .almost_full(F2C_AlmostFull),          // output
               .empty     (F2C_RspEmpty)              // output
               );// indication to arbiter that the fifo is empty

// this is to solve the issue that  there is a 1 cycle latency on the memory ready from F2C
// Need to make sure we have a 1 entry margin in the fifo when we declare not ready 
//==================================
// C2F FIFO - accumulate core 2 Fabric requests
//==================================
// a FIFO to accumulate the requests from the core to the fabric
assign C2F_ReqQ103H.address      = DMemAddressQ103H;
assign C2F_ReqQ103H.data         = DMemWrDataQ103H;
assign C2F_ReqQ103H.opcode       = DMemWrEnQ103H ? WR : RD;
assign C2F_ReqQ103H.requestor_id = local_tile_id;
assign C2F_ReqQ103H.next_tile_fifo_arb_id = NULL_CARDINAL;
assign C2F_ReqValidQ103H         = NonLocalDMemReqQ103H && (!OutstandingReadReq);

fifo #(.DATA_WIDTH($bits(t_tile_trans)),.FIFO_DEPTH(2))
c2f_req_fifo  (.clk       (Clock),
               .rst       (Rst),
               .push      (C2F_ReqValidQ103H),      //valid_alloc_req#
               .push_data (C2F_ReqQ103H),           //alloc_req#
               .pop       (C2F_OutFabricValidQ104H),//arbiter chose this fifo to pop.
               .pop_data  (C2F_OutFabricQ104H),     //arbiter input
               .full      (C2F_ReqFull),            //out_ready_fifo#
               .almost_full (),
               .empty     (C2F_ReqEmpty)
               );// indication to arbiter that the fifo is empty

//==================================
// Arbiter - choose between the different transactions trying to access the fabric
//==================================
// The arbiter is a Round Robin arbiter 
// FIXME currently this is a naive implementation - not checking the target fifo_arb - waiting until all fifo_arb are ready
assign valid_candidate[0] = !F2C_RspEmpty && (&fab_ready);  // add back pressure from the fabric
assign valid_candidate[1] = !C2F_ReqEmpty && (&fab_ready);  // add back pressure from the fabric
arbiter #(
    .NUM_CLIENTS        (2)
) u_arbiter (
    .clk                (Clock),
    .rst                (Rst),
    // ctrl path
    .valid_candidate    (valid_candidate),
    .winner_dec_id      (winner_dec_id)
);
assign F2C_OutFabricValidQ505H = winner_dec_id[0];
assign C2F_OutFabricValidQ104H = winner_dec_id[1];

assign OutFabricValidQ505H =  F2C_OutFabricValidQ505H | C2F_OutFabricValidQ104H;
assign OutFabricQ505H      =  F2C_OutFabricValidQ505H ? F2C_OutFabricQ505H :
                              C2F_OutFabricValidQ104H ? C2F_OutFabricQ104H :
                                                        '0;                 
                                                        
assign big_core_ready = (!F2C_AlmostFull); // add back pressure to the fabric


//================================
// Memorry access assertion
//===============================
`ifdef SIM_ONLY
logic  AddrRangeMiss;
logic  FabricAccessQ103H;
logic  clk;        // FIXME - in MAFIA_ASSERT macro we use 'clk' instead of 'Clk'
assign clk               = Clock; 
assign FabricAccessQ103H = (DMemAddressQ103H[31:24] != 8'h0) || WhoAmIReqQ103H; // FIXME - possibly need to be refactored. The address is bigger than VGA_MEM_REGION_ROOF when acces tiles
assign AddrRangeMiss     = (DMemAddressQ103H > VGA_MEM_REGION_ROOF || DMemAddressQ103H < D_MEM_REGION_FLOOR) & !FabricAccessQ103H;

`MAFIA_ASSERT($sformatf("access adder %h is out of range",DMemAddressQ103H), AddrRangeMiss, DMemWrEnQ103H, "write")
`MAFIA_ASSERT($sformatf("access adder %h is out of range",DMemAddressQ103H), AddrRangeMiss, DMemRdEnQ103H, "read")
`endif

endmodule
