// Core -> Cache request
typedef struct packed {
    logic [31:0]  Address;  
    logic [31:0]  Data;    
    logic [31:0]  Pc;
    logic [31:0]  cur_time;
} t_mem_store_history ;

typedef struct packed {
    logic [31:0]  Address;  
    logic [31:0]  Data;    
    logic [31:0]  Pc;
    logic [31:0]  cur_time;
} t_mem_load_history ;

typedef enum logic [5:0] {
    NULL  = 6'd0,
    LUI   = 6'd1,
    AUIPC = 6'd2,
    JAL   = 6'd3,
    JALR  = 6'd4,
    BEQ   = 6'd5,
    BNE   = 6'd6,
    BLT   = 6'd7,
    BGE   = 6'd8,
    BLTU  = 6'd9,
    BGEU  = 6'd10,
    LB    = 6'd11,
    LH    = 6'd12,
    LW    = 6'd13,
    LBU   = 6'd14,
    LHU   = 6'd15,
    SB    = 6'd16,
    SH    = 6'd17,
    SW    = 6'd18,
    ADDI  = 6'd19,
    SLTI  = 6'd20,
    SLTIU = 6'd21,
    XORI  = 6'd22,
    ORI   = 6'd23,
    ANDI  = 6'd24,
    SLLI  = 6'd25,
    SRLI  = 6'd26,
    SRAI  = 6'd27,
    ADD   = 6'd28,
    SUB   = 6'd29,
    SLL   = 6'd30,
    SLT   = 6'd31,
    SLTU  = 6'd32,
    XOR   = 6'd33,
    SRL   = 6'd34,
    SRA   = 6'd35,
    OR    = 6'd36,
    AND   = 6'd37,
    FENCE = 6'd38,
    ECALL = 6'd39,
    EBREAK= 6'd40,
    CSRRW = 6'd41,
    CSRRS = 6'd42,
    CSRRC = 6'd43,
    CSRRWI= 6'd44,
    CSRRSI= 6'd45,
    CSRRCI= 6'd46
} t_rv32i_instr;

t_mem_store_history rf_mem_store_history[$];
t_mem_store_history rf_cur_mem_store;
t_mem_store_history ref_rf_mem_store_history[$];
t_mem_store_history ref_rf_cur_mem_store;

t_mem_load_history rf_mem_load_history[$];
t_mem_load_history rf_cur_mem_load;
t_mem_load_history ref_rf_mem_load_history[$];
t_mem_load_history ref_rf_cur_mem_load;


`ifndef USE_RF_AND_MEM_CHK              // Avoid multiple Pc declaration signal when using both rf and memory checkers
    logic [31:0] PcQ101H;             // To I_MEM
    logic [31:0] PcQ102H;             // To I_MEM
    logic [31:0] PcQ103H, PcQ104H, PcQ105H;
    assign PcQ101H = mini_core_top.mini_core.mini_core_ctrl.CtrlQ101H.Pc;
    assign PcQ102H = mini_core_top.mini_core.mini_core_ctrl.CtrlQ102H.Pc;
    assign PcQ103H = mini_core_top.mini_core.mini_core_ctrl.CtrlQ103H.Pc;
    assign PcQ104H = mini_core_top.mini_core.mini_core_ctrl.CtrlQ104H.Pc;
    assign PcQ105H = mini_core_top.mini_core.mini_core_ctrl.CtrlQ105H.Pc;
`endif

// signals for store
logic DMemWrEnQ103H;
logic [31:0] DMemWrDataQ103H;
logic [31:0] AluOutQ103H;
assign DMemWrEnQ103H   = mini_core_top.mini_core.mini_core_mem_access1.Ctrl.DMemWrEnQ103H;
assign DMemWrDataQ103H = mini_core_top.mini_core.mini_core_mem_access1.DMemWrDataQ103H;
assign AluOutQ103H     = mini_core_top.mini_core.mini_core_mem_access1.AluOutQ103H;   // store address

// signals for load
logic DMemRdEnQ105H;
logic [31:0] DMemRdDataQ105H;
logic [31:0] AluOutQ105H;
logic [31:0] l_data;
assign DMemRdEnQ105H   = mini_core_top.mini_core.mini_core_ctrl.CtrlQ105H.DMemRdEn;
assign DMemRdDataQ105H = mini_core_top.mini_core.mini_core_wb.DMemRdDataQ105H;
assign AluOutQ105H     = mini_core_top.mini_core.mini_core_wb.AluOutQ105H;   // load address
assign l_data = (rv32i_ref.instr_type == LB)  ?  rv32i_ref.lb_data :
                (rv32i_ref.instr_type == LH)  ?  rv32i_ref.lh_data :
                (rv32i_ref.instr_type == LW)  ?  rv32i_ref.lw_data :
                (rv32i_ref.instr_type == LBU) ? rv32i_ref.lbu_data :
                (rv32i_ref.instr_type == LHU) ? rv32i_ref.lhu_data : 0;

task get_mem_store();
$display("get_mem_store start");
fork forever begin 
    @(posedge Clk) begin
        if (DMemWrEnQ103H) begin
            rf_cur_mem_store.Address  = AluOutQ103H;
            rf_cur_mem_store.Data     = DMemWrDataQ103H;
            rf_cur_mem_store.Pc       = PcQ103H;
            rf_cur_mem_store.cur_time = $time;
            rf_mem_store_history.push_back(rf_cur_mem_store);
            // $display("rf_cur_mem_store = %p", rf_cur_mem_store);
         end
    end
end
join_none
endtask

task get_mem_load();
$display("get_mem_load start");
fork forever begin 
    @(posedge Clk) begin
        if (DMemRdEnQ105H) begin
            rf_cur_mem_load.Address  = AluOutQ105H;
            rf_cur_mem_load.Data     = DMemRdDataQ105H;
            rf_cur_mem_load.Pc       = PcQ105H;
            rf_cur_mem_load.cur_time = $time;
            rf_mem_load_history.push_back(rf_cur_mem_load);
            // $display("rf_cur_mem_load = %p", rf_cur_mem_load);

        end
    end
end
join_none
endtask

task get_ref_mem_store();
fork forever begin 
    @(posedge Clk) begin
        if (rv32i_ref.DMemWrEn) begin
            ref_rf_cur_mem_store.Address  = rv32i_ref.mem_wr_addr;
            ref_rf_cur_mem_store.Data     = rv32i_ref.data_rd2;
            ref_rf_cur_mem_store.Pc       = rv32i_ref.pc;
            ref_rf_cur_mem_store.cur_time = $time;
            ref_rf_mem_store_history.push_back(ref_rf_cur_mem_store);
            // $display("ref_rf_cur_mem_store = %p", ref_rf_cur_mem_store);
            end 
        end
    end
join_none
endtask

task get_ref_mem_load();
fork forever begin 
    @(posedge Clk) begin
        if (rv32i_ref.DMemRdEn) begin
            ref_rf_cur_mem_load.Address  = rv32i_ref.mem_rd_addr;
            ref_rf_cur_mem_load.Data     = l_data;  
            ref_rf_cur_mem_load.Pc       = rv32i_ref.pc;
            ref_rf_cur_mem_load.cur_time = $time;
            ref_rf_mem_load_history.push_back(ref_rf_cur_mem_load);
            // $display("ref_rf_cur_mem_load = %p", ref_rf_cur_mem_load);
            end 
        end
    end
join_none
endtask


string s_msg = "Store data integrity test passed"; // default
task di_mem_store();
$display("ref_rf_mem_store_history size = %0d", ref_rf_mem_store_history.size());
$display("rf_mem_store_history size     = %0d", rf_mem_store_history.size());
foreach(ref_rf_mem_store_history[i])begin
    if ((ref_rf_mem_store_history[i].Address == rf_mem_store_history[i].Address ) && 
        (ref_rf_mem_store_history[i].Data    == rf_mem_store_history[i].Data ) )
    begin
        $display(" >> rf_mem_store_history[%0d] Match: time: %0d, PC: %8h, Address: %h, Data: %h", i, rf_mem_store_history[i].cur_time,
                                                                                                 rf_mem_store_history[i].Pc,
                                                                                                 rf_mem_store_history[i].Address,
                                                                                                 rf_mem_store_history[i].Data);
        //ref_rf_mem_store_history.delete(i);
        //rf_mem_store_history.delete(i);
    end else begin
        $display(" >> rf_mem_store_history[%0d] Mismatch!!", i);
        $error("ERROR: rf_mem_store_history mismatch");
        $display("      ref_rf_mem_store_history[%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, ref_rf_mem_store_history[i].cur_time, ref_rf_mem_store_history[i].Pc, ref_rf_mem_store_history[i].Address, ref_rf_mem_store_history[i].Data);
        $display("      rf_mem_store_history    [%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, rf_mem_store_history[i].cur_time    , rf_mem_store_history[i].Pc    , rf_mem_store_history[i].Address    , rf_mem_store_history[i].Data    );
        s_msg = "Store data integrity test failed - rf_mem_store_history mismatch";
    end
end

if(ref_rf_mem_store_history.size() != rf_mem_store_history.size()) begin
    $error("ERROR: rf_mem_store_history size mismatch");
    s_msg = "Store data integrity test failed - rf_mem_store_history size mismatch";
end else begin
    $display("rf_mem_store_history size match");
end
$display("Store data Integrity final status: %s", s_msg);
$display("====================================\n");
//TODO - review why the below code is not working (history not empty)
//if(ref_rf_mem_store_history.size() != 0) begin
//    $error("ERROR: rf_mem_store_history not empty");
//end else begin
//    $display("rf_mem_store_history size match");
//end
endtask

string l_msg = "Load data integrity test passed"; // default
task di_mem_load();
$display("ref_rf_mem_load_history size = %0d", ref_rf_mem_load_history.size());
$display("rf_mem_load_history size     = %0d", rf_mem_load_history.size());
foreach(ref_rf_mem_load_history[i])begin
    if ((ref_rf_mem_load_history[i].Address == rf_mem_load_history[i].Address ) && 
        (ref_rf_mem_load_history[i].Data    == rf_mem_load_history[i].Data ) )
    begin
        $display(" >> rf_mem_load_history[%0d] Match: time: %0d, PC: %8h, Address: %h, Data: %h", i, rf_mem_load_history[i].cur_time,
                                                                                                 rf_mem_load_history[i].Pc,
                                                                                                 rf_mem_load_history[i].Address,
                                                                                                 rf_mem_load_history[i].Data);
        //ref_rf_mem_load_history.delete(i);
        //rf_mem_load_history.delete(i);
    end else begin
        $display(" >> rf_mem_load_history[%0d] Mismatch!!", i);
        $error("ERROR: rf_mem_load_history mismatch");
        $display("      ref_rf_mem_load_history[%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, ref_rf_mem_load_history[i].cur_time, ref_rf_mem_load_history[i].Pc, ref_rf_mem_load_history[i].Address, ref_rf_mem_load_history[i].Data);
        $display("      rf_mem_load_history    [%0d] =   {time: %0d, Pc: %8h, Address: %h, Data: %h}", i, rf_mem_load_history[i].cur_time    , rf_mem_load_history[i].Pc    , rf_mem_load_history[i].Address    , rf_mem_load_history[i].Data    );
        l_msg = "Load data integrity test failed - rf_mem_load_history mismatch";
    end
end

if(ref_rf_mem_load_history.size() != rf_mem_load_history.size()) begin
    $error("ERROR: rf_mem_load_history size mismatch");
    l_msg = "Load data integrity test failed - rf_mem_load_history size mismatch";
end else begin
    $display("rf_mem_load_history size match");
end
$display("Load data Integrity final status: %s", l_msg);
$display("===============================\n");

endtask

task sl_eot (string s_msg, string l_msg);
    #10;
    $display("======================================");
    $display("End of simulation: %s", s_msg);
    $display("======================================\n");
    
    $display("======================================");
    $display("Starting store data integrity test");
    $display("======================================\n");
    di_mem_store();

    #10;
    $display("====================================");
    $display("Starting load data integrity test");
    $display("====================================\n");
    di_mem_load();
    $finish;
endtask
