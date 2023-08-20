`include "macros.sv"
`define MINI_CORE_TILE(col,row)           fabric.col``col``.row``row``.mini_core_tile_ins
`define IN_LOCAL_REQ(col,row)             fabric.col``col``.row``row``.mini_core_tile_ins.in_local_req
`define MINI_CORE_TILE_READY(m_col,m_row) fabric.col[m_col].row[m_row].mini_core_tile_ins.mini_core_ready
`define RAND_EP(rand_ep)  rand_ep = {4'($urandom_range(4'd1, 4'd3)), 4'($urandom_range(4'd1, 4'd3))};


module fabric_mini_cores_tb;
import mini_core_pkg::*;
import common_pkg::*;
typedef struct packed {
    t_tile_trans trans;
    t_tile_id source;
    t_tile_id target;
} t_tile_trans_v;
parameter V_FABRIC_SIZE = 3;
parameter V_ROW = V_FABRIC_SIZE;
parameter V_COL = V_FABRIC_SIZE;
parameter V_REQUESTS = 9;
parameter V_NUM_CYCLES = 10;
parameter ADRS_WIDTH = 16;

logic              clk;
logic              rst;

logic  [7:0] IMem  [V_ROW:1] [V_COL:1]   [I_MEM_SIZE_MINI + I_MEM_OFFSET_MINI - 1 : I_MEM_OFFSET_MINI];
logic  [7:0] DMem  [V_ROW:1] [V_COL:1]   [D_MEM_SIZE_MINI + D_MEM_OFFSET_MINI - 1 : D_MEM_OFFSET_MINI];
logic [7:0] i_mem  [V_ROW:1] [V_COL:1]   [(2**ADRS_WIDTH)-1:0] ;
//logic  [7:0]  i_mem    [5:0] [4:0]  [65535:0];
int fabric_test_true;
int mini_core_tile_test_true;
string test_name;
static int cnt_trans_source;
static int cnt_trans_source_rsp;
static int cnt_trans_target;
t_tile_trans [V_ROW:1] [V_COL:1] origin_trans;
t_tile_trans [V_ROW:1] [V_COL:1] origin_trans_fab;
t_tile_trans [V_ROW:1] [V_COL:1] target_trans;
t_tile_trans [V_ROW:1] [V_COL:1] tile_rsp_trans;
t_fab_ready  [V_ROW:1] [V_COL:1] tile_ready; 
logic [7:0]  requestor_id_ref [V_ROW:1] [V_COL:1] ;
//t_cardinal [V_ROW:1] [V_COL:1] ref_cardinal;
static t_tile_trans_v monitor_source_trans [V_ROW:1] [V_COL:1] [$];
static t_tile_trans_v monitor_source_trans_rsp [V_ROW:1] [V_COL:1] [$];
static t_tile_trans_v monitor_target_trans [V_ROW:1] [V_COL:1] [$];
bit [V_ROW:1] [V_COL:1] valid_tile;
bit [V_ROW:1] [V_COL:1] valid_tile_rsp;
bit [V_ROW:1] [V_COL:1] valid_local;
logic [V_ROW:1] [V_COL:1] mini_core_ready;
bit [V_ROW:1] [V_COL:1] mini_core_ready_bit;
bit flg;
t_tile_id m_source;
t_tile_id m_target;
int num_cycles = V_NUM_CYCLES;

`include "mini_core_tile_dut.vh"
`include "fabric_dut.vh"
`include "fabric_tasks.vh"
`include "mini_core_tile_tasks.vh"
`include "fabric_inputs_trk.vh"
`include "mini_core_trk.sv"

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
      //assign fabric.col[col].row[row].mini_core_tile_ins.in_local_req_valid            = valid_tile  [col][row];           
      assign fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.C2F_ReqValidQ103H = valid_tile[col][row]; // input to req_fifo 
      //assign fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.F2C_OutFabricValidQ504H = valid_tile_rsp[col][row];    
      assign fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.C2F_ReqQ103H = origin_trans[col][row];     
      //assign fabric.col[col].row[row].mini_core_tile_ins.in_local_ready[0] = mini_core_ready[col][row];
      //assign fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.mini_core_ready = mini_core_ready[col][row];
                
    // if to fabric
      assign origin_trans_fab[col][row] = fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.C2F_ReqQ103H;   // input_data to req_fifo    
      assign tile_rsp_trans[col][row] = fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.F2C_OutFabricQ504H;// input_data to rd_rsp fifo
      assign valid_tile_rsp[col][row] = fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.F2C_OutFabricValidQ504H;// valid input_data to rd_rsp fifo
      assign valid_local[col][row] = fabric.col[col].row[row].mini_core_tile_ins.out_local_req_valid;
      assign target_trans[col][row] = fabric.col[col].row[row].mini_core_tile_ins.out_local_req;
      //assign target_trans[col][row] = fabric.col[col].row[row].mini_core_tile_ins.out_local_req;
      assign requestor_id_ref[col][row] = fabric.col[col].row[row].mini_core_tile_ins.pre_in_local_req.requestor_id;
      assign tile_ready[col][row] = fabric.col[col].row[row].mini_core_tile_ins.out_local_ready;
      // mini_cores
      assign fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.i_mem.mem = i_mem[col][row];
      //assign mini_core_ready[col][row] = fabric.col[col].row[row].mini_core_tile_ins.mini_core_top.mini_mem_wrap.mini_core_ready;
    end
  end
endgenerate

`MAFIA_DFF(IMem, IMem, clk)
`MAFIA_DFF(DMem, DMem, clk)
task load_mem(input int col, input int row);
    $readmemh({"../../../target/fabric/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem[1][1]);
    force i_mem[col][row] = IMem[col][row]; //backdoor to actual memory
    //load the data to the DUT & reference model 
    //file = $fopen({"../../../target/fabric/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    //if (file) begin
      //  $fclose(file);
        //$readmemh({"../../../target/fabric/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        //force mini_core_top.mini_mem_wrap.d_mem.mem = DMem; //backdoor to actual memory
        //#10
        //release mini_core_top.mini_mem_wrap.d_mem.mem;
    //end
endtask

integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the DUT & reference model
    //======================================
    for(int i = 1; i<= V_COL; i++) begin
    for(int j = 1; j<= V_ROW; j++) begin
      automatic int col = i;
      automatic int row = j;
      fork 
        load_mem(col,row);
      join
    end
    end
end

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
  end else if(1) begin
    $display("==============================");
    $display("[INFO] this is FABRIC test");
    $display("==============================");
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
