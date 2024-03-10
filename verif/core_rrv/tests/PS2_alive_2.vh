// wait until we see CR of the "scanf" ready for readingE

delay(5);
$display("TIME: %t,waiting for CR to be ready for reading", $time);
$display("core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en = %d", core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en);
while (!core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
$display("TIME: %t, CR is ready for reading", $time);


get_scan_code(.key("H"));
send_symbol_unshifted(.scan_code_kbd(scan_code)); //h
get_scan_code(.key("E")); 
send_symbol_unshifted(.scan_code_kbd(scan_code)); //e
get_scan_code(.key("L")); 
send_symbol_unshifted(.scan_code_kbd(scan_code)); //l
get_scan_code(.key("L")); 
send_symbol_unshifted(.scan_code_kbd(scan_code)); //l
get_scan_code(.key("O")); 
send_symbol_unshifted(.scan_code_kbd(scan_code)); //o
get_scan_code(.key("ENTER"));
send_symbol_unshifted(.scan_code_kbd(scan_code));



send_symbol_shifted("H"); //H
send_symbol_shifted("E"); //E
send_symbol_shifted("L"); //L 
send_symbol_shifted("L"); //L
send_symbol_shifted("O"); //O
send_symbol_shifted("ENTER");

