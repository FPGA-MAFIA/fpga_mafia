`include "macros.sv"
module core_rrv_csr
import core_rrv_pkg::*;
(
    input logic                       Clk,
    input logic                       Rst,
    input logic [31:0]                PcQ102H,
    // Inputs from the core
    input var t_csr_inst_rrv          CsrInstQ102H,
    input logic [31:0]                CsrWriteDataQ102H,
    input var t_csr_interrupt_update  CsrInterruptUpdateQ102H, // 32-bit data to be written into the CSR
    input     ValidInstQ105H,
    // Outputs to the core
    output var t_csr_pc_update        CsrPcUpdateQ102H,
    output logic                      TimerInterruptEnable,
    output logic [31:0]               CsrReadDataQ102H // 32-bit data read from the CSR
);

    // Define the CSR registers
    t_csr csr; 
    t_csr next_csr;
//==============================
// CSR Access
//------------------------------
logic        csr_wren;
logic        csr_rden;
logic [1:0]  csr_op;
logic [11:0] csr_addr;
logic [31:0] csr_data_imm;
logic        csr_imm_bit;
assign csr_wren     = CsrInstQ102H.csr_wren;
assign csr_rden     = CsrInstQ102H.csr_rden;
assign csr_addr     = CsrInstQ102H.csr_addr;
assign csr_data_imm = CsrInstQ102H.csr_data_imm;
assign csr_op       = CsrInstQ102H.csr_op;
assign csr_imm_bit  = CsrInstQ102H.csr_imm_bit; 

logic [31:0] csr_data;
assign csr_data = (csr_imm_bit) ? csr_data_imm : CsrWriteDataQ102H;
logic csr_mcycle_overflow;
logic csr_minstret_overflow;
logic [63:0] csr_minstret_high_low;
logic [63:0] csr_mcycle_high_low;
logic CsrMstatusMieBit, CsrMieMieBit;
logic left_lfsr_bit;

//==========================================================================
// RO/V - read only from SW  , and may be updated from HW. Example: csr_cycle (HW updates it, SW can read it - NOTE: the mcycle is RW/V)
// RW/V - read/write from SW , and may be updated from HW. Example: csr_mcause (HW updates when exception occurs, then SW can read it and clear it)
// RO   - read only from SW/HW , there is no write access. Example: csr_mvendorid
// RW   - read/write from SW. Example: csr_scratch
always_comb begin
    //==========================================================================
    // default values - no change
    //==========================================================================
    next_csr             = csr;
    CsrMstatusMieBit     = 0; 
    CsrMieMieBit         = 0;
    TimerInterruptEnable = 0;
    //==========================================================================
    // RW/V -> HW updates (may be overwritten by SW writes)
    //==========================================================================
    {csr_mcycle_overflow , next_csr.csr_mcycle}  = csr.csr_mcycle  + 1'b1;
    next_csr.csr_mcycleh  = csr.csr_mcycleh + csr_mcycle_overflow;
    csr_mcycle_high_low   = {csr.csr_mcycleh, csr.csr_mcycle}; //TODO - csr_mcycle_high_low is not part of the spec
    if(ValidInstQ105H) begin
        {csr_minstret_overflow , next_csr.csr_minstret}  = csr.csr_minstret + 1'b1;
        next_csr.csr_minstreth = csr.csr_minstreth + csr_minstret_overflow;
        csr_minstret_high_low  = {csr.csr_minstreth, csr.csr_minstret}; //TODO - csr_minstret_high_low is not part of the spec
    end
    if((csr.csr_custom_mtime >= csr.csr_custom_mtimecmp) && (csr.csr_custom_mtime!=0 && csr.csr_custom_mtimecmp!=0)) begin
        next_csr.csr_mip     = 32'h80;
        CsrMstatusMieBit     = csr.csr_mstatus[3]; 
        CsrMieMieBit         = csr.csr_mie[7];
        TimerInterruptEnable = CsrMstatusMieBit & CsrMieMieBit;
    end
    
    //==========================================================================   
    if(CsrInterruptUpdateQ102H.timer_interrupt_taken) begin
        TimerInterruptEnable  = 0;
        next_csr.csr_mcause   = 32'h80000007;
        next_csr.csr_mepc     = CsrInterruptUpdateQ102H.Pc;
        next_csr.csr_mie      = 32'h00000808;  // disable mie 
        next_csr.csr_mstatus  = 32'h00000080;  // mstatus[7] will be equall to mstatus[3]. If interrupt taken than mstatus[3] = 1
    end
    if(CsrInterruptUpdateQ102H.illegal_instruction) begin
        next_csr.csr_mcause = 32'h00000002;
        next_csr.csr_mepc   = CsrInterruptUpdateQ102H.Pc;
        next_csr.csr_mtval  = CsrInterruptUpdateQ102H.mtval_instruction;
    end
    if(CsrInterruptUpdateQ102H.misaligned_access) begin
        next_csr.csr_mcause = 32'h00000004;
        next_csr.csr_mepc   = CsrInterruptUpdateQ102H.Pc;
        next_csr.csr_mtval  = CsrInterruptUpdateQ102H.mtval_instruction;//FIXME
    end
    if(CsrInterruptUpdateQ102H.illegal_csr_access) begin
        next_csr.csr_mcause = 32'h0000000B;
        next_csr.csr_mepc   = CsrInterruptUpdateQ102H.Pc;
        next_csr.csr_mtval  = CsrInterruptUpdateQ102H.mtval_instruction;
    end
    if(CsrInterruptUpdateQ102H.breakpoint) begin
        next_csr.csr_mcause = 32'h00000003;
        next_csr.csr_mepc   = CsrInterruptUpdateQ102H.Pc;
        next_csr.csr_mtval  = CsrInterruptUpdateQ102H.mtval_instruction;
    end
    if(CsrInterruptUpdateQ102H.Mret && csr.csr_mip[7]) begin
            next_csr.csr_mie     = 32'h00000888;  // enable mie
            next_csr.csr_mstatus = 32'h00000008;
            next_csr.csr_mip     = 32'h0; 
    end

    //==========================================================
    //32bit lfsr. Polynom: x^32 + x^22 + x^2 + x^1 + 1
    left_lfsr_bit =  (csr.csr_custom_lfsr[31]) ^ (csr.csr_custom_lfsr[21]) ^ (csr.csr_custom_lfsr[1]) ^ (csr.csr_custom_lfsr[0]);
    next_csr.csr_custom_lfsr = {left_lfsr_bit, csr.csr_custom_lfsr[31:1]};
    //==========================================================================
    // SW writes
    //==========================================================================
    if(csr_wren) begin
        unique casez ({csr_op,csr_addr}) // address holds the offset
            // ---- RW CSR ----
            // CSR_MCYCLE
            {2'b01, CSR_MCYCLE}       : next_csr.csr_mcycle = csr_data;
            {2'b10, CSR_MCYCLE}       : next_csr.csr_mcycle = csr.csr_mcycle | csr_data;
            {2'b11, CSR_MCYCLE}       : next_csr.csr_mcycle = csr.csr_mcycle & ~csr_data;
            // CSR_MCYCLEH
            {2'b01, CSR_MCYCLEH}      : next_csr.csr_mcycleh = csr_data;
            {2'b10, CSR_MCYCLEH}      : next_csr.csr_mcycleh = csr.csr_mcycleh | csr_data;
            {2'b11, CSR_MCYCLEH}      : next_csr.csr_mcycleh = csr.csr_mcycleh & ~csr_data;
            // CSR_MINSTRET
            {2'b01, CSR_MINSTRET}     : next_csr.csr_minstret = csr_data;
            {2'b10, CSR_MINSTRET}     : next_csr.csr_minstret = csr.csr_minstret | csr_data;
            {2'b11, CSR_MINSTRET}     : next_csr.csr_minstret = csr.csr_minstret & ~csr_data;
            // CSR_MINSTRETH
            {2'b01, CSR_MINSTRETH}    : next_csr.csr_minstreth = csr_data;
            {2'b10, CSR_MINSTRETH}    : next_csr.csr_minstreth = csr.csr_minstreth | csr_data;
            {2'b11, CSR_MINSTRETH}    : next_csr.csr_minstreth = csr.csr_minstreth & ~csr_data;
            // CSR_MHPMCOUNTER3
            {2'b01, CSR_MHPMCOUNTER3} : next_csr.csr_mhpmcounter3 = csr_data;
            {2'b10, CSR_MHPMCOUNTER3} : next_csr.csr_mhpmcounter3 = csr.csr_mhpmcounter3 | csr_data;
            {2'b11, CSR_MHPMCOUNTER3} : next_csr.csr_mhpmcounter3 = csr.csr_mhpmcounter3 & ~csr_data;
            // CSR_MHPMCOUNTER3H
            {2'b01, CSR_MHPMCOUNTER3H}: next_csr.csr_mhpmcounter3h = csr_data;
            {2'b10, CSR_MHPMCOUNTER3H}: next_csr.csr_mhpmcounter3h = csr.csr_mhpmcounter3h | csr_data;
            {2'b11, CSR_MHPMCOUNTER3H}: next_csr.csr_mhpmcounter3h = csr.csr_mhpmcounter3h & ~csr_data;
            // CSR_MHPMCOUNTER4
            {2'b01, CSR_MHPMCOUNTER4} : next_csr.csr_mhpmcounter4 = csr_data;
            {2'b10, CSR_MHPMCOUNTER4} : next_csr.csr_mhpmcounter4 = csr.csr_mhpmcounter4 | csr_data;
            {2'b11, CSR_MHPMCOUNTER4} : next_csr.csr_mhpmcounter4 = csr.csr_mhpmcounter4 & ~csr_data;
            // CSR_MHPMCOUNTER4H
            {2'b01, CSR_MHPMCOUNTER4H}: next_csr.csr_mhpmcounter4h = csr_data;
            {2'b10, CSR_MHPMCOUNTER4H}: next_csr.csr_mhpmcounter4h = csr.csr_mhpmcounter4h | csr_data;
            {2'b11, CSR_MHPMCOUNTER4H}: next_csr.csr_mhpmcounter4h = csr.csr_mhpmcounter4h & ~csr_data;
            // CSR_MCOUNTINHIBIT
            {2'b01, CSR_MCOUNTINHIBIT}: next_csr.csr_mcountinhibit = csr_data;
            {2'b10, CSR_MCOUNTINHIBIT}: next_csr.csr_mcountinhibit = csr.csr_mcountinhibit | csr_data;
            {2'b11, CSR_MCOUNTINHIBIT}: next_csr.csr_mcountinhibit = csr.csr_mcountinhibit & ~csr_data;
            // CSR_MHPMEVENT3
            {2'b01, CSR_MHPMEVENT3}   : next_csr.csr_mhpmevent3 = csr_data;
            {2'b10, CSR_MHPMEVENT3}   : next_csr.csr_mhpmevent3 = csr.csr_mhpmevent3 | csr_data;
            {2'b11, CSR_MHPMEVENT3}   : next_csr.csr_mhpmevent3 = csr.csr_mhpmevent3 & ~csr_data;
            // CSR_MHPMEVENT4
            {2'b01, CSR_MHPMEVENT4}   : next_csr.csr_mhpmevent4 = csr_data;
            {2'b10, CSR_MHPMEVENT4}   : next_csr.csr_mhpmevent4 = csr.csr_mhpmevent4 | csr_data;
            {2'b11, CSR_MHPMEVENT4}   : next_csr.csr_mhpmevent4 = csr.csr_mhpmevent4 & ~csr_data;
            // CSR_MSTATUS
            {2'b01, CSR_MSTATUS}      : next_csr.csr_mstatus = csr_data;
            {2'b10, CSR_MSTATUS}      : next_csr.csr_mstatus = csr.csr_mstatus | csr_data;
            {2'b11, CSR_MSTATUS}      : next_csr.csr_mstatus = csr.csr_mstatus & ~csr_data;
            // CSR_MSTATUSH
            {2'b01, CSR_MSTATUSH}     : next_csr.csr_mstatush = csr_data;
            {2'b10, CSR_MSTATUSH}     : next_csr.csr_mstatush = csr.csr_mstatush | csr_data;
            {2'b11, CSR_MSTATUSH}     : next_csr.csr_mstatush = csr.csr_mstatush & ~csr_data;
            // CSR_MISA
            {2'b01, CSR_MISA}         : next_csr.csr_misa = csr_data;
            {2'b10, CSR_MISA}         : next_csr.csr_misa = csr.csr_misa | csr_data;
            {2'b11, CSR_MISA}         : next_csr.csr_misa = csr.csr_misa & ~csr_data;
            // CSR_MEDELEG
            {2'b01, CSR_MEDELEG}      : next_csr.csr_medeleg = csr_data;
            {2'b10, CSR_MEDELEG}      : next_csr.csr_medeleg = csr.csr_medeleg | csr_data;
            {2'b11, CSR_MEDELEG}      : next_csr.csr_medeleg = csr.csr_medeleg & ~csr_data;
            // CSR_MIDELEG
            {2'b01, CSR_MIDELEG}    : next_csr.csr_mideleg = csr_data;
            {2'b10, CSR_MIDELEG}    : next_csr.csr_mideleg = csr.csr_mideleg | csr_data;
            {2'b11, CSR_MIDELEG}    : next_csr.csr_mideleg = csr.csr_mideleg & ~csr_data;
            // CSR_MIE
            {2'b01, CSR_MIE}    : next_csr.csr_mie = csr_data;
            {2'b10, CSR_MIE}    : next_csr.csr_mie = csr.csr_mie | csr_data;
            {2'b11, CSR_MIE}    : next_csr.csr_mie = csr.csr_mie & ~csr_data;
            // CSR_MTVEC
            {2'b01, CSR_MTVEC}    : next_csr.csr_mtvec = csr_data;
            {2'b10, CSR_MTVEC}    : next_csr.csr_mtvec = csr.csr_mtvec | csr_data;
            {2'b11, CSR_MTVEC}    : next_csr.csr_mtvec = csr.csr_mtvec & ~csr_data;
            // CSR_MCOUNTERN
            {2'b01, CSR_MCOUNTERN}    : next_csr.csr_mcountern = csr_data;
            {2'b10, CSR_MCOUNTERN}    : next_csr.csr_mcountern = csr.csr_mcountern | csr_data;
            {2'b11, CSR_MCOUNTERN}    : next_csr.csr_mcountern = csr.csr_mcountern & ~csr_data;
            // CSR_MSCRATCH
            {2'b01, CSR_MSCRATCH}    : next_csr.csr_mscratch = csr_data;
            {2'b10, CSR_MSCRATCH}    : next_csr.csr_mscratch = csr.csr_mscratch | csr_data;
            {2'b11, CSR_MSCRATCH}    : next_csr.csr_mscratch = csr.csr_mscratch & ~csr_data;
            // CSR_MEPC
            {2'b01, CSR_MEPC}    : next_csr.csr_mepc = csr_data;
            {2'b10, CSR_MEPC}    : next_csr.csr_mepc = csr.csr_mepc | csr_data;
            {2'b11, CSR_MEPC}    : next_csr.csr_mepc = csr.csr_mepc & ~csr_data;
            // CSR_MCAUSE 
            {2'b01, CSR_MCAUSE}    : next_csr.csr_mcause = csr_data;
            {2'b10, CSR_MCAUSE}    : next_csr.csr_mcause = csr.csr_mcause | csr_data;
            {2'b11, CSR_MCAUSE}    : next_csr.csr_mcause = csr.csr_mcause & ~csr_data;
            // CSR_MTVAL
            {2'b01, CSR_MTVAL}    : next_csr.csr_mtval = csr_data;
            {2'b10, CSR_MTVAL}    : next_csr.csr_mtval = csr.csr_mtval | csr_data;
            {2'b11, CSR_MTVAL}    : next_csr.csr_mtval = csr.csr_mtval & ~csr_data;
            // CSR_MIP
            {2'b01, CSR_MIP}    : next_csr.csr_mip = csr_data;
            {2'b10, CSR_MIP}    : next_csr.csr_mip = csr.csr_mip | csr_data;
            {2'b11, CSR_MIP}    : next_csr.csr_mip = csr.csr_mip & ~csr_data;
            // CSR_MTINST
            {2'b01, CSR_MTINST}    : next_csr.csr_mtinst = csr_data;
            {2'b10, CSR_MTINST}    : next_csr.csr_mtinst = csr.csr_mtinst | csr_data;
            {2'b11, CSR_MTINST}    : next_csr.csr_mtinst = csr.csr_mtinst & ~csr_data;
            // CSR_MTVAL2
            {2'b01, CSR_MTVAL2}    : next_csr.csr_mtval2 = csr_data;
            {2'b10, CSR_MTVAL2}    : next_csr.csr_mtval2 = csr.csr_mtval2 | csr_data;
            {2'b11, CSR_MTVAL2}    : next_csr.csr_mtval2 = csr.csr_mtval2 & ~csr_data;
            // CSR_CUSTOM_MTIMECMP
            {2'b01, CSR_CUSTOM_MTIMECMP}    : next_csr.csr_custom_mtimecmp = csr_data;
            {2'b10, CSR_CUSTOM_MTIMECMP}    : next_csr.csr_custom_mtimecmp = csr.csr_custom_mtimecmp | csr_data;
            {2'b11, CSR_CUSTOM_MTIMECMP}    : next_csr.csr_custom_mtimecmp = csr.csr_custom_mtimecmp & ~csr_data;
            // CSR_CUSTOM_LFSR
            {2'b01, CSR_CUSTOM_LFSR}        : next_csr.csr_custom_lfsr = csr_data;
            {2'b10, CSR_CUSTOM_LFSR}        : next_csr.csr_custom_lfsr = csr.csr_custom_lfsr  | csr_data;
            {2'b11, CSR_CUSTOM_LFSR}        : next_csr.csr_custom_lfsr = csr.csr_custom_lfsr  & ~csr_data;
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end // if(csr_wren)

    //==========================================================================
    // handle HW exceptions:
    //==========================================================================
    // 1. illegal instruction
    // 2. misaligned access
    // 3. illegal CSR access
    // 4. breakpoint
    // ==========================================================================
    //==========================================================================
    // ---- RO/V CSR - writes from RTL ----
    // RO/V - read only from SW  , and may be updated from HW. Example: csr_custom_mtime (HW updates it, SW can read it - NOTE: the mcycle is RW/V)
    //==========================================================================
    next_csr.csr_custom_mtime = csr.csr_custom_mtime + 1'b1;
    // the cycle & instret are accessable to read only -> only the mcycle & minstret are updated by the SW/HW
    next_csr.csr_cycle    = next_csr.csr_mcycle;
    next_csr.csr_cycleh   = next_csr.csr_mcycleh;
    next_csr.csr_instret  = next_csr.csr_minstret;
    next_csr.csr_instreth = next_csr.csr_minstreth;
    //==========================================================================
    // Reset values for CSR
    //==========================================================================
    if(Rst) begin
        next_csr = '0;
        // ==================================================
        // May override the reset values - add the values here
        // ==================================================
        // next_csr.csr_misa = 32'h40001104;
        next_csr.csr_custom_lfsr = 32'hACE1; //seed initialization
    end // if(Rst)
    //==========================================================================
    // READ ONLY - constant values
    //==========================================================================
    next_csr.csr_mvendorid     = 32'b0; // CSR_MVENDORID
    next_csr.csr_marchid       = 32'b0; // CSR_MARCHID
    next_csr.csr_mimpid        = 32'b0; // CSR_MIMPID
    next_csr.csr_mhartid       = 32'b0; // CSR_MHARTID
    next_csr.csr_mconfigptr    = 32'b0; // CSR_MCONFIGPTR
end//always_comb

`MAFIA_DFF(csr, next_csr, Clk)

// ==============================================================================
// READING THE CSR
// ==============================================================================
always_comb begin
    CsrReadDataQ102H = 32'b0;
    if(csr_rden) begin
        unique casez (csr_addr) // address holds the offset
            // ---- RO CSR ----
            CSR_CYCLE          : CsrReadDataQ102H = csr.csr_cycle; 
            CSR_CYCLEH         : CsrReadDataQ102H = csr.csr_cycleh; 
            CSR_INSTRET        : CsrReadDataQ102H = csr.csr_instret; 
            CSR_INSTRETH       : CsrReadDataQ102H = csr.csr_instreth; 
            CSR_MVENDORID      : CsrReadDataQ102H = csr.csr_mvendorid;
            CSR_MARCHID        : CsrReadDataQ102H = csr.csr_marchid;
            CSR_MIMPID         : CsrReadDataQ102H = csr.csr_mimpid;
            CSR_MHARTID        : CsrReadDataQ102H = csr.csr_mhartid;
            CSR_MCONFIGPTR     : CsrReadDataQ102H = csr.csr_mconfigptr;
            // ---- RW CSR ----
            CSR_MCYCLE         : CsrReadDataQ102H = csr.csr_mcycle;
            CSR_MCYCLEH        : CsrReadDataQ102H = csr.csr_mcycleh;
            CSR_MINSTRET       : CsrReadDataQ102H = csr.csr_minstret;
            CSR_MINSTRETH      : CsrReadDataQ102H = csr.csr_minstreth;
            CSR_MHPMCOUNTER3   : CsrReadDataQ102H = csr.csr_mhpmcounter3;
            CSR_MHPMCOUNTER3H  : CsrReadDataQ102H = csr.csr_mhpmcounter3h;
            CSR_MHPMCOUNTER4   : CsrReadDataQ102H = csr.csr_mhpmcounter4;
            CSR_MHPMCOUNTER4H  : CsrReadDataQ102H = csr.csr_mhpmcounter4h;
            CSR_MCOUNTINHIBIT  : CsrReadDataQ102H = csr.csr_mcountinhibit;
            CSR_MHPMEVENT3     : CsrReadDataQ102H = csr.csr_mhpmevent3;
            CSR_MHPMEVENT4     : CsrReadDataQ102H = csr.csr_mhpmevent4;
            CSR_MSTATUS        : CsrReadDataQ102H = csr.csr_mstatus;
            CSR_MSTATUSH       : CsrReadDataQ102H = csr.csr_mstatush;
            CSR_MISA           : CsrReadDataQ102H = csr.csr_misa;
            CSR_MEDELEG        : CsrReadDataQ102H = csr.csr_medeleg;
            CSR_MIDELEG        : CsrReadDataQ102H = csr.csr_mideleg;
            CSR_MIE            : CsrReadDataQ102H = csr.csr_mie;
            CSR_MTVEC          : CsrReadDataQ102H = csr.csr_mtvec;
            CSR_MCOUNTERN      : CsrReadDataQ102H = csr.csr_mcountern;
            CSR_MSCRATCH       : CsrReadDataQ102H = csr.csr_mscratch;
            CSR_MEPC           : CsrReadDataQ102H = csr.csr_mepc;
            CSR_MCAUSE         : CsrReadDataQ102H = csr.csr_mcause;
            CSR_MTVAL          : CsrReadDataQ102H = csr.csr_mtval;
            CSR_MIP            : CsrReadDataQ102H = csr.csr_mip;
            CSR_MTINST         : CsrReadDataQ102H = csr.csr_mtinst;
            CSR_MTVAL2         : CsrReadDataQ102H = csr.csr_mtval2;
            CSR_CUSTOM_MTIME   : CsrReadDataQ102H = csr.csr_custom_mtime;
            CSR_CUSTOM_MTIMECMP: CsrReadDataQ102H = csr.csr_custom_mtimecmp;

            default        : CsrReadDataQ102H = 32'b0 ;
        endcase
    end
end

// Update program counter
logic  BeginInterrupt;
assign BeginInterrupt = (CsrInterruptUpdateQ102H.illegal_instruction || CsrInterruptUpdateQ102H.misaligned_access 
                       || CsrInterruptUpdateQ102H.illegal_csr_access || CsrInterruptUpdateQ102H.breakpoint 
                       || CsrInterruptUpdateQ102H.external_interrupt || CsrInterruptUpdateQ102H.timer_interrupt_taken);

assign CsrPcUpdateQ102H.InterruptJumpEnQ102H       = BeginInterrupt;
assign CsrPcUpdateQ102H.InterruptJumpAddressQ102H  = csr.csr_mtvec;
assign CsrPcUpdateQ102H.InteruptReturnEnQ102H      = CsrInterruptUpdateQ102H.Mret;
assign CsrPcUpdateQ102H.InteruptReturnAddressQ102H = csr.csr_mepc;



  
endmodule

   