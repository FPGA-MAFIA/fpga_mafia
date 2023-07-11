python build.py -dut 'cache' -tests 'cache_alive' -hw  -sim              -> compiling the hw for 'alive' test only 
python build.py -dut 'cache' -tests 'cache_alive' -sim -gui 

python build.py -dut 'cache'  -all -sim


python build.py -dut 'd_cache' -regress alive -hw  -sim 