`include "macros.sv"
//`include "uvm_macros.svh"
module router_tb;
import common_pkg::*;
parameter V_REQUESTS   = 1;
parameter V_FIFO_DEPTH = 4; // currently this value causes failure in the test due to FIFO size must be grater than 3
parameter V_NUM_FIFO   = 4;  // number of fifos to exercise in the test (HW is always 4, simulation may stimuli only some of them)
parameter V_NO_BACK_PRESSURE = 0; // used to disable back pressure in the test which will cause a failure in the test
parameter V_MAX_DELAY  = 5; // max delay in the test
parameter V_BACK_PRESURE = 10;
logic              clk;
logic              rst;
static t_tile_trans ref_fifo_Q [3:0][$]; // see if we want to parametrize this
static t_tile_trans ref_outputs_Q [$];  
static int cnt_in;
static int cnt_out;
static int cnt_fifo_pop;
static bit [3:0] empty;
static bit [3:0] full;
int router_test_true;
int fifo_arb_test_true;
int rand_in_ready;
//static t_tile_trans ref_fifo_Q [$];
//static int try_q [$];
string test_name;
// instantiation of DUT's - trk inside.
`include "fifo_arb_dut.vh"
`include "fifo_arb_tasks.vh"
`include "fifo_arb_trk.vh"

`include "router_dut.vh"
`include "router_tasks.vh"
`include "router_trk.vh"
// =============================
// CLK GEN
// =============================
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

assign full = fifo_arb_ins.full;
assign empty = fifo_arb_ins.empty;


// =============================
// RST gen
// =============================
task rst_ins();
    //start with reset
    rst = 1'b1;
    //make sure router valid input is 0 as default
    in_north_req_valid = '0;
    in_south_req_valid = '0;
    in_east_req_valid  = '0;
    in_west_req_valid  = '0;
    in_ready_arb_fifo  = 5'b11111; // change only in relevant tests.
    //make sure fifo_arb valid input is 0 as default
    for(int i =0; i<4 ; i++) begin
      valid_alloc_req[i] = '0;
    end
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


// =============================
// checkers fifo_arb
// =============================


// =============================
// checkers router
// =============================




// =============================
// checkers general
// =============================
task try();
int try;
try = $urandom_range(0,100); 
$display("###########    this is try num: %0d",try);
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
  // check what is the test prefix fifo_arb or router
  find_string(.str(test_name), .substr("router")  , .found(router_test_true));
  find_string(.str(test_name), .substr("fifo_arb"), .found(fifo_arb_test_true));

  rst_ins();
//=======================
// The FIFO_ARB sequence
//=======================
  if(fifo_arb_test_true) begin
    $display("==============================");
    $display("[INFO] this is FIFO_ARB test");
    $display("==============================");
  fork 
      run_fifo_arb_test(test_name);
      fifo_arb_get_inputs();
      fifo_arb_get_outputs();
      //arb_check();
      //fifo_arb_check_empty_full();
  
   join
   fork
      #5us; // just for protection so the test wont stuck.
      wait((cnt_in == cnt_out)&& cnt_out > 0); 
   join_any

  if(test_name !== "fifo_arb_Assertion_test")begin
   $display("output size is: %0d",ref_outputs_Q.size());
   for(int i = 0; i<4 ; i++)begin
    $display("ref_fifo[%0d] size: %0d",i,ref_fifo_Q[i].size());
   end
   fifo_arb_DI_checker();
  end
   delay(30);
   $finish();
//======================
// The ROUTER sequence
//======================
  end else if(router_test_true) begin
    $display("==============================");
    $display("[INFO] : this is ROUTER test");
    $display("==============================");
    fork
    run_router_test(test_name);
    join 
   delay(30);
   $finish();
//======================
// Error test name detected
//======================
  end else begin
    $error("[ERROR] : this is not a valid test name");
  end
end

endmodule

