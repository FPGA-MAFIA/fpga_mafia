'''
This script helps to convert hex instructions .mif files.
To run it, use "python hex2mif.py input.txt/sv output.mif"
you need to export the binary instruction as hexadecimal text file.
But for any kind of input files, it should work fine as long as
it uses the following format:
DEADBEEF
BAADF00D
'''

from asyncio.windows_events import NULL
import sys

comment_msg='''-- http://srecord.sourceforge.net/
-- SUPPOSE! be similar to->
-- Generated automatically by srec_cat -o --mif
--
'''

#gather bytes into Little Endian format
def gather_to_LE(line_bytes):
    i=0
    word = line_bytes[i+3] + line_bytes[i+2] + line_bytes[i+1] + line_bytes[i]
    
    return word

def convert(f_in, f_out,data_offset):

    str_log = ""            # will save all output data
    
    line_bytes = list()     # TODO comment

    #sizes
    depth_counter = 0       # The number of all words in file
    width_word = 32         # hard-coded for our architecture
    
    prefix_line = 0         # The init of each line 0xxx:  --> that tells the start of the i'th word in this line
    word_in_line = 0        # to know skip after reach limit of 8 word in line (or less)
    
    # address
    count_addr = 0
    start_addr = ""
    
    # for case convert data_mem/other - and want to shift is begin address to start on 0x0000
    data_offset = (int(data_offset,16))
    
    with open(f_in) as fr:
        lines = fr.readlines()
    
    for line in lines:
        
        if word_in_line == 8 :
            str_log+=(f'{prefix_line:X}: '.zfill(6))
            word_in_line = 0

        # care for line address kind ("@0000xxxx")
        if line.startswith('@'):
            count_addr += 1                                     # to recognize 2nd appear of @0xxx is the start addr
            
            # take the address in hex, and divide in 4 to get number of words, (each word = 4 bytes)
            prefix_line = ((int(line[1:-1],16)-data_offset)//4) 
            line_res = (f'{prefix_line:X}: '.zfill(6))          # print in hex but without leading 0x
            # start a new line when see new addr
            str_log=str_log[:-1]                # cut of the last space char (" ") and replace in (";")
            str_log += ";\n" +  str(line_res) 
            word_in_line = 0
            
            if count_addr == 2: # TODO- FIXME for case of data_mem if work the same
                start_addr = (f'{int(line[1:-1],16):X}'.zfill(6))
                   
        
        # care for regular line: 1) take  all bytes.  2) gather to WORD (with Little-E) 
        #                                             3) then rest them 8 words at most in each line if 
        else:
            line_bytes = (line.split()) # 1. take  all bytes
            
            # add leading zeros to line if it is not in lenght of moultiple of word (4 bytes) 
            while not (len(line_bytes)/4).is_integer():
                line_bytes.append('00')
            
            # 2. gather to WORD. from separate byte -to  a 32 bit (4 byte) word - in LITTLE ENDIAN
            for i, byte in enumerate(line_bytes):
                if (i%4 != 0):
                    continue
                else:
                    # gather each 4 byte in the row to word (32 bit) little -endian format
                    word  = gather_to_LE(line_bytes[i:i+4])
                    str_log += str(word)
                    depth_counter += 1
                    word_in_line  += 1 # to jump new line when reach 8
                    
                    if word_in_line != 8: # if it is not the last byte in line - add space (" ")
                        str_log += " "
                    else:               # word_in_line == 8:
                        str_log+=";\n"
                        # update prefix_line
                        prefix_line += word_in_line
                        
    str_begin = comment_msg + 'DEPTH={:d};\nWIDTH={:d};\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN'.format(depth_counter, width_word)
    str_log = str(str_log)[:-1] # cut of the last space char (" ") and replace in (";")
    if str_log[-1] != ";":
        str_log+=";"
    str_log+="\n-- start address = " + start_addr +"\nEND;\n"
    
    str_final = str_begin + str_log
    print(str_final)
    
    with open(f_out, 'w') as fw:
        fw.write(str_final)
    
    return 

def main():
    if len(sys.argv) < 4:
        print ('Usage: hex2mif  input.sv  output.mif  data_offset_address\n')
        print ('     * data_offset_address - send hex number without 0x prefix')
    else:
        in_ = sys.argv[1]
        out_ = sys.argv[2]
        data_offset = sys.argv[3]
        if not out_.endswith('.mif'):
            print('Output file must be .mif file')
        else:
            convert(in_, out_, data_offset)
            print('Converted ' + in_ + ' to ' + out_ + '.')


    return

if __name__ == "__main__":
    main()