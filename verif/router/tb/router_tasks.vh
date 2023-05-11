
task run_router_test(input string test);
  delay(30);
  // ====================
  // router tests:
  // ====================
  if(test == "router_alive")begin
    `include "router_alive.sv"
  end else if(test == "router_send_to_north")begin
    `include "router_send_to_north.sv"
  end else begin
    $error(" [ERROR] : test %s not found",test);
  end
endtask

task random_gen_req(input t_cardinal input_card);
  t_cardinal next_tile_fifo_arb_id;
  input_gen_valid[input_card] = 1'b1;
  input_gen[input_card].data                  = $urandom_range(32'h00, 32'hFFFF_FFFF);
  input_gen[input_card].address               = {4'h1,4'h1,24'h0};//$urandom_range(32'h01, 32'hFF_FF_FFFF);
  input_gen[input_card].opcode                = t_tile_opcode'($urandom_range(1, 3));
  input_gen[input_card].requestor_id          = $urandom_range(8'h1, 8'hff);
  input_gen[input_card].next_tile_fifo_arb_id = NORTH;//t_cardinal'($urandom_range(3'h1, 3'h5));
  delay(1);
  input_gen_valid[input_card] = 1'b0;
  
endtask

task gen_req(input  t_cardinal   input_card,
             input  logic [31:0] address, 
             input  t_cardinal   next_tile_fifo_arb_id
             );

  input_gen_valid[input_card] = 1'b1;
  input_gen[input_card].data                  = $urandom_range(32'h00, 32'hFFFF_FFFF);
  input_gen[input_card].address               = address;
  input_gen[input_card].opcode                = t_tile_opcode'($urandom_range(1, 3));
  input_gen[input_card].requestor_id          = $urandom_range(8'h1, 8'hff);
  input_gen[input_card].next_tile_fifo_arb_id = next_tile_fifo_arb_id;
  delay(1);
  input_gen_valid[input_card] = 1'b0;
endtask

