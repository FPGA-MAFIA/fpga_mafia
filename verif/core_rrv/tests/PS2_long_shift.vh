// wait until we see CR of the "scanf" ready for readingE

delay(5);
$display("TIME: %t,waiting for CR to be ready for reading", $time);
$display("core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en = %d", core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en);
while (!core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
$display("TIME: %t, CR is ready for reading", $time);

// sending string imitating the keyboard input
send_string("low-case");
while (!core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
//Usiing the long_shift - expecting to print APPER
send_string_with_long_shift("upper-case");

while (!core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
