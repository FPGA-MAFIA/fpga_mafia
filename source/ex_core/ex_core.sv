


module ex_core (
    input   logic           Clk,
    input   logic           Rst
);

logic [31:0] RegRdData1, RegRdData2, RegWrData, AluOut;



//==============================================================================
// Cycle 100 -> the instruction fetch
//==============================================================================
// Fetch: Set PC & read instruction from memory
//==============================================================================

assign NextPcQ100H = (Ctrl.sel_pc == JMP_OR_BRNCH)  ? alu_outQ101H : PcQ101H + 32'd4;

`MAFIA_RST_DFF(PcQ100H, NextPcQ101H, Clk, Rst)
// instance the i_mem module
ex_core_i_mem i_mem (
    .clk     (Clk),
    .address (PcQ100H),          //input
    .rd_data (instructionQ101H)  //output
)

//==============================================================================
// Cycle 101 -> the instruction decode + read RegFile + Execute
//==============================================================================
// Decode: instruction + read RegFile
// Execute: perform ALU operation
// Send MEM read/write signals
//==============================================================================
ex_core_decoder decoder (

);

ex_core_rf rf (
    .clk        (clk        ) ,// input  logic         clk,          // Clock signal
    .Ctrl       (CtrlRf     ) ,// input  var t_ctrl_rf Ctrl,         // Corrected type name here
    .RegWrData  (RegWrData  ) ,// input  logic [31:0]  RegWrData,    // Data to write to the register
    .RegRdData1 (RegRdData1 ) ,// output logic [31:0]  RegRdData1,   // Data from the first read register
    .RegRdData2 (RegRdData2 ) ,// output logic [31:0]  RegRdData2    // Data from the second read register
);


ex_core_alu alu(
   .operand1  (RegRdData1 ) , //input logic [31:0]      operand1,
   .operand2  (RegRdData2 ) , //input logic [31:0]      operand2,
   .Ctrl      (CtrlALU  ) , //input var t_ctrl_alu    Ctrl,
   .result    (AluOut   ) , //output logic [31:0]     result,
   .zero      (zero     ) , //output logic            zero
);



ex_core_i_mem i_mem (
    .clk    (Clk),
    .address(PcQ100H),          //input
    .data   (instructionQ101H)  //output
)
//==============================================================================
// Cycle 102 -> the 
//==============================================================================
//  WRITE BACK: Mux the result of the ALU operation with the data read from memory + write to RegFile
//==============================================================================




endmodule
