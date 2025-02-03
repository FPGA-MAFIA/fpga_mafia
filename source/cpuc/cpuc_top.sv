// cpuc + mem_wrapper

`include "cpuc_macros.vh"

module cpuc_top
import cpuc_package::*;
(
    input logic clk,
    input logic rst,
    output var t_reg_output  cpuc_register_outputs

);


// instruction memory
logic [INST_MEM_ADDR-1:0]  instruction_in;
logic [DATA_WIDTH-1:0]     pc;

// dual data memory interface 
t_dual_ram2_cpuc          dual_ram2_cpuc;  
t_cpuc2_dual_ram          cpuc2_dual_ram;
    
// quad ram memory interface
t_quad_ram2_cpuc         quad_ram2_cpuc;
t_cpuc2_quad_ram         cpuc2_quad_ram;

// constant memory
t_constants_output constants_output;

//-------------------
//   cpuc 
//-------------------
cpuc cpuc
(
    .clk(clk),
    .rst(rst),
    
    // instruction memory interface
    .instruction_in(instruction_in),
    .pc_reg(pc),

    // dual data memory interface 
    .dual_ram2_cpuc(dual_ram2_cpuc),  
    .cpuc2_dual_ram(cpuc2_dual_ram),
    
    // quad ram memory interface
    .quad_ram2_cpuc(quad_ram2_cpuc),
    .cpuc2_quad_ram(),
    // register outputs
    .cpuc_register_outputs(cpuc_register_outputs),
    // constants
    .constants2_cpuc(constants_output)
);


//-------------------
//  memory wrapper
//-------------------
cpuc_mem_wrapper 
#(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH))
cpuc_mem_wrapper
(
    .clk(clk),
    // instruction memory interface
    .instruction_out(instruction_in),
    .pc(pc), 
    // dual data memory interface 
    .dual_ram2_cpuc(dual_ram2_cpuc),  
    .cpuc2_dual_ram(cpuc2_dual_ram),
    
    // quad ram memory interface
    .quad_ram2_cpuc(quad_ram2_cpuc),
    .cpuc2_quad_ram(cpuc2_quad_ram),

    // constant memory
    .constants_output(constants_output)

);

endmodule