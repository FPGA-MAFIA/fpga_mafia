    MEMORY {  
        i_mem          : ORIGIN = 0x00000000 , LENGTH = 0x4000  
        global_data    : ORIGIN = 0x00004000 , LENGTH = 0x4000  
    }  
    SECTIONS {  
        .text : {  
        . = ALIGN(4);  
        *(.start);  
        *(.text);  
        . = ORIGIN(i_mem) + LENGTH(i_mem) - 1;  
        BYTE(0);  
    }  > i_mem  
        .data : {  
        . = ALIGN(4);  
        *(.rodata);  
        *(.sdata);  
        *(.sbss);  
        } > global_data  
        .bss : {} > global_data  
    }  
