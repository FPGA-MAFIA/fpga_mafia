task run_fifo_arb_test(input string test);
  delay(30);
  // ====================
  // fifo_arb tests:
  // ====================
  if (test == "fifo_arb_simple") begin
     `include "fifo_arb_simple.sv"
  end else if(test == "fifo_arb_single_fifo_full_BW")begin
    `include "fifo_arb_single_fifo_full_BW.sv"
  end else if(test == "fifo_arb_all_fifo_full_BW")begin
    `include "fifo_arb_all_fifo_full_BW.sv"
  end else if(test == "fifo_arb_Assertion_test")begin
    `include "fifo_arb_Assertion_test.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

// fifo_arb DUT related tasks
task automatic push_fifo(input int num_fifo);
  //$display("%t, push_fifo %d",$time, num_fifo);
  if(V_NO_BACK_PRESSURE)begin
    valid_alloc_req[num_fifo] = 1'b1;
    delay(1);
    valid_alloc_req[num_fifo] = '0;
  end else begin
    wait(full[num_fifo] !== 1'b1);//begin
      valid_alloc_req[num_fifo] = 1'b1;
      delay(1);
      valid_alloc_req[num_fifo] = '0;
    //end
  end
endtask


task automatic fifo_arb_get_inputs();
//forever begin
for(int i = 0; i<4; i++) begin
  automatic int index = i;
  fork begin
    forever begin
      //$display("this is thred %0d at time %t",index,$time);
      wait(valid_alloc_req[index] == 1'b1);
      #0;
      cnt_in = cnt_in + 1;
      $display("$$$$$$$$$$$$$$$$$$$$$$$$$$$ input of fifo number %0d and CNT_IN = %0d",index,cnt_in);
       ref_fifo_Q[index].push_back(alloc_req[index]);
       //$display("size: %0d, element in array: %p at time %t",ref_fifo_Q[index].size(),ref_fifo_Q[index],$time);
       //$display("this is the data of fifo %0d  %0b", index,$bits(alloc_req[index]));
      wait(valid_alloc_req[index] == 1'b0);  
    end
  end 
  forever begin
    wait(fifo_arb_ins.arb.winner_dec_id[index] == 1'b1);
    if(winner_req_valid == 1'b0) $display("problem in fifo %0d at time %0t",index,$time);
    cnt_fifo_pop = cnt_fifo_pop + 1;
    $display("cnt_fifo_pop = %0d in fifo %0d at time %0t winner_valid is %0b and fifo_pop is %4b",cnt_fifo_pop,index,$time,winner_req_valid,fifo_arb_ins.arb.winner_dec_id);
    wait(fifo_arb_ins.arb.winner_dec_id[index] == 1'b0);
  end
  join_none
end
//end
endtask

task automatic fifo_arb_get_outputs();
int fifo_pop_cnt = 0;
fork
forever begin

  @(winner_req);
  #0;
  if(winner_req_valid == 1'b1)begin
  cnt_out = cnt_out + 1;
  ref_outputs_Q.push_back(winner_req);
  $display("CNT OUT = %0d",cnt_out);
  //$display("this is the outputs array %p @ with size %d time %t",ref_outputs_Q,ref_outputs_Q.size(),$time);
  end
  //else $error("winner_req changed but not valid at time %0t with data %p",$time,winner_req);
end
//forever begin
//  @(fifo_arb_ins.arb.winner_dec_id);
//  fifo_pop_cnt = fifo_pop_cnt + 1;
//  $display("fifo_pop_cnt is: %0d and fifo_pop is %4b",fifo_pop_cnt,fifo_arb_ins.arb.winner_dec_id);
//end
join_none
endtask

task automatic fifo_arb_check_empty_full();
//$display("@@@@@@@@@@@this is full signal %b",full);
fork
    forever begin 
        @(full);
        $display("@@@@@@@@@@@this is full signal %b",full);
    end
    forever begin 
        @(empty);
        $display("@@@@@@@@@@@this is empty signal %b",empty);
    end

join_none
endtask
task fifo_arb_DI_checker(); // pseudo ref_model
automatic bit check = 0;
repeat(5000)begin// TODO - check why we nust have this repeat, and if we must then how many loops?
  foreach(ref_fifo_Q[i,j])begin
    foreach(ref_outputs_Q[k])begin
      if(ref_fifo_Q[i][j] == ref_outputs_Q[k])begin
        //$display("before delete: this is ref_fifo_Q[%0d]: %p with bits: %0b",i,ref_fifo_Q[i],$bits(ref_fifo_Q[i]));
        //$display("before delete: this is ref_outputs_Q[%0d]: %p with bits: %0b",k,ref_outputs_Q[k],$bits(ref_outputs_Q[k]));
        //$display("this is item i = %0d , j = %0d and value: %p",i,j,ref_fifo_Q[i][j]);
        ref_fifo_Q[i].delete(j);
        ref_outputs_Q.delete(k);
        //$display("after delete: this is ref_fifo_Q[%0d]: %p",i,ref_fifo_Q[i]);
        //break;
      end
    end

    end
  end
  if(ref_outputs_Q.size()!= 0)begin
    $error("output list not empty ,data is and size %0d",ref_outputs_Q.size());
    check = 1'b1;
  end
  for(int i=0;i<4;i++)begin
    if(ref_fifo_Q[i].size() != 0)begin
      check = 1'b1;
       $error("input list not empty for fifo %0d , and size %0d",i,ref_fifo_Q[i].size());
    end   
  end
  if(check == 1'b0)
    $display("DI CHECKER: DATA IS CORRECT");
endtask



task automatic fifo_arb_rand_data();
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



task automatic fifo_arb_gen_trans(input int num_fifo);
fifo_arb_rand_data();
push_fifo(num_fifo);
endtask
