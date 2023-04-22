`include "macros.sv"
parameter V_NUM_CLIENTS = 4 ;
parameter V_FIFO_DEPTH = 2;
//`include "uvm_macros.svh"
module router_tb;
import router_pkg::*;
logic              clk;
logic              rst;
static t_tile_trans ref_fifo_Q [V_NUM_CLIENTS-1:0][$];
static t_tile_trans ref_outputs_Q [$];  
static int cnt_in;
static int cnt_out;
static bit [3:0] empty;
static bit [3:0] full;
//static t_tile_trans ref_fifo_Q [$];
//static int try_q [$];
string test_name;
// instantiation of DUT's - trk inside.
`include "fifo_arb_dut.vh"
`include "router_dut.vh"
`include "fifo_arb_tasks.vh"
`include "router_tasks.vh"
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
for( int i =0; i < len - len_substr; i++) begin
    if(str.substr(i,i+len_substr-1) == substr) begin
       $display("found it");
       found = found | 1;
    end
end
endfunction

initial begin : timeout_monitor
  #2us;
  //$fatal(1, "Timeout");
  $error("timeout test");
  $finish();
end


int router_test_true;
int fifo_arb_test_true;
// =============================
//  This is the main test sequence
// =============================
initial begin
  rst_ins();
  $display("================\n     START\n================\n");
  if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
  else $fatal("CANNOT FINT TEST %s at time %t",test_name , $time());
  // check what is the test prefix fifo_arb or router
  find_string(.str(test_name), .substr("router")  , .found(router_test_true));
  find_string(.str(test_name), .substr("fifo_arb"), .found(fifo_arb_test_true));

//=======================
// The FIFO_ARB sequence
//=======================
  if(fifo_arb_test_true == 1) begin
    $display("this is fifo_arb test");
  fork 
      run_fifo_arb_test(test_name);
      fifo_arb_get_inputs();
      fifo_arb_get_outputs();
      //fifo_arb_check_empty_full();
  
   join
   fork
    #1000;
    wait((cnt_in == cnt_out)&& cnt_out > 0); 
   join_any
   //#1000;
   //$display("ref_outputs is %p",ref_fifo_Q);
   //for(int i = 0 ; i<4;i++)
   //   $display("[INFO] : this is ref_input for fifo %0d: %p",i,ref_fifo_Q[i]);

  if(test_name !== "fifo_arb_Assertion_test")begin
   fifo_arb_DI_checker();
  end
   delay(30);
   $finish();
//======================
// The ROUTER sequence
//======================
  end else if(router_test_true == 1) begin
    $display("[INFO] : this is router test");
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

