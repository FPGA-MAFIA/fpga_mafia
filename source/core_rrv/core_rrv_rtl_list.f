//-----------------------------------------------------------------------------
// Title            : simple core  design
// Project          : simple_core
//-----------------------------------------------------------------------------
// File             : core
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 9/2022
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------

+incdir+../../../source/core_rrv/
+incdir+../../../source/fabric/
+incdir+../../../source/common/

// param packages
../../../source/core_rrv/packages/core_rrv_pkg.sv

// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/core_rrv/core_rrv_if.sv
../../../source/core_rrv/core_rrv_ctrl.sv
../../../source/core_rrv/core_rrv_rf.sv
../../../source/core_rrv/core_rrv_cr_mem.sv
../../../source/core_rrv/core_rrv_exe.sv
../../../source/core_rrv/core_rrv_csr.sv
../../../source/core_rrv/core_rrv_vga_ctrl.sv
../../../source/core_rrv/core_rrv_vga_sync_gen.sv
../../../source/core_rrv/vga_mem.sv
../../../source/core_rrv/core_rrv_mem_acs1.sv
../../../source/core_rrv/core_rrv_mem_acs2.sv
../../../source/core_rrv/core_rrv_wb.sv
../../../source/core_rrv/core_rrv.sv
../../../source/core_rrv/core_rrv_top.sv
../../../source/core_rrv/core_rrv_mem_wrap.sv

// KBD FIles
../../../source/core_rrv/ps2_kbd/ps2_kbd_ctrl.sv




