// Core -> Cache request
typedef struct packed {
    logic [4:0]   RegDst;   //reg destination
    logic [31:0]  Data;    
} t_rf_write_history ;

t_rf_write_history rf_write_history[$];
t_rf_write_history rf_cur_write;
t_rf_write_history ref_rf_write_history[$];
t_rf_write_history ref_rf_cur_write;


task get_rf_write();
$display("get_rf_write start");
fork forever begin 
    @(posedge Clk) begin
        if (mini_core_top.mini_core.CtrlRegWrEnQ104H && (mini_core_top.mini_core.RegDstQ104H!=5'b0)) begin
            rf_cur_write.RegDst = mini_core_top.mini_core.RegDstQ104H;
            rf_cur_write.Data   = mini_core_top.mini_core.RegWrDataQ104H;
            rf_write_history.push_back(rf_cur_write);
    // $display("rf_cur_write = %p", rf_cur_write);
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
            if (rv32i_ref.rd != 5'b0) begin
                ref_rf_write_history.push_back(ref_rf_cur_write);
                // $display("ref_rf_cur_write = %p", ref_rf_cur_write);
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
foreach(rf_write_history[i])begin
    if (ref_rf_write_history[i]==rf_write_history[i]) begin
        //$display(" >> rf_write_history[%0d] match: %p", i, rf_write_history[i]);
        //ref_rf_write_history.delete(i);
        //rf_write_history.delete(i);
    end else begin
        $display(" >> rf_write_history[%0d] Mismatch!!", i);
        $display("      ref_rf_write_history[%0d] = %p", i, ref_rf_write_history[i]);
        $display("      rf_write_history[%0d]     = %p", i, rf_write_history[i]);
        $error("ERROR: rf_write_history mismatch");
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
