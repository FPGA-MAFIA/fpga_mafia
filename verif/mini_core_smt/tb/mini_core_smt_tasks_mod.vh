
// -----------------------------------------------------------------------------
// Title            : SMT task file with dual-thread ref_core support
// -----------------------------------------------------------------------------

typedef struct packed {
    logic [4:0]   RegDst;
    logic [31:0]  Data;
    logic [31:0]  Pc;
    logic [31:0]  cur_time;
    int ThreadID;
} t_rf_write_history;

t_rf_write_history rf_write_history[$];
t_rf_write_history rf_cur_write;
t_rf_write_history ref_rf_write_history_0[$];
t_rf_write_history ref_rf_write_history_1[$];
t_rf_write_history ref_rf_cur_write_0;
t_rf_write_history ref_rf_cur_write_1;

logic [31:0] PcQ101H;
logic [31:0] PcQ102H;
logic [31:0] PcQ103H, PcQ104H;
logic CurrThread;
logic ThreadIDQ101H,ThreadIDQ102H,ThreadIDQ103H,ThreadIDQ104H;
logic ReadyQ100H,ReadyQ101H,ReadyQ102H,ReadyQ103H,ReadyQ104H;
logic ImmediateQ102H, RegRdData1Q102H,RegRdData2Q102H;

assign ReadyQ100H = mini_core_smt_top.mini_core_smt.ReadyQ100H;
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
        if (ref_core0.reg_wr_en) begin
            ref_rf_cur_write_0.RegDst = ref_core0.rd;
            ref_rf_cur_write_0.Data   = ref_core0.next_regfile[ref_core0.rd];
            ref_rf_cur_write_0.Pc     = ref_core0.pc;
            ref_rf_cur_write_0.cur_time = $time;
            ref_rf_cur_write_0.ThreadID  = 0; 
            if (ref_core0.rd != 5'b0)
                ref_rf_write_history_0.push_back(ref_rf_cur_write_0);
        end
        if (ref_core1.reg_wr_en) begin
            ref_rf_cur_write_1.RegDst = ref_core1.rd;
            ref_rf_cur_write_1.Data   = ref_core1.next_regfile[ref_core1.rd];
            ref_rf_cur_write_1.Pc     = ref_core1.pc;
            ref_rf_cur_write_1.cur_time = $time;
            ref_rf_cur_write_1.ThreadID  = 1;
            if (ref_core1.rd != 5'b0)
                ref_rf_write_history_1.push_back(ref_rf_cur_write_1);
        end
    end
end
join_none
endtask

task automatic di_register_write();
    string msg = "Data integrity test passed";
    int i;
    int tid0_index = 0;
    int tid1_index = 0;

    $display("ref_rf_write_history_0 size = %0d", ref_rf_write_history_0.size());
    $display("ref_rf_write_history_1 size = %0d", ref_rf_write_history_1.size());
    $display("rf_write_history       size = %0d", rf_write_history.size());

    foreach (rf_write_history[i]) begin
        t_rf_write_history ref_entry;

        if (rf_write_history[i].ThreadID == 0) begin
            if (tid0_index < ref_rf_write_history_0.size())
                ref_entry = ref_rf_write_history_0[tid0_index++];
            else begin
                $display("WARNING: Thread 0 out of bounds at i=%0d", i);
                continue;
            end
        end else begin
            if (tid1_index < ref_rf_write_history_1.size())
                ref_entry = ref_rf_write_history_1[tid1_index++];
            else begin
                $display("WARNING: Thread 1 out of bounds at i=%0d", i);
                continue;
            end
        end

        if ((ref_entry.RegDst == rf_write_history[i].RegDst) &&
            (ref_entry.Data   == rf_write_history[i].Data)) begin
            $display("✅ rf_write_history[%0d] Match: time: %0d, PC: %8h, RegDst: %d, Data: %h",
                      i,
                      rf_write_history[i].cur_time,
                      rf_write_history[i].Pc,
                      rf_write_history[i].RegDst,
                      rf_write_history[i].Data);
        end else begin
            $display("❌ >> rf_write_history[%0d] Mismatch!!", i);
            $error("ERROR: rf_write_history mismatch");
            msg = "Data integrity test failed - rf_write_history mismatch";
        end
    end


    $display("Data Integrity final status: %s", msg);
    $display("===============================");
endtask

task eot (string msg);
    #10;
    $display("===============================");
    $display("End of simulation: %s", msg);
    $display("===============================");
    $display("===============================");
    $display("Starting data integrity test");
    $display("===============================");
    di_register_write();
    $finish;
endtask
