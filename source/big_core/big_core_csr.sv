module big_core_csr #(parameter CSR_SIZE = 4096) (
    input logic Clk,
    input logic Rst,

    // Inputs from the core
    input logic         csr_wren,
    input logic         csr_rden,
    input logic [1:0]   csr_op,    // 2-bit CSR operation (00: Read, 01: Write, 10: Set, 11: Clear)
    input logic [11:0]  csr_addr, // 12-bit CSR address
    input logic [31:0]  csr_data, // 32-bit data to be written into the CSR

    // Outputs to the core
    output logic [31:0] csr_read_data // 32-bit data read from the CSR
);

    // Define the CSR registers
    logic csrs [CSR_SIZE-1:0][31:0]; // 4,096 CSRs, each 32 bits wide

    // Internal signals
    logic [31:0] csr_write_data;

    if      (csr_op == 2'b00) assign csr_write_data = {$size(csr_data){1'b0}};
    else if (csr_op == 2'b01) assign csr_write_data = csr_data;
    else if (csr_op == 2'b10) assign csr_write_data = csrs[csr_addr] |  csr_data;
    else if (csr_op == 2'b11) assign csr_write_data = csrs[csr_addr] & ~csr_data;
    
    `MAFIA_EN_RST_DFF(csr_read_data , csrs[csr_addr]  , Clk, csr_rden, Rst)
    `MAFIA_EN_RST_DFF(csrs[csr_addr], csr_write_data  , Clk, csr_wren, Rst)
endmodule