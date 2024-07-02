`include "macros.vh"
module mini_ex_core_alu_tb;

    import mini_ex_core_pkg::*;

    logic Clock;
    logic Rst;
    t_alu_in AluInputs;
    logic [31:0] AluOutQ102H;


    mini_ex_core_alu mini_ex_core_alu (
     .Clock         (Clock),
     .Rst           (Rst),
     .AluInputs     (AluInputs),
     .AluOutQ102H   (AluOutQ102H)
    );

    //generating clock
    initial begin
        Clock = 0;
        forever #5 Clock = ~Clock;
    end

    //generating clock
    initial begin
        Rst <= 1'b0; //active reset
        //Testing Rst
        AluInputs.RegSrc1Q101H = 32'd4;
        AluInputs.RegSrc2Q101H = 32'd8;
        AluInputs.AluOp        = ADD;
        #20; 

        //ADD
        Rst <= 1'b1; //active reset
        #20;

        //SUB
        AluInputs.AluOp        = SUB;
        //positive
        AluInputs.RegSrc1Q101H = 32'd4;
        AluInputs.RegSrc2Q101H = 32'd8;
        #20;
        $display("SUB POS value %d", AluOutQ102H);

        //negative
        AluInputs.RegSrc1Q101H = 32'd4;
        AluInputs.RegSrc2Q101H = 32'd8;
        #20;
        $display("SUB NEG value %d", AluOutQ102H);

        //SLT
        AluInputs.AluOp        = SLT;
        AluInputs.RegSrc1Q101H = 32'd8;
        AluInputs.RegSrc2Q101H = 32'd4;
        #20;
        AluInputs.RegSrc1Q101H = 32'd4;
        AluInputs.RegSrc2Q101H = 32'd8;
        #20;

        //SLTU
        AluInputs.RegSrc1Q101H = -8;
        AluInputs.RegSrc2Q101H =  4;
        AluInputs.AluOp        = SLTU;
        #20;

        //SLL
        AluInputs.RegSrc1Q101H = 1;
        AluInputs.RegSrc2Q101H = 2;
        AluInputs.AluOp        = SLL;
        #20;

        //SRL
        AluInputs.RegSrc1Q101H = 2;
        AluInputs.RegSrc2Q101H = 1;
        AluInputs.AluOp        = SRL;
        #20;

        //SRA
        AluInputs.RegSrc1Q101H = -2;
        AluInputs.RegSrc2Q101H = 1;
        AluInputs.AluOp        = SRA;
        #20;

        //XOR
        AluInputs.RegSrc1Q101H = 1;
        AluInputs.RegSrc2Q101H = 1;
        AluInputs.AluOp        = XOR;
        #20;

        
        //OR
        AluInputs.RegSrc1Q101H = 1;
        AluInputs.RegSrc2Q101H = 0;
        AluInputs.AluOp        = OR;
        #20;


        //AND
        AluInputs.AluOp        = AND;
        #20;
    end

parameter V_TIMEOUT = 100000;
initial begin: detect_timeout
    //=======================================
    // timeout
    //=======================================
    #V_TIMEOUT 
    $error("test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end


endmodule


