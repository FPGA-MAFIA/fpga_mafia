
task run_router_test(input string test);
  delay(30);
  // ====================
  // router tests:
  // ====================
  if(test == "router_alive")begin
    `include "router_alive.sv"
  end else if(test == "router_1_req_per_io")begin
   // `include "router_1_req_per_io.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

task random_gen_req(output t_tile_trans trans, output logic trans_valid);
  trans_valid                 = 1'b1;
  trans.data                  = $urandom_range(32'h00, 32'hFFFF_FFFF);
  trans.address               = $urandom_range(32'h01, 32'hFF_FF_FFFF);
  trans.opcode                = t_tile_opcode'($urandom_range(1, 3));
  trans.requestor_id          = $urandom_range(8'h1, 8'hff);
  trans.next_tile_fifo_arb_id = t_cardinal'($urandom_range(3'h1, 3'h5));
  delay(1); //FIXME - this wont allow us to do B2B requests
  trans_valid                 = 1'b0;
  trans.data                  = '0;
  trans.address               = '0;
  trans.opcode                = t_tile_opcode'(0);
  trans.requestor_id          = '0;
  trans.next_tile_fifo_arb_id = t_cardinal'(0);
endtask
