

// systemverilog file to create the task needed for driving the PS2 interface of the Core DUT
// will have a simple task that accepts a byte and sends it to the PS2 interface (clock and data lines)

task send_byte_to_ps2 (input logic [7:0] data);
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


task send_symbol_unshifted(input logic [7:0] scan_code);
    send_byte_to_ps2(.data(scan_code));
    send_byte_to_ps2(.data(RELEASE_CODE)); //releasing
    send_byte_to_ps2(.data(scan_code));
endtask

// for example: consider we want to send the letter 'W' to the PS2 interface
// LEFT_SHIFT - 0x12
// 'W' - 0x1D
// RELEASE_CODE - 0xF0
// 'W' - 0x1D
// RELEASE_CODE - 0xF0
// LEFT_SHIFT - 0x12
task send_symbol_shifted(input logic [7:0] scan_code);
    send_byte_to_ps2(.data(LEFT_SHIFT_CODE));
    send_byte_to_ps2(.data(scan_code)); 
    send_byte_to_ps2(.data(RELEASE_CODE)); //releasing
    send_byte_to_ps2(.data(scan_code));
    send_byte_to_ps2(.data(RELEASE_CODE)); //releasing
    send_byte_to_ps2(.data(LEFT_SHIFT_CODE));
endtask

task send_char(input byte str);
    begin
        case(str)
            // Unshifted characters
            "a" : send_symbol_unshifted(8'h1C);
            "b" : send_symbol_unshifted(8'h32);
            "c" : send_symbol_unshifted(8'h21);
            "d" : send_symbol_unshifted(8'h23);
            "e" : send_symbol_unshifted(8'h24);
            "f" : send_symbol_unshifted(8'h2B);
            "g" : send_symbol_unshifted(8'h34);
            "h" : send_symbol_unshifted(8'h33);
            "i" : send_symbol_unshifted(8'h43);
            "j" : send_symbol_unshifted(8'h3B);
            "k" : send_symbol_unshifted(8'h42);
            "l" : send_symbol_unshifted(8'h4B);
            "m" : send_symbol_unshifted(8'h3A);
            "n" : send_symbol_unshifted(8'h31);
            "o" : send_symbol_unshifted(8'h44);
            "p" : send_symbol_unshifted(8'h4D);
            "q" : send_symbol_unshifted(8'h15);
            "r" : send_symbol_unshifted(8'h2D);
            "s" : send_symbol_unshifted(8'h1B);
            "t" : send_symbol_unshifted(8'h2C);
            "u" : send_symbol_unshifted(8'h3C);
            "v" : send_symbol_unshifted(8'h2A);
            "w" : send_symbol_unshifted(8'h1D);
            "x" : send_symbol_unshifted(8'h22);
            "y" : send_symbol_unshifted(8'h35);
            "z" : send_symbol_unshifted(8'h1A);
            // Shifted characters
            "A" : send_symbol_shifted(8'h1C);
            "B" : send_symbol_shifted(8'h32);
            "C" : send_symbol_shifted(8'h21);
            "D" : send_symbol_shifted(8'h23);
            "E" : send_symbol_shifted(8'h24);
            "F" : send_symbol_shifted(8'h2B);
            "G" : send_symbol_shifted(8'h34);
            "H" : send_symbol_shifted(8'h33);
            "I" : send_symbol_shifted(8'h43);
            "J" : send_symbol_shifted(8'h3B);
            "K" : send_symbol_shifted(8'h42);
            "L" : send_symbol_shifted(8'h4B);
            "M" : send_symbol_shifted(8'h3A);
            "N" : send_symbol_shifted(8'h31);
            "O" : send_symbol_shifted(8'h44);
            "P" : send_symbol_shifted(8'h4D);
            "Q" : send_symbol_shifted(8'h15);
            "R" : send_symbol_shifted(8'h2D);
            "S" : send_symbol_shifted(8'h1B);
            "T" : send_symbol_shifted(8'h2C);
            "U" : send_symbol_shifted(8'h3C);
            "V" : send_symbol_shifted(8'h2A);
            "W" : send_symbol_shifted(8'h1D);
            "X" : send_symbol_shifted(8'h22);
            "Y" : send_symbol_shifted(8'h35);
            "Z" : send_symbol_shifted(8'h1A);
            // numbers
            "0" : send_symbol_unshifted(8'h45);
            "1" : send_symbol_unshifted(8'h16);
            "2" : send_symbol_unshifted(8'h1E);
            "3" : send_symbol_unshifted(8'h26);
            "4" : send_symbol_unshifted(8'h25);
            "5" : send_symbol_unshifted(8'h2E);
            "6" : send_symbol_unshifted(8'h36);
            "7" : send_symbol_unshifted(8'h3D);
            "8" : send_symbol_unshifted(8'h3E);
            "9" : send_symbol_unshifted(8'h46);
            // UnShifted special characters
            " " : send_symbol_unshifted(8'h29);
            "." : send_symbol_unshifted(8'h49);
            "," : send_symbol_unshifted(8'h41);
            ";" : send_symbol_unshifted(8'h4C);
            "[" : send_symbol_unshifted(8'h54);
            "]" : send_symbol_unshifted(8'h5B);
            "=" : send_symbol_unshifted(8'h55);            
            "-" : send_symbol_unshifted(8'h4E);
            "\\": send_symbol_unshifted(8'h5D);
            "'" : send_symbol_unshifted(8'h52);
            "`" : send_symbol_unshifted(8'h0E);
            // Shifted special characters
            "\%": send_symbol_shifted(8'h2E);
            "!" : send_symbol_shifted(8'h16);
            "@" : send_symbol_shifted(8'h1E);
            "#" : send_symbol_shifted(8'h26);
            "$" : send_symbol_shifted(8'h25);
            "^" : send_symbol_shifted(8'h36);
            "&" : send_symbol_shifted(8'h3D);
            "*" : send_symbol_shifted(8'h3E);
            "(" : send_symbol_shifted(8'h46);
            ")" : send_symbol_shifted(8'h45);
            "{" : send_symbol_shifted(8'h54);
            "}" : send_symbol_shifted(8'h5B);
            "+" : send_symbol_shifted(8'h55);
            "_" : send_symbol_shifted(8'h4E);
            "|" : send_symbol_shifted(8'h5D);
            "\"": send_symbol_shifted(8'h52);


            default: $display("Unsupported character");
        endcase
    end
endtask

task send_string(input string str);
    begin
        for(int i=0; i<str.len(); i++) begin
            send_char(str[i]);
        end
        send_byte_to_ps2(.data(ENTER_CODE));
    end
endtask



task send_string_with_long_shift(input string str);
    begin
        //Send shift byte
        send_byte_to_ps2(.data(LEFT_SHIFT_CODE));
        //Send the string (May be all lower case - but the Shift should be set)
        for(int i=0; i<str.len(); i++) begin
            send_char(str[i]);
        end
        //release the shift
        send_byte_to_ps2(.data(RELEASE_CODE));
        send_byte_to_ps2(.data(LEFT_SHIFT_CODE));
        //press enter
        send_byte_to_ps2(.data(ENTER_CODE));
    end
endtask
