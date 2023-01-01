vlog.exe -f ../../verif/mini_core/tb/mini_core_list.f -lint | tee example.log 
vsim.exe work.mini_core_tb -c -do 'run -all' +STRING=alive
vsim.exe -gui work.mini_core_tb  +STRING=alive &
