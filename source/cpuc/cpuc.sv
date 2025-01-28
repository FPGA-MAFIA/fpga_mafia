//------------------------------------------------------------------------------------------
//                 CPUC SUGGESTED CONFIGURATION
//------------------------------------------------------------------------------------------
// R7 R6 R5 R4 R3 R2 R1 R0 == == == ==  > > > > + + + + X1 X2 M1 A1 V1 we1 we2 M2 A2 V2 PC
//------------------------------------------------------------------------------------------
// R - register
// X - 2x1 mux
// M, A, V, we - memory ports corresponds to data_in, address, data_out and write enable
//------------------------------------------------------------------------------------------

`include "cpuc_macros.vh"
module cpuc
import cpuc_package::*;
(
    input logic clk,
    input logic rst,
    
    // instruction memory interface
    input logic [INST_MEM_ADDR-1:0]  instruction_in,

    // dual data memory interface portA
    input var t_dual_ram2_cpuc       dual_ram2_cpuc_a,  
    output var t_cpuc2_dual_ram      cpuc2_dual_ram_a,
    
    // dual data memory interface portB
    input var t_dual_ram2_cpuc       dual_ram2_cpuc_b,  
    output var t_cpuc2_dual_ram      cpuc2_dual_ram_b,
    
    // register outputs
    output var t_reg_output          cpuc_register_outputs
);

//-------------------------------
//         output grid
//-------------------------------
logic [HORIZONTAL_GRID_SIZE-1:0][DATA_WIDTH-1] horizontal_grid; // outputs of relevant components


//-----
// R
//-----
genvar regs;
generate 
    for(regs=0; regs<REG_NUM; regs++) begin
        cpuc_register cpuc_register
        (
            .clk(clk),
            .rst(rst),
            .data_in(),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-regs])
        );
    end
endgenerate

//-----
// ==
//-----
genvar equal;
generate 
    for(equal=0; equal < EQUAL_COMPERATOR; equal++) begin
        cpuc_equal_comperator cpuc_equal_comperator
        (
            .data_in0(),
            .data_in1(),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-equal])    
        );
    end
endgenerate

//-----
// >
//-----
genvar greator;
generate 
    for(greator=0; greator < GREATOR_COMPERATOR; greator++) begin
        cpuc_greator_comperator cpuc_greator_comperator
        (
            .data_in0(),
            .data_in1(),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-greator])    
        );
    end
endgenerate

//-----
// +
//-----
genvar add;
generate
    for(add=0; add < ADDER_NUM; add++) begin
        cpuc_adder cpuc_adder
        (
            .data_in0(),
            .data_in1(),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-add]),
            .carry_out()
        );
    end
endgenerate

//-----
// X
//-----
genvar mux;
generate 
    for(mux=0; mux < MUX; mux++) begin
        cpuc_mux cpuc_mux
        (
            .data_in0(),
            .data_in1(),
            .ctrl(), 
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-mux])
        );
    end
endgenerate

//-----
// V
//-----
genvar mem_data_out;
generate 
    for(mem_data_out=0; mem_data_out < DUAL_RAM; mem_data_out++) begin
            cpuc_dual_ram
            #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))
            cpuc2_dual_ram
            (
                .clk(clk),
                // port A
                .addr_a(),
                .din_a(),
                .we_a(),
                .dout_a(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-mem_data_out]), 
                // port B
                .addr_b(),
                .din_b(),
                .we_b(),
                .dout_b(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-(mem_data_out+1)])
            );
        end
endgenerate

//-----
// PC
//-----
genvar pc;
generate 
    for(pc=0; pc<PC_NUM; pc++) begin
        cpuc_register cpuc_pc
        (
            .clk(clk),
            .rst(rst),
            .data_in(),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-2*DUAL_RAM-pc])
        );
    end
endgenerate

endmodule


