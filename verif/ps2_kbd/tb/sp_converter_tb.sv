//-----------------------------------------------------------------------------
// Title            : Serial to paraller PS2 data converter tb
// Project          : PS2 keyboard
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Created          : 2/2024
//-----------------------------------------------------------------------------
// Description :
// Converts  serial data bits comes from PS2 into parallel 8 bits
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------


module sp_converter_tb();
 
    logic Rst, KbdClk, KbdSerialData, ParallelDataReady;
    logic [7:0]  ParallelData;
    logic [10:0] packetW;
    logic [10:0] packetRelease;
    
    assign packetW = 11'h23a;
    assign packetRelease = 11'h7e0;
    
    // ========================
    // clock gen
    // ========================
    initial begin: clock_gen
    forever begin
         #5 KbdClk = 1'b0;
         #5 KbdClk = 1'b1;
    end //forever
    end//initial clock_gen

    // ========================
    // reset generation
    // ========================
    initial begin: reset_gen
         Rst = 1'b1;
    #50  Rst = 1'b0;
    end: reset_gen
    
    sp_converter sp_converter(
        .Rst(Rst),
        .KbdClk(KbdClk),
        .KbdSerialData(KbdSerialData),
        .ParallelData(ParallelData),
        .ParallelDataReady(ParallelDataReady)    
    );
    
    initial begin : main
        
        // transfering 0x23A 'w'
        $display("The tranfered packet is %1h", packetW);

        #50 KbdSerialData <= packetW[0];
        
        #10 KbdSerialData <= packetW[1];
        
        #10 KbdSerialData <= packetW[2];
        
        #10 KbdSerialData <= packetW[3];
        
        #10 KbdSerialData <= packetW[4];

        #10 KbdSerialData <= packetW[5];
        
        #10 KbdSerialData <= packetW[6];
 
        #10 KbdSerialData <= packetW[7];

        #10 KbdSerialData <= packetW[8];
 
        #10 KbdSerialData <= packetW[9];

        #10 KbdSerialData <= packetW[10];

        wait(ParallelDataReady) begin
            if(ParallelData == 8'h00011101)
                $display("recieve w");
            else 
                $display("error is recieving w");
            
        end    
        // transfering 0x7E0 'release key'
        $display("The tranfered packet is %1h", packetRelease);

        #10 KbdSerialData <= packetRelease[0];
        
        #10 KbdSerialData <= packetRelease[1];

        #10 KbdSerialData <= packetRelease[2];

        #10 KbdSerialData <= packetRelease[3];
 
        #10 KbdSerialData <= packetRelease[4];
   
        #10 KbdSerialData <= packetRelease[5];
        
        #10 KbdSerialData <= packetRelease[6];
    
        #10 KbdSerialData <= packetRelease[7];
      
        #10 KbdSerialData <= packetRelease[8];
        
        #10 KbdSerialData <= packetRelease[9];
    
        #10 KbdSerialData <= packetRelease[10];

        wait(ParallelDataReady) begin
            if(ParallelData == 8'h11110000) begin
                $display("recieve release Key");
            end
            else 
                $display("error is recieving release Key");
            
        end 
        $display("Test has finished");

        $finish();
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


        
                               
