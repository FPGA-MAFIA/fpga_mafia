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
    } > i_mem 

    .rodata : {
        . = ALIGN(4);
        *(.rodata);
        . = ALIGN(4);
        LONG(0); 
    } > global_data

    .data : {  
        . = ALIGN(4);  
        *(.data);  
        *(.sdata);  
        *(.sbss);  
        *(.bss);  
    } > global_data  
}
