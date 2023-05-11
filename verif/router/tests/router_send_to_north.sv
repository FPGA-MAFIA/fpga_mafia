//First request
delay(10);
gen_req (.input_card(SOUTH), .address({4'h1,4'h1,24'h0}) , .next_tile_fifo_arb_id(NORTH));
delay(10);
gen_req (.input_card(EAST),  .address({4'h1,4'h1,24'h0}) , .next_tile_fifo_arb_id(NORTH));
delay(10);
gen_req (.input_card(WEST),  .address({4'h2,4'h3,24'h0}) , .next_tile_fifo_arb_id(WEST));
