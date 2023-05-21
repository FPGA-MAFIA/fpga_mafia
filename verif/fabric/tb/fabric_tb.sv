`include "macros.sv"
`define MINI_CORE_TILE(col,row) fabric.col[col].row[row].mini_core_tile_ins
`define IN_LOCAL_REQ(col,row)   `MINI_CORE_TILE(col,row).in_local_req

`define RAND_EP(rand_ep)  rand_ep = {4'($urandom_range(4'd1, 4'd3)), 4'($urandom_range(4'd1, 4'd3))};

module fabric_tb;
import router_pkg::*;
import mini_core_pkg::*;
logic              clk;
logic              rst;
int fabric_test_true;
int mini_core_tile_test_true;
string test_name;
t_tile_id rand_source;
t_tile_id rand_target;
static int cnt_trans;
static t_tile_trans origin_trans;
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
  //$error("timeout test");
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
      //fabric_get_in_trans();
      //fabric_get_source_tile_id();
      //fabric_get_current_tile_id();
      //fabric_get_trans_from_tile();
      //fabric_DI_checker();
      #5us;
      join
  join_any
  end else begin
    $error("[ERROR] : this is not a valid test name");
  end
  delay(30);
  $display("TEST DONE");
  $finish();
end

endmodule
