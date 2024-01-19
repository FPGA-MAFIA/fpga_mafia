import os
import sys
import itertools



def orderer_func(arg1):
    N = 6
    input_filename = arg1
    output_filename = "target/mem_ss/output.log"
    temp_filename  = "target/mem_ss/temp.log"

    # Open input and output files
    with open(input_filename, 'r') as input_file, open(output_filename, 'w') as output_file:      
            
        lines = input_file.readlines()
        #Write the header
        for line in lines:
            if N != 0:
                N = N-1
                output_file.write(line)

        while (lines):
            with open(temp_filename, 'w') as temp_file:
                # Find the first occurrence of "CORE_RD_REQ"
                input_file.seek(0) 
                lines = input_file.readlines()
                core_rd_req_found = False
                cache_rd_rsp_found = False
                for line in lines:
                    if "CORE_RD_REQ" in line and not core_rd_req_found:
                        # Write the line to the output file and continue
                        output_file.write(line)
                        core_rd_req_found = True
                #if req and req_found set, simply write to temp        
                    elif  "CORE_RD_REQ" in line and core_rd_req_found:
                        temp_file.write(line) 
                
                # If req_found is set, find the rsp pair to req 
                    if "CACHE_RD_RSP" in line and not cache_rd_rsp_found and core_rd_req_found :
                        # Write the line to the output file and continue
                        output_file.write(line)
                        cache_rd_rsp_found = True
                #if req_found is 0 just write to temp        
                    elif "CACHE_RD_RSP" in line:     
                        temp_file.write(line) 
                    
            input_file.close()
            os.remove(input_filename)

            temp_file.close()

            os.rename(temp_filename, input_filename)
            input_file   = open(input_filename, 'r')
    input_file.close()
    os.remove(input_filename)
    os.rename(output_filename, input_filename)           