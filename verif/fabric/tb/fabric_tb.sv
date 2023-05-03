`include "macros.sv"
module fabric_tb;
import router_pkg::*;
import mini_core_pkg::*;
logic              clk;
logic              rst;
int fabric_test_true;
int mini_core_tile_test_true;
string test_name;

`include "fabric_tasks.vh"
`include "mini_core_tile_tasks.vh"
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
#1;
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
  end else begin
    $error("[ERROR] : this is not a valid test name");
  end
end

endmodule
