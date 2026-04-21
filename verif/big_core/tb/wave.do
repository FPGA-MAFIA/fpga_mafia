# Waveform starter for big_core_tb (run from target/big_core/modelsim, or via build.py -gui).
# Requires compile/sim with access (build.py uses vlog +acc and vsim -voptargs=+acc).
# If waves are still empty, delete target/big_core/modelsim/work and re-run with -hw.

onerror { resume }

add wave -divider "TB"
add wave sim:/big_core_tb/Clk
add wave sim:/big_core_tb/Rst

add wave -divider "DUT big_core_top"
add wave -r sim:/big_core_tb/big_core_top/*

add wave -divider "Reference rv32i_ref"
add wave -r sim:/big_core_tb/rv32i_ref/*
