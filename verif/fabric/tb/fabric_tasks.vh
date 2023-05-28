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
assign source_row = source_id[3:0];
assign source_col = source_id[7:4];
$display(" [INFO] : new request source_id = %h, target_id = %h",source_id,target_id);

//first row
if ( (source_row == 4'd1) && (source_col == 4'd1) ) `ASSIGN_IN_LOCAL_REQ(4'd1,4'd1,target_id,opcode)
if ( (source_row == 4'd1) && (source_col == 4'd2) ) `ASSIGN_IN_LOCAL_REQ(4'd2,4'd1,target_id,opcode)
if ( (source_row == 4'd1) && (source_col == 4'd3) ) `ASSIGN_IN_LOCAL_REQ(4'd3,4'd1,target_id,opcode)
//second row
if ( (source_row == 4'd2) && (source_col == 4'd1) ) `ASSIGN_IN_LOCAL_REQ(4'd1,4'd2,target_id,opcode)
if ( (source_row == 4'd2) && (source_col == 4'd2) ) `ASSIGN_IN_LOCAL_REQ(4'd2,4'd2,target_id,opcode)
if ( (source_row == 4'd2) && (source_col == 4'd3) ) `ASSIGN_IN_LOCAL_REQ(4'd3,4'd2,target_id,opcode)
//third row
if ( (source_row == 4'd3) && (source_col == 4'd1) ) `ASSIGN_IN_LOCAL_REQ(4'd1,4'd3,target_id,opcode)
if ( (source_row == 4'd3) && (source_col == 4'd2) ) `ASSIGN_IN_LOCAL_REQ(4'd2,4'd3,target_id,opcode)
if ( (source_row == 4'd3) && (source_col == 4'd3) ) `ASSIGN_IN_LOCAL_REQ(4'd3,4'd3,target_id,opcode)

 // add the macros

endtask

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