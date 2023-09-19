`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS FLASH CONTROLLER OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module flash_unit(
    input do_flash,
    output flash_if_id,
    output flash_id_ex
);

   assign flash_if_id = (do_flash) ? 1'b1 : 1'b0;
   assign flash_id_ex = (do_flash) ? 1'b1 : 1'b0;
    
endmodule
