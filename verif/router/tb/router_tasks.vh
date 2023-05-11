
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
  logic [3:0] random_col;
  logic [3:0] random_row;
  input_gen_valid[input_card] = 1'b1;
  input_gen[input_card].data                  = $urandom_range(32'h00, 32'hFFFF_FFFF);
  input_gen[input_card].opcode                = t_tile_opcode'($urandom_range(1, 3));
  input_gen[input_card].requestor_id          = '0;// not really used in router level 
  do begin 
  // generate random address and the corelating next_tile_fifo_arb_id
  // this next logic is dependent on the algorithm used in the router
  // for now, first reach row, then reach col
    random_row = $urandom_range(4'h1, 4'h3);
    random_col = $urandom_range(4'h1, 4'h3);
    input_gen[input_card].address               = {random_col[3:0],random_row[3:0],24'h0};
    if     (random_row[3:0] < local_tile_id[3:0]) input_gen[input_card].next_tile_fifo_arb_id = NORTH;
    else if(random_row[3:0] > local_tile_id[3:0]) input_gen[input_card].next_tile_fifo_arb_id = SOUTH;
    else if(random_col[3:0] < local_tile_id[7:4]) input_gen[input_card].next_tile_fifo_arb_id = WEST;
    else if(random_col[3:0] > local_tile_id[7:4]) input_gen[input_card].next_tile_fifo_arb_id = EAST;
    else                                          input_gen[input_card].next_tile_fifo_arb_id = LOCAL;
  end  while( input_gen[input_card].next_tile_fifo_arb_id == input_card); // make sure we don't send a request to the same tile that generated it

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

