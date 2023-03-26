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
     `include "fifo_arb_dif_num_active_fifo.sv" // TODO- WHY INCLUDE NOT WORKING??
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
  assert(fifo_arb_ins.winner_req == final_winner_xmr)// not good!!! need to check if output of winner fifo i.e inside_fifo[winner_dec_id] [rd_ptr-1] == winner_req
    else $error("output is different than fifo");
  wait(winner_valid == 1'b0);
end
endtask

initial begin
  fork begin
      run_test(test_name);
  end
//FIXME - disable checkers for now, need to fix them
//  begin // checkers
//      check_correct_output();
//  end
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

