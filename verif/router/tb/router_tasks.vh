
task run_router_test(input string test);
  delay(30);
  // ====================
  // router tests:
  // ====================
  if(test == "router_alive")begin
    `include "router_alive.sv"
  end else if(test == "router_send_to_north")begin
    `include "router_send_to_north.sv"
    end else if(test == "router_send_to_south")begin
    `include "router_send_to_south.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

task random_gen_req(input t_cardinal card, output t_tile_trans trans);
  t_cardinal local_card;
  trans.data                  = $urandom_range(32'h00, 32'hFFFF_FFFF);
  trans.address               = $urandom_range(32'h01, 32'hFF_FF_FFFF);
  trans.opcode                = t_tile_opcode'($urandom_range(1, 3));
  trans.requestor_id          = $urandom_range(8'h1, 8'hff);
  do begin local_card = t_cardinal'($urandom_range(3'h1, 3'h5)); end
  while( local_card == card);
  trans.next_tile_fifo_arb_id = local_card;
endtask

task gen_req(input  logic [31:0] address, 
             input  t_cardinal   local_card,
             output t_tile_trans trans
             );
  trans.data                  = $urandom_range(32'h00, 32'hFFFF_FFFF);
  trans.address               = address;
  trans.opcode                = t_tile_opcode'($urandom_range(1, 3));
  trans.requestor_id          = $urandom_range(8'h1, 8'hff);
  trans.next_tile_fifo_arb_id = local_card;
endtask

