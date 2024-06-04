// wait until we see CR of the "scanf" ready for readingE

delay(5);
$display("TIME: %t,waiting for CR to be ready for reading", $time);
$display("big_core_cachel1_top.big_core_cachel1_mem_wrap.big_core_cachel1_cr_mem.kbd_cr.kbd_scanf_en = %d", big_core_cachel1_top.big_core_cachel1_mem_wrap.big_core_cachel1_cr_mem.kbd_cr.kbd_scanf_en);
while (!big_core_cachel1_top.big_core_cachel1_mem_wrap.big_core_cachel1_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
$display("TIME: %t, CR is ready for reading", $time);

// sending string imitating the keyboard input
send_string("5");

// wait until we see CR of the "scanf" ready for reading
while (!big_core_cachel1_top.big_core_cachel1_mem_wrap.big_core_cachel1_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
$display("TIME: %t, CR is ready for reading", $time);

// sending string imitating the keyboard input
send_string("7");

