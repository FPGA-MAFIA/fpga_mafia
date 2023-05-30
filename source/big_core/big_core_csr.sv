`include "macros.sv"
module big_core_csr
import big_core_pkg::*;
(
    input logic Clk,
    input logic Rst,
    input logic [31:0] PcQ102H,
    // Inputs from the core
    input var t_csr_inst CsrInstQ102H,
    input var t_csr_hw_updt CsrHwUpdt, // 32-bit data to be written into the CSR
    // Outputs to the core
    output logic [31:0] MePc, // 32-bit data read from the CSR
    output logic        interrupt_counter_expired,
    output logic [31:0] CsrReadDataQ102H // 32-bit data read from the CSR
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
logic [31:0] csr_data;
assign csr_wren = CsrInstQ102H.csr_wren;
assign csr_rden = CsrInstQ102H.csr_rden;
assign csr_addr = CsrInstQ102H.csr_addr;
assign csr_data = CsrInstQ102H.csr_data;
assign csr_op   = CsrInstQ102H.csr_op;

logic csr_cycle_low_overflow;
always_comb begin
    next_csr = csr;
    if(csr_wren) begin
        unique casez ({csr_op,csr_addr}) // address holds the offset
            // ---- RW CSR ----
            {2'b01,CSR_SCRATCH}   : next_csr.csr_scratch = csr_data;
            {2'b10,CSR_SCRATCH}   : next_csr.csr_scratch = csr.csr_scratch |  csr_data;
            {2'b11,CSR_SCRATCH}   : next_csr.csr_scratch = csr.csr_scratch & ~csr_data;

            {2'b01,CSR_MCAUSE}    : next_csr.csr_mcause = csr_data;                    
            {2'b10,CSR_MCAUSE}    : next_csr.csr_mcause = csr.csr_mcause |  csr_data;
            {2'b11,CSR_MCAUSE}    : next_csr.csr_mcause = csr.csr_mcause & ~csr_data;
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end
    //==========================================================================
    // ---- RO CSR - writes from RTL ----
    //==========================================================================
    // the cycle counter is incremented on every clock cycle
        {csr_cycle_low_overflow , next_csr.csr_cycle_low}  = csr.csr_cycle_low  + 1'b1;
        next_csr.csr_cycle_high = csr.csr_cycle_high + csr_cycle_low_overflow;
    //==========================================================================

    //==========================================================================
    // handle HW exceptions:
    //==========================================================================
    // 1. illegal instruction
    // 2. misaligned access
    // 3. illegal CSR access
    // 4. breakpoint
    if(CsrHwUpdt.illegal_instruction) next_csr.csr_mcause = 32'h00000002;
    if(CsrHwUpdt.misaligned_access)   next_csr.csr_mcause = 32'h00000004;
    if(CsrHwUpdt.illegal_csr_access)  next_csr.csr_mcause = 32'h0000000B;
    if(CsrHwUpdt.breakpoint)          next_csr.csr_mcause = 32'h00000003;
    // handle HW interrupts:
    // 1. timer interrupt
    // 2. external interrupt
    if(interrupt_counter_expired)     begin
        next_csr.csr_mepc   = PcQ102H;
    end
    if(CsrHwUpdt.external_interrupt)  next_csr.csr_mcause = 32'h0000000B;

    //==========================================================================
    // Reset values for CSR
    //==========================================================================
    if(Rst) begin
        next_csr = '0;
        //May override the reset values
        next_csr.csr_scratch   = 32'h1001;
    end // if(Rst)
end//always_comb

`MAFIA_DFF(csr, next_csr, Clk)

// This is the load
always_comb begin
    CsrReadDataQ102H = 32'b0;
    if(csr_rden) begin
        unique casez (csr_addr) // address holds the offset
            // ---- RW CSR ----
            CSR_SCRATCH    : CsrReadDataQ102H = csr.csr_scratch;
            // ---- RO CSR ----
            CSR_CYCLE_LOW  : CsrReadDataQ102H = csr.csr_cycle_low;
            CSR_CYCLE_HIGH : CsrReadDataQ102H = csr.csr_cycle_high;
            CSR_MCAUSE     : CsrReadDataQ102H = csr.csr_mcause;
            CSR_MEPC       : CsrReadDataQ102H = csr.csr_mepc;
            default        : CsrReadDataQ102H = 32'b0 ;
        endcase
    end
end

assign MePc = csr.csr_mepc;


always_comb begin
    //create an interrupt if the cycle counter is equal to the compare value
    interrupt_counter_expired = '0;// csr.csr_cycle_low == csr.csr_scratch;
end
endmodule