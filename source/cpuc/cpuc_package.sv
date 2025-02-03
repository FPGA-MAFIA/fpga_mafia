// cpuc package

package cpuc_package;

    parameter DATA_WIDTH    = 8;

    // memories sizes
    parameter INST_MEM_ADDR = 4; // instruction memory address width
    parameter ADDRESS_WIDTH = 4; // dual memory address width
    parameter CONST_NUM     = 4; // number of constants in the memory

    // cpuc_componenets
    parameter REG_NUM            = 8;
    parameter ADDER_NUM          = 4; 
    parameter EQUAL_COMPARATOR   = 4;
    parameter GREATER_COMPARATOR = 4;
    parameter MUX                = 2;
    parameter PC_NUM             = 1;

    // memories components
    parameter INSTRUCTION_MEM = 1;
    parameter DUAL_RAM        = 1;
    parameter QUAD_RAM        = 1;

    //grid parameters
    parameter HORIZONTAL_GRID_SIZE = REG_NUM + EQUAL_COMPARATOR + GREATER_COMPARATOR + ADDER_NUM + MUX +
                                     DUAL_RAM + DUAL_RAM +  // we have two output ports
                                     QUAD_RAM + QUAD_RAM + QUAD_RAM + QUAD_RAM + // we have four output ports
                                     PC_NUM;
    
    // registers
    typedef struct packed{
        logic [REG_NUM-1:0][DATA_WIDTH-1:0] reg_output;
    } t_reg_output;

    // dual ram
    typedef struct packed {
        logic [ADDRESS_WIDTH-1:0] addr_a;
        logic [ADDRESS_WIDTH-1:0] addr_b;
        logic [DATA_WIDTH-1:0]    data_a;
        logic [DATA_WIDTH-1:0]    data_b;
        logic                     we_a;
        logic                     we_b;
    } t_cpuc2_dual_ram;

    typedef struct packed {
        logic [DATA_WIDTH-1:0] dout_a;
        logic [DATA_WIDTH-1:0] dout_b;
    } t_dual_ram2_cpuc;

    // quad ram
    typedef struct packed{
        logic [ADDRESS_WIDTH-1:0] addr_a;
        logic [ADDRESS_WIDTH-1:0] addr_b;
        logic [ADDRESS_WIDTH-1:0] addr_c;
        logic [ADDRESS_WIDTH-1:0] addr_d;
        logic [DATA_WIDTH-1:0]    data_a;
        logic [DATA_WIDTH-1:0]    data_b;
        logic                     we_a;
        logic                     we_b;
    } t_cpuc2_quad_ram;

   typedef struct packed {
        logic [DATA_WIDTH-1:0] dout_a;
        logic [DATA_WIDTH-1:0] dout_b;
        logic [DATA_WIDTH-1:0] dout_c;
        logic [DATA_WIDTH-1:0] dout_d;
   } t_quad_ram2_cpuc;

    typedef struct packed{
        logic [CONST_NUM-1:0][DATA_WIDTH-1:0] constants_output;
    } t_constants_output;

endpackage