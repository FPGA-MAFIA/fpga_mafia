//----------------------------------------------------------------------------------------
//                 CPUC SUGGESTED CONFIGURATION
//-------------------------------------------------------------------------------------------------------------------------------------------
// R0 R1 R2 R3 R4 R5 R6 R7 PC == == == ==  > > > > + + + + X1 X2 M1 A1 V1 we1 we2 M2 A2 V2 M01 A01 M02 A02 M03 A03 M04 A04 V01 V02 we01 we02
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
    output var t_reg_output          cpuc_register_outputs,
    // constants inputs
    input var t_constants_output     constants2_cpuc
);


logic [HORIZONTAL_GRID_SIZE-1:0][DATA_WIDTH-1]  horizontal_grid;         // outputs of relevant components

logic [REG_NUM+PC_NUM-1:0][DATA_WIDTH-1]        vertical_regs_grid;      // each element is an input to register
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_regs_const_grid;

logic [EQUAL_COMPARATOR-1:0][DATA_WIDTH-1]      vertical_equal_grid_in0;
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_equal_const_grid_in0; 
logic [EQUAL_COMPARATOR-1:0][DATA_WIDTH-1]      vertical_equal_grid_in1;
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_equal_const_grid_in1; 

logic [GREATER_COMPARATOR-1:0][DATA_WIDTH-1]    vertical_greater_grid_in0;
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_greater_const_grid_in0;  
logic [GREATER_COMPARATOR-1:0][DATA_WIDTH-1]    vertical_greater_grid_in1;
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_greater_const_grid_in1;  

logic [ADDER_NUM-1:0][DATA_WIDTH-1]             vertical_add_grid_in0;
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_add_const_grid_in0; 
logic [ADDER_NUM-1:0][DATA_WIDTH-1]             vertical_add_grid_in1;
logic [CONST_NUM-1:0][DATA_WIDTH-1]             vertical_add_const_grid_in1; 

logic [MUX-1:0][DATA_WIDTH-1]                   vertical_mux_grid_in0;
logic [MUX-1:0][DATA_WIDTH-1]                   vertical_mux_grid_in1;
logic [MUX-1:0][DATA_WIDTH-1]                   vertical_mux_grid_ctrl;

logic [DUAL_RAM-1:0][DATA_WIDTH-1]             vertical_dual_ram_grid_A1;
logic [DUAL_RAM-1:0][DATA_WIDTH-1]             vertical_dual_ram_grid_V1;
logic [DUAL_RAM-1:0][DATA_WIDTH-1]             vertical_dual_ram_grid_we1;
logic [DUAL_RAM-1:0][DATA_WIDTH-1]             vertical_dual_ram_grid_A2;
logic [DUAL_RAM-1:0][DATA_WIDTH-1]             vertical_dual_ram_grid_V2;
logic [DUAL_RAM-1:0][DATA_WIDTH-1]             vertical_dual_ram_grid_we2;


//-------------------------------
//         output grid
//-------------------------------

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
            .data_in({vertical_regs_grid[regs],vertical_regs_const_grid}),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-regs])
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
            .data_in({vertical_regs_grid[REG_NUM+pc],vertical_regs_const_grid}),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-pc])
        );
    end
endgenerate

//-----
// ==
//-----
genvar equal;
generate 
    for(equal=0; equal < EQUAL_COMPARATOR; equal++) begin
        cpuc_equal_comparator cpuc_equal_comparator
        (
            .data_in0({vertical_equal_grid_in0[equal],vertical_equal_const_grid_in0}),
            .data_in1({vertical_equal_grid_in1[equal],vertical_equal_const_grid_in1}),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-equal])    
        );
    end
endgenerate

//-----
// >
//-----
genvar greater;
generate 
    for(greater=0; greater < GREATER_COMPARATOR; greater++) begin
        cpuc_greater_comparator cpuc_greater_comparator
        (
            .data_in0({vertical_greater_grid_in0[greater],vertical_equal_const_grid_in0}),
            .data_in1({vertical_greater_grid_in1[greater],vertical_equal_const_grid_in1}),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-greater])    
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
            .data_in0({vertical_add_grid_in0[add],vertical_add_const_grid_in0}),
            .data_in1({vertical_add_grid_in1[add],vertical_add_const_grid_in1}),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-add]),
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
            .data_in0(vertical_mux_grid_in0[mux]),
            .data_in1(vertical_mux_grid_in1[mux]),
            .ctrl(vertical_mux_grid_ctrl[mux]), 
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-mux])
        );
    end
endgenerate

//---------------
// M - dual ram
//---------------
genvar dual_mem_data_out;
generate
    for(dual_mem_data_out=0; dual_mem_data_out < DUAL_RAM; dual_mem_data_out++) begin
        // from dual ram to cpuc
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-dual_mem_data_out] = 
                              dual_ram2_cpuc.dout_a;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(dual_mem_data_out+1)] = 
                              dual_ram2_cpuc.dout_b;
        // to dual ram from cpuc
        assign cpuc2_dual_ram.addr_a = vertical_dual_ram_grid_A1[dual_mem_data_out];
        assign cpuc2_dual_ram.data_a = vertical_dual_ram_grid_V1[dual_mem_data_out];
        assign cpuc2_dual_ram.we_a   = vertical_dual_ram_grid_we1[dual_mem_data_out];
        assign cpuc2_dual_ram.addr_b = vertical_dual_ram_grid_A2[dual_mem_data_out];
        assign cpuc2_dual_ram.data_b = vertical_dual_ram_grid_V2[dual_mem_data_out];
        assign cpuc2_dual_ram.we_b   = vertical_dual_ram_grid_we2[dual_mem_data_out];
    end
endgenerate

//---------------
// M - quad ram
//---------------
genvar quad_data_mem_out;
generate
    for(quad_data_mem_out=0; quad_data_mem_out < QUAD_RAM; quad_data_mem_out++) begin
        // from quad ram to cpuc
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+0)] = 
                            quad_ram2_cpuc.dout_a;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+1)] = 
                            quad_ram2_cpuc.dout_b;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+2)] = 
                            quad_ram2_cpuc.dout_c;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-PC_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+3)] = 
                            quad_ram2_cpuc.dout_d;
    end
endgenerate


//-------------------------------
//         input grid
//-------------------------------

//------------
// R and PC
//------------
genvar i_reg, j_reg, i_reg_consts, j_reg_consts;
generate
    for(i_reg=0; i_reg<REG_NUM+PC_NUM; i_reg++)begin      // loops over all registers + pc
        for(j_reg=0; j_reg<HORIZONTAL_GRID_SIZE; j_reg++) begin // individual register. loops over all inputs
                cpuc_tri_state cpuc_reg_tri_state
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_reg]),
                    .en(instruction_in[i_reg*HORIZONTAL_GRID_SIZE+j_reg]), 
                    .data_out(vertical_regs_grid[i_reg])
                );
        end
    end
    // constants
    for(i_reg_consts=0;i_reg_consts<REG_NUM+PC_NUM;i_reg_consts++) begin
        for(j_reg_consts=0; j_reg_consts<CONST_NUM; j_reg_consts++) begin 
            cpuc_tri_state cpuc_reg_consts_tri_state
                (
                    .data_in(constants2_cpuc.constants_output[i_reg_consts]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+i_reg_consts*CONST_NUM+j_reg_consts]), 
                    .data_out(vertical_regs_const_grid[i_reg_consts])
                );
        end
    end
endgenerate

//-----
// ==
//-----
genvar i_equal, j_equal, i_equal_consts, j_equal_consts; // TODO - input only from registers 
generate
    for(i_equal=0; i_equal<EQUAL_COMPARATOR; i_equal++)begin  // loops over all equal comparators
        for(j_equal=0; j_equal<REG_NUM+PC_NUM; j_equal++) begin      // individual comparator. loops over reg outputs
                cpuc_tri_state cpuc_equal_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_equal]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+ (REG_NUM+PC_NUM)*CONST_NUM+ (i_equal*(REG_NUM+PC_NUM)+2*j_equal)]), //even instruction bits
                    .data_out(vertical_equal_grid_in0[i_equal])
                );
                cpuc_tri_state cpuc_equal_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_equal]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+ (REG_NUM+PC_NUM)*CONST_NUM + (i_equal*(REG_NUM+PC_NUM)+2*j_equal+1)]), //odd instruction bits
                    .data_out(vertical_equal_grid_in1[i_equal])
                );
        end
    end
    for(i_equal_consts=0; i_equal_consts<EQUAL_COMPARATOR; i_equal_consts++) begin 
      for(j_equal_consts=0; j_equal_consts<CONST_NUM; j_equal_consts++) begin 
        cpuc_tri_state cpuc_equal_consts_tri_state_in0
            (
                .data_in(constants2_cpuc.constants_output[i_equal_consts]),
                .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+(i_equal_consts*CONST_NUM+2*j_equal_consts)]), 
                .data_out(vertical_equal_const_grid_in0[i_equal_consts])
            );
        cpuc_tri_state cpuc_equal_consts_tri_state_in1
            (
                .data_in(constants2_cpuc.constants_output[i_equal_consts]),
                .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+(i_equal_consts*CONST_NUM+2*j_equal_consts+1)]), 
                .data_out(vertical_equal_const_grid_in1[i_equal_consts])
            );
      end
    end
endgenerate

//-----
// >
//-----

genvar i_greater, j_greater, i_greater_consts, j_greater_consts; // TODO - input only from registers 
generate
    for(i_greater=0; i_greater<GREATER_COMPARATOR; i_greater++)begin  // loops over all greater comparators
        for(j_greater=0; j_greater<REG_NUM+PC_NUM; j_greater++) begin        // individual comparator. loops over reg outputs
                cpuc_tri_state cpuc_greater_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_greater]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+(i_greater*(REG_NUM+PC_NUM)+2*j_greater)]), //even instruction bits
                    .data_out(vertical_greater_grid_in0[i_greater])
                );
                cpuc_tri_state cpuc_greater_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_greater]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+(i_greater*(REG_NUM+PC_NUM)+2*j_greater+1)]), //odd instruction bits
                    .data_out(vertical_greater_grid_in1[i_greater])
                );
        end
    end
    for(i_greater_consts=0; i_greater_consts<GREATER_COMPARATOR; i_greater_consts++) begin
        for(j_greater_consts=0; j_greater_consts<CONST_NUM; j_greater_consts++) begin 
            cpuc_tri_state cpuc_greater_consts_tri_state_in0
                (
                    .data_in(constants2_cpuc.constants_output[i_greater_consts]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+(i_greater_consts*CONST_NUM+2*j_greater_consts)]), 
                    .data_out(vertical_greater_const_grid_in0[i_greater_consts])
                );
            cpuc_tri_state cpuc_greater_consts_tri_state_in1
                (
                    .data_in(constants2_cpuc.constants_output[i_greater_consts]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+(i_greater_consts*CONST_NUM+2*j_greater_consts+1)]), 
                    .data_out(vertical_greater_const_grid_in1[i_greater_consts])
                );
        end
    end 
endgenerate

//-----
// +
//-----
genvar i_add, j_add, i_add_consts, j_add_consts; // TODO - input only from registers 
generate
    for(i_add=0; i_add<ADDER_NUM; i_add++)begin  // loops over all add comparators
        for(j_add=0; j_add<REG_NUM+PC_NUM; j_add++) begin        // individual comparator. loops over reg outputs
                cpuc_tri_state cpuc_add_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_add]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+(i_add*(REG_NUM+PC_NUM)+2*j_add)]), //even instruction bits
                    .data_out(vertical_add_grid_in0[i_add])
                );
                cpuc_tri_state cpuc_add_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_add]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+(i_add*(REG_NUM+PC_NUM)+2*j_add+1)]), //odd instruction bits
                    .data_out(vertical_add_grid_in1[i_add])
                );
        end
    end
    for(i_add_consts=0; i_add_consts<ADDER_NUM; i_add_consts++) begin 
        for(j_add_consts=0; j_add_consts<CONST_NUM; j_add_consts++) begin 
            cpuc_tri_state cpuc_add_consts_tri_state_in0
                (
                    .data_in(constants2_cpuc.constants_output[i_add_consts]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+(i_add_consts*(REG_NUM+PC_NUM)+2*j_add_consts)]), 
                    .data_out(vertical_add_const_grid_in0[i_add_consts])
                );
            cpuc_tri_state cpuc_add_consts_tri_state_in1
                (
                    .data_in(constants2_cpuc.constants_output[i_add_consts]),
                    .en(instruction_in[(REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+(i_add_consts*(REG_NUM+PC_NUM)+2*j_add_consts+1)]), 
                    .data_out(vertical_add_const_grid_in1[i_add_consts])
                );
        end 
    end 
endgenerate

//--------
// Mux
//--------
genvar i_mux, j_mux;  
generate
    for(i_mux=0; i_mux<MUX; i_mux++)begin                   
        for(j_mux=0; j_mux<REG_NUM+PC_NUM; j_mux++) begin // mux inputs only comes from registers and PC 
                cpuc_tri_state cpuc_mux_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_mux]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + ((i_mux*(REG_NUM+PC_NUM)+3*j_mux))), 
                    .data_out(vertical_mux_grid_in0[i_mux])
                );

                  cpuc_tri_state cpuc_mux_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_mux]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + ((i_mux*(REG_NUM+PC_NUM)+3*j_mux+1))), 
                    .data_out(vertical_mux_grid_in1[i_mux])
                );

                  cpuc_tri_state cpuc_mux_tri_state_ctrl
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_mux]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + ((i_mux*(REG_NUM+PC_NUM)+3*j_mux+2))), 
                    .data_out(vertical_mux_grid_ctrl[i_mux])
                );
        end
    end
endgenerate

//-----------
// Dual RAM
//-----------
genvar i_dual, j_dual;  
generate
    for(i_dual=0; i_dual<DUAL_RAM; i_dual++)begin                   
        for(j_dual=0; j_dual<REG_NUM+PC_NUM; j_dual++) begin // dual ram inputs only comes from registers and PC 
                // A1 address port1
                cpuc_tri_state cpuc_dual_tri_state_A1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_dual]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + 3*MUX*(REG_NUM+PC_NUM) + ((i_dual*(REG_NUM+PC_NUM)+6*j_dual))), 
                    .data_out(vertical_dual_ram_grid_A1[i_dual])
                );
                // V1 input data port1
                cpuc_tri_state cpuc_dual_tri_state_V1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_dual]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + 3*MUX*(REG_NUM+PC_NUM) + ((i_dual*(REG_NUM+PC_NUM)+6*j_dual+1))), 
                    .data_out(vertical_dual_ram_grid_V1[i_dual])
                );
                // write enabel port1
                cpuc_tri_state cpuc_dual_tri_state_we1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_dual]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + 3*MUX*(REG_NUM+PC_NUM) + ((i_dual*(REG_NUM+PC_NUM)+6*j_dual+2))), 
                    .data_out(vertical_dual_ram_grid_we1[i_dual])
                );
                // A2 address port2
                cpuc_tri_state cpuc_dual_tri_state_A2
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_dual]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + 3*MUX*(REG_NUM+PC_NUM) + ((i_dual*(REG_NUM+PC_NUM)+6*j_dual+3))), 
                    .data_out(vertical_dual_ram_grid_A2[i_dual])
                );
                // V2 inpur data port2
                cpuc_tri_state cpuc_dual_tri_state_V2
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_dual]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + 3*MUX*(REG_NUM+PC_NUM) + ((i_dual*(REG_NUM+PC_NUM)+6*j_dual+4))), 
                    .data_out(vertical_dual_ram_grid_V2[i_dual])
                );
                // write enbale port2
                cpuc_tri_state cpuc_dual_tri_state_we2
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_dual]),
                    .en((REG_NUM+PC_NUM)*HORIZONTAL_GRID_SIZE+(REG_NUM+PC_NUM)*CONST_NUM+2*EQUAL_COMPARATOR*(REG_NUM+PC_NUM)+2*EQUAL_COMPARATOR*CONST_NUM+2*GREATER_COMPARATOR*(REG_NUM+PC_NUM)+2*GREATER_COMPARATOR*CONST_NUM+2*ADDER_NUM*(REG_NUM+PC_NUM)+2*ADDER_NUM*CONST_NUM + 3*MUX*(REG_NUM+PC_NUM) + ((i_dual*(REG_NUM+PC_NUM)+6*j_dual+5))), 
                    .data_out(vertical_dual_ram_grid_we2[i_dual])
                );

             
        end
    end
endgenerate
endmodule


