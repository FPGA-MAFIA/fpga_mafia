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
//send_byte_to_ps2(.data(8'h1d)); //pressing the key "w"
//send_byte_to_ps2(.data(8'hF0)); //releasing
//send_byte_to_ps2(.data(8'h1d)); //the realesed key "W"
//char keymap_shifted[256] = {
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '~', '?', // 0x00 - 0x0F
//    '?', '?', '?', '?', '?', 'Q', '!', '?', '?', '?', 'Z', 'S', 'A', 'W', '@', '?', // 0x10 - 0x1F
//    '?', 'C', 'X', 'D', 'E', '#', '$', '?', '?', 'V', 'F', 'T', 'R', '%', '?', '?', // 0x20 - 0x2F
//    '?', 'N', 'B', 'H', 'G', 'Y', '^', '?', '?', '?', 'M', 'J', 'U', '&', '*', '?', // 0x30 - 0x3F
//    '?', '?', '<', 'K', 'I', 'O', ')', '(', '?', '?', '>', '?', 'L', ':', 'P', '_', // 0x40 - 0x4F
//    '?', '?', '"', '?', '{', '+', '?', '?', '?', '?', '?', '}', '?', '|', '?', '?', // 0x50 - 0x5F
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '1', '?', '4', '7', '?', '?', '?', // 0x60 - 0x6F
//    '0', '.', '2', '5', '6', '8', '?', '?', '?', '+', '3', '-', '*', '9', '?', '?', // 0x70 - 0x7F
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0x80 - 0x8F
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0x90 - 0x9F
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xA0 - 0xAF
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xB0 - 0xBF
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xC0 - 0xCF
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xD0 - 0xDF
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', // 0xE0 - 0xEF
//    '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?'  // 0xF0 - 0xFF
//};
// sending "H"
send_byte_to_ps2(.data(8'h33)); //pressing the key "h"
send_byte_to_ps2(.data(8'hF0)); //releasing
send_byte_to_ps2(.data(8'h33)); //pressing the key "h"

// sending "E"
send_byte_to_ps2(.data(8'h24)); //pressing the key "e"
send_byte_to_ps2(.data(8'hF0)); //releasing
send_byte_to_ps2(.data(8'h24)); //pressing the key "e"

// sending "L"
send_byte_to_ps2(.data(8'h4C)); //pressing the key "l"
send_byte_to_ps2(.data(8'hF0)); //releasing
send_byte_to_ps2(.data(8'h4C)); //pressing the key "l"

// sending "L"
send_byte_to_ps2(.data(8'h4C)); //pressing the key "l"
send_byte_to_ps2(.data(8'hF0)); //releasing
send_byte_to_ps2(.data(8'h4C)); //pressing the key "l"

// sending "O"
send_byte_to_ps2(.data(8'h45)); //pressing the key "o"
send_byte_to_ps2(.data(8'hF0)); //releasing
send_byte_to_ps2(.data(8'h45)); //pressing the key "o"


// sending "ENTER"
send_byte_to_ps2(.data(8'h5a)); //pressing the key "ENTER"
send_byte_to_ps2(.data(8'hF0)); //releasing
send_byte_to_ps2(.data(8'h5a)); //the realesed key "ENTER"


// NOTE we must send "enter" to the PS2 to make the "scanf" function to return
// FIXME -> missing the code to send "enter" to the PS2 (\n)