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

// param packages
../../../source/mini_core/mini_core_pkg.sv
../../../source/common/common_pkg.sv

// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/mini_core/mini_core.sv
../../../source/mini_core/mini_top.sv
../../../source/mini_core/mini_mem_wrap.sv
