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
    parameter EQUAL_COMPERATOR   = 4;
    parameter GREATOR_COMPERATOR = 4;
    parameter MUX                = 2;
    parameter PC_NUM             = 1;

    // memories components
    parameter INSRUCTION_MEM = 1;
    parameter DUAL_RAM       = 1;

    //grid parameters
    parameter HORIZONTAL_GRID_SIZE = REG_NUM + EQUAL_COMPERATOR + GREATOR_COMPERATOR + ADDER_NUM + MUX + PC_NUM +
                                     DUAL_RAM + DUAL_RAM; // we have two output ports

    typedef struct packed{

        logic [REG_NUM-1:0][DATA_WIDTH-1:0] reg_output;

    } t_reg_output;

    typedef struct packed {
        logic [ADDRESS_WIDTH-1:0] addr2_dmem;
        logic [DATA_WIDTH-1:0]    din2_dmem;
        logic                     we2_dmem;
    } t_cpuc2_dual_ram;

    typedef struct packed {
        logic [DATA_WIDTH-1:0] dout2_cpuc;
    } t_dual_ram2_cpuc;

    typedef struct packed{
        logic [CONST_NUM-1:0][DATA_WIDTH-1:0] constants_output;
    } t_constants_output;

endpackage