MEMORY {  
    i_mem          : ORIGIN = I_MEM_OFFSET , LENGTH = I_MEM_LENGTH  
    global_data    : ORIGIN = D_MEM_OFFSET , LENGTH = D_MEM_LENGTH  
}

_stack_start   = ORIGIN(global_data) + LENGTH(global_data);

SECTIONS {  
    /* Code section loaded into instruction memory */
    .text : {  
        . = ALIGN(4);  
        *(.start);  
        *(.text);  
    } > i_mem 

    /* Read-Only Data loaded into global_data (RAM) */
    .rodata : {
        . = ALIGN(4);
        *(.rodata);
        . = ALIGN(4);
        LONG(0); /* Pad the last word to 32 bits if necessary */
    } > global_data

    /* Initialized Data section directly in global_data */
    .data : {  
        . = ALIGN(4);  
        *(.data);  
        LONG(0); /* Pad the last word to 32 bits if necessary */
        *(.sdata);  
        LONG(0); /* Pad the last word to 32 bits if necessary */
    } > global_data  

    /* Uninitialized Small Data section (.sbss) */
    .sbss (NOLOAD) : {  
        . = ALIGN(4);
        __sbss_start = .;          /* Start of .sbss */
        *(.sbss);  
        __sbss_end = .;            /* End of .sbss */
    } > global_data  

    /* Uninitialized Data section (.bss) */
    .bss (NOLOAD) : {  
        . = ALIGN(4);
        __bss_start = .;           /* Start of .bss */
        *(.bss);  
        __bss_end = .;             /* End of .bss */
    } > global_data  
}
