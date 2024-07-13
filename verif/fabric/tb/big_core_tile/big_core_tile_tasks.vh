task run_big_core_tile_test(input string test);
  delay(30);
  // ====================
  // big_core_tile tests:
  // ====================
  if (test == "big_core_tile_simple") begin
     `include "big_core_tile_simple.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

task automatic gen_rand_data();
  delay(1);
  //t_tile_opcode opcode_t;
  //int index_opcode = 0;
  //automatic int index_next_tile = 0;
  //index_opcode = $urandom_range(0,3);
  //index_next_tile = $urandom_range(0,6);
  in_north_req.data = $urandom_range(0,2^32-1);
  in_north_req.address = $urandom_range(0,2^32-1);
  in_north_req.opcode = WR;
  in_north_req.requestor_id = $urandom_range(0,2^10-1);
  in_north_req.next_tile_fifo_arb_id = NORTH;
  //$display("#########################alloc_req is %p for fifo %0d time: %t#######################################",alloc_req[i],i,$time());
endtask
