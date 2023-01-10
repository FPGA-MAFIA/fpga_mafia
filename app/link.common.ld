    MEMORY {  
        i_mem          : ORIGIN = %I_MEM_ORIGIN , LENGTH = 0x2000  
        global_data    : ORIGIN = 0x00002000 , LENGTH = 0x2000  
    }  


_stack_start   = ORIGIN(global_data) + LENGTH(global_data);

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