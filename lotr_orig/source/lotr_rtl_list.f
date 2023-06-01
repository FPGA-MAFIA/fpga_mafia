//====================================
//====== includes ====================
//====================================
+incdir+../../../source/common/

//====================================
//====== PARAM PACKAGE ===============
//====================================
../../../source/common/lotr_pkg.sv

//====================================
//======    RTL     ==================
//====================================
-f ../../../source/gpc_4t_rtl_list.f
-f ../../../source/rc_rtl_list.f
-f ../../../source/uart_io_rtl_list.f

//===========
// FPGA Tile
//===========
../../../source/rtl/fpga_tile/DE10Lite_MMIO.sv
../../../source/rtl/fpga_tile/vga_ctrl.sv
../../../source/rtl/fpga_tile/vga_mem.sv
../../../source/rtl/fpga_tile/vga_sync_gen.sv
//===========
// LOTR - Fabric
//===========
../../../source/rtl/lotr/fpga_tile.sv
../../../source/rtl/lotr/gpc_4t_tile.sv
../../../source/rtl/lotr/uart_tile.sv
../../../source/rtl/lotr/lotr.sv