//====================================
//====== includes ====================
//====================================
+incdir+../../../source/lotr/common/

//====================================
//====== PARAM PACKAGE ===============
//====================================
../../../source/lotr/common/lotr_pkg.sv

//====================================
//======    RTL     ==================
//====================================
-f ../../../source/lotr/gpc_4t_rtl_list.f
-f ../../../source/lotr/rc_rtl_list.f
-f ../../../source/lotr/uart_io_rtl_list.f

//===========
// FPGA Tile
//===========
../../../source/lotr/rtl/fpga_tile/DE10Lite_MMIO.sv
../../../source/lotr/rtl/fpga_tile/vga_ctrl.sv
../../../source/lotr/rtl/fpga_tile/vga_mem.sv
../../../source/lotr/rtl/fpga_tile/vga_sync_gen.sv
//===========
// LOTR - Fabric
//===========
../../../source/lotr/rtl/lotr/fpga_tile.sv
../../../source/lotr/rtl/lotr/gpc_4t_tile.sv
../../../source/lotr/rtl/lotr/uart_tile.sv
../../../source/lotr/rtl/lotr/lotr.sv