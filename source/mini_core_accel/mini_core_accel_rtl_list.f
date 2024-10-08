//-----------------------------------------------------------------------------
// Title            : mini_core_accelerator
// Project          : mini_core_accelerator
//-----------------------------------------------------------------------------
// File             : core
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          :
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------


+incdir+../../../source/common/
+incdir+../../../source/mini_core/
+incdir+../../../source/big_core/
+incdir+../../../source/fabric/
+incdir+../../../source/mini_core_accel/

// param packages
../../../source/mini_core/mini_core_pkg.sv
../../../source/mini_core_accel/mini_core_accel_pkg.sv

// Common
../../../source/common/fifo.sv
../../../source/common/arbiter.sv
../../../source/common/mem.sv

//RTL FIles
../../../source/mini_core/mini_core_if.sv
../../../source/mini_core/mini_core_ctrl.sv
../../../source/mini_core/mini_core_rf.sv
../../../source/mini_core/mini_core_exe.sv
../../../source/mini_core/mini_core_mem_acs.sv
../../../source/mini_core/mini_core_wb.sv
../../../source/mini_core/mini_core.sv
../../../source/mini_core_accel/mini_core_accel_top.sv
../../../source/mini_core_accel/mini_core_accel_mem_wrap.sv
../../../source/mini_core_accel/mini_core_accel_cr_mem.sv

// Accelerator farm files
../../../source/mini_core_accel/accelerators/multiplier_int8.sv
../../../source/mini_core_accel/accelerators/pipe_line_mul.sv
../../../source/mini_core_accel/accelerators/neuron_mac.sv
../../../source/mini_core_accel/accelerators/mini_core_accel_farm.sv
../../../source/mini_core_accel/accelerators/systolic_array/single_cycle_mul.sv
../../../source/mini_core_accel/accelerators/systolic_array/pe_unit.sv
../../../source/mini_core_accel/accelerators/systolic_array/systolic_array_net.sv
../../../source/mini_core_accel/accelerators/systolic_array/systolic_array_ctrl.sv
../../../source/mini_core_accel/accelerators/systolic_array/systolic_array_top.sv
