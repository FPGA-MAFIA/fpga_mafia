`include "macros.sv"
//`include "uvm_macros.svh"
module router_tb;
import router_pkg::*;
logic              clk;
logic              rst;
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
  if(test == "simple_test") begin

  end
  if(test == "fifo_arb_dif_num_active_fifo")begin
     //`include "fifo_arb_dif_num_active_fifo.sv" // TODO- WHY INCLUDE NOT WORKING??
      parameter NUM_OF_FIFO_ACTIVE = 1;
      parameter RANDOM_TEST = 0;
      parameter ROUNDS = 4;
      int num_fifo_active; 
      
      if(RANDOM_TEST) begin
          num_fifo_active = $urandom_range(1,4); // 4 fifo for now.
      end
      else 
          num_fifo_active = NUM_OF_FIFO_ACTIVE;
      $display("num_fifo_active id %0d",num_fifo_active);
      if(RANDOM_TEST) begin
          num_fifo_active = $urandom_range(1,4); // 4 fifo for now.
      end
      else 
          num_fifo_active = NUM_OF_FIFO_ACTIVE;

          for(int j = 0; j<ROUNDS; j++)   
            for (int i=0; i<num_fifo_active; i++) begin
             push_fifo(i);
             delay(100);
            end
          begin
              check_correct_output();
          end
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
task check_correct_output();
forever begin
  wait(fifo_arb_ins.winner_valid == 1'b1);
  assert(fifo_arb_ins.winner_req == fifo_arb_ins.fifo_pop)// not good!!! need to check if output of winner fifo i.e inside_fifo[winner_dec_id] [rd_ptr-1] == winner_req
    else $error("output is different than fifo");
  wait(winner_valid == 1'b0);
end
endtask

initial begin
  fork begin
      run_test(test_name);
  end
  begin // checkers
      check_correct_output();
  end
   join_any
   delay(30);
   $finish();
end


initial begin : timeout_monitor
  #150ns;
  //$fatal(1, "Timeout");
  $finish();
end
endmodule

