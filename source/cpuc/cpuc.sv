//----------------------------------------------------------------------------------------
//                 CPUC SUGGESTED CONFIGURATION
//-------------------------------------------------------------------------------------------------------------------------------------------
// R7 R6 R5 R4 R3 R2 R1 R0 == == == ==  > > > > + + + + X1 X2 M1 A1 V1 we1 we2 M2 A2 V2 M01 A01 M02 A02 M03 A03 M04 A04 V01 V02 we01 we02 PC
//-------------------------------------------------------------------------------------------------------------------------------------------
// R - register
// X - 2x1 mux
// M, A, V, we - memory ports corresponds to data_out, address, data_in and write enable
// * memory ports with index 0x referred to quad ram
//----------------------------------------------------------------------------------------

`include "cpuc_macros.vh"
module cpuc
import cpuc_package::*;
(
    input logic clk,
    input logic rst,
    
    // instruction memory interface
    input logic [INST_MEM_ADDR-1:0]  instruction_in,
    output logic [DATA_WIDTH-1:0]    pc_reg,

    // dual data memory interface 
    input var t_dual_ram2_cpuc       dual_ram2_cpuc,  
    output var t_cpuc2_dual_ram      cpuc2_dual_ram,
    
    // quad ram memory interface
    input var  t_quad_ram2_cpuc      quad_ram2_cpuc,
    output var t_cpuc2_quad_ram      cpuc2_quad_ram,
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

//---------------
// M - dual ram
//---------------
genvar dual_mem_data_out;
generate
    for(dual_mem_data_out=0; dual_mem_data_out < DUAL_RAM; dual_mem_data_out++) begin
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-dual_mem_data_out] = 
                              dual_ram2_cpuc.dout_a;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-(dual_mem_data_out+1)] = 
                              dual_ram2_cpuc.dout_b;
    end
endgenerate

//---------------
// M - quad ram
//---------------
genvar quad_data_mem_out;
generate
    for(quad_data_mem_out=0; quad_data_mem_out < QUAD_RAM; quad_data_mem_out++) begin
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+0)] = 
                            quad_ram2_cpuc.dout_a;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+1)] = 
                            quad_ram2_cpuc.dout_b;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+2)] = 
                            quad_ram2_cpuc.dout_c;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+3)] = 
                            quad_ram2_cpuc.dout_d;
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
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPERATOR-GREATOR_COMPERATOR-ADDER_NUM-MUX-2*DUAL_RAM-4*QUAD_RAM-pc])
        );
    end
endgenerate

endmodule


