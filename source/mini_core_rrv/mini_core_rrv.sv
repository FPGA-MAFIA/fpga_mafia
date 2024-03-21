`include "macros.vh"

module mini_core_rrv 
import mini_core_rrv_pkg::*;
(
    input Clock,
    input Rst,
    // I_MEM interface
    input logic [31:0] PreInstructionQ101H, // from I_MEM
    output logic [31:0] PcQ100H,
    // D_mem interface
    output var t_core2mem_req Core2DmemReqQ101H,
    input logic [31:0] DMemRdRspQ102H  
);

    var t_ctrl_if   CtrlIf;
    var t_ctrl_rf   CtrlRf;
    var t_ctrl_alu  CtrlAlu;
    var t_ctrl_mem  CtrlDmem;
    var t_ctrl_wb   CtrlWb;
    logic           BranchCondMetQ101H;
    logic [31:0]    AluOutQ101H, AluOutQ102H; 
    logic [31:0]    PcQ101H, PcQ102H; 
    logic [31:0]    RegWrDataQ102H;
    logic [31:0]    RegRdData1Q101H, RegRdData2Q101H;
    logic [31:0]    ImmediateQ101H;
    logic [31:0]    DMemWrDataQ101H;
    
    //================================
    //    Stage Q100H
    //================================


    mini_core_if  mini_core_if
    (
    .Clock(Clock),
    .Rst(Rst),
    .Ctrl(CtrlIf),
    .AluOutQ101H(AluOutQ101H),
    .PcQ100H(PcQ100H),     // to I_MEM
    .PcQ101H(PcQ101H)     // to Q101H stage
    );

    //================================
    //    Stage Q101H
    //================================
    
    // controller
    mini_core_rrv_ctrl mini_core_rrv_ctrl 
    (
    .Clock(Clock),
    .Rst(Rst), 
    .PreInstructionQ101H(PreInstructionQ101H),
    .BranchCondMetQ101H(BranchCondMetQ101H),
    .CtrlIf(CtrlIf),
    .CtrlRf(CtrlRf),
    .CtrlAlu(CtrlAlu),
    .CtrlDmem(CtrlDmem),
    .CtrlWb(CtrlWb),
    .ImmediateQ101H(ImmediateQ101H)
    );


    // register file
    mini_core_rrv_rf #(.RF_NUM_MSB(RF_NUM_MSB))
    mini_core_rf
    (
    .Clock(Clock),
    .Rst(Rst),
    .Ctrl(CtrlRf),
    .PcQ101H(PcQ101H),
    .RegWrDataQ102H(RegWrDataQ102H),
    .RegRdData1Q101H(RegRdData1Q101H),  // signal from rf
    .RegRdData2Q101H(RegRdData2Q101H)   // signal from rf
    );

    // alu
    mini_core_rrv_alu mini_core_rrv_alu
    ( .Clock(Clock),
      .Rst(Rst),
      .PcQ101H(PcQ101H),
      .Ctrl(CtrlAlu),
      .PreRegRdData1Q101H(RegRdData1Q101H),
      .PreRegRdData2Q101H(RegRdData2Q101H),
      .ImmediateQ101H(ImmediateQ101H),
      .AluOutQ101H(AluOutQ101H),
      .AluOutQ102H(AluOutQ102H),
      .DMemWrDataQ101H(DMemWrDataQ101H),
      .BranchCondMetQ101H(BranchCondMetQ101H),
      .PcQ102H(PcQ102H)      
    );
    
    // Date memory
    mini_core_rrv_mem_acs mini_core_rrv_mem_acs
   (
    .Clock(Clock),
    .Rst(Rst),
    .Ctrl(CtrlDmem),
    .AluOutQ101H(AluOutQ101H), // address
    .DMemWrDataQ101H(DMemWrDataQ101H),
    .Core2DmemReqQ101H(Core2DmemReqQ101H)
   );

    //================================
    //    Stage Q102H
    //================================

    mini_core_rrv_wb mini_core_rrv_wb
    (
    .Clock(Clock),
    .Rst(Rst),
    .AluOutQ102H(AluOutQ102H),
    .PcQ102H(PcQ102H), 
    .Ctrl(CtrlWb),
    .RegWrDataQ102H(RegWrDataQ102H),
    .DMemRdRspQ102H(DMemRdRspQ102H)
    );

endmodule










