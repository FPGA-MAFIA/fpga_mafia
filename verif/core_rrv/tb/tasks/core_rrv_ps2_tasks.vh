

// systemverilog file to create the task needed for driving the PS2 interface of the Core DUT
// will have a simple task that accepts a byte and sends it to the PS2 interface (clock and data lines)

task send_byte_to_ps2 (input logic [7:0] data);
    $display("code: %1h", data);
    #10;
    // Clock for release
    //Start bit
    #40 ps2_data = 1'b0;// 40
    #10 ps2_clk = 1'b0;// 50
    #50 ps2_clk = 1'b1;// 100
    // bit[0]
    #40 ps2_data = data[0];//140
    #10 ps2_clk = 1'b0;// 150
    #50 ps2_clk = 1'b1;// 200
    // bit[1]
    #40 ps2_data = data[1];// 240
    #10 ps2_clk = 1'b0;// 250
    #50 ps2_clk = 1'b1;// 300
    // bit[2]
    #40 ps2_data = data[2];// 340
    #10 ps2_clk = 1'b0;// 350
    #50 ps2_clk = 1'b1;// 400
    // bit[3]
    #40 ps2_data = data[3];// 440
    #10 ps2_clk = 1'b0;// 450
    #50 ps2_clk = 1'b1;// 500
    // bit[4]
    #40 ps2_data = data[4];//540
    #10 ps2_clk = 1'b0;// 550
    #50 ps2_clk = 1'b1;// 600
    // bit[5]
    #40 ps2_data = data[5];// 640
    #10 ps2_clk = 1'b0;// 650
    #50 ps2_clk = 1'b1;// 700
    // bit[6]
    #40 ps2_data = data[6];//740
    #10 ps2_clk = 1'b0;// 750
    #50 ps2_clk = 1'b1;// 800
    // bit[7]
    #40 ps2_data = data[7];//840
    #10 ps2_clk = 1'b0;// 850
    #50 ps2_clk = 1'b1;// 900
    // Parity bit
    #40 ps2_data = !(data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);//940
    #10 ps2_clk = 1'b0;// 950
    #50 ps2_clk = 1'b1;// 1000
    // Stop bit
    #40 ps2_data = 1'b1;//1040
    #10 ps2_clk = 1'b0;// 1050
    #50 ps2_clk = 1'b1;// 1100
    #300;
endtask


task send_symbol_unshifted(input logic [7:0] scan_code_kbd);
    send_byte_to_ps2(.data(scan_code_kbd));
    send_byte_to_ps2(.data(RELEASE_CODE)); //releasing
    send_byte_to_ps2(.data(scan_code_kbd)); 
endtask

// for example: consider we want to send the letter 'W' to the PS2 interface
// LEFT_SHIFT - 0x12
// 'W' - 0x1D
// RELEASE_CODE - 0xF0
// 'W' - 0x1D
// RELEASE_CODE - 0xF0
// LEFT_SHIFT - 0x12
task send_symbol_shifted(input logic [7:0] scan_code_kbd);
    send_byte_to_ps2(.data(LEFT_SHIFT_CODE));
    send_byte_to_ps2(.data(scan_code_kbd)); 
    send_byte_to_ps2(.data(RELEASE_CODE)); //releasing
    send_byte_to_ps2(.data(scan_code_kbd));
    send_byte_to_ps2(.data(RELEASE_CODE)); //releasing
    send_byte_to_ps2(.data(LEFT_SHIFT_CODE));
endtask

// Task to convert char to scan code
task get_scan_code(input string key);
    begin
        case(key)
            // Map each character to its corresponding scan code
            "ESC"         :      scan_code = 8'h76;
            "F1"          :      scan_code = 8'h05;
            "F2"          :      scan_code = 8'h06;
            "F3"          :      scan_code = 8'h04;
            "F4"          :      scan_code = 8'h0C;
            "F5"          :      scan_code = 8'h03;
            "F6"          :      scan_code = 8'h0B;
            "F7"          :      scan_code = 8'h83;
            "F8"          :      scan_code = 8'h0A;
            "F9"          :      scan_code = 8'h01;
            "F10"         :      scan_code = 8'h09;
            "F11"         :      scan_code = 8'h78;
            "F12"         :      scan_code = 8'h07;
            "TICK"        :      scan_code = 8'h0E; // `
            "ONE"         :      scan_code = 8'h16; 
            "TWO"         :      scan_code = 8'h1E;
            "THREE"       :      scan_code = 8'h26;
            "FOUR"        :      scan_code = 8'h25;
            "FIVE"        :      scan_code = 8'h2E;
            "SIX"         :      scan_code = 8'h36;
            "SEVEN"       :      scan_code = 8'h3D;
            "EIGHT"       :      scan_code = 8'h3E;
            "NINE"        :      scan_code = 8'h46;
            "ZERO"        :      scan_code = 8'h45;
            "HYPHEN"      :      scan_code = 8'h4E; // -
            "EQUAL"       :      scan_code = 8'h55;
            "BACKSPACE"   :      scan_code = 8'h66; // =
            "TAB"         :      scan_code = 8'h0D;
            "Q"           :      scan_code = 8'h15;
            "W"           :      scan_code = 8'h1D;
            "E"           :      scan_code = 8'h24;
            "R"           :      scan_code = 8'h2D;
            "T"           :      scan_code = 8'h2C;
            "Y"           :      scan_code = 8'h35;
            "U"           :      scan_code = 8'h3C;
            "I"           :      scan_code = 8'h43;
            "O"           :      scan_code = 8'h44;
            "P"           :      scan_code = 8'h4D;
            "LSBR"        :      scan_code = 8'h54;  // left square bracket [
            "RSBR"        :      scan_code = 8'h5B;  // right square bracket ]
            "BACKSLASH"   :      scan_code = 8'h5D;   // \
            "CAPSLOCK"    :      scan_code = 8'h58;
            "A"           :      scan_code = 8'h1C;
            "S"           :      scan_code = 8'h1B;
            "D"           :      scan_code = 8'h23;
            "F"           :      scan_code = 8'h2B;
            "G"           :      scan_code = 8'h34;
            "H"           :      scan_code = 8'h33;
            "J"           :      scan_code = 8'h3B;
            "K"           :      scan_code = 8'h42;
            "L"           :      scan_code = 8'h4B;
            "SEMICOLON"   :      scan_code = 8'h4C;  // ;
            "APOSTROPHE"  :      scan_code = 8'h52;  // '
            "ENTER"       :      scan_code = 8'h5A;
            "LSHIFT"      :      scan_code = 8'h12;
            "Z"           :      scan_code = 8'h1A;
            "X"           :      scan_code = 8'h22;
            "C"           :      scan_code = 8'h21;
            "V"           :      scan_code = 8'h2A;
            "B"           :      scan_code = 8'h32;
            "N"           :      scan_code = 8'h31;
            "M"           :      scan_code = 8'h3A;
           "COMMA"        :      scan_code = 8'h41;  // ;
           "DOT"          :      scan_code = 8'h49;  // .
            "SLASH"       :      scan_code = 8'h4A;  // /
            "RSHIFT"      :      scan_code = 8'h59;  // right shift
            "LCTRL"       :      scan_code = 8'h14;  // left control
            "LALT"        :      scan_code = 8'h11;  // left alt
            "SPACE"       :      scan_code = 8'h29;
            default       :      scan_code = 8'h00; // You might use a special value to indicate an unsupported character
        endcase
    end
endtask



task send_char(input char str);
    begin
        case(str)
            // Unshifted characters
            "a" : send_symbol_unshifted(8'h1C);
            "b" : send_symbol_unshifted(8'h32);
            "c" : send_symbol_unshifted(8'h21);
            "d" : send_symbol_unshifted(8'h23);
            //...
            "z" : send_symbol_unshifted(8'h2A);
            // Shifted characters
            "A" : send_symbol_shifted(8'h1C);
            "B" : send_symbol_shifted(8'h32);
            "C" : send_symbol_shifted(8'h21);
            "D" : send_symbol_shifted(8'h23);
            //...
            "Z" : send_symbol_shifted(8'h2A);
            default: $display("Unsupported character");
        endcase
    end
endtask

