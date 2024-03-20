module mini_core_rrv_alu_tb;
import mini_core_rrv_pkg::*;

    logic         Clock;    
    logic         Rst;
    var t_ctrl_alu Ctrl;
    logic [31:0]  AluOutQ102H, AluOutQ101H;
    logic         BranchCondMetQ101H;


    initial begin: clock_gen
        forever begin
            #5 Clock = 1'b0;
            #5 Clock = 1'b1;
        end

    end

    mini_core_rrv_alu mini_core_rrv_alu
    ( .Clock(Clock),
      .Rst(Rst),
      .PcQ101H    (),
      .Ctrl(Ctrl),
      .AluOutQ101H(AluOutQ101H),
      .AluOutQ102H(AluOutQ102H),
      .BranchCondMetQ101H(BranchCondMetQ101H),
      .PcQ102H           ()      
    );

    initial begin: main
       Ctrl.AluIn1Q101H = 32'h5;
       Ctrl.AluIn2Q101H = 32'h3;
       Ctrl.AluOpQ101H = ADD;
       #20
       $display("AluOutQ102H = %h", AluOutQ102H);
       
       Ctrl.AluOpQ101H = SUB;
       #20
       $display("AluOutQ102H = %h", AluOutQ102H);
       
       Ctrl.AluOpQ101H = SLT;
       #20
       $display("AluOutQ102H = %h", AluOutQ102H);
       
       Ctrl.AluOpQ101H = SLTU;
       #20
       $display("AluOutQ102H = %h", AluOutQ102H);
       
       Ctrl.AluOpQ101H = SLL;
       #20
       $display("AluOutQ102H = %h", AluOutQ102H);

       $finish;

    end

    parameter V_TIMEOUT = 100000;
    initial begin: time_out_detection
        #V_TIMEOUT
        $display("reached time_out");
        $finish;
    end


endmodule

