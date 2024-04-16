 // to run that TB please time
 // ./build.py -dut mini_core_rrv -top mini_core_rrv_rf_tb -hw -sim -gui &

module mini_core_rrv_rf_tb;
import mini_core_rrv_pkg::*;

    logic Clock;
    logic Rst;
    var t_ctrl_rf Ctrl;
    logic [31:0]  PcQ101H;
    logic [31:0]  RegWrDataQ102H;
    logic [31:0]  RegRdData1Q101H;
    logic [31:0]  RegRdData2Q101H;



    initial begin: clock_gen
            forever begin
                #5 Clock = 1'b0;
                #5 Clock = 1'b1;
            end

    end

    mini_core_rrv_rf #(.RF_NUM_MSB(RF_NUM_MSB)) 
    mini_core_rrv_rf (
    .Clock(Clock), 
    .Rst(Rst),
    .Ctrl(Ctrl),
    .PcQ101H(PcQ101H),
    .RegWrDataQ102H(RegWrDataQ102H),
    .RegRdData1Q101H(RegRdData1Q101H),
    .RegRdData2Q101H(RegRdData2Q101H)
    );

    initial begin: main 
        // write to register file
        Rst = 1'b1;
        #20
        
        Rst = 1'b0;
        Ctrl.RegWrEnQ102H = 1'b1;
        RegWrDataQ102H    = 32'h5;
        Ctrl.RegDstQ102H  = 5'h0;
        #20
        Ctrl.RegDstQ102H  = 5'h1;
        #20
        Ctrl.RegDstQ102H  = 5'h2;
        #20
        Ctrl.RegDstQ102H  = 5'h3;
        #20
        Ctrl.RegDstQ102H  = 5'h4;
        #20
        Ctrl.RegDstQ102H  = 5'h5;
        #20

        // read from register file
        Ctrl.RegWrEnQ102H = 1'b0;
        Ctrl.RegSrc1Q101H = 32'h0;
        Ctrl.RegSrc2Q101H = 32'h0;
        #20
        Ctrl.RegSrc1Q101H = 32'h1;
        Ctrl.RegSrc2Q101H = 32'h0;
        #20
        Ctrl.RegSrc1Q101H = 32'h1;
        Ctrl.RegSrc2Q101H = 32'h2;
        #20

        $finish;

    end

    parameter V_TIMEOUT = 100000;
    initial begin: time_out_detection
        #V_TIMEOUT
        $display("reached time_out");
        $finish;
    end

endmodule


