// include macros
//+incdir+../../../source/mini_core_rrv/ 
+incdir+../../../source/common/ 

// include trackers and tasks files
+incdir+../../../verif/mini_core_rrv/tb/trk
+incdir+../../../verif/mini_core_rrv/tb/ref_tasks

// ref model
../../../verif/rv32i_ref/tb/rv32i_ref_pkg.sv
../../../verif/rv32i_ref/tb/rv32i_ref.sv

// include TB's
../../../verif/mini_core_rrv/tb/mini_core_rrv_if_tb.sv
../../../verif/mini_core_rrv/tb/mini_core_rrv_rf_tb.sv
../../../verif/mini_core_rrv/tb/mini_core_rrv_alu_tb.sv
../../../verif/mini_core_rrv/tb/mini_core_rrv_ri_type_tb.sv
../../../verif/mini_core_rrv/tb/mini_core_rrv_tb.sv
