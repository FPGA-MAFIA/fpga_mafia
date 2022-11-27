vlog.exe -f ../../source/big_core/big_core_list.f
vsim.exe work.big_core_tb -c -do 'run -all'
vsim.exe -gui work.big_core_tb 
