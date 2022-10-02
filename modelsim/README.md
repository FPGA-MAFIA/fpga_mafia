vlog.exe -f ../source/core_list.f
vsim.exe work.core_tb -c -do 'run -all'
vsim.exe -gui work.core_tb 
