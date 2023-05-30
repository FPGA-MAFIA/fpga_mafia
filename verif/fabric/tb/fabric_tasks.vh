task run_fabric_test(input string test);
  delay(30);
  // ====================
  // mini_core_tile tests:
  // ====================
  if (test == "fabric_alive") begin
     `include "fabric_alive.sv"
  end else if(test == "fabric_all_tiles") begin
     `include "fabric_all_tiles.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

`define ASSIGN_IN_LOCAL_REQ(m_col,m_row,m_target_id, m_opcode)                                                  \
  assign fabric.col[m_col].row[m_row].mini_core_tile_ins.in_local_req_valid            = 1'b1;                  \
  assign fabric.col[m_col].row[m_row].mini_core_tile_ins.pre_in_local_req.data         = $urandom_range(0,1024);\
  assign fabric.col[m_col].row[m_row].mini_core_tile_ins.pre_in_local_req.address      = {m_target_id, 24'h0};  \
  assign fabric.col[m_col].row[m_row].mini_core_tile_ins.pre_in_local_req.opcode       = m_opcode;              \
  assign fabric.col[m_col].row[m_row].mini_core_tile_ins.pre_in_local_req.requestor_id = {m_col,m_row};         \
  delay(1);                                                                                                     \
  assign fabric.col[m_col].row[m_row].mini_core_tile_ins.in_local_req_valid        = 1'b0;

// XMR to drive a request from one local core in the fabric to another
task send_req(input t_tile_id source_id, input t_tile_id target_id, input t_tile_opcode opcode);
int source_row, source_col;
int target_row, target_col;
assign source_row = source_id[3:0];
assign source_col = source_id[7:4];
assign target_row = target_id[3:0];
assign target_col = target_id[7:4];
//$display(" [INFO] : new request source_id = %h, target_id = %h",source_id,target_id);
  for (int row = 1; row <= V_ROW; row = row + 1) begin
    for (int col = 1; col <= V_COL; col = col + 1) begin 
      if ( (source_row == row) && (source_col == col) )begin
         valid_tile[col][row] = 1'b1;          
         origin_trans[col][row].data = $urandom_range(0,1024);
         origin_trans[col][row].address = {target_id, 24'h0};
         origin_trans[col][row].opcode = opcode;
         origin_trans[col][row].requestor_id = source_id;                     
         //monitor_origin_trans[col][row].source = {source_col,source_row};                     
         //monitor_origin_trans[col][row].target = {target_col,target_row};                     
         delay(1);                                                                                                     
         valid_tile[col][row] = 1'b0;          
         //$display("origin_trans = %p at time %t from tile [%0d,%0d] to tile: [%0d,%0d]",origin_trans[col][row],$time,col,row,target_col,target_row);
      end
    end
  end 

endtask

task automatic fabric_get_source_from_tile();// note - this is not exactley the best verification methodology,
//better to take the signals from each tile (from the generate) and not from the origin_trans (act as BFM) - low priority, fix if have time.
t_tile_trans_v [V_COL:1][V_ROW:1] temp_trans;
t_tile_id source_id;
  for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
      automatic int col = i;
      automatic int row = j;
      fork forever begin
        wait(valid_tile[col][row] == 1'b1);
        source_id[7:4] = col; // {col,row} dosent work as expected
        source_id[3:0] = row;
        //$display("THIS IS SOURCE_ID %h",source_id);
        //$display("[Time: %0t] valid_local from tile [%0d,%0d] is %0b",$time,col,row,valid_local[col][row]);
        //$display("requestor_id is %0h",origin_trans[col][row].requestor_id);
        #0;
        temp_trans[col][row].trans.data = origin_trans[col][row].data;
        temp_trans[col][row].trans.opcode = origin_trans[col][row].opcode;
        temp_trans[col][row].trans.address = origin_trans[col][row].address;
        temp_trans[col][row].trans.next_tile_fifo_arb_id = NULL_CARDINAL;
        temp_trans[col][row].trans.requestor_id = '0;
        temp_trans[col][row].source = source_id;
        temp_trans[col][row].target = origin_trans[col][row].address[31:24];
        $display("source_trans.source is %h and target_trans.target is %h in tile [%0d,%0d] ",temp_trans[col][row].source,temp_trans[col][row].target,col,row);
        monitor_source_trans[col][row].push_back(temp_trans[col][row]);
        wait(valid_tile[col][row] == 1'b0);
      end join_none

    end
  end

endtask
task automatic fabric_get_target_from_tile();
t_tile_trans_v [V_COL:1][V_ROW:1] temp_trans;
t_tile_id target_id;
  for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
      automatic int col = i;
      automatic int row = j;
      fork forever begin
        wait(valid_local[col][row] == 1'b1);
        target_id[7:4] = col; // {col,row} dosent work as expected
        target_id[3:0] = row;
        //$display("############### time %t after this is req_id %h,temp_trans.source %h",$time,requestor_id_ref[col][row],temp_trans[col][row].source);
        //$display("[Time: %0t] valid_local from tile [%0d,%0d] is %0b",$time,col,row,valid_local[col][row]);
        //$display("requestor_id is %0h",origin_trans[col][row].requestor_id);
        #0;
        temp_trans[col][row].trans.data    =  target_trans[col][row].data;
        temp_trans[col][row].trans.opcode  =  target_trans[col][row].opcode;
        temp_trans[col][row].trans.address =  target_trans[col][row].address;
        temp_trans[col][row].source = target_trans[col][row].requestor_id;
        temp_trans[col][row].target = target_id;
        temp_trans[col][row].trans.requestor_id = '0;
        temp_trans[col][row].trans.next_tile_fifo_arb_id = NULL_CARDINAL;
        //$display("############### time %t after this is req_id %h,temp_trans.source %h trans is %p",$time,requestor_id_ref[col][row],temp_trans[col][row].source,temp_trans[col][row]);
        //$display("target_trans.source is %h and target_trans.target is %h in tile [%0d,%0d] ",temp_trans[col][row].source,temp_trans[col][row].target,col,row);
        monitor_target_trans[col][row].push_back(temp_trans[col][row]);
        //$display("time: %0t monitor_target_trans is %p",$time,monitor_target_trans[col][row]);
        wait(valid_local[col][row] == 1'b0);
      end join_none

    end
  end

endtask

task fabric_DI_checker();
int total_source_cnt;
int total_target_cnt;
bit flag;
  for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
      total_source_cnt = total_source_cnt + monitor_source_trans[i][j].size();
      //$display("THIS IS DI_CHECKER - MONITOR_SOURCE_TRANS SIZE FOR TILE [%0d,%0d] IS %0d",i,j,monitor_source_trans[i][j].size());
    end
  end
    for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
      total_target_cnt = total_target_cnt + monitor_target_trans[i][j].size();
      //$display("THIS IS DI_CHECKER - MONITOR_TARGET_TRANS SIZE FOR TILE [%0d,%0d] IS %0d",i,j,monitor_target_trans[i][j].size());
    end
  end
  $display("total_source_cnt is: %0d",total_source_cnt);
  $display("total_target_cnt is: %0d",total_target_cnt);
  repeat(5000)begin
    foreach(monitor_source_trans[i,j,p])begin
      foreach(monitor_target_trans[k,l,s])begin
        //$display("monitor_source_trans in tile [%0d,%0d,%0d] is %p size is %0d",i,j,p,monitor_source_trans[i][j][p],monitor_source_trans[i][j].size());
        //$display("monitor_target_trans in tile [%0d,%0d,%0d] is %p size is %0d",i,j,p,monitor_target_trans[k][l][s],monitor_target_trans[i][j].size());
        if(monitor_source_trans[i][j][p] == monitor_target_trans[k][l][s]) begin
          monitor_source_trans[i][j].delete(p);
          monitor_target_trans[k][l].delete(s);
        end
      end
    end
  end
    for(int i = 1;i<= V_COL;i++)begin
      for(int j = 1;j<= V_ROW;j++)begin
        if(monitor_source_trans[i][j].size()!= 0)begin
          $error("DI CHECKER - source_list not empty tile [%0d,%0d] size of tile is: %0d",i,j,monitor_source_trans[i][j].size());
          flag = 1'b1;
        end
        if(monitor_target_trans[i][j].size()!= 0)begin
          $error("DI CHECKER - target_list not empty tile [%0d,%0d] size of tile is: %0d",i,j,monitor_target_trans[i][j].size()); 
          flag = 1'b1;
        end
    end
    end
    if(flag == 1'b0) $display("DATA IS CORRECT");

endtask


task send_rand_req();
    t_tile_id rand_source;
    t_tile_id rand_target;
    t_tile_opcode opcode;
    int rand_op;
    do begin 
        `RAND_EP(rand_source)
        `RAND_EP(rand_target)
    end while (rand_source == rand_target);
    rand_op = $urandom_range(0,1);
    if(rand_op == 0)
      opcode = WR;
    else
      opcode = RD;
    send_req(rand_source,rand_target,opcode);

endtask

task send_rand_req_from_tile(input t_tile_id source);
    t_tile_id rand_target;
    t_tile_opcode opcode;
    int rand_op;
    do begin 
        `RAND_EP(source)
        `RAND_EP(rand_target)
    end while (source == rand_target);
    rand_op = $urandom_range(0,1);
    if(rand_op == 0)
      opcode = WR;
    else
      opcode = RD;
    send_req(source,rand_target,opcode);

endtask