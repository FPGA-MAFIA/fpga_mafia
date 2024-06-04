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

+incdir+../../../source/big_core_cachel1/
+incdir+../../../source/fabric/
+incdir+../../../source/common/

// param packages
../../../source/big_core_cachel1/packages/big_core_cachel1_pkg.sv
../../../source/mem_ss/d_cache/d_cache_param_pkg.sv


// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

// d_cache
../../../source/mem_ss/d_cache/d_cache_pipe_wrap.sv
../../../source/mem_ss/d_cache/d_cache_pipe.sv
../../../source/mem_ss/d_cache/d_cache_tq_entry.sv
../../../source/mem_ss/d_cache/d_cache_tq.sv
../../../source/mem_ss/d_cache/d_cache.sv




//RTL FIles
../../../source/big_core_cachel1/big_core_cachel1_if.sv
../../../source/big_core_cachel1/big_core_cachel1_ctrl.sv
../../../source/big_core_cachel1/big_core_cachel1_rf.sv
../../../source/big_core_cachel1/big_core_cachel1_cr_mem.sv
../../../source/big_core_cachel1/big_core_cachel1_exe.sv
../../../source/big_core_cachel1/big_core_cachel1_csr.sv
../../../source/big_core_cachel1/big_core_cachel1_vga_ctrl.sv
../../../source/big_core_cachel1/big_core_cachel1_vga_sync_gen.sv
../../../source/big_core_cachel1/vga_mem.sv
../../../source/big_core_cachel1/big_core_cachel1_mem_acs1.sv
../../../source/big_core_cachel1/big_core_cachel1_mem_acs2.sv
../../../source/big_core_cachel1/big_core_cachel1_wb.sv
../../../source/big_core_cachel1/big_core_cachel1.sv
../../../source/big_core_cachel1/big_core_cachel1_top.sv
../../../source/big_core_cachel1/big_core_cachel1_mem_wrap.sv

// KBD FIles
../../../source/big_core_cachel1/ps2_kbd/ps2_kbd_ctrl.sv




