+incdir+../../../source/common/
+incdir+../../../source/mini_core/
+incdir+../../../source/big_core/

//=======================================
//RTL FIles
//=======================================
// common files
../../../source/common/fifo.sv
../../../source/common/mem.sv
../../../source/common/arbiter.sv
../../../source/fabric/fabric_pkg.sv

// Router files
../../../source/fabric/router/router.sv
../../../source/fabric/router/fifo_arb.sv
../../../source/fabric/router/next_tile_fifo_arb.sv

//  mini_core files
../../../source/mini_core/mini_core_pkg.sv
../../../source/mini_core/mini_core.sv
../../../source/mini_core/mini_core_if.sv
../../../source/mini_core/mini_core_ctrl.sv
../../../source/mini_core/mini_core_rf.sv
../../../source/mini_core/mini_core_exe.sv
../../../source/mini_core/mini_core_wb.sv
../../../source/mini_core/mini_core_mem_acs.sv
../../../source/mini_core/mini_core_top.sv
../../../source/mini_core/mini_mem_wrap.sv

// big_core_files
../../../source/big_core/packages/big_core_pkg.sv
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
../../../source/big_core/big_core_top.sv
../../../source/big_core/big_core_mem_wrap.sv
../../../source/big_core/big_core_d_mem_wrap.sv
../../../source/big_core/ps2_kbd/ps2_kbd_ctrl.sv



// fabric files
../../../source/fabric/fabric.sv
../../../source/fabric/fabric_big_cores.sv
../../../source/fabric/mini_core_tile.sv
../../../source/fabric/big_core_tile.sv