task run_fabric_test(input string test);
  delay(30);
  // ====================
  // mini_core_tile tests:
  // ====================
  if (test == "fabric_alive") begin
     `include "fabric_alive.sv"
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
$display(" [INFO] : new request source_id = %h, target_id = %h",source_id,target_id);
  for (int row = 1; row <= V_ROW; row = row + 1) begin
    for (int col = 1; col <= V_COL; col = col + 1) begin 
      if ( (source_row == row) && (source_col == col) )begin
         valid_tile[col][row] = 1'b1;          
         origin_trans[col][row].trans.data = $urandom_range(0,1024);
         origin_trans[col][row].trans.address = {target_id, 24'h0};
         origin_trans[col][row].trans.opcode = opcode;
         origin_trans[col][row].trans.requestor_id = {col,row};                     
         origin_trans[col][row].source = {source_col,source_row};                     
         origin_trans[col][row].target = {target_col,target_row};                     
         delay(1);                                                                                                     
         valid_tile[col][row] = 1'b0;          
         $display("origin_trans = %p at time %t from tile [%0d,%0d] to tile: [%0d,%0d]",origin_trans[col][row],$time,col,row,target_col,target_row);
      end
    end
  end 

endtask

//task fabric_DI_checker(input t_tile_id source, input t_tile_id target);
//forever begin
//  wait(source == target);
//  cnt_trans = cnt_trans + 1;
//  if(origin_trans == current_trans)begin
//    $display("DATA OK FOR TRANS %0d",cnt_trans);
//  end
//  else $error("data in and data out are different at time %t, data in: %p, data_out: %p",$time,origin_trans,current_trans);
//
//end

//endtask


task send_rand_req();
    t_tile_id rand_source;
    t_tile_id rand_target;
    t_tile_opcode opcode;
    do begin 
        `RAND_EP(rand_source)
        `RAND_EP(rand_target)
    end while (rand_source == rand_target);
    opcode = WR;//FIXME support also RD
    send_req(rand_source,rand_target,opcode);

endtask