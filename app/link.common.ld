    

    MEMORY {  
        i_mem          : ORIGIN = I_MEM_OFFSET , LENGTH = I_MEM_LENGTH  
        global_data    : ORIGIN = D_MEM_OFFSET , LENGTH = D_MEM_LENGTH  
    }  


_stack_start   = ORIGIN(global_data) + LENGTH(global_data);

    SECTIONS {  
        .text : {  
        . = ALIGN(4);  
        *(.start);  
        *(.text);  
    }  > i_mem  
        .data : {  
        . = ALIGN(4);  
        *(.rodata);  
        *(.sdata);  
        *(.sbss);  
        } > global_data  
        .bss : {} > global_data  
    }  