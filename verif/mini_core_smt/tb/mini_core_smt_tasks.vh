// Core -> Cache request
typedef struct packed {
    logic [4:0]   RegDst;   //reg destination
    logic [31:0]  Data;    
    logic [31:0]  Pc;
    logic [31:0]  cur_time;
} t_rf_write_history ;

t_rf_write_history rf_write_history[$];
t_rf_write_history rf_cur_write;
t_rf_write_history ref_rf_write_history[$];
t_rf_write_history ref_rf_cur_write;


logic [31:0] PcQ101H;             // To I_MEM
logic [31:0] PcQ102H;             // To I_MEM
logic [31:0] PcQ103H, PcQ104H;
logic CurrThread;
logic ThreadIDQ101H,ThreadIDQ102H,ThreadIDQ103H,ThreadIDQ104H;
logic ReadyQ100H,ReadyQ101H,ReadyQ102H,ReadyQ103H,ReadyQ104H;
logic ImmediateQ102H, RegRdData1Q102H,RegRdData2Q102H;
assign ReadyQ100H = mini_core_smt_top.mini_core_smt.ReadyQ100H;
//assign ReadyQ101H = mini_core_smt_top.mini_core_smt.ReadyQ101H;
assign ReadyQ102H = mini_core_smt_top.mini_core_smt.ReadyQ102H;
assign ReadyQ103H = mini_core_smt_top.mini_core_smt.ReadyQ103H;
assign ReadyQ104H = mini_core_smt_top.mini_core_smt.ReadyQ104H;

assign CurrThread = mini_core_smt_top.mini_core_smt.CurrThread;
assign ThreadIDQ101H = mini_core_smt_top.mini_core_smt.ThreadIDQ101H;
assign ThreadIDQ102H = mini_core_smt_top.mini_core_smt.ThreadIDQ102H;
assign ThreadIDQ103H = mini_core_smt_top.mini_core_smt.ThreadIDQ103H;
assign ThreadIDQ104H = mini_core_smt_top.mini_core_smt.ThreadIDQ104H;


assign ImmediateQ102H = mini_core_smt_top.mini_core_smt.ImmediateQ102H;
assign RegRdData1Q102H = mini_core_smt_top.mini_core_smt.RegRdData1Q102H;
assign RegRdData2Q102H = mini_core_smt_top.mini_core_smt.RegRdData2Q102H;



assign PcQ101H = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlQ101H.Pc;
assign PcQ102H = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlQ102H.Pc;
assign PcQ103H = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlQ103H.Pc;
assign PcQ104H = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlQ104H.Pc;
logic RegWrEnQ104H;
logic [4:0]  RegDstQ104H;
logic [31:0] RegWrDataQ104H;
assign RegWrEnQ104H   = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlRf_t0.RegWrEnQ104H;
assign RegDstQ104H    = mini_core_smt_top.mini_core_smt.mini_core_smt_ctrl.CtrlRf_t0.RegDstQ104H;
assign RegWrDataQ104H = mini_core_smt_top.mini_core_smt.RegWrDataQ104H;
task get_rf_write();
$display("get_rf_write start");
fork forever begin 
    @(posedge Clk) begin
        if (RegWrEnQ104H && (RegDstQ104H!=5'b0)) begin
            rf_cur_write.RegDst    = RegDstQ104H;
            rf_cur_write.Data      = RegWrDataQ104H;
            rf_cur_write.Pc        = PcQ104H;
            rf_cur_write.cur_time  = $time;
            rf_write_history.push_back(rf_cur_write);
       $display("rf_cur_write = %p", rf_cur_write);
        end
    end
end
join_none
endtask

task get_ref_rf_write();
fork forever begin 
    @(posedge Clk) begin
        if (rv32i_ref.reg_wr_en) begin
            ref_rf_cur_write.RegDst = rv32i_ref.rd;
            ref_rf_cur_write.Data   = rv32i_ref.next_regfile[rv32i_ref.rd];
            ref_rf_cur_write.Pc     = rv32i_ref.pc;
            ref_rf_cur_write.cur_time   = $time;
            if (rv32i_ref.rd != 5'b0) begin
                ref_rf_write_history.push_back(ref_rf_cur_write);
                 $display("ref_rf_cur_write = %p", ref_rf_cur_write);
            end
        end
    end
end
join_none
endtask


string msg = "Data integrity test passed"; // default
task di_register_write();
$display("ref_rf_write_history size = %0d", ref_rf_write_history.size());
$display("rf_write_history size     = %0d", rf_write_history.size());
foreach(ref_rf_write_history[i])begin
    if ((ref_rf_write_history[i].RegDst == rf_write_history[i].RegDst ) && 
        (ref_rf_write_history[i].Data   == rf_write_history[i].Data   ) )
    begin
        $display(" >> rf_write_history[%0d] Match: time: %0d, PC: %8h, RegDsd: %d, Data: %h", i, rf_write_history[i].cur_time,
                                                                                                 rf_write_history[i].Pc,
                                                                                                 rf_write_history[i].RegDst,
                                                                                                 rf_write_history[i].Data);
        //ref_rf_write_history.delete(i);
        //rf_write_history.delete(i);
    end else begin
        $display(" >> rf_write_history[%0d] Mismatch!!", i);
        $error("ERROR: rf_write_history mismatch");
        $display("      thread in WB 104 is : %d, thread in MEM 103 is : %d, thread in EXE 102 is : %d ,thread in DEC 101 is : %d, thread in IF 100 is : %d", ThreadIDQ104H, ThreadIDQ103H,ThreadIDQ102H,ThreadIDQ101H,CurrThread); 
        //$display("      CurrThread is : %d ,Ready 104 is : %d, Ready 103 is : %d, Ready 102 is : %d ,Ready 101 is : %d, Ready 100 is : %d", CurrThread, ReadyQ104H, ReadyQ103H,ReadyQ102H,ReadyQ101H,ReadyQ100H);
        $display("      PcQ102H is %8h, ImmediateQ102H is %8h, RegRdData1Q102H is %8h, RegRdData2Q102H is %8h ",PcQ102H,ImmediateQ102H,RegRdData1Q102H,RegRdData2Q102H );
        $display("      ref_rf_write_history[%0d] =   {time: %0d, Pc: %8h, RegDst: %d, Data: %h}", i, ref_rf_write_history[i].cur_time, ref_rf_write_history[i].Pc, ref_rf_write_history[i].RegDst, ref_rf_write_history[i].Data);
        $display("      rf_write_history    [%0d] =   {time: %0d, Pc: %8h, RegDst: %d, Data: %h}", i, rf_write_history[i].cur_time    , rf_write_history[i].Pc    , rf_write_history[i].RegDst    , rf_write_history[i].Data    );
        msg = "Data integrity test failed - rf_write_history mismatch";
    end
end

if(ref_rf_write_history.size() != rf_write_history.size()) begin
    $error("ERROR: rf_write_history size mismatch");
    msg = "Data integrity test failed - rf_write_history size mismatch";
end else begin
    $display("rf_write_history size match");
end
$display("Data Integrity final status: %s", msg);
$display("===============================\n");
//TODO - review why the below code is not working (history not empty)
//if(ref_rf_write_history.size() != 0) begin
//    $error("ERROR: rf_write_history not empty");
//end else begin
//    $display("rf_write_history size match");
//end

endtask




task eot (string msg);
    #10;
    $display("===============================");
    $display("End of simulation: %s", msg);
    $display("===============================\n");
    
    $display("===============================");
    $display("Starting data integrity test");
    $display("===============================");
    di_register_write();
    $finish;
endtask
