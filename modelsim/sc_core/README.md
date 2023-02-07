vlog.exe -lint -f ../../verif/sc_core/tb/sc_core_list.f
vsim.exe work.sc_core_tb -c -do 'run -all' +STRING=alive
vsim.exe -gui work.sc_core_tb +STRING=alive &
