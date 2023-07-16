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
        end
    end
end
join_none
endtask

task get_ref_rf_write();
fork forever begin 
    @(posedge Clk) begin
        if (!(rv32i_ref.regfile[31:1] === rv32i_ref.next_regfile[31:1])) begin
            ref_rf_cur_write.RegDst = rv32i_ref.rd;
            ref_rf_cur_write.Data   = rv32i_ref.next_regfile[rv32i_ref.rd];
            ref_rf_write_history.push_back(ref_rf_cur_write);
        end
    end
end
join_none
endtask


task di_register_write();
foreach(ref_rf_write_history[i])begin
    if (ref_rf_write_history[i]==rf_write_history[i]) begin
        $display("rf_write_history[%0d] match", i);
        $display(" match-ref_rf_write_history[%0d].RegDst = %0d", i, ref_rf_write_history[i].RegDst);
        $display(" match-ref_rf_write_history[%0d].Data   = %0d", i, ref_rf_write_history[i].Data);
        $display(" match-rf_write_history[%0d].RegDst = %0d", i, rf_write_history[i].RegDst);
        $display(" match-rf_write_history[%0d].Data   = %0d", i, rf_write_history[i].Data);
        ref_rf_write_history.delete(i);
        rf_write_history.delete(i);
    end else begin
        $display(" Note: Mismatch!!", i);
        $display("      ref_rf_write_history[%0d].RegDst = %0d", i, ref_rf_write_history[i].RegDst);
        $display("      ref_rf_write_history[%0d].Data   = %0d", i, ref_rf_write_history[i].Data);
        $display("      rf_write_history[%0d].RegDst = %0d", i, rf_write_history[i].RegDst);
        $display("      rf_write_history[%0d].Data   = %0d", i, rf_write_history[i].Data);
        $error("ERROR: rf_write_history mismatch");
    end
end

if(ref_rf_write_history.size() != rf_write_history.size()) begin
    $error("ERROR: rf_write_history size mismatch");
end else begin
    $display("rf_write_history size match");
end

if(ref_rf_write_history.size() != 0) begin
    $error("ERROR: rf_write_history size mismatch");
end else begin
    $display("rf_write_history size match");
end

endtask




task eot (string msg);
    #10;
    $display("=========\n -- Calling di_register_write -- \n=========");
    di_register_write();
    $display("===============================");
    $display("End of simulation: %s", msg);
    $display("===============================");

    $finish;
endtask
