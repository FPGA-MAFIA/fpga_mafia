`include "macros.sv"
`define MINI_CORE_TILE(col,row) fabric.col[col].row[row].mini_core_tile_ins
`define IN_LOCAL_REQ(col,row)   `MINI_CORE_TILE(col,row).in_local_req

`define RAND_EP(rand_ep)  rand_ep = {4'($urandom_range(4'd1, 4'd3)), 4'($urandom_range(4'd1, 4'd3))};

module fabric_tb;
import common_pkg::*;
import mini_core_pkg::*;
typedef struct packed {
    t_tile_trans trans;
    t_tile_id source;
    t_tile_id target;
} t_tile_trans_v;
parameter V_FABRIC_SIZE = 3;
parameter V_ROW = V_FABRIC_SIZE;
parameter V_COL = V_FABRIC_SIZE;
parameter V_REQUESTS = 2;
parameter V_NUM_CYCLES = 10;

logic              clk;
logic              rst;
int fabric_test_true;
int mini_core_tile_test_true;
string test_name;
static int cnt_trans;
t_tile_trans [V_ROW:1] [V_COL:1] origin_trans;
t_tile_trans [V_ROW:1] [V_COL:1] target_trans;
t_fab_ready  [V_ROW:1] [V_COL:1] tile_ready; 
logic [7:0]  requestor_id_ref [V_ROW:1] [V_COL:1] ;
//t_cardinal [V_ROW:1] [V_COL:1] ref_cardinal;
static t_tile_trans_v monitor_source_trans [V_ROW:1] [V_COL:1] [$];
static t_tile_trans_v monitor_target_trans [V_ROW:1] [V_COL:1] [$];
bit [V_ROW:1] [V_COL:1] valid_tile;
bit [V_ROW:1] [V_COL:1] valid_local;
`include "mini_core_tile_dut.vh"
`include "fabric_dut.vh"
`include "fabric_tasks.vh"
`include "mini_core_tile_tasks.vh"
`include "fabric_inputs_trk.vh"
// =============================
// CLK GEN
// =============================
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

// =============================
// RST gen
// =============================
task rst_ins();
    //start with reset
    rst = 1'b1;
    delay(10);
    //release reset
    rst = '0;
endtask
genvar row, col;
generate
  for (col = 1; col <= V_COL; col = col + 1) begin : gen_col
    for (row = 1; row <= V_ROW; row = row + 1) begin : gen_row
    // fabric to if
      assign fabric.col[col].row[row].mini_core_tile_ins.in_local_req_valid            = valid_tile  [col][row];           
      assign fabric.col[col].row[row].mini_core_tile_ins.pre_in_local_req.data         = origin_trans[col][row].data;    
      assign fabric.col[col].row[row].mini_core_tile_ins.pre_in_local_req.address      = origin_trans[col][row].address;
      assign fabric.col[col].row[row].mini_core_tile_ins.pre_in_local_req.opcode       = origin_trans[col][row].opcode;  
      assign fabric.col[col].row[row].mini_core_tile_ins.pre_in_local_req.requestor_id = origin_trans[col][row].requestor_id;                 
    // if to fabric
      assign valid_local[col][row] = fabric.col[col].row[row].mini_core_tile_ins.router_inst.out_local_req_valid;
      assign target_trans[col][row] = fabric.col[col].row[row].mini_core_tile_ins.router_inst.out_local_req;
      assign requestor_id_ref[col][row] = fabric.col[col].row[row].mini_core_tile_ins.pre_in_local_req.requestor_id;
      assign tile_ready[col][row] = fabric.col[col].row[row].mini_core_tile_ins.out_local_ready;
    end
  end
endgenerate


initial begin
  fork
  forever begin
    @(valid_local);
    for(int i=1;i<=V_ROW; i++)begin
      for(int j=1;j<=V_COL; j++)begin
        //$display("[Time %0t]: Tile[%0d,%0d] local_valid: %0b,address: %0h,requestor_id %0h",$realtime,i,j,valid_tile[i][j],origin_trans[i][j].address, origin_trans[i][j].requestor_id);
        //$display("[Time %0t]: Tile[%0d,%0d] local_valid: %0b",$realtime,i,j,valid_local[i][j]);
    end
  end
  end
  forever begin
    @(origin_trans);
    for(int i=1;i<=V_ROW; i++)begin
      for(int j=1;j<=V_COL; j++)begin
        //$display("[Time %0t]: Tile[%0d,%0d] valid_req: %0b,address: %0h,requestor_id %0h",$realtime,i,j,valid_tile[i][j],origin_trans[i][j].address, origin_trans[i][j].requestor_id);
        //$display("[Time %0t]: Tile[%0d,%0d] local_valid: %0b",$realtime,i,j,valid_local[i][j]);
    end
  end
end
  join
end

// =============================
//  general tasks
// =============================
task automatic delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

function void find_string( input string str, 
                           input string substr,
                           output int found);
automatic int len = str.len();
automatic int len_substr = substr.len();
found = 0;
for( int i =0; i < len - len_substr; i++) begin
    if(str.substr(i,i+len_substr-1) == substr) begin
       found = found | 1;
    end
end

    if(found == 1) $display("[INFO] find_string - found %s in %s",substr,str);
    if(found == 0) $display("[INFO] find_string - did not find %s in %s",substr,str);
endfunction

initial begin : timeout_monitor
  #10us;
  //$fatal(1, "Timeout");
  $error("timeout test");
  $finish();
end

// =============================
//  This is the main test sequence
// =============================
initial begin
  $display("================\n     START\n================\n");
  if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
  else $fatal("CANNOT FIND TEST %s at time %t",test_name , $time());
  // check what is the test prefix mini_core_tile or fabric
  find_string(.str(test_name), .substr("mini_core_tile")  , .found(mini_core_tile_test_true));
  find_string(.str(test_name), .substr("fabric"), .found(fabric_test_true));

  rst_ins();
//=======================
// The MINI_CORE_TILE sequence
//=======================
  if(mini_core_tile_test_true) begin
    $display("==============================");
    $display("[INFO] this is MINI_CORE_TILE test");
    $display("==============================");
  fork 
      run_mini_core_tile_test(test_name);  
  join
  end else if(fabric_test_true) begin
    $display("==============================");
    $display("[INFO] this is FABRIC test");
    $display("==============================");
    cnt_trans = 0;
  fork 
      run_fabric_test(test_name);
      fork  
          //for(int i = 1; i<= V_COL; i++) begin
          //  for(int j = 1; j<= V_ROW; j++) begin
          //     automatic int col = i;
          //     automatic int row = j;
          //     fork forever begin
          //        fabric_get_inputs_from_tile();
          //      end join_none
          //   end
          //end
      fabric_get_source_from_tile();
      fabric_get_target_from_tile();
      //fabric_get_in_trans();
      //fabric_get_source_tile_id();
      //fabric_get_current_tile_id();
      //fabric_get_trans_from_tile();
      #5us;
      join
  join_any
  fabric_DI_checker();
  end else begin
    $error("[ERROR] : this is not a valid test name");
  end
  delay(30);
  $display("TEST DONE");
  $finish();
end

endmodule
