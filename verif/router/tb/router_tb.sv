`include "macros.sv"
parameter V_NUM_CLIENTS = 4 ;
//`include "uvm_macros.svh"
module router_tb;
import router_pkg::*;
logic              clk;
logic              rst;
static t_tile_trans ref_fifo_Q [V_NUM_CLIENTS-1:0][$];
static t_tile_trans ref_outputs_Q [$];  
logic in_north_req_valid;
logic in_south_req_valid;
logic in_east_req_valid;
logic in_west_req_valid;
t_tile_trans in_north_req;
t_tile_trans input_gen [3:0];
static int cnt;

//static t_tile_trans ref_fifo_Q [$];
//static int try_q [$];
string test_name;
// instantiation of DUT's - trk inside.
`include "fifo_arb_dut.vh"
//`include "router_dut.vh"
// CLK GEN
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end
// RST 
task rst_ins();
    in_north_req       = '0;
    in_north_req_valid = '0;
    in_south_req_valid = '0;
    in_east_req_valid = '0;
    in_west_req_valid = '0;
    rst = 1'b1;
    for(int i =0; i<4 ; i++) begin
      valid_alloc_req[i] = '0;
    end
    delay(10);
    rst = '0;
endtask
// ***   tasks
//  general
task automatic delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

task run_test(input string test);
  $display("================\n     START\n================\n");
  if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
  else $fatal("CANNOT FINT TEST %s at time %t",test_name , $time());
  delay(30);
  if (test == "simple") begin
     `include "simple.sv"
  end else if(test == "fifo_arb_dif_num_active_fifo")begin
     `include "fifo_arb_dif_num_active_fifo.sv" 
  end else if(test == "single_fifo_full_BW")begin
    `include "single_fifo_full_BW.sv"
  end else if(test == "alive_router")begin
    `include "alive_router.sv"
  end else if(test == "all_fifo_full_BW")begin
    `include "all_fifo_full_BW.sv"
  end

endtask


// DUT related tasks
task automatic push_fifo(input int num_fifo);
  $display("%t, push_fifo %d",$time, num_fifo);
  valid_alloc_req[num_fifo] = 1'b1;
  delay(1);
  valid_alloc_req[num_fifo] = '0;
endtask
// checkers
logic [1:0] rd_ptr_xmr [3:0];
t_tile_trans winner_xmr[3:0];

logic [1:0] fifo_winner_xmr;
logic [1:0]  final_rd_ptr_xmr;
t_tile_trans final_winner_xmr;

genvar FIFO_E;
generate for(FIFO_E =0; FIFO_E<4; FIFO_E++) begin
  assign rd_ptr_xmr[FIFO_E]      = fifo_arb_ins.gen_fifo[FIFO_E].inside_fifo.rd_ptr;
  assign winner_xmr[FIFO_E]      = fifo_arb_ins.gen_fifo[FIFO_E].inside_fifo.fifo_array[rd_ptr_xmr[FIFO_E]-1];
end endgenerate

  assign fifo_winner_xmr  = $clog2(fifo_arb_ins.arb.winner_dec_id); //FIXME - use proper encoder
  assign final_rd_ptr_xmr = rd_ptr_xmr[fifo_winner_xmr];
  assign final_winner_xmr = winner_xmr[fifo_winner_xmr];


task automatic check_correct_output();
forever begin
  wait(fifo_arb_ins.winner_req_valid == 1'b1);
  if(fifo_arb_ins.winner_req == final_winner_xmr)
    $display("fifo_ok");// not good!!! need to check if output of winner fifo i.e inside_fifo[winner_dec_id] [rd_ptr-1] == winner_req
  else $error("output is different than fifo");
  wait(winner_req_valid == 1'b0);
end
endtask

task automatic get_inputs();
//forever begin
for(int i = 0; i<4; i++) begin
  automatic int index = i;
  fork begin
    //forever begin
      $display("this is thred %0d at time %t",index,$time);
      wait(valid_alloc_req[index] == 1'b1);
      $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$ input of fifo number %0d",index);
       ref_fifo_Q[index].push_back(alloc_req[index]);
       $display("size: %0d, element in array: %p at time %t",ref_fifo_Q[index].size(),ref_fifo_Q[index],$time);
       $display("this is the data of fifo %0d  %0b", index,$bits(alloc_req[index]));
      wait(valid_alloc_req[index] == 1'b0);  
    //end
  end join_none
end
//end
endtask

task try();
int try;
try = $urandom_range(0,100); 
$display("###########    this is try num: %0d",try);
endtask
task try_pop();
for(int i = 0; i<10; i++)begin
automatic int j = i;
fork begin
  //$display("j inside fork pop - %0d",j);
  delay(7);
  ref_fifo_Q[0].pop_front();
  $display("size: %0d, element in array: %p at time %t",ref_fifo_Q[0].size(),ref_fifo_Q[0],$time);
  end join
end
endtask

task automatic get_outputs();
fork
forever begin
  wait(winner_req_valid == 1'b1);
  cnt = cnt + 1;
  //#1;
  $display("winner req is: %p at time %t and cnt = %d",winner_req,$time,cnt);
  ref_outputs_Q.push_back(winner_req);
  $display("this is the outputs array %p @ time %t",ref_outputs_Q,$time);
  wait(winner_req_valid == 1'b0);
end
join_none
endtask
task DI_checker(); // pseudo ref_model
automatic bit check = 0;
foreach(ref_fifo_Q[i])begin
  foreach(ref_fifo_Q[i][j])begin
    foreach(ref_outputs_Q[k])begin
      if(ref_fifo_Q[i][j] == ref_outputs_Q[k])begin
        $display("before delete: this is ref_fifo_Q[%0d]: %p with bits: %0b",i,ref_fifo_Q[i],$bits(ref_fifo_Q[i]));
        //$display("before delete: this is ref_outputs_Q[%0d]: %p with bits: %0b",k,ref_outputs_Q[k],$bits(ref_outputs_Q[k]));
        //$display("this is item i = %0d , j = %0d and value: %p",i,j,ref_fifo_Q[i][j]);
        ref_fifo_Q[i].delete(j);
        ref_outputs_Q.delete(k);
        //$display("after delete: this is ref_fifo_Q[%0d]: %p",i,ref_fifo_Q[i]);
        //break;
      end
    end
    //if(ref_outputs_Q.find(ref_fifo_Q[i][j] , with (item1,item2) item1 === item2) ==-1)begin
      //$error("trans in fifo %0d and element %0d didnt get out of fifo_arb",i,j);
    end
  end
  if(ref_outputs_Q.size()!= 0)begin
    $error("output list not empty ,data is %p",ref_outputs_Q);
    check = 1'b1;
  end
  for(int i=0;i<4;i++)begin
    if(ref_fifo_Q[i].size() != 0)begin
      check = 1'b1;
       $error("input list not empty for fifo %0d ,data is %p",i,ref_fifo_Q[i]);
    end   
  end
  if(check == 1'b0)
    $display("DI CHECKER: DATA IS CORRECT");
endtask
task automatic rand_data();
  delay(1);
  //t_tile_opcode opcode_t;
  //int index_opcode = 0;
  //automatic int index_next_tile = 0;
  //index_opcode = $urandom_range(0,3);
  //index_next_tile = $urandom_range(0,6);
    for(int i = 0 ; i<4 ; i++) begin
        alloc_req[i].data = $urandom_range(0,2^32-1);
        alloc_req[i].address = $urandom_range(0,2^32-1);
        alloc_req[i].opcode = WR;
        alloc_req[i].requestor_id = $urandom_range(0,2^10-1);
        alloc_req[i].next_tile_fifo_arb_id = NORTH;
        //$display("#########################alloc_req is %p for fifo %0d time: %t#######################################",alloc_req[i],i,$time());
end
endtask

task automatic gen_trans(input int num_fifo);
rand_data();
push_fifo(num_fifo);
endtask
initial begin
  rst_ins();

  fork 
      run_test(test_name);
      //try();
      //try_pop();
      get_inputs();
      get_outputs();
  
   join
   wait(cnt == 3);
   $display("ref_outputs is %p",ref_fifo_Q);
   for(int i = 0 ; i<4;i++)
      $display("this is ref_input for fifo %0d: %p",i,ref_fifo_Q[i]);
   DI_checker();
   delay(30);
   $finish();
end

initial begin : timeout_monitor
  #2us;
  //$fatal(1, "Timeout");
  $error("timeout test");
  $finish();
end

// need to include router_dut.sv

endmodule

