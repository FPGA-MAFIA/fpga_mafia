//First request
delay(10);
gen_req (.input_card(SOUTH),
         .address({4'h1,4'h1,24'h0}) , 
         .next_tile_fifo_arb_id(NORTH)
);
delay(10);
gen_req (.input_card(EAST),
         .address({4'h1,4'h1,24'h0}) , 
         .next_tile_fifo_arb_id(NORTH)
);

gen_req (.input_card(WEST),
         .address({4'h2,4'h3,24'h0}) , 
         .next_tile_fifo_arb_id(WEST)
);
//delay(10);
//
////second request
//delay(10);
//input_gen_valid[WEST] = 1'b1;
//gen_req(.address({4'h2,4'h2,24'h0}) , 
//        .local_card(NORTH),
//        .trans(input_gen[WEST]));
//delay(1);
//input_gen_valid[WEST] = 1'b0;
//delay(10);
//
////Third request
//delay(10);
//input_gen_valid[LOCAL] = 1'b1;
//gen_req(.address({4'h2,4'h2,24'h0}) , 
//        .local_card(NORTH),
//        .trans(input_gen[LOCAL]));
//delay(1);
//input_gen_valid[LOCAL] = 1'b0;
//delay(10);
//
////forth request
//delay(10);
//input_gen_valid[EAST] = 1'b1;
//gen_req(.address({4'h2,4'h1,24'h0}) , 
//        .local_card(NORTH),
//        .trans(input_gen[EAST]));
//delay(1);
//input_gen_valid[EAST] = 1'b0;
//delay(10);
//
//