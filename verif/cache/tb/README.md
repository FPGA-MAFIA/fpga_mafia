
python build.py -proj_name 'cache' -debug -tests 'alive plus_test' -full_run  -> run full test (app, hw, sim) for alive & plus_test only 
python build.py -proj_name 'cache' -debug -tests 'alive' -app                 -> compiling the sw for 'alive' test only 
python build.py -proj_name 'cache' -debug -tests 'alive' -hw                  -> compiling the hw for 'alive' test only 
python build.py -proj_name 'cache' -debug -tests 'alive' -sim -gui 


python build.py -proj_name 'cache' -debug  -all -sim