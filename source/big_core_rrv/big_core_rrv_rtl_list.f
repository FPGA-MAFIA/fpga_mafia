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


+incdir+../../../source/common/
+incdir+../../../source/big_core_rrv/
+incdir+../../../source/big_core/
+incdir+../../../source/fabric/

// param packages
../../../source/common/common_pkg.sv

// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/big_core_rrv/mini_core_if.sv
../../../source/big_core_rrv/mini_core_ctrl.sv
../../../source/big_core_rrv/mini_core_rf.sv
../../../source/big_core_rrv/mini_core_exe.sv
../../../source/big_core_rrv/mini_core_csr.sv
../../../source/big_core_rrv/mini_core_mem_acs1.sv
../../../source/big_core_rrv/mini_core_mem_acs2.sv
../../../source/big_core_rrv/mini_core_wb.sv
../../../source/big_core_rrv/mini_core.sv
../../../source/big_core_rrv/mini_core_top.sv
../../../source/big_core_rrv/mini_mem_wrap.sv
