`include "macros.sv"
parameter NUM_CLIENTS = 4 ;
//`include "uvm_macros.svh"
module router_tb;
import router_pkg::*;
logic              clk;
logic              rst;
static t_tile_trans ref_fifo_Q [NUM_CLIENTS-1:0][$];
static t_tile_trans ref_outputs_Q [$];  
//static t_tile_trans ref_fifo_Q [$];
//static int try_q [$];
string test_name;
// instansiation of DUT's - trk inside.
`include "fifo_arb_dut.vh"
// CLK GEN
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end
// RST 
initial begin
    rst = 1'b1;
    for(int i =0; i<4 ; i++) begin
      valid_alloc_req[i] = '0;
    end
    delay(10);
    rst = '0;
end
// ***   tasks
//  general
task delay(input int cycles);
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
  if(test == "simple") begin
     `include "simple.sv"
  end
  if(test == "fifo_arb_dif_num_active_fifo")begin
     `include "fifo_arb_dif_num_active_fifo.sv" 
  end
  if(test == "single_fifo_full_BW")begin
    `include "single_fifo_full_BW.sv"
  end
endtask
// DUT related tasks
task push_fifo(input int num_fifo);
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


task check_correct_output();
forever begin
  wait(fifo_arb_ins.winner_valid == 1'b1);
  if(fifo_arb_ins.winner_req == final_winner_xmr)
    $display("fifo_ok");// not good!!! need to check if output of winner fifo i.e inside_fifo[winner_dec_id] [rd_ptr-1] == winner_req
  else $error("output is different than fifo");
  wait(winner_valid == 1'b0);
end
endtask

task get_inputs();
//forever begin
for(int i = 0; i<4; i++) begin
  automatic int index = i;
  fork begin
    //forever begin
      $display("this is thred %0d",index);
      wait(valid_alloc_req[index] == 1'b1);
      $display("input of fifo number %0d",index);
       ref_fifo_Q[index].push_back(alloc_req[index]);
       $display("size: %0d, element in array: %p at time %t",ref_fifo_Q[0].size(),ref_fifo_Q[0],$time);
       //$display("this is the data of fifo %0d  %0b", index,$bits(alloc_req[index]));
      wait(valid_alloc_req[index] == 1'b0);  
    //end
  end join
end
//end
endtask

task try();
for(int i = 0; i<10; i++)begin
      //$display("pre fork: this is thred %0d",i);

  automatic int j = i;
fork begin
      $display("in fork: this is thred %0d",i);

  //$display("j inside fork push - %0d",j);
  delay(5);
  ref_fifo_Q[j%4].push_back(j%4);
  //$display("size: %0d, element in array: %p at time %t",ref_fifo_Q[j%4].size(),ref_fifo_Q,$time);
end join
end
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

task get_outputs();
fork
forever begin
  wait(winner_valid == 1'b1);
  ref_outputs_Q.push_back(winner_req);
  $display("this is the outputs array %p @ time %t",ref_outputs_Q,$time);
  wait(winner_valid == 1'b0);
end
join_none
endtask
task DI_checker();
foreach(ref_fifo_Q[i])begin
  foreach(ref_fifo_Q[i][j])begin
    foreach(ref_outputs_Q[k])begin
        $display("before delete: this is ref_fifo_Q[%0d]: %p",i,ref_fifo_Q[i]);
        $display("before delete: this is ref_outputs_Q: %p",ref_outputs_Q[k]);
      if(ref_fifo_Q[i][j] == ref_outputs_Q[k])begin
        $display("before delete: this is ref_fifo_Q[%0d]: %p",i,ref_fifo_Q[i]);
        $display("before delete: this is ref_outputs_Q: %p",ref_outputs_Q[k]);

        ref_fifo_Q[i].delete(j);
        ref_outputs_Q.delete(k);
        $display("after delete: this is ref_fifo_Q[%0d]: %p",i,ref_fifo_Q[i]);
      end
    end
    //if(ref_outputs_Q.find(ref_fifo_Q[i][j] , with (item1,item2) item1 === item2) ==-1)begin
      //$error("trans in fifo %0d and element %0d didnt get out of fifo_arb",i,j);
      $display("this is item i = %0d , j = %0d and value: %p",i,j,ref_fifo_Q[i][j]);
    end
  end
endtask
//task DI_checker();
//  t_tile_trans item1, item2;
//  foreach (ref_fifo_Q[i]) begin
//    foreach (ref_fifo_Q[i][j]) begin
//      item1 = ref_fifo_Q[i][j];
//      int match = 0;
//      foreach (ref_outputs_Q[k]) begin
//        item2 = ref_outputs_Q[k];
//        if (item2 === item1) begin
//          match = 1;
//          break;
//        end
//      end
//      if (!match) begin
//        $error("trans in fifo %0d and element %0d didnt get out of fifo_arb", i, j);
//      end
//    end
//  end
//endtask




initial begin
  fork 
      run_test(test_name);
      //try();
      //try_pop();
  
//FIXME - disable checkers for now, need to fix them
   // checkers
      //check_correct_output();
      get_inputs();
      get_outputs();
  
   join
   DI_checker();
   delay(30);
   $finish();
end

initial begin : timeout_monitor
  #2us;
  //$fatal(1, "Timeout");
  $finish();
end
endmodule

