//First request
delay(10);
input_gen_valid[NORTH] = 1'b1;
random_gen_req(.card(NORTH), .trans(input_gen[NORTH]));
delay(1);
input_gen_valid[NORTH] = 1'b0;

//Second request
delay(10);
input_gen_valid[NORTH] = 1'b1;
random_gen_req(.card(NORTH), .trans(input_gen[NORTH]));
delay(1);
input_gen_valid[NORTH] = 1'b0;