vlog.exe -lint -f ../../verif/cache/tb/cache_list.f
vsim.exe work.cache_tb -c -do 'run -all'
vsim.exe -gui work.cache_tb 
