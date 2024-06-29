module big_core_kbd_test(
    input  logic MAX10_CLK1_50,
    input  logic Rst,         // not neccessary at all
    input  logic KbdClockIn,  // recieved clock from keyboard
    input  logic KbdDataIn,   // recieved data from keyboard
    
    /*
    when inputs are not connected the synthesizer ignores them
    this is the reason why we make a naive assign just to capture
    them in signal tapping
    */
    output logic Clock25Khz,
    output logic KbdClockOut,
    output logic KbdDataOut
);

    assign KbdClockOut = (Rst) ? KbdClockIn : 1'b0;
    assign KbdDataOut  = (Rst) ? KbdDataIn  : 1'b0;

// we use pll to create slower clock to capture keyboard signals in signal tapping
pll	pll_inst (
	.areset (),
	.inclk0 ( MAX10_CLK1_50 ),
	.c0 ( Clock25Khz ),
	.locked ()
	);


endmodule

