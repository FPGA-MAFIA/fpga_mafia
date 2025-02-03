//----------------------------------------------------------------------------------------
//                 CPUC SUGGESTED CONFIGURATION
//-------------------------------------------------------------------------------------------------------------------------------------------
// R0 R1 R2 R3 R4 R5 R6 R7 == == == ==  > > > > + + + + X1 X2 M1 A1 V1 we1 we2 M2 A2 V2 M01 A01 M02 A02 M03 A03 M04 A04 V01 V02 we01 we02 PC
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


logic [HORIZONTAL_GRID_SIZE-1:0][DATA_WIDTH-1]  horizontal_grid;         // outputs of relevant components
logic [REG_NUM-1:0][DATA_WIDTH-1]               vertical_regs_grid;      // each element is an input to register
logic [EQUAL_COMPARATOR-1:0][DATA_WIDTH-1]      vertical_equal_grid_in0; 
logic [EQUAL_COMPARATOR-1:0][DATA_WIDTH-1]      vertical_equal_grid_in1; 
logic [GREATER_COMPARATOR-1:0][DATA_WIDTH-1]    vertical_greater_grid_in0; 
logic [GREATER_COMPARATOR-1:0][DATA_WIDTH-1]    vertical_greater_grid_in1; 
logic [ADDER_NUM-1:0][DATA_WIDTH-1]             vertical_add_grid_in0; 
logic [ADDER_NUM-1:0][DATA_WIDTH-1]             vertical_add_grid_in1; 

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
            .data_in(vertical_regs_grid[regs]),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-regs])
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
            .data_in0(vertical_equal_grid_in0[equal]),
            .data_in1(vertical_equal_grid_in1[equal]),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-equal])    
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
            .data_in0(vertical_greater_grid_in0[greater]),
            .data_in1(vertical_greater_grid_in0[greater]),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-greater])    
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
            .data_in0(vertical_add_grid_in0[add]),
            .data_in1(vertical_add_grid_in1[add]),
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-add]),
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
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-mux])
        );
    end
endgenerate

//---------------
// M - dual ram
//---------------
genvar dual_mem_data_out;
generate
    for(dual_mem_data_out=0; dual_mem_data_out < DUAL_RAM; dual_mem_data_out++) begin
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-dual_mem_data_out] = 
                              dual_ram2_cpuc.dout_a;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(dual_mem_data_out+1)] = 
                              dual_ram2_cpuc.dout_b;
    end
endgenerate

//---------------
// M - quad ram
//---------------
genvar quad_data_mem_out;
generate
    for(quad_data_mem_out=0; quad_data_mem_out < QUAD_RAM; quad_data_mem_out++) begin
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+0)] = 
                            quad_ram2_cpuc.dout_a;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+1)] = 
                            quad_ram2_cpuc.dout_b;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+2)] = 
                            quad_ram2_cpuc.dout_c;
        assign horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-(DUAL_RAM+1)-(quad_data_mem_out+3)] = 
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
            .data_out(horizontal_grid[HORIZONTAL_GRID_SIZE-1-REG_NUM-EQUAL_COMPARATOR-GREATER_COMPARATOR-ADDER_NUM-MUX-2*DUAL_RAM-4*QUAD_RAM-pc])
        );
    end
endgenerate

//-------------------------------
//         input grid
//-------------------------------

//-----
// R
//-----
genvar i_reg, j_reg;
integer reg_instruction_eb_bits;
generate
    for(i_reg=0; i_reg<REG_NUM; i_reg++)begin      // loops over all registers
        for(j_reg=0; j_reg<HORIZONTAL_GRID_SIZE; j_reg++) begin // individual register. loops over all inputs
                assign reg_instruction_eb_bits = i_reg*HORIZONTAL_GRID_SIZE+j_reg;
                cpuc_tri_state cpuc_reg_tri_state
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_reg]),
                    .en(instruction_in[reg_instruction_eb_bits]), 
                    .data_out(vertical_regs_grid[i_reg])
                );
        end
    end 
endgenerate

//-----
// ==
//-----
genvar i_equal, j_equal; // TODO - input only from registers 
integer equal_instruction_en_bits_in0, equal_instruction_en_bits_in1;
generate
    for(i_equal=0; i_equal<EQUAL_COMPARATOR; i_equal++)begin  // loops over all equal comparators
        for(j_equal=0; j_equal<REG_NUM+PC_NUM; j_equal++) begin      // individual comparator. loops over reg outputs
                assign equal_instruction_en_bits_in0 = REG_NUM*HORIZONTAL_GRID_SIZE+
                                                       (i_equal*REG_NUM+2*j_equal);
                assign equal_instruction_en_bits_in1 = REG_NUM*HORIZONTAL_GRID_SIZE+
                                                       (i_equal*REG_NUM+2*j_equal+1);
                cpuc_tri_state cpuc_equal_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_equal]),
                    .en(instruction_in[equal_instruction_en_bits_in0]), //even instruction bits
                    .data_out(vertical_equal_grid_in0[i_equal])
                );
                cpuc_tri_state cpuc_equal_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_equal]),
                    .en(instruction_in[equal_instruction_en_bits_in1]), //odd instruction bits
                    .data_out(vertical_equal_grid_in1[i_equal])
                );
        end
    end 
endgenerate

//-----
// >
//-----

genvar i_greater, j_greater; // TODO - input only from registers 
integer greater_instruction_en_bits_in0, greater_instruction_en_bits_in1;
generate
    for(i_greater=0; i_greater<GREATER_COMPARATOR; i_greater++)begin  // loops over all greater comparators
        for(j_greater=0; j_greater<REG_NUM+PC_NUM; j_greater++) begin        // individual comparator. loops over reg outputs
                assign greater_instruction_en_bits_in0 = REG_NUM*HORIZONTAL_GRID_SIZE+2*EQUAL_COMPARATOR*REG_NUM+
                                                         (i_greater*REG_NUM+2*j_greater);
                assign greater_instruction_en_bits_in1 = REG_NUM*HORIZONTAL_GRID_SIZE+2*EQUAL_COMPARATOR*REG_NUM+
                                                         (i_greater*REG_NUM+2*j_greater+1);
                cpuc_tri_state cpuc_greater_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_greater]),
                    .en(instruction_in[greater_instruction_en_bits_in0]), //even instruction bits
                    .data_out(vertical_greater_grid_in0[i_greater])
                );
                cpuc_tri_state cpuc_greater_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_greater]),
                    .en(instruction_in[greater_instruction_en_bits_in1]), //odd instruction bits
                    .data_out(vertical_greater_grid_in1[i_greater])
                );
        end
    end 
endgenerate

//-----
// +
//-----
genvar i_add, j_add; // TODO - input only from registers 
integer add_instruction_en_bits_in0, add_instruction_en_bits_in1;
generate
    for(i_add=0; i_add<ADDER_NUM; i_add++)begin  // loops over all add comparators
        for(j_add=0; j_add<REG_NUM+PC_NUM; j_add++) begin        // individual comparator. loops over reg outputs
                assign add_instruction_en_bits_in0 = REG_NUM*HORIZONTAL_GRID_SIZE+2*EQUAL_COMPARATOR*REG_NUM+2*ADDER_NUM*REG_NUM+
                                                         (i_add*REG_NUM+2*j_add);
                assign add_instruction_en_bits_in1 = REG_NUM*HORIZONTAL_GRID_SIZE+2*EQUAL_COMPARATOR*REG_NUM+2*ADDER_NUM*REG_NUM+
                                                         (i_add*REG_NUM+2*j_add+1);
                cpuc_tri_state cpuc_add_tri_state_in0
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_add]),
                    .en(instruction_in[add_instruction_en_bits_in0]), //even instruction bits
                    .data_out(vertical_add_grid_in0[i_add])
                );
                cpuc_tri_state cpuc_add_tri_state_in1
                (
                    .data_in(horizontal_grid[HORIZONTAL_GRID_SIZE-1-j_add]),
                    .en(instruction_in[add_instruction_en_bits_in1]), //odd instruction bits
                    .data_out(vertical_add_grid_in1[i_add])
                );
        end
    end 
endgenerate

endmodule


