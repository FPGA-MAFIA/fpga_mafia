//-----------------------------------------------------------------------------
// Title            : 7 stages pipline design
// Project          : big_core
//-----------------------------------------------------------------------------
// File             : core
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Created          : 11/2022
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------

+incdir+../../../source/common/
+incdir+../../../source/big_core/
+incdir+../../../source/mini_core/
//RTL FIles
../../../source/common/common_pkg.sv
../../../source/big_core/big_core_pkg.sv
../../../source/big_core/big_core.sv
../../../source/big_core/big_core_top.sv
../../../source/big_core/big_core_mem_wrap.sv
../../../source/big_core/big_core_cr_mem.sv
../../../source/big_core/big_core_vga_ctrl.sv
../../../source/big_core/big_core_vga_sync_gen.sv
../../../source/big_core/vga_mem.sv
../../../source/big_core/d_mem.sv
../../../source/big_core/i_mem.sv
../../../source/big_core/big_core_csr.sv

// KBD FIles
../../../source/big_core/big_core_kbd/big_core_kbd_controller.sv
../../../source/big_core/big_core_kbd/big_core_kbd_gray_fifo.sv
../../../source/big_core/big_core_kbd/big_core_kbd_odd_parity_checker.sv
../../../source/big_core/big_core_kbd/big_core_kbd_release_checker.sv
../../../source/big_core/big_core_kbd/big_core_kbd_struct_checker.sv
