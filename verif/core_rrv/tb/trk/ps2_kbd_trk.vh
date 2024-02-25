integer trk_cr_kbd;
initial begin: cr_kbd
    #1
    trk_cr_kbd = $fopen({"../../../target/core_rrv/tests/",test_name,"/trk_cr_kbd.log"},"w");
    $fwrite(trk_cr_kbd,"--------------------------------------------------------------\n");
    $fwrite(trk_cr_kbd,"time \t    | CR_KBD_SCANF_EN\t| CR_KBD_READY\t| CR_KBD_DATA\t|\n");
    $fwrite(trk_cr_kbd,"--------------------------------------------------------------\n");  

end

always @(posedge Clk) begin : cr_kbd_print
        $fwrite(trk_cr_kbd,"%t \t |%8h \t         |%8h \t   |%8h \t \n", $time,
        core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en, 
        core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_ready,
        core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_data 
);
end