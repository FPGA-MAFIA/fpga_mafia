// wait until we see CR of the "scanf" ready for reading

delay(5);
$display("TIME: %t,waiting for CR to be ready for reading", $time);
$display("core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en = %d", core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en);
while (!core_rrv_top.core_rrv_mem_wrap.core_rrv_cr_mem.kbd_cr.kbd_scanf_en) begin
    $display("not ready");
    delay(5); 
end
$display("TIME: %t, CR is ready for reading", $time);

// sending "W"
$display("TIME: %t, sending first the key 'W' to the PS2", $time);
send_byte_to_ps2(.data(8'h1d)); //pressing the key "w"
$display("TIME: %t, sending release of the key 'W' to the PS2", $time);
send_byte_to_ps2(.data(8'hF0)); //releasing
$display("TIME: %t, sending 'W' to the PS2", $time);
send_byte_to_ps2(.data(8'h1d)); //the realesed key "W"

// sending "ENTER"
$display("TIME: %t, sending  'ENTER' to the PS2", $time);
send_byte_to_ps2(.data(8'h5a)); //pressing the key "ENTER"
$display("TIME: %t, sending release of the key 'ENTER' to the PS2", $time);
send_byte_to_ps2(.data(8'hF0)); //releasing
$display("TIME: %t, sending 'ENETR' to the PS2", $time);
send_byte_to_ps2(.data(8'h5a)); //the realesed key "ENTER"


// NOTE we must send "enter" to the PS2 to make the "scanf" function to return
// FIXME -> missing the code to send "enter" to the PS2 (\n)