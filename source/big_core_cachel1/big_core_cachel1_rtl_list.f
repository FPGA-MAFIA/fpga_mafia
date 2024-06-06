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

+incdir+../../../source/big_core/
+incdir+../../../source/fabric/
+incdir+../../../source/common/

// param packages
../../../source/big_core/packages/big_core_pkg.sv
../../../source/mem_ss/d_cache/d_cache_param_pkg.sv
../../../source/mem_ss/sdram_ctrl/sdram_ctrl_pkg.sv

// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/big_core/big_core_if.sv
../../../source/big_core/big_core_ctrl.sv
../../../source/big_core/big_core_rf.sv
../../../source/big_core/big_core_cr_mem.sv
../../../source/big_core/big_core_exe.sv
../../../source/big_core/big_core_csr.sv
../../../source/big_core/big_core_vga_ctrl.sv
../../../source/big_core/big_core_vga_sync_gen.sv
../../../source/big_core/vga_mem.sv
../../../source/big_core/big_core_mem_acs1.sv
../../../source/big_core/big_core_mem_acs2.sv
../../../source/big_core/big_core_wb.sv
../../../source/big_core/big_core.sv
../../../source/big_core/big_core_mem_wrap.sv

// modifies big_core_cachel1_files
../../../source/big_core_cachel1/big_core_cachel1_top.sv

// cache files
../../../source/mem_ss/d_cache/d_cache_pipe_wrap.sv
../../../source/mem_ss/d_cache/d_cache_pipe.sv
../../../source/mem_ss/d_cache/d_cache_tq_entry.sv
../../../source/mem_ss/d_cache/d_cache_tq.sv
../../../source/mem_ss/d_cache/d_cache.sv

// sdram controller files
../../../source/mem_ss/sdram_ctrl/sdram_ctrl.sv


// KBD FIles
../../../source/big_core/ps2_kbd/ps2_kbd_ctrl.sv




