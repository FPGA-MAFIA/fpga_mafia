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


// param packages

+incdir+../../../source/common/
../../../source/mini_core/mini_core_pkg.sv
../../../source/router/router_pkg.sv
../../../source/common/common_pkg.sv
../../../source/router/arbiter.sv
../../../source/router/fifo.sv

//RTL FIles
../../../source/common/mem.sv
../../../source/mini_core/mini_core.sv
../../../source/mini_core/mini_top.sv
../../../source/mini_core/mini_mem_wrap.sv
