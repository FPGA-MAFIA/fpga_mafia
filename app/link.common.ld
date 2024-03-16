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
        LONG(0); /* Pad the last word to 32 bits if necessary*/
    } > global_data

    .data : {  
        . = ALIGN(4);  
        *(.data);  
        LONG(0); /* Pad the last word to 32 bits if necessary*/
        *(.sdata);  
        LONG(0); /* Pad the last word to 32 bits if necessary*/
        *(.sbss);  
        LONG(0); /* Pad the last word to 32 bits if necessary*/
        *(.bss);  
        LONG(0); /* Pad the last word to 32 bits if necessary*/
    } > global_data  
}
