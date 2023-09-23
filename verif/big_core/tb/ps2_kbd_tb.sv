//-----------------------------------------------------------------------------
// Title            : big_core tb
// Project          : 7 stages core
//-----------------------------------------------------------------------------
// File             : big_core_tb.sv
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Created          : 11/2022
//-----------------------------------------------------------------------------
// Description :
// simple test bench
// (1) generate the clock & rst. 
// (2) load backdoor the I_MEM & D_MEM.
// (3) End the test when the ebrake command is executed
//-----------------------------------------------------------------------------

`include "macros.sv"
module ps2_kbd_tb ;


logic Rst;
logic kbd_clk;
logic data_in;
logic core_clk;
logic valid;
logic [7:0] data_out;
logic error;
logic extension;

//create clock free running:
initial begin : free_running_core_clk
    core_clk = 1'b1;
    forever #1 core_clk = ~core_clk;
end
initial begin : reset
    Rst = 1'b1;
    #50 Rst = 1'b0;
end
initial begin : naive_clk_gen
         kbd_clk = 1'b1;//0
    #5   kbd_clk = 1'b0;//5
    #5   kbd_clk = 1'b1;//10
    #90 kbd_clk = 1'b1;//100
    // Clock for any word
    #5   kbd_clk = 1'b0;//105
    #5   kbd_clk = 1'b1;//110
    #5   kbd_clk = 1'b0;//115
    #5   kbd_clk = 1'b1;//120
    #5   kbd_clk = 1'b0;//125
    #5   kbd_clk = 1'b1;//130
    #5   kbd_clk = 1'b0;//135
    #5   kbd_clk = 1'b1;//140
    #5   kbd_clk = 1'b0;//145
    #5   kbd_clk = 1'b1;//150
    #5   kbd_clk = 1'b0;//155
    #5   kbd_clk = 1'b1;//160
    #5   kbd_clk = 1'b0;//165
    #5   kbd_clk = 1'b1;//170
    #5   kbd_clk = 1'b0;//175
    #5   kbd_clk = 1'b1;//180
    #5   kbd_clk = 1'b0;//185
    #5   kbd_clk = 1'b1;//190
    #5   kbd_clk = 1'b0;//195
    #5   kbd_clk = 1'b1;//200
    #5   kbd_clk = 1'b0;//205
    #5   kbd_clk = 1'b1;//210
    #90                 //300
    // Clock for release
    #5   kbd_clk = 1'b0;//305
    #5   kbd_clk = 1'b1;//310
    #5   kbd_clk = 1'b0;//315
    #5   kbd_clk = 1'b1;//320
    #5   kbd_clk = 1'b0;//325
    #5   kbd_clk = 1'b1;//330
    #5   kbd_clk = 1'b0;//335
    #5   kbd_clk = 1'b1;//340
    #5   kbd_clk = 1'b0;//345
    #5   kbd_clk = 1'b1;//350
    #5   kbd_clk = 1'b0;//355
    #5   kbd_clk = 1'b1;//360
    #5   kbd_clk = 1'b0;//365
    #5   kbd_clk = 1'b1;//370
    #5   kbd_clk = 1'b0;//375
    #5   kbd_clk = 1'b1;//380
    #5   kbd_clk = 1'b0;//385
    #5   kbd_clk = 1'b1;//390
    #5   kbd_clk = 1'b0;//395
    #5   kbd_clk = 1'b1;//400
    #5   kbd_clk = 1'b0;//405
    #5   kbd_clk = 1'b1;//410
    #90                ;//500
    // Clock for any word
    #5   kbd_clk = 1'b0;//505
    #5   kbd_clk = 1'b1;//510
    #5   kbd_clk = 1'b0;//515
    #5   kbd_clk = 1'b1;//520
    #5   kbd_clk = 1'b0;//525
    #5   kbd_clk = 1'b1;//530
    #5   kbd_clk = 1'b0;//535
    #5   kbd_clk = 1'b1;//540
    #5   kbd_clk = 1'b0;//545
    #5   kbd_clk = 1'b1;//550
    #5   kbd_clk = 1'b0;//555
    #5   kbd_clk = 1'b1;//560
    #5   kbd_clk = 1'b0;//565
    #5   kbd_clk = 1'b1;//570
    #5   kbd_clk = 1'b0;//575
    #5   kbd_clk = 1'b1;//580
    #5   kbd_clk = 1'b0;//585
    #5   kbd_clk = 1'b1;//590
    #5   kbd_clk = 1'b0;//595
    #5   kbd_clk = 1'b1;//600
    #5   kbd_clk = 1'b0;//605
    #5   kbd_clk = 1'b1;//610
    #90  kbd_clk = 1'b1;//700
    // Clock for any word
    #5   kbd_clk = 1'b0;//705
    #5   kbd_clk = 1'b1;//710
    #5   kbd_clk = 1'b0;//715
    #5   kbd_clk = 1'b1;//720
    #5   kbd_clk = 1'b0;//725
    #5   kbd_clk = 1'b1;//730
    #5   kbd_clk = 1'b0;//735
    #5   kbd_clk = 1'b1;//740
    #5   kbd_clk = 1'b0;//745
    #5   kbd_clk = 1'b1;//750
    #5   kbd_clk = 1'b0;//755
    #5   kbd_clk = 1'b1;//760
    #5   kbd_clk = 1'b0;//765
    #5   kbd_clk = 1'b1;//770
    #5   kbd_clk = 1'b0;//775
    #5   kbd_clk = 1'b1;//780
    #5   kbd_clk = 1'b0;//785
    #5   kbd_clk = 1'b1;//790
    #5   kbd_clk = 1'b0;//795
    #5   kbd_clk = 1'b1;//800
    #5   kbd_clk = 1'b0;//805
    #5   kbd_clk = 1'b1;//810
    #90                ;//900
end

initial begin : naive_data_gen
    data_in = 1'b1;//0
    // "W" Key Code press
    #200               ;
    #102 data_in = 1'b0;//302
    #10  data_in = 1'b1;//312
    #10  data_in = 1'b0;//322
    #10  data_in = 1'b1;//332
    #30  data_in = 1'b0;//362
    #30  data_in = 1'b1;//392
    #108               ;//500
    // "Release" Key Code press
    #2   data_in = 1'b0;//502 - START bit
    #10  data_in = 1'b1;//512 - Data  bits
    #70  data_in = 1'b0;//582 - Odd   bit
    #10  data_in = 1'b0;//592 - Odd   bit
    #10  data_in = 1'b1;//602 - STOP  bit
    #98                ;//700
    // "W" Key Code press again
    #2   data_in = 1'b0;//702
    #10  data_in = 1'b1;//712
    #10  data_in = 1'b0;//722
    #10  data_in = 1'b1;//732
    #30  data_in = 1'b0;//762
    #30  data_in = 1'b1;//792
    #108               ;//900

    $finish;
end

logic scanf_en;
logic core_read_en;
logic data_ready;
initial begin
    #120                ;

    scanf_en = 1'b0     ;
    #40 scanf_en = 1'b1 ;
    #700                ;
    core_read_en = 1'b1 ;
end
big_core_kdb_controller big_core_kdb_controller 
(
 .kbd_clk         (kbd_clk      ), //   input  logic       kbd_clk,
 .data_in_kc      (data_in      ), //   input  logic       data_in,
 //
 .core_clk        (core_clk     ), //   input  logic       core_clk,
 .core_rst        (Rst          ), //   input  logic       Rst, 
 .core_read_en    (core_read_en ), //   input  logic       data_in,
 .data_out        (data_out     ), //   output logic [7:0] data_out, 
 .valid           (valid        ), //   output logic       valid, 
 .extension       (extension    ), //   output logic       extension,
 .error           (error        ), //   output logic       error
 //
 .data_ready      (data_ready), //   output logic       data_ready,
 .scanf_en        (scanf_en  )  //   input  logic       scanf_en   
);



endmodule
