//========================
// basic example of Register File 
// =======================

`include "macros.vh"

module mini_ex_core_rg
    import mini_ex_core_pkg::*;
(
    input logic           Clock,
    input logic           Rst,
    input var t_rg_read   RgRead,
    input var t_rg_write  RgWrite,
    output var t_rg_val   ValRegsQ101H 
);
    var t_rg_val  ValRegsQ100H;
    logic [0:31][DATA_WIDTH - 1 : 0] Registers;

    always_comb begin: RegisterFile
        //reset    
            if(Rst) begin
                Registers = '{default: '0};
                ValRegsQ100H.Reg1Val = Registers[0];
                ValRegsQ100H.Reg2Val = Registers[0];
            end else begin 
            //read
                ValRegsQ100H.Reg1Val = Registers[RgRead.ReadReg1Q100H];
                ValRegsQ100H.Reg2Val = Registers[RgRead.ReadReg2Q100H];
            //write
                if(RgWrite.WriteEnableQ100H) begin
                    Registers[RgWrite.DstRegQ100H] = RgWrite.WriteValueQ100H;
                end
            end
    end
   
    `MAFIA_DFF(ValRegsQ101H, ValRegsQ100H, Clock);
    
endmodule
