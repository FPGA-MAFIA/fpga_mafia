// cpuc memory wrapper

`include "cpuc_macros.vh"

module cpuc_mem_wrapper
import cpuc_package::*;

#(parameter ADDRESS_WIDTH, parameter DATA_WIDTH)
(
    input logic clk,
    // instruction memory interface
    output logic [INST_MEM_ADDR-1:0]  instruction_out,
    input  logic [DATA_WIDTH-1:0]     pc, 
    // dual data memory interface 
    output var t_dual_ram2_cpuc    dual_ram2_cpuc,  
    input var t_cpuc2_dual_ram     cpuc2_dual_ram,
    
    // quad ram memory interface
    output var  t_quad_ram2_cpuc   quad_ram2_cpuc,
    input var t_cpuc2_quad_ram     cpuc2_quad_ram

);

// FIXME - structs must be refactored when dual and quad ram will be more than 1
//-------------------
// dual data memory
//-------------------
genvar dual_mem_data_out;
generate 
    for(dual_mem_data_out=0; dual_mem_data_out < DUAL_RAM; dual_mem_data_out++) begin
            cpuc_dual_ram
            #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))
            cpuc_dual_ram
            (
                .clk(clk),
                // port A
                .addr_a(), //A1
                .din_a(),  //V1
                .we_a(),
                .dout_a(dual_ram2_cpuc.dout_a), //M1
                // port B
                .addr_b(), //A2
                .din_b(),  //V2
                .we_b(),
                .dout_b(dual_ram2_cpuc.dout_b) //M2
            );
        end
endgenerate

//-------------------
// quad data memory
//-------------------
genvar quad_data_mem_out;
generate
    for(quad_data_mem_out=0; quad_data_mem_out < QUAD_RAM; quad_data_mem_out++) begin
        cpuc_quad_ram 
        #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))
        cpuc_quad_ram
        (
            .clk(clk), 
            // data_bus
            .din_a(),
            .din_b(),
            // we
            .we_a(),
            .we_b(),
            // address_bus
            .addr_a(),
            .addr_b(),
            .addr_c(),
            .addr_d(),
            // data_bus
            .dout_a(quad_ram2_cpuc.dout_a),
            .dout_b(quad_ram2_cpuc.dout_b),
            .dout_c(quad_ram2_cpuc.dout_c),
            .dout_d(quad_ram2_cpuc.dout_d)

        );
    end
endgenerate


cpuc_inst_mem 
#(.INST_MEM_ADDR(INST_MEM_ADDR), .INST_WIDTH()) // TODO - define INST_WIDTH
cpuc_inst_mem
    (
    .clk(clk),
    .we(),
    .instruction_in(),
    .address(pc),
    .instruction_out(instruction_out) 
    );


endmodule